//! Unit Code Generator
//!
//! This module provides functionality for generating unit (authentication) codes.
//! Unit codes are the lowest level in the packaging hierarchy:
//! 1 Unit is a single product item
//! Multiple Units make up 1 Packet
//!
//! Code format: PREFIX-SEQUENCE (e.g., TSFG-00001, TSFG-00002, TSFG-00003)
//! Unit codes also include authentication codes for verification

use crate::models::{UnitCode, CodeGenerationResponse, NexaTraceError};
use crate::algorithms::authentication;
use rand::Rng;
use std::collections::HashMap;
use uuid::Uuid;

/// Generate a single unit code
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    packet_code: String,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(sequence)?;
    validate_packet_code(&packet_code)?;
    validate_factory_id(&factory_id)?;

    // Generate the code
    let code = format!("{}-{:05}", prefix, sequence);

    // Add packet identifier and factory hash
    let packet_hash = generate_packet_hash(&packet_code, &code);
    let factory_hash = generate_factory_hash(&factory_id, &code);
    let final_code = format!("{}-{}-{}", code, packet_hash, factory_hash);

    Ok(final_code)
}

/// Generate multiple unit codes in batch
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packet_code: String,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_packet_code(&packet_code)?;
    validate_factory_id(&factory_id)?;

    let mut codes = Vec::with_capacity(count as usize);

    for i in 0..count {
        let sequence = start_sequence + i;
        let code = generate_single_code(
            prefix.clone(),
            sequence,
            packet_code.clone(),
            factory_id.clone(),
        )?;
        codes.push(code);
    }

    Ok(codes)
}

/// Generate unit codes with authentication codes
pub fn generate_with_authentication(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packet_code: String,
    factory_id: String,
    authentication_length: u32,
) -> Result<Vec<UnitCode>, NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_packet_code(&packet_code)?;
    validate_factory_id(&factory_id)?;
    validate_authentication_length(authentication_length)?;

    let mut unit_codes = Vec::with_capacity(count as usize);

    for unit_index in 0..count {
        let unit_sequence = start_sequence + unit_index;
        let unit_code = generate_single_code(
            prefix.clone(),
            unit_sequence,
            packet_code.clone(),
            factory_id.clone(),
        )?;

        // Generate authentication code
        let auth_code = authentication::generate_secure_code(authentication_length)
            .map_err(|e| NexaTraceError::GenerationError(e.to_string()))?;

        // Generate serial number
        let serial_number = generate_serial_number(&unit_code, unit_sequence);

        let unit = UnitCode {
            code: unit_code,
            sequence: unit_sequence,
            packet_code: packet_code.clone(),
            authentication_code: auth_code,
            serial_number,
        };

        unit_codes.push(unit);
    }

    Ok(unit_codes)
}

/// Generate unit codes with master authentication codes
pub fn generate_with_master_codes(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packet_code: String,
    factory_id: String,
    units_per_master: u32,
    authentication_length: u32,
) -> Result<(Vec<UnitCode>, Vec<String>), NexaTraceError> {
    // Validate inputs
    validate_prefix(&prefix)?;
    validate_sequence(start_sequence)?;
    validate_count(count)?;
    validate_packet_code(&packet_code)?;
    validate_factory_id(&factory_id)?;
    validate_units_per_master(units_per_master)?;
    validate_authentication_length(authentication_length)?;

    let mut unit_codes = Vec::with_capacity(count as usize);
    let mut master_codes = Vec::new();

    let total_masters = (count + units_per_master - 1) / units_per_master; // Ceiling division

    for master_index in 0..total_masters {
        // Generate master authentication code
        let master_auth_code = authentication::generate_secure_code(authentication_length * 2)
            .map_err(|e| NexaTraceError::GenerationError(e.to_string()))?;
        master_codes.push(master_auth_code.clone());

        // Calculate range for this master code
        let start = start_sequence + (master_index * units_per_master);
        let end = std::cmp::min(start + units_per_master, start_sequence + count);

        for unit_index in start..end {
            let unit_sequence = unit_index;
            let unit_code = generate_single_code(
                prefix.clone(),
                unit_sequence,
                packet_code.clone(),
                factory_id.clone(),
            )?;

            // Generate unit authentication code (derived from master)
            let unit_auth_code = derive_unit_auth_code(&master_auth_code, unit_sequence);

            // Generate serial number
            let serial_number = generate_serial_number(&unit_code, unit_sequence);

            let unit = UnitCode {
                code: unit_code,
                sequence: unit_sequence,
                packet_code: packet_code.clone(),
                authentication_code: unit_auth_code,
                serial_number,
            };

            unit_codes.push(unit);
        }
    }

    Ok((unit_codes, master_codes))
}

