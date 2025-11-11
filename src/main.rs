use slint::SharedString;

slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;

    // Limpar calculadora
    let ui_weak = ui.as_weak();
    ui.on_clean(move || {
        ui_weak.unwrap().set_calc(SharedString::from("0"));
    });

    // Deletar último caractere
    let ui_weak = ui.as_weak();
    ui.on_delete(move || {
        let ui = ui_weak.unwrap();
        let current = ui.get_calc().to_string();
        let new_value = if current.len() <= 1 {
            "0"
        } else {
            &current[..current.len() - 1]
        };
        ui.set_calc(SharedString::from(new_value));
    });

    // Adicionar caractere
    let ui_weak = ui.as_weak();
    ui.on_add_character(move |value| {
        let ui = ui_weak.unwrap();
        let current = ui.get_calc().to_string();
        
        // Substituir "0" inicial por número
        if current == "0" && value.chars().next().unwrap().is_ascii_digit() {
            ui.set_calc(value);
            return;
        }
        
        // Evitar operadores consecutivos
        let last_char = current.chars().last().unwrap_or('0');
        let new_char = value.chars().next().unwrap();
        if is_operator(last_char) && is_operator(new_char) {
            return;
        }
        
        ui.set_calc(SharedString::from(format!("{}{}", current, value)));
    });

    // Calcular resultado
    let ui_weak = ui.as_weak();
    ui.on_calculate(move || {
        let ui = ui_weak.unwrap();
        let expr = ui.get_calc()
            .to_string()
            .replace('x', "*")
            .replace('÷', "/");
        
        match evaluate(&expr) {
            Ok(result) => {
                let output = format_result(result);
                ui.set_calc(SharedString::from(output));
            }
            Err(_) => ui.set_calc(SharedString::from("Err"))
        }
    });

    ui.run()
}

fn is_operator(c: char) -> bool {
    matches!(c, '+' | '-' | 'x' | '÷' | '%')
}

fn evaluate(expr: &str) -> Result<f64, ()> {
    let tokens = tokenize(expr)?;
    let tokens = apply_percent(tokens)?;
    let tokens = apply_mul_div(tokens)?;
    apply_add_sub(tokens)
}

fn tokenize(expr: &str) -> Result<Vec<String>, ()> {
    let mut tokens = Vec::new();
    let mut num = String::new();
    
    for ch in expr.trim().chars() {
        if ch.is_ascii_digit() || ch == '.' {
            num.push(ch);
        } else if matches!(ch, '+' | '-' | '*' | '/' | '%') {
            if !num.is_empty() {
                tokens.push(num.clone());
                num.clear();
            }
            tokens.push(ch.to_string());
        } else if !ch.is_whitespace() {
            return Err(());
        }
    }
    
    if !num.is_empty() {
        tokens.push(num);
    }
    
    // Remove operador final
    if let Some(last) = tokens.last() {
        if matches!(last.as_str(), "+" | "-" | "*" | "/") {
            tokens.pop();
        }
    }
    
    Ok(tokens)
}

fn apply_percent(tokens: Vec<String>) -> Result<Vec<String>, ()> {
    let mut result = Vec::new();
    
    for token in tokens {
        if token == "%" {
            let num: String = result.pop().ok_or(())?;
            let val: f64 = num.parse().map_err(|_| ())?;
            result.push((val / 100.0).to_string());
        } else {
            result.push(token);
        }
    }
    
    Ok(result)
}

fn apply_mul_div(tokens: Vec<String>) -> Result<Vec<String>, ()> {
    let mut result = Vec::new();
    let mut i = 0;
    
    while i < tokens.len() {
        if i + 2 < tokens.len() && matches!(tokens[i + 1].as_str(), "*" | "/") {
            let left: f64 = tokens[i].parse().map_err(|_| ())?;
            let right: f64 = tokens[i + 2].parse().map_err(|_| ())?;
            
            let val = match tokens[i + 1].as_str() {
                "*" => left * right,
                "/" => {
                    if right == 0.0 { return Err(()); }
                    left / right
                }
                _ => return Err(())
            };
            
            result.push(val.to_string());
            i += 3;
        } else {
            result.push(tokens[i].clone());
            i += 1;
        }
    }
    
    Ok(result)
}

fn apply_add_sub(tokens: Vec<String>) -> Result<f64, ()> {
    if tokens.is_empty() {
        return Ok(0.0);
    }
    
    let mut result: f64 = tokens[0].parse().map_err(|_| ())?;
    let mut i = 1;
    
    while i + 1 < tokens.len() {
        let right: f64 = tokens[i + 1].parse().map_err(|_| ())?;
        
        result = match tokens[i].as_str() {
            "+" => result + right,
            "-" => result - right,
            _ => return Err(())
        };
        
        i += 2;
    }
    
    if !result.is_finite() {
        return Err(());
    }
    
    Ok(result)
}

fn format_result(num: f64) -> String {
    let formatted = if num.fract().abs() < 1e-10 {
        format!("{:.0}", num)
    } else {
        format!("{}", num)
    };
    
    if formatted.len() > 16 {
        format!("{:.8e}", num)
    } else {
        formatted
    }
}