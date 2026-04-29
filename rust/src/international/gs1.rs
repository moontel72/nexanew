//! GS1 standard code generation

use crate::models::NexaTraceError;

/// Generate a GS1-compliant code
pub fn generate_gs1_code(
    company_prefix: String,
    item_reference: String,
    serial_number: String,
) -> Result<String, NexaTraceError> {
    if company_prefix.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Company prefix cannot be empty".to_string(),
        ));
    }
    Ok(format!(
        "(01){}{}(21){}",
        company_prefix, item_reference, serial_number
    ))
}
