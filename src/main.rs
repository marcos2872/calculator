slint::include_modules!();

fn main() -> Result<(), slint::PlatformError> {
    let ui = AppWindow::new()?;

    let ui_weak = ui.as_weak();
    
    ui.on_increment_counter(move || {
        let ui = ui_weak.unwrap();
        let current = ui.get_counter();
        ui.set_counter(current + 1);
    });

    let ui_weak = ui.as_weak();
    ui.on_decrement_counter(move || {
        let ui = ui_weak.unwrap();
        let current = ui.get_counter();
        ui.set_counter(current - 1);
    });

    let ui_weak = ui.as_weak();
    ui.on_close_window(move || {
        let ui = ui_weak.unwrap();
        ui.hide().unwrap();
        std::process::exit(0);
    });
    
    let ui_weak = ui.as_weak();
    ui.on_minimize_window(move || {
        let ui = ui_weak.unwrap();
        ui.hide().unwrap();
    });

    ui.run()
}