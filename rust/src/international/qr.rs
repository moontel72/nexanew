//! QR code data generation

use crate::models::NexaTraceError;

/// Generate QR code data payload
pub fn generate_qr_data(
    code: String,
    additional_data: Option<String>,
) -> Result<String, NexaTraceError> {
    let qr_content = match additional_data {
        Some(data) => format!("{{\"code\":\"{}\",\"data\":\"{}\"}}", code, data),
        None => format!("{{\"code\":\"{}\"}}", code),
    };
    Ok(qr_content)
}
