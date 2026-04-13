//! Carton Code Generator
//!
//! This module provides functionality for generating carton codes.
//! Carton codes are the second level in the packaging hierarchy:
//! 1 Carton contains multiple Packets
//! Multiple Cartons make up 1 Bundle
//!
//! Code format: PREFIX-SEQUENCE (e.g., YY-001, YY-002, YY-003)

use crate::models::{CartonCode, CodeGenerationResponse, NexaTraceError};
use rand::Rng;
use std::collections::HashMap;
use uuid::Uuid;

/// Generate a single carton code
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(sequence)?;
    validate_bundle_code(&bundle_code)?;
    validate_factory_id(&factory_id)?;

    // Generate the code
    let code = format!("{}-{:03}", prefix, sequence);

    // Add bundle identifier and factory hash
    let bundle_hash = generate_bundle_hash(&bundle_code, &code);
    let factory_hash = generate_factory_hash(&factory_id, &code);
    let final_code = format!("{}-{}-{}", code, bundle_hash, factory_hash);

    Ok(final_code)
}

/// Generate multiple carton codes in batch
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_bundle_code(&bundle_code)?;
    validate_factory_id(&factory_id)?;

    let mut codes = Vec::with_capacity(count as usize);

    for i in 0..count {
        let sequence = start_sequence + i;
        let code = generate_single_code(
            prefix.clone(),
            sequence,
            bundle_code.clone(),
            factory_id.clone(),
        )?;
        codes.push(code);
    }

    Ok(codes)
}

/// Generate carton codes with hierarchy (including packet codes)
pub fn generate_with_hierarchy(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packets_per_carton: u32,
    packet_prefix: String,
    bundle_code: String,
    factory_id: String,
) -> Result<Vec<CartonCode>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_packets_per_carton(packets_per_carton)?;
    validate_prefix(&packet_prefix)?;
    validate_bundle_code(&bundle_code)?;
    validate_factory_id(&factory_id)?;

    let mut carton_codes = Vec::with_capacity(count as usize);

    for carton_index in 0..count {
        let carton_sequence = start_sequence + carton_index;
        let carton_code = generate_single_code(
            prefix.clone(),
            carton_sequence,
            bundle_code.clone(),
            factory_id.clone(),
        )?;

        // Generate packet codes for this carton
        let mut packet_codes = Vec::with_capacity(packets_per_carton as usize);
        for packet_index in 0..packets_per_carton {
            let packet_sequence = packet_index + 1;
            let packet_code = crate::generators::packet::generate_single_code(
                packet_prefix.clone(),
                packet_sequence,
                carton_code.clone(),
                factory_id.clone(),
            )?;
            packet_codes.push(packet_code);
        }

        // Calculate totals
        let total_packets = packets_per_carton;
        let total_units = total_packets * 24; // Assuming 24 units per packet

        let carton = CartonCode {
            code: carton_code,
            sequence: carton_sequence,
            bundle_code: bundle_code.clone(),
            packet_codes,
            total_packets,
            total_units,
        };

        carton_codes.push(carton);
    }

    Ok(carton_codes)
}

/// Generate carton codes with international standards
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes
    let base_codes = generate_batch(
        prefix.clone(),
        start_sequence,
        count,
        bundle_code.clone(),
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
            "CARTON".to_string(), // Item reference for cartons
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

/// Validate carton code format
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Expected format: PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH
    let parts: Vec<&str> = code.split('-').collect();

    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid carton code format. Expected 4 parts, got {}", parts.len())
        ));
    }

    let prefix = parts[0];
    let sequence_str = parts[1];
    let bundle_hash = parts[2];
    let factory_hash = parts[3];

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

    // Validate bundle hash (should be 6 characters alphanumeric)
    if bundle_hash.len() != 6 || !bundle_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid bundle hash: {}", bundle_hash)
        ));
    }

    // Validate factory hash (should be 6 characters alphanumeric)
    if factory_hash.len() != 6 || !factory_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid factory hash: {}", factory_hash)
        ));
    }

    Ok(true)
}

/// Parse carton code into components
pub fn parse_code(code: &str) -> Result<HashMap<String, String>, NexaTraceError> {
    validate_code(code)?;

    let parts: Vec<&str> = code.split('-').collect();
    let prefix = parts[0];
    let sequence = parts[1];
    let bundle_hash = parts[2];
    let factory_hash = parts[3];

    let mut components = HashMap::new();
    components.insert("prefix".to_string(), prefix.to_string());
    components.insert("sequence".to_string(), sequence.to_string());
    components.insert("bundle_hash".to_string(), bundle_hash.to_string());
    components.insert("factory_hash".to_string(), factory_hash.to_string());
    components.insert("code_type".to_string(), "carton".to_string());

    // Extract bundle and factory hints
    components.insert("bundle_hint".to_string(), format!("BUNDLE-{}", &bundle_hash[0..3]));
    components.insert("factory_hint".to_string(), format!("FACTORY-{}", &factory_hash[0..3]));

    Ok(components)
}

