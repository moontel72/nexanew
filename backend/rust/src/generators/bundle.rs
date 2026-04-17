//! Bundle Code Generator
//!
//! This module provides functionality for generating bundle codes.
//! Bundle codes are the highest level in the packaging hierarchy:
//! 1 Bundle contains multiple Cartons
//!
//! Code format: PREFIX-SEQUENCE (e.g., A-01, B-02, C-03)

use crate::models::{BundleCode, CodeGenerationResponse, NexaTraceError};
use rand::Rng;
use std::collections::HashMap;
use uuid::Uuid;

/// Generate a single bundle code
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(sequence)?;
    validate_factory_id(&factory_id)?;

    // Generate the code
    let code = format!("{}-{:02}", prefix, sequence);

    // Add factory identifier hash
    let factory_hash = generate_factory_hash(&factory_id, &code);
    let final_code = format!("{}-{}", code, factory_hash);

    Ok(final_code)
}

/// Generate multiple bundle codes in batch
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_factory_id(&factory_id)?;

    let mut codes = Vec::with_capacity(count as usize);

    for i in 0..count {
        let sequence = start_sequence + i;
        let code = generate_single_code(prefix.clone(), sequence, factory_id.clone())?;
        codes.push(code);
    }

    Ok(codes)
}

/// Generate bundle codes with hierarchy (including carton codes)
pub fn generate_with_hierarchy(
    prefix: String,
    start_sequence: u32,
    count: u32,
    cartons_per_bundle: u32,
    carton_prefix: String,
    factory_id: String,
) -> Result<Vec<BundleCode>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_cartons_per_bundle(cartons_per_bundle)?;
    validate_prefix(&carton_prefix)?;
    validate_factory_id(&factory_id)?;

    let mut bundle_codes = Vec::with_capacity(count as usize);

    for bundle_index in 0..count {
        let bundle_sequence = start_sequence + bundle_index;
        let bundle_code = generate_single_code(
            prefix.clone(),
            bundle_sequence,
            factory_id.clone(),
        )?;

        // Generate carton codes for this bundle
        let mut carton_codes = Vec::with_capacity(cartons_per_bundle as usize);
        for carton_index in 0..cartons_per_bundle {
            let carton_sequence = carton_index + 1;
            let carton_code = crate::generators::carton::generate_single_code(
                carton_prefix.clone(),
                carton_sequence,
                bundle_code.clone(),
                factory_id.clone(),
            )?;
            carton_codes.push(carton_code);
        }

        // Calculate totals
        let total_cartons = cartons_per_bundle;
        let total_packets = total_cartons * 6; // Assuming 6 packets per carton
        let total_units = total_packets * 24; // Assuming 24 units per packet

        let bundle = BundleCode {
            code: bundle_code,
            sequence: bundle_sequence,
            carton_codes,
            total_cartons,
            total_packets,
            total_units,
        };

        bundle_codes.push(bundle);
    }

    Ok(bundle_codes)
}

/// Generate bundle codes with international standards
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes
    let base_codes = generate_batch(
        prefix.clone(),
        start_sequence,
        count,
        factory_id.clone(),
    )?;

    // Generate international codes
    let mut international_codes = Vec::with_capacity(count as usize);
    let mut qr_codes = Vec::with_capacity(count as usize);
    let mut barcodes = Vec::with_capacity(count as usize);

    for (index, base_code) in base_codes.iter().enumerate() {
        // Generate GS1 code
        let serial_number = format!("{:08}", start_sequence + index as u32);
        let gs1_code = crate::international::gs1::generate_gs1_code(
            company_prefix.clone(),
            "BUNDLE".to_string(), // Item reference for bundles
            serial_number,
        )?;
        international_codes.push(gs1_code.clone());

        // Generate QR code
        let qr_data = crate::international::qr::generate_qr_data(
            base_code.clone(),
            Some(gs1_code.clone()),
        )?;
        qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            base_code.clone(),
            "CODE128".to_string(),
        )?;
        barcodes.push(barcode_data);
    }

    let response = CodeGenerationResponse {
        success: true,
        batch_id: Uuid::new_v4().to_string(),
        codes_generated: count,
        generated_codes: base_codes,
        qr_codes: Some(qr_codes),
        barcodes: Some(barcodes),
        international_codes: Some(international_codes),
        error: None,
    };

    Ok(response)
}

/// Validate bundle code format
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Expected format: PREFIX-SEQUENCE-FACTORYHASH
    let parts: Vec<&str> = code.split('-').collect();

    if parts.len() != 3 {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid bundle code format. Expected 3 parts, got {}", parts.len())
        ));
    }

    let prefix = parts[0];
    let sequence_str = parts[1];
    let factory_hash = parts[2];

    // Validate prefix
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}", prefix)
        ));
    }

    // Validate sequence
    let sequence = sequence_str.parse::<u32>().map_err(|_| {
        NexaTraceError::ValidationError(format!("Invalid sequence number: {}", sequence_str))
    })?;

    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string()
        ));
    }

    // Validate factory hash (should be 8 characters alphanumeric)
    if factory_hash.len() != 8 || !factory_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid factory hash: {}", factory_hash)
        ));
    }

    Ok(true)
}

