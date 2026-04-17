//! Packet Code Generator
//!
//! This module provides functionality for generating packet codes.
//! Packet codes are the third level in the packaging hierarchy:
//! 1 Packet contains multiple Units
//! Multiple Packets make up 1 Carton
//!
//! Code format: PREFIX-SEQUENCE (e.g., YBZ-0001, YBZ-0002, YBZ-0003)

use crate::models::{PacketCode, CodeGenerationResponse, NexaTraceError};
use rand::Rng;
use std::collections::HashMap;
use uuid::Uuid;

/// Generate a single packet code
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    carton_code: String,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(sequence)?;
    validate_carton_code(&carton_code)?;
    validate_factory_id(&factory_id)?;

    // Generate the code
    let code = format!("{}-{:04}", prefix, sequence);

    // Add carton identifier and factory hash
    let carton_hash = generate_carton_hash(&carton_code, &code);
    let factory_hash = generate_factory_hash(&factory_id, &code);
    let final_code = format!("{}-{}-{}", code, carton_hash, factory_hash);

    Ok(final_code)
}

/// Generate multiple packet codes in batch
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_carton_code(&carton_code)?;
    validate_factory_id(&factory_id)?;

    let mut codes = Vec::with_capacity(count as usize);

    for i in 0..count {
        let sequence = start_sequence + i;
        let code = generate_single_code(
            prefix.clone(),
            sequence,
            carton_code.clone(),
            factory_id.clone(),
        )?;
        codes.push(code);
    }

    Ok(codes)
}

/// Generate packet codes with hierarchy (including unit codes)
pub fn generate_with_hierarchy(
    prefix: String,
    start_sequence: u32,
    count: u32,
    units_per_packet: u32,
    unit_prefix: String,
    carton_code: String,
    factory_id: String,
) -> Result<Vec<PacketCode>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_units_per_packet(units_per_packet)?;
    validate_prefix(&unit_prefix)?;
    validate_carton_code(&carton_code)?;
    validate_factory_id(&factory_id)?;

    let mut packet_codes = Vec::with_capacity(count as usize);

    for packet_index in 0..count {
        let packet_sequence = start_sequence + packet_index;
        let packet_code = generate_single_code(
            prefix.clone(),
            packet_sequence,
            carton_code.clone(),
            factory_id.clone(),
        )?;

        // Generate unit codes for this packet
        let mut unit_codes = Vec::with_capacity(units_per_packet as usize);
        for unit_index in 0..units_per_packet {
            let unit_sequence = unit_index + 1;
            let unit_code = crate::generators::unit::generate_single_code(
                unit_prefix.clone(),
                unit_sequence,
                packet_code.clone(),
                factory_id.clone(),
            )?;
            unit_codes.push(unit_code);
        }

        // Calculate totals
        let total_units = units_per_packet;

        let packet = PacketCode {
            code: packet_code,
            sequence: packet_sequence,
            carton_code: carton_code.clone(),
            unit_codes,
            total_units,
        };

        packet_codes.push(packet);
    }

    Ok(packet_codes)
}

/// Generate packet codes with international standards
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes
    let base_codes = generate_batch(
        prefix.clone(),
        start_sequence,
        count,
        carton_code.clone(),
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
            "PACKET".to_string(), // Item reference for packets
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

/// Validate packet code format
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Expected format: PREFIX-SEQUENCE-CARTONHASH-FACTORYHASH
    let parts: Vec<&str> = code.split('-').collect();

    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid packet code format. Expected 4 parts, got {}", parts.len())
        ));
    }

    let prefix = parts[0];
    let sequence_str = parts[1];
    let carton_hash = parts[2];
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

    // Validate carton hash (should be 8 characters alphanumeric)
    if carton_hash.len() != 8 || !carton_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid carton hash: {}", carton_hash)
        ));
    }

    // Validate factory hash (should be 4 characters alphanumeric)
    if factory_hash.len() != 4 || !factory_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid factory hash: {}", factory_hash)
        ));
    }

    Ok(true)
}

/// Parse packet code into components
pub fn parse_code(code: &str) -> Result<HashMap<String, String>, NexaTraceError> {
    validate_code(code)?;

    let parts: Vec<&str> = code.split('-').collect();
    let prefix = parts[0];
    let sequence = parts[1];
    let carton_hash = parts[2];
    let factory_hash = parts[3];

    let mut components = HashMap::new();
    components.insert("prefix".to_string(), prefix.to_string());
    components.insert("sequence".to_string(), sequence.to_string());
    components.insert("carton_hash".to_string(), carton_hash.to_string());
    components.insert("factory_hash".to_string(), factory_hash.to_string());
    components.insert("code_type".to_string(), "packet".to_string());

    // Extract carton and factory hints
    components.insert("carton_hint".to_string(), format!("CARTON-{}", &carton_hash[0..4]));
    components.insert("factory_hint".to_string(), format!("FACTORY-{}", &factory_hash[0..2]));

    Ok(components)
}