/// Generate unit codes with international standards (optional)
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packet_code: String,
    factory_id: String,
    company_prefix: Option<String>,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes
    let base_codes = generate_batch(
        prefix.clone(),
        start_sequence,
        count,
        packet_code.clone(),
        factory_id.clone(),
    )?;

    // Generate authentication codes
    let mut authentication_codes = Vec::with_capacity(count as usize);
    let mut qr_codes = Vec::with_capacity(count as usize);
    let mut barcodes = Vec::with_capacity(count as usize);
    let mut international_codes = Vec::new();

    for (index, base_code) in base_codes.iter().enumerate() {
        // Generate authentication code
        let auth_code = authentication::generate_secure_code(16)
            .map_err(|e| NexaTraceError::GenerationError(e.to_string()))?;
        authentication_codes.push(auth_code.clone());

        // Generate QR code with authentication data
        let qr_data = crate::international::qr::generate_qr_data(
            base_code.clone(),
            Some(auth_code.clone()),
        )?;
        qr_codes.push(qr_data);

        // Generate barcode
        let barcode_data = crate::international::barcode::generate_barcode_data(
            base_code.clone(),
            "CODE128".to_string(),
        )?;
        barcodes.push(barcode_data);

        // Generate international code if requested
        if let Some(ref company_prefix) = company_prefix {
            let serial_number = format!("{:010}", start_sequence + index as u32);
            let gs1_code = crate::international::gs1::generate_gs1_code(
                company_prefix.clone(),
                "UNIT".to_string(), // Item reference for units
                serial_number,
            )?;
            international_codes.push(gs1_code);
        }
    }

    let response = CodeGenerationResponse {
        success: true,
        batch_id: Uuid::new_v4().to_string(),
        codes_generated: count,
        generated_codes: base_codes,
        qr_codes: Some(qr_codes),
        barcodes: Some(barcodes),
        international_codes: if international_codes.is_empty() {
            None
        } else {
            Some(international_codes)
        },
        error: None,
    };

    Ok(response)
}

/// Validate unit code format
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Expected format: PREFIX-SEQUENCE-PACKETHASH-FACTORYHASH
    let parts: Vec<&str> = code.split('-').collect();

    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid unit code format. Expected 4 parts, got {}", parts.len())
        ));
    }

    let prefix = parts[0];
    let sequence_str = parts[1];
    let packet_hash = parts[2];
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

    // Validate packet hash (should be 10 characters alphanumeric)
    if packet_hash.len() != 10 || !packet_hash.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid packet hash: {}", packet_hash)
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

/// Parse unit code into components
pub fn parse_code(code: &str) -> Result<HashMap<String, String>, NexaTraceError> {
    validate_code(code)?;

    let parts: Vec<&str> = code.split('-').collect();
    let prefix = parts[0];
    let sequence = parts[1];
    let packet_hash = parts[2];
    let factory_hash = parts[3];

    let mut components = HashMap::new();
    components.insert("prefix".to_string(), prefix.to_string());
    components.insert("sequence".to_string(), sequence.to_string());
    components.insert("packet_hash".to_string(), packet_hash.to_string());
    components.insert("factory_hash".to_string(), factory_hash.to_string());
    components.insert("code_type".to_string(), "unit".to_string());

    // Extract packet and factory hints
    components.insert("packet_hint".to_string(), format!("PACKET-{}", &packet_hash[0..5]));
    components.insert("factory_hint".to_string(), format!("FACTORY-{}", &factory_hash[0..3]));

    Ok(components)
}