/// Parse bundle code into components
pub fn parse_code(code: &str) -> Result<HashMap<String, String>, NexaTraceError> {
    validate_code(code)?;

    let parts: Vec<&str> = code.split('-').collect();
    let prefix = parts[0];
    let sequence = parts[1];
    let factory_hash = parts[2];

    let mut components = HashMap::new();
    components.insert("prefix".to_string(), prefix.to_string());
    components.insert("sequence".to_string(), sequence.to_string());
    components.insert("factory_hash".to_string(), factory_hash.to_string());
    components.insert("code_type".to_string(), "bundle".to_string());

    // Extract factory ID from hash (simplified - in real implementation would decode)
    components.insert("factory_id_hint".to_string(), format!("FACTORY-{}", &factory_hash[0..4]));

    Ok(components)
}

/// Generate factory hash for code
fn generate_factory_hash(factory_id: &str, code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", factory_id, code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 8 characters of hex representation
    hex::encode(result)[0..8].to_string()
}

/// Validate prefix
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}. Must be 1-3 uppercase letters", prefix)
        ));
    }
    Ok(())
}

/// Check if prefix is valid
fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    (1..=3).contains(&len) && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate sequence number
fn validate_sequence(sequence: u32) -> Result<(), NexaTraceError> {
    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string()
        ));
    }

    if sequence > 9999 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot exceed 9999".to_string()
        ));
    }

    Ok(())
}

/// Validate count
fn validate_count(count: u32) -> Result<(), NexaTraceError> {
    if count == 0 {
        return Err(NexaTraceError::ValidationError(
            "Count cannot be zero".to_string()
        ));
    }

    if count > 10000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 10,000 codes at once".to_string()
        ));
    }

    Ok(())
}

/// Validate cartons per bundle
fn validate_cartons_per_bundle(cartons_per_bundle: u32) -> Result<(), NexaTraceError> {
    if cartons_per_bundle == 0 {
        return Err(NexaTraceError::ValidationError(
            "Cartons per bundle cannot be zero".to_string()
        ));
    }

    if cartons_per_bundle > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 100 cartons per bundle".to_string()
        ));
    }

    Ok(())
}

/// Validate factory ID
fn validate_factory_id(factory_id: &str) -> Result<(), NexaTraceError> {
    if factory_id.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Factory ID cannot be empty".to_string()
        ));
    }

    if factory_id.len() > 50 {
        return Err(NexaTraceError::ValidationError(
            "Factory ID cannot exceed 50 characters".to_string()
        ));
    }

    Ok(())
}

/// Generate random bundle code (for testing/demo)
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    // Random prefix (A-Z)
    let prefix_char = (b'A' + rng.gen_range(0..26)) as char;
    let prefix = prefix_char.to_string();

    // Random sequence (1-99)
    let sequence = rng.gen_range(1..100);

    // Random factory hash
    let factory_hash: String = (0..8)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    format!("{}-{:02}-{}", prefix, sequence, factory_hash)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code("A".to_string(), 1, "factory_123".to_string()).unwrap();
        assert!(code.starts_with("A-01-"));
        assert_eq!(code.len(), 14); // A-01-XXXXXXXX
    }

    #[test]
    fn test_generate_batch() {
        let codes = generate_batch("B".to_string(), 1, 5, "factory_123".to_string()).unwrap();
        assert_eq!(codes.len(), 5);
        assert!(codes[0].starts_with("B-01-"));
        assert!(codes[4].starts_with("B-05-"));
    }

    #[test]
    fn test_validate_code() {
        // Valid code
        let valid_code = "A-01-ABCD1234";
        assert!(validate_code(valid_code).unwrap());

        // Invalid formats
        assert!(validate_code("A-01").is_err()); // Missing factory hash
        assert!(validate_code("A-01-ABCD12345").is_err()); // Factory hash too long
        assert!(validate_code("abc-01-ABCD1234").is_err()); // Lowercase prefix
        assert!(validate_code("A-00-ABCD1234").is_err()); // Zero sequence
    }

    #[test]
    fn test_parse_code() {
        let code = "C-42-ABCD1234";
        let components = parse_code(code).unwrap();

        assert_eq!(components.get("prefix").unwrap(), "C");
        assert_eq!(components.get("sequence").unwrap(), "42");
        assert_eq!(components.get("factory_hash").unwrap(), "ABCD1234");
        assert_eq!(components.get("code_type").unwrap(), "bundle");
    }

    #[test]
    fn test_generate_random_code() {
        let code = generate_random_code();
        assert!(validate_code(&code).is_ok());
    }

    #[test]
    fn test_validate_prefix() {
        assert!(is_valid_prefix("A"));
        assert!(is_valid_prefix("AB"));
        assert!(is_valid_prefix("ABC"));
        assert!(!is_valid_prefix("")); // Empty
        assert!(!is_valid_prefix("ABCD")); // Too long
        assert!(!is_valid_prefix("a")); // Lowercase
        assert!(!is_valid_prefix("A1")); // Contains number
    }
}
