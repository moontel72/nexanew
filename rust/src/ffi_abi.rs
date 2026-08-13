//! Stable C ABI exports consumed by the Flutter app via `dart:ffi`.
//!
//! The shipped Dart bindings (`lib/rust_module/ffi_config.dart`) look these
//! symbols up by name: `init_rust_module`, `generate_codes`,
//! `generate_bundle_codes`, `generate_carton_codes`, `generate_packet_codes`,
//! `generate_unit_codes`, `validate_code`, `validate_code_batch`,
//! `generate_checksum`, `encrypt_code`, `decrypt_code`.
//!
//! The `#[frb]` bindings in lib.rs remain available for flutter_rust_bridge
//! codegen clients; this explicit C ABI is the contract used by the shipped
//! Dart code on native (mobile/desktop) platforms.
//!
//! Memory convention: callers pass NUL-terminated UTF-8 strings and receive
//! a NUL-terminated UTF-8 JSON response allocated by Rust (`CString::into_raw`).

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::panic::{catch_unwind, AssertUnwindSafe};

use serde_json::{json, Value};

use crate::{algorithms, generators};

// ── Helpers ────────────────────────────────────────────────────

fn c_to_string(ptr: *const c_char) -> String {
    if ptr.is_null() {
        return String::new();
    }
    unsafe { CStr::from_ptr(ptr) }
        .to_string_lossy()
        .into_owned()
}

fn string_to_c(s: String) -> *mut c_char {
    match CString::new(s) {
        Ok(c) => c.into_raw(),
        Err(_) => std::ptr::null_mut(),
    }
}

fn json_to_c(value: Value) -> *mut c_char {
    string_to_c(value.to_string())
}

fn error_response(message: &str) -> Value {
    json!({ "status": "error", "error": message })
}

fn parse_request(input: *const c_char) -> Value {
    serde_json::from_str(&c_to_string(input)).unwrap_or(Value::Null)
}

/// Generate a batch for a specific code type from the Dart request JSON:
/// `{ code_type, prefix, start_sequence, count, factory_id, parent_code }`.
fn generate_for_code_type(code_type: &str, req: &Value) -> Result<Vec<String>, String> {
    let prefix = req
        .get("prefix")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();
    let start = req
        .get("start_sequence")
        .and_then(|v| v.as_u64())
        .unwrap_or(1) as u32;
    let count = req.get("count").and_then(|v| v.as_u64()).unwrap_or(0) as u32;
    let factory_id = req
        .get("factory_id")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();
    let parent = req
        .get("parent_code")
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();

    let result: Result<Vec<String>, String> = match code_type {
        "bundle" => generators::generate_bundle_batch(prefix, start, count, factory_id)
            .map_err(|e| e.to_string()),
        "carton" => generators::generate_carton_batch(prefix, start, count, parent, factory_id)
            .map_err(|e| e.to_string()),
        "packet" => generators::generate_packet_batch(prefix, start, count, parent, factory_id)
            .map_err(|e| e.to_string()),
        "unit" => generators::generate_unit_batch(prefix, start, count, parent, factory_id)
            .map_err(|e| e.to_string()),
        other => Err(format!("Unsupported code type: {}", other)),
    };

    result
}

fn generate_specific(input: *const c_char, code_type: &str) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        generate_for_code_type(code_type, &parse_request(input))
    }));
    match result {
        Ok(Ok(codes)) => json_to_c(json!({ "status": "success", "codes": codes })),
        Ok(Err(e)) => json_to_c(error_response(&e)),
        Err(_) => json_to_c(error_response("Rust module panicked during generation")),
    }
}

/// Validate a code against every generator; returns the first match.
fn validate_any(code: &str) -> Value {
    if let Ok(true) = generators::validate_bundle_code(code) {
        return json!({ "status": "success", "valid": true, "code_type": "bundle" });
    }
    if let Ok(true) = generators::validate_carton_code(code) {
        return json!({ "status": "success", "valid": true, "code_type": "carton" });
    }
    if let Ok(true) = generators::validate_packet_code(code) {
        return json!({ "status": "success", "valid": true, "code_type": "packet" });
    }
    if let Ok(true) = generators::validate_unit_code(code) {
        return json!({ "status": "success", "valid": true, "code_type": "unit" });
    }
    json!({ "status": "success", "valid": false })
}

