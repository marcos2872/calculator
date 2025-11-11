use slint::SharedString;

slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;

    let ui_weak = ui.as_weak();
    ui.on_clean(move || {
        let ui = ui_weak.unwrap();
        ui.set_calc(SharedString::from("0"));
    });

    let ui_weak = ui.as_weak();
    ui.on_delete(move || {
        let ui = ui_weak.unwrap();
        let current = ui.get_calc();
        let new_value = if current.len() <= 1 {
            "0"
        } else {
            current.get(..current.len() - 1).unwrap_or("0")
        };
        ui.set_calc(SharedString::from(new_value));
    });

    let ui_weak = ui.as_weak();
    ui.on_add_character(move |value| {
        let ui = ui_weak.unwrap();
        let current = ui.get_calc();
        
        // Caso especial: substituir "0" inicial
        if current == "0" && !value.starts_with('.') && !is_operator_char(&value) {
            ui.set_calc(value);
            return;
        }
        
        // Verificar se o último caractere é um operador
        let last_is_operator = current.chars()
            .last()
            .map(|c| is_operator_char(&c.to_string()))
            .unwrap_or(false);
        
        // Se ambos são operadores, não adicionar
        if last_is_operator && is_operator_char(&value) {
            return;
        }
        
        // Adicionar o caractere
        let new_calc = format!("{}{}", current, value);
        ui.set_calc(SharedString::from(new_calc));
    });

    let ui_weak = ui.as_weak();
    ui.on_calculate(move || {
        let ui = ui_weak.unwrap();
        let mut expression = ui.get_calc().to_string();

        // Normalização básica
        expression = expression.replace('x', "*").replace('÷', "/");

        // Remover operador final se existir (exceto %)
        if let Some(last) = expression.chars().last() {
            if matches!(last, '+' | '-' | '*' | '/') {
                expression.pop();
            }
        }

        // Tokenização simples
        let mut tokens: Vec<String> = Vec::new();
        let mut current = String::new();
        for ch in expression.chars() {
            if ch.is_ascii_digit() || ch == '.' {
                current.push(ch);
            } else if matches!(ch, '+' | '-' | '*' | '/' | '%') {
                if !current.is_empty() { 
                    tokens.push(current.clone()); 
                    current.clear(); 
                }
                tokens.push(ch.to_string());
            } else {
                // caractere inválido
                ui.set_calc(SharedString::from("Err"));
                return;
            }
        }
        if !current.is_empty() { tokens.push(current); }

        if tokens.is_empty() {
            ui.set_calc(SharedString::from("0"));
            return;
        }

        // Primeira passagem: resolver % (como operador unário pós-fixo)
        let mut after_percent: Vec<String> = Vec::new();
        let mut i = 0;
        while i < tokens.len() {
            if tokens[i] == "%" {
                if after_percent.is_empty() { 
                    ui.set_calc(SharedString::from("Err")); 
                    return; 
                }
                let left = after_percent.pop().unwrap();
                let l: f64 = match left.parse::<f64>() {
                    Ok(v) if v.is_finite() => v,
                    _ => { ui.set_calc(SharedString::from("Err")); return; }
                };
                after_percent.push((l / 100.0).to_string());
            } else {
                after_percent.push(tokens[i].clone());
            }
            i += 1;
        }

        // Segunda passagem: * e /
        let mut pass: Vec<String> = Vec::new();
        let mut i = 0;
        while i < after_percent.len() {
            if after_percent[i] == "*" || after_percent[i] == "/" {
                if pass.is_empty() || i + 1 >= after_percent.len() { 
                    ui.set_calc(SharedString::from("Err")); 
                    return; 
                }
                let left = pass.pop().unwrap();
                let l: f64 = match left.parse::<f64>() {
                    Ok(v) if v.is_finite() => v,
                    _ => { ui.set_calc(SharedString::from("Err")); return; }
                };
                let right = &after_percent[i + 1];
                let r: f64 = match right.parse::<f64>() {
                    Ok(v) if v.is_finite() => v,
                    _ => { ui.set_calc(SharedString::from("Err")); return; }
                };
                
                let res = if after_percent[i] == "*" { 
                    l * r 
                } else { 
                    if r == 0.0 { 
                        ui.set_calc(SharedString::from("Err")); 
                        return; 
                    }
                    l / r 
                };
                
                pass.push(res.to_string());
                i += 2;
            } else {
                pass.push(after_percent[i].clone());
                i += 1;
            }
        }

        // Terceira passagem: + e -
        if pass.is_empty() { 
            ui.set_calc(SharedString::from("0")); 
            return; 
        }
        
        let mut result: f64 = match pass[0].parse::<f64>() {
            Ok(v) if v.is_finite() => v,
            _ => { ui.set_calc(SharedString::from("Err")); return; }
        };
        
        let mut i = 1;
        while i + 1 < pass.len() {
            let op = &pass[i];
            let rhs: f64 = match pass[i + 1].parse::<f64>() {
                Ok(v) if v.is_finite() => v,
                _ => { ui.set_calc(SharedString::from("Err")); return; }
            };
            
            result = match op.as_str() {
                "+" => result + rhs,
                "-" => result - rhs,
                _ => { ui.set_calc(SharedString::from("Err")); return; }
            };
            i += 2;
        }

        if !result.is_finite() { 
            ui.set_calc(SharedString::from("Err")); 
            return; 
        }

        // Formatação: remover .0
        let mut out = if result.fract().abs() < 1e-12 { 
            format!("{:.0}", result) 
        } else { 
            format!("{}", result) 
        };
        
        if out.len() > 16 { 
            out = format!("{:.8e}", result); 
        }

        ui.set_calc(SharedString::from(out));
    });

    ui.run()
}

fn is_operator_char(c: &str) -> bool {
    matches!(c, "+" | "-" | "x" | "%" | "÷" )
}