//! Barcode data generation

use crate::models::NexaTraceError;

/// Generate barcode data payload
pub fn generate_barcode_data(
    code: String,
    barcode_type: String,
) -> Result<String, NexaTraceError> {
    if code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Code cannot be empty".to_string(),
        ));
    }
    Ok(format!("{}:{}", barcode_type, code))
}