/// Generate carton hash for code
fn generate_carton_hash(carton_code: &str, packet_code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", carton_code, packet_code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 8 characters of hex representation
    hex::encode(result)[0..8].to_string()
}

/// Generate factory hash for code
fn generate_factory_hash(factory_id: &str, code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", factory_id, code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 4 characters of hex representation
    hex::encode(result)[0..4].to_string()
}

/// Validate prefix
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}. Must be 3 uppercase letters", prefix)
        ));
    }
    Ok(())
}

/// Check if prefix is valid
fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 3 && prefix.chars().all(|c| c.is_ascii_uppercase())
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

/// Validate units per packet
fn validate_units_per_packet(units_per_packet: u32) -> Result<(), NexaTraceError> {
    if units_per_packet == 0 {
        return Err(NexaTraceError::ValidationError(
            "Units per packet cannot be zero".to_string()
        ));
    }

    if units_per_packet > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 100 units per packet".to_string()
        ));
    }

    Ok(())
}

/// Validate carton code
fn validate_carton_code(carton_code: &str) -> Result<(), NexaTraceError> {
    if carton_code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Carton code cannot be empty".to_string()
        ));
    }

    // Basic validation - should contain at least two dashes
    let dash_count = carton_code.chars().filter(|c| *c == '-').count();
    if dash_count < 2 {
        return Err(NexaTraceError::ValidationError(
            "Invalid carton code format".to_string()
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

/// Generate random packet code (for testing/demo)
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    // Random prefix (3 uppercase letters)
    let prefix_chars: String = (0..3)
        .map(|_| (b'A' + rng.gen_range(0..26)) as char)
        .collect();
    let prefix = prefix_chars;

    // Random sequence (1-9999)
    let sequence = rng.gen_range(1..10000);

    // Random carton hash
    let carton_hash: String = (0..8)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    // Random factory hash
    let factory_hash: String = (0..4)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    format!("{}-{:04}-{}-{}", prefix, sequence, carton_hash, factory_hash)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code(
            "YBZ".to_string(),
            1,
            "YY-001-ABC123-DEF456".to_string(),
            "factory_123".to_string(),
        ).unwrap();
        assert!(code.starts_with("YBZ-0001-"));
        assert_eq!(code.split('-').count(), 4);
    }

    #[test]
    fn test_generate_batch() {
        let codes = generate_batch(
            "ABC".to_string(),
            1,
            5,
            "ZZ-001-GHI789-JKL012".to_string(),
            "factory_456".to_string(),
        ).unwrap();
        assert_eq!(codes.len(), 5);
        assert!(codes[0].starts_with("ABC-0001-"));
        assert!(codes[4].starts_with("ABC-0005-"));
    }

    #[test]
    fn test_validate_code() {
        // Valid code
        let valid_code = "YBZ-0001-ABCD1234-EFGH";
        assert!(validate_code(valid_code).unwrap());

        // Invalid formats
        assert!(validate_code("YBZ-0001-ABCD1234").is_err()); // Missing factory hash
        assert!(validate_code("YBZ-0001-ABCD12345-EFGH").is_err()); // Carton hash too long
        assert!(validate_code("ybz-0001-ABCD1234-EFGH").is_err()); // Lowercase prefix
        assert!(validate_code("YZ-0001-ABCD1234-EFGH").is_err()); // Two character prefix
        assert!(validate_code("YBZZ-0001-ABCD1234-EFGH").is_err()); // Four character prefix
        assert!(validate_code("YBZ-0000-ABCD1234-EFGH").is_err()); // Zero sequence
    }

    #[test]
    fn test_parse_code() {
        let code = "ABC-0042-GHIJ5678-KLMN";
        let components = parse_code(code).unwrap();

        assert_eq!(components.get("prefix").unwrap(), "ABC");
        assert_eq!(components.get("sequence").unwrap(), "0042");
        assert_eq!(components.get("carton_hash").unwrap(), "GHIJ5678");
        assert_eq!(components.get("factory_hash").unwrap(), "KLMN");
        assert_eq!(components.get("code_type").unwrap(), "packet");
    }

    #[test]
    fn test_generate_random_code() {
        let code = generate_random_code();
        assert!(validate_code(&code).is_ok());
    }

    #[test]
    fn test_validate_prefix() {
        assert!(is_valid_prefix("YBZ"));
        assert!(is_valid_prefix("ABC"));
        assert!(!is_valid_prefix("AB")); // Too short
        assert!(!is_valid_prefix("ABCD")); // Too long
        assert!(!is_valid_prefix("ybz")); // Lowercase
        assert!(!is_valid_prefix("AB1")); // Contains number
    }

    #[test]
    fn test_validate_carton_code() {
        assert!(validate_carton_code("YY-001-ABC123-DEF456").is_ok());
        assert!(validate_carton_code("").is_err());
        assert!(validate_carton_code("NO-DASH").is_err()); // Only one dash
    }
}