/// Generate bundle hash for code
fn generate_bundle_hash(bundle_code: &str, carton_code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", bundle_code, carton_code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 6 characters of hex representation
    hex::encode(result)[0..6].to_string()
}

/// Generate factory hash for code
fn generate_factory_hash(factory_id: &str, code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", factory_id, code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 6 characters of hex representation
    hex::encode(result)[0..6].to_string()
}

/// Validate prefix
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}. Must be 2-3 uppercase letters", prefix)
        ));
    }
    Ok(())
}

/// Check if prefix is valid
fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    (2..=3).contains(&len) && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate sequence number
fn validate_sequence(sequence: u32) -> Result<(), NexaTraceError> {
    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string()
        ));
    }

    if sequence > 999 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot exceed 999".to_string()
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

    if count > 1000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 1,000 codes at once".to_string()
        ));
    }

    Ok(())
}

/// Validate packets per carton
fn validate_packets_per_carton(packets_per_carton: u32) -> Result<(), NexaTraceError> {
    if packets_per_carton == 0 {
        return Err(NexaTraceError::ValidationError(
            "Packets per carton cannot be zero".to_string()
        ));
    }

    if packets_per_carton > 50 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 50 packets per carton".to_string()
        ));
    }

    Ok(())
}

/// Validate bundle code
fn validate_bundle_code(bundle_code: &str) -> Result<(), NexaTraceError> {
    if bundle_code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Bundle code cannot be empty".to_string()
        ));
    }

    // Basic validation - should contain at least one dash
    if !bundle_code.contains('-') {
        return Err(NexaTraceError::ValidationError(
            "Invalid bundle code format".to_string()
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

/// Generate random carton code (for testing/demo)
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    // Random prefix (YY, ZZ, etc.)
    let prefix_chars: String = (0..2)
        .map(|_| (b'A' + rng.gen_range(0..26)) as char)
        .collect();
    let prefix = prefix_chars;

    // Random sequence (1-999)
    let sequence = rng.gen_range(1..1000);

    // Random bundle hash
    let bundle_hash: String = (0..6)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    // Random factory hash
    let factory_hash: String = (0..6)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    format!("{}-{:03}-{}-{}", prefix, sequence, bundle_hash, factory_hash)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code(
            "YY".to_string(),
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        ).unwrap();
        assert!(code.starts_with("YY-001-"));
        assert_eq!(code.split('-').count(), 4);
    }

    #[test]
    fn test_generate_batch() {
        let codes = generate_batch(
            "ZZ".to_string(),
            1,
            5,
            "B-02-EFGH5678".to_string(),
            "factory_456".to_string(),
        ).unwrap();
        assert_eq!(codes.len(), 5);
        assert!(codes[0].starts_with("ZZ-001-"));
        assert!(codes[4].starts_with("ZZ-005-"));
    }

    #[test]
    fn test_validate_code() {
        // Valid code
        let valid_code = "YY-001-ABC123-DEF456";
        assert!(validate_code(valid_code).unwrap());

        // Invalid formats
        assert!(validate_code("YY-001-ABC123").is_err()); // Missing factory hash
        assert!(validate_code("YY-001-ABC12345-DEF456").is_err()); // Bundle hash too long
        assert!(validate_code("yy-001-ABC123-DEF456").is_err()); // Lowercase prefix
        assert!(validate_code("Y-001-ABC123-DEF456").is_err()); // Single character prefix
        assert!(validate_code("YY-000-ABC123-DEF456").is_err()); // Zero sequence
    }

    #[test]
    fn test_parse_code() {
        let code = "ZZ-042-ABC123-DEF456";
        let components = parse_code(code).unwrap();

        assert_eq!(components.get("prefix").unwrap(), "ZZ");
        assert_eq!(components.get("sequence").unwrap(), "042");
        assert_eq!(components.get("bundle_hash").unwrap(), "ABC123");
        assert_eq!(components.get("factory_hash").unwrap(), "DEF456");
        assert_eq!(components.get("code_type").unwrap(), "carton");
    }

    #[test]
    fn test_generate_random_code() {
        let code = generate_random_code();
        assert!(validate_code(&code).is_ok());
    }

    #[test]
    fn test_validate_prefix() {
        assert!(is_valid_prefix("YY"));
        assert!(is_valid_prefix("ZZZ"));
        assert!(!is_valid_prefix("Y")); // Too short
        assert!(!is_valid_prefix("YYYY")); // Too long
        assert!(!is_valid_prefix("yy")); // Lowercase
        assert!(!is_valid_prefix("Y1")); // Contains number
    }

    #[test]
    fn test_validate_bundle_code() {
        assert!(validate_bundle_code("A-01-ABCD1234").is_ok());
        assert!(validate_bundle_code("").is_err());
        assert!(validate_bundle_code("NO_DASH").is_err());
    }
}
