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
        
        let new_calc = if current == "0" && !value.starts_with('.') && !is_operator(&value) {
            value.to_string()
        } else if is_operator(&current[&current.len() - 1..]) && is_operator(&value) {
            current.to_string()
        } else {
            format!("{}{}", current, value)
        };
        
        ui.set_calc(SharedString::from(new_calc));
    });

    let ui_weak = ui.as_weak();
    ui.on_calculate(move || {
        let ui = ui_weak.unwrap();
        let expression = ui.get_calc();

        let calc = 
        
        ui.set_calc(SharedString::from("0"));
    });

    ui.run()
}

fn is_operator(s: &str) -> bool {
    matches!(s, "+" | "-" | "x" | "÷" | "%")
}   