/// Generate packet hash for code
fn generate_packet_hash(packet_code: &str, unit_code: &str) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", packet_code, unit_code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 10 characters of hex representation
    hex::encode(result)[0..10].to_string()
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

/// Generate serial number for unit
fn generate_serial_number(unit_code: &str, sequence: u32) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", unit_code, sequence);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 12 characters of hex representation
    hex::encode(result)[0..12].to_string()
}

/// Derive unit authentication code from master code
fn derive_unit_auth_code(master_code: &str, sequence: u32) -> String {
    use sha2::{Sha256, Digest};

    let data = format!("{}-{}", master_code, sequence);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 16 characters of hex representation
    hex::encode(result)[0..16].to_string()
}

/// Validate prefix
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}. Must be 4 uppercase letters", prefix)
        ));
    }
    Ok(())
}

/// Check if prefix is valid
fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 4 && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate sequence number
fn validate_sequence(sequence: u32) -> Result<(), NexaTraceError> {
    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string()
        ));
    }

    if sequence > 99999 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot exceed 99999".to_string()
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

    if count > 100000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 100,000 codes at once".to_string()
        ));
    }

    Ok(())
}

/// Validate authentication code length
fn validate_authentication_length(length: u32) -> Result<(), NexaTraceError> {
    if length < 8 {
        return Err(NexaTraceError::ValidationError(
            "Authentication code must be at least 8 characters".to_string()
        ));
    }

    if length > 64 {
        return Err(NexaTraceError::ValidationError(
            "Authentication code cannot exceed 64 characters".to_string()
        ));
    }

    Ok(())
}

/// Validate units per master code
fn validate_units_per_master(units_per_master: u32) -> Result<(), NexaTraceError> {
    if units_per_master == 0 {
        return Err(NexaTraceError::ValidationError(
            "Units per master cannot be zero".to_string()
        ));
    }

    if units_per_master > 1000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 1000 units per master code".to_string()
        ));
    }

    Ok(())
}