// ── Exports ────────────────────────────────────────────────────

#[no_mangle]
pub extern "C" fn init_rust_module() {
    let _ = env_logger::try_init();
}

#[no_mangle]
pub extern "C" fn generate_codes(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        let req = parse_request(input);
        let code_type = req.get("code_type").and_then(|v| v.as_str()).unwrap_or("");
        generate_for_code_type(code_type, &req)
    }));
    match result {
        Ok(Ok(codes)) => json_to_c(json!({ "status": "success", "codes": codes })),
        Ok(Err(e)) => json_to_c(error_response(&e)),
        Err(_) => json_to_c(error_response("Rust module panicked during generation")),
    }
}

#[no_mangle]
pub extern "C" fn generate_bundle_codes(input: *const c_char) -> *mut c_char {
    generate_specific(input, "bundle")
}

#[no_mangle]
pub extern "C" fn generate_carton_codes(input: *const c_char) -> *mut c_char {
    generate_specific(input, "carton")
}

#[no_mangle]
pub extern "C" fn generate_packet_codes(input: *const c_char) -> *mut c_char {
    generate_specific(input, "packet")
}

#[no_mangle]
pub extern "C" fn generate_unit_codes(input: *const c_char) -> *mut c_char {
    generate_specific(input, "unit")
}

#[no_mangle]
pub extern "C" fn validate_code(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| validate_any(&c_to_string(input))));
    match result {
        Ok(v) => json_to_c(v),
        Err(_) => json_to_c(error_response("Rust module panicked during validation")),
    }
}

#[no_mangle]
pub extern "C" fn validate_code_batch(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        let req = parse_request(input);
        let codes = req
            .get("codes")
            .and_then(|v| v.as_array())
            .map(|arr| {
                arr.iter()
                    .filter_map(|v| v.as_str().map(|s| s.to_string()))
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default();
        let results: Vec<Value> = codes.iter().map(|c| validate_any(c)).collect();
        json!({ "status": "success", "results": results })
    }));
    match result {
        Ok(v) => json_to_c(v),
        Err(_) => json_to_c(error_response("Rust module panicked during validation")),
    }
}

#[no_mangle]
pub extern "C" fn generate_checksum(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        match algorithms::checksum::calculate(&c_to_string(input)) {
            Ok(digest) => json!({ "status": "success", "checksum": digest }),
            Err(e) => error_response(&e.to_string()),
        }
    }));
    match result {
        Ok(v) => json_to_c(v),
        Err(_) => json_to_c(error_response("Rust module panicked during checksum")),
    }
}

#[no_mangle]
pub extern "C" fn encrypt_code(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        let plaintext = c_to_string(input);
        let key = match std::env::var("NEXATRACE_FFI_KEY") {
            Ok(k) if !k.is_empty() => k,
            _ => return error_response("NEXATRACE_FFI_KEY environment variable is not set"),
        };
        match algorithms::encryption::encrypt(&plaintext, &key) {
            Ok(ciphertext) => json!({ "status": "success", "ciphertext": ciphertext }),
            Err(e) => error_response(&e.to_string()),
        }
    }));
    match result {
        Ok(v) => json_to_c(v),
        Err(_) => json_to_c(error_response("Rust module panicked during encryption")),
    }
}

#[no_mangle]
pub extern "C" fn decrypt_code(input: *const c_char) -> *mut c_char {
    let result = catch_unwind(AssertUnwindSafe(|| {
        let ciphertext = c_to_string(input);
        let key = match std::env::var("NEXATRACE_FFI_KEY") {
            Ok(k) if !k.is_empty() => k,
            _ => return error_response("NEXATRACE_FFI_KEY environment variable is not set"),
        };
        match algorithms::encryption::decrypt(&ciphertext, &key) {
            Ok(plaintext) => json!({ "status": "success", "plaintext": plaintext }),
            Err(e) => error_response(&e.to_string()),
        }
    }));
    match result {
        Ok(v) => json_to_c(v),
        Err(_) => json_to_c(error_response("Rust module panicked during decryption")),
    }
}
