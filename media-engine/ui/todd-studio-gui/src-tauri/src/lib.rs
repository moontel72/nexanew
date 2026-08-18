//! Todd Studio desktop shell. The actual director UI lives in the React
//! frontend; this crate only hosts the Tauri webview + native shell.

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .run(tauri::generate_context!())
        .expect("error while running Todd Studio");
}
