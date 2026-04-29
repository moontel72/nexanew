//! Validation utilities

use crate::models::NexaTraceError;

/// Validate a code format based on code type
pub fn validate_code_format(code: &str, code_type: &str) -> Result<bool, NexaTraceError> {
    if code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Code cannot be empty".to_string(),
        ));
    }
    if code_type.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Code type cannot be empty".to_string(),
        ));
    }

    match code_type.to_lowercase().as_str() {
        "bundle" => validate_bundle_format(code),
        "carton" => validate_carton_format(code),
        "packet" => validate_packet_format(code),
        "unit" => validate_unit_format(code),
        _ => Err(NexaTraceError::ValidationError(format!(
            "Unknown code type: {}",
            code_type
        ))),
    }
}

fn validate_bundle_format(code: &str) -> Result<bool, NexaTraceError> {
    if !code.contains('-') {
        return Err(NexaTraceError::ValidationError(
            "Bundle code must contain separator".to_string(),
        ));
    }
    Ok(true)
}

fn validate_carton_format(code: &str) -> Result<bool, NexaTraceError> {
    if !code.contains('-') {
        return Err(NexaTraceError::ValidationError(
            "Carton code must contain separator".to_string(),
        ));
    }
    Ok(true)
}

fn validate_packet_format(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(
            "Packet code must have 4 parts".to_string(),
        ));
    }
    Ok(true)
}

fn validate_unit_format(code: &str) -> Result<bool, NexaTraceError> {
    if !code.contains('-') {
        return Err(NexaTraceError::ValidationError(
            "Unit code must contain separator".to_string(),
        ));
    }
    Ok(true)
}