/// Validate packet code
fn validate_packet_code(packet_code: &str) -> Result<(), NexaTraceError> {
    if packet_code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Packet code cannot be empty".to_string()
        ));
    }

    // Basic validation - should contain at least three dashes
    let dash_count = packet_code.chars().filter(|c| *c == '-').count();
    if dash_count < 3 {
        return Err(NexaTraceError::ValidationError(
            "Invalid packet code format".to_string()
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

/// Generate random unit code (for testing/demo)
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    // Random prefix (4 uppercase letters)
    let prefix_chars: String = (0..4)
        .map(|_| (b'A' + rng.gen_range(0..26)) as char)
        .collect();
    let prefix = prefix_chars;

    // Random sequence (1-99999)
    let sequence = rng.gen_range(1..100000);

    // Random packet hash
    let packet_hash: String = (0..10)
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

    format!("{}-{:05}-{}-{}", prefix, sequence, packet_hash, factory_hash)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code(
            "TSFG".to_string(),
            1,
            "YBZ-0001-ABCD1234-EFGH".to_string(),
            "factory_123".to_string(),
        ).unwrap();
        assert!(code.starts_with("TSFG-00001-"));
        assert_eq!(code.split('-').count(), 4);
    }

    #[test]
    fn test_generate_batch() {
        let codes = generate_batch(
            "ABCD".to_string(),
            1,
            5,
            "ABC-0001-GHIJ5678-KLMN".to_string(),
            "factory_456".to_string(),
        ).unwrap();
        assert_eq!(codes.len(), 5);
        assert!(codes[0].starts_with("ABCD-00001-"));
        assert!(codes[4].starts_with("ABCD-00005-"));
    }

    #[test]
    fn test_generate_with_authentication() {
        let units = generate_with_authentication(
            "TSFG".to_string(),
            1,
            3,
            "YBZ-0001-ABCD1234-EFGH".to_string(),
            "factory_123".to_string(),
            16,
        ).unwrap();
        assert_eq!(units.len(), 3);
        assert!(units[0].code.starts_with("TSFG-00001-"));
        assert_eq!(units[0].authentication_code.len(), 16);
        assert_eq!(units[0].serial_number.len(), 12);
    }

    #[test]
    fn test_generate_with_master_codes() {
        let (units, masters) = generate_with_master_codes(
            "TSFG".to_string(),
            1,
            10,
            "YBZ-0001-ABCD1234-EFGH".to_string(),
            "factory_123".to_string(),
            5,
            16,
        ).unwrap();
        assert_eq!(units.len(), 10);
        assert_eq!(masters.len(), 2); // 10 units / 5 per master = 2 masters
        assert!(masters[0].len() >= 32); // authentication_length * 2
    }

    #[test]
    fn test_validate_code() {
        // Valid code
        let valid_code = "TSFG-00001-ABCDEFGHIJ-KLMNOP";
        assert!(validate_code(valid_code).unwrap());

        // Invalid formats
        assert!(validate_code("TSFG-00001-ABCDEFGHIJ").is_err()); // Missing factory hash
        assert!(validate_code("TSFG-00001-ABCDEFGHIJK-LMNOP").is_err()); // Packet hash too long
        assert!(validate_code("tsfg-00001-ABCDEFGHIJ-KLMNOP").is_err()); // Lowercase prefix
        assert!(validate_code("TSF-00001-ABCDEFGHIJ-KLMNOP").is_err()); // Three character prefix
        assert!(validate_code("TSFGG-00001-ABCDEFGHIJ-KLMNOP").is_err()); // Five character prefix
        assert!(validate_code("TSFG-00000-ABCDEFGHIJ-KLMNOP").is_err()); // Zero sequence
    }

    #[test]
    fn test_parse_code() {
        let code = "ABCD-00042-GHIJKLMNOP-QRSTUV";
        let components = parse_code(code).unwrap();

        assert_eq!(components.get("prefix").unwrap(), "ABCD");
        assert_eq!(components.get("sequence").unwrap(), "00042");
        assert_eq!(components.get("packet_hash").unwrap(), "GHIJKLMNOP");
        assert_eq!(components.get("factory_hash").unwrap(), "QRSTUV");
        assert_eq!(components.get("code_type").unwrap(), "unit");
    }

    #[test]
    fn test_generate_random_code() {
        let code = generate_random_code();
        assert!(validate_code(&code).is_ok());
    }

    #[test]
    fn test_validate_prefix() {
        assert!(is_valid_prefix("TSFG"));
        assert!(is_valid_prefix("ABCD"));
        assert!(!is_valid_prefix("TSF")); // Too short
        assert!(!is_valid_prefix("TSFGG")); // Too long
        assert!(!is_valid_prefix("tsfg")); // Lowercase
        assert!(!is_valid_prefix("TSF1")); // Contains number
    }

    #[test]
    fn test_validate_packet_code() {
        assert!(validate_packet_code("YBZ-0001-ABCD1234-EFGH").is_ok());
        assert!(validate_packet_code("").is_err());
        assert!(validate_packet_code("NO-DASH-HERE").is_err()); // Only two dashes
    }

    #[test]
    fn test_validate_authentication_length() {
        assert!(validate_authentication_length(8).is_ok());
        assert!(validate_authentication_length(16).is_ok());
        assert!(validate_authentication_length(64).is_ok());
        assert!(validate_authentication_length(7).is_err()); // Too short
        assert!(validate_authentication_length(65).is_err()); // Too long
    }

    #[test]
    fn test_validate_units_per_master() {
        assert!(validate_units_per_master(1).is_ok());
        assert!(validate_units_per_master(100).is_ok());
        assert!(validate_units_per_master(1000).is_ok());
        assert!(validate_units_per_master(0).is_err()); // Zero
        assert!(validate_units_per_master(1001).is_err()); // Too many
    }
