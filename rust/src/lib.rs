//! NexaTrace Rust Module
//! High-performance code generation and processing for NexaTrace System
//!
//! This module provides:
//! - Secure code generation for all code types (Bundle, Carton, Packet, Unit)
//! - International standard integration (GS1, QR codes, barcodes)
//! - Batch processing for large volumes (100,000+ codes)
//! - Cryptographic security and validation
//! - Flutter integration via FFI

// Re-export public API
pub mod algorithms;
pub mod generators;
pub mod international;
pub mod models;
pub mod utils;

// Flutter Rust Bridge integration
use flutter_rust_bridge::frb;

/// Initialize the Rust module
#[frb(init)]
pub fn init() {
    // Initialize logging
    env_logger::init();
    log::info!("NexaTrace Rust module initialized");
}

/// Generate a single bundle code
#[frb]
pub fn generate_bundle_code(
    prefix: String,
    sequence: u32,
    factory_id: String,
) -> Result<String, String> {
    generators::bundle::generate_single_code(prefix, sequence, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate multiple bundle codes in batch
#[frb]
pub fn generate_bundle_codes_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    factory_id: String,
) -> Result<Vec<String>, String> {
    generators::bundle::generate_batch(prefix, start_sequence, count, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate a single carton code
#[frb]
pub fn generate_carton_code(
    prefix: String,
    sequence: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<String, String> {
    generators::carton::generate_single_code(prefix, sequence, bundle_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate multiple carton codes in batch
#[frb]
pub fn generate_carton_codes_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<Vec<String>, String> {
    generators::carton::generate_batch(prefix, start_sequence, count, bundle_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate a single carton code with a specific format
///
/// Supported formats: "itf14", "gs1_128", "code128_industrial", "qr", "datamatrix", "code128_label"
#[frb]
pub fn generate_carton_code_with_format(
    code_format: String,
    prefix: String,
    sequence: u32,
    bundle_code: String,
    factory_id: String,
    company_prefix: Option<String>,
) -> Result<String, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    let params = generators::carton::CartonGenerationParams {
        code_format: format,
        prefix,
        start_sequence: sequence,
        count: 1,
        bundle_code,
        factory_id,
        company_prefix,
        packets_per_carton: None,
        units_per_packet: None,
        packet_prefix: None,
    };
    generators::carton::generate_single_code_with_format(&params)
        .map_err(|e| e.to_string())
}

/// Generate multiple carton codes in batch with a specific format
///
/// Supported formats: "itf14", "gs1_128", "code128_industrial", "qr", "datamatrix", "code128_label"
#[frb]
pub fn generate_carton_codes_batch_with_format(
    code_format: String,
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
    company_prefix: Option<String>,
) -> Result<Vec<String>, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    let params = generators::carton::CartonGenerationParams {
        code_format: format,
        prefix,
        start_sequence,
        count,
        bundle_code,
        factory_id,
        company_prefix,
        packets_per_carton: None,
        units_per_packet: None,
        packet_prefix: None,
    };
    generators::carton::generate_batch_with_format(&params)
        .map_err(|e| e.to_string())
}

/// Get all supported carton code format identifiers
#[frb]
pub fn get_carton_code_formats() -> Vec<String> {
    generators::carton::CartonCodeFormat::all_formats()
        .iter()
        .map(|s| s.to_string())
        .collect()
}

/// Validate a carton code against a specific format
#[frb]
pub fn validate_carton_code_with_format(
    code: String,
    code_format: String,
) -> Result<bool, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    generators::carton::validate_code_with_format(&code, format)
        .map_err(|e| e.to_string())
}

/// Generate a single packet code
#[frb]
pub fn generate_packet_code(
    prefix: String,
    sequence: u32,
    carton_code: String,
    factory_id: String,
) -> Result<String, String> {
    generators::packet::generate_single_code(prefix, sequence, carton_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate multiple packet codes in batch
#[frb]
pub fn generate_packet_codes_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
) -> Result<Vec<String>, String> {
    generators::packet::generate_batch(prefix, start_sequence, count, carton_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate a single packet code with a specific format
///
/// Supported formats: "itf14", "gs1_128", "code128_industrial", "qr", "datamatrix", "code128_label"
#[frb]
pub fn generate_packet_code_with_format(
    code_format: String,
    prefix: String,
    sequence: u32,
    carton_code: String,
    factory_id: String,
    company_prefix: Option<String>,
) -> Result<String, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    let params = generators::packet::PacketGenerationParams {
        code_format: format,
        prefix,
        start_sequence: sequence,
        count: 1,
        carton_code,
        factory_id,
        company_prefix,
        units_per_packet: None,
        unit_prefix: None,
    };
    generators::packet::generate_single_code_with_format(&params)
        .map_err(|e| e.to_string())
}

/// Generate multiple packet codes in batch with a specific format
///
/// Supported formats: "itf14", "gs1_128", "code128_industrial", "qr", "datamatrix", "code128_label"
#[frb]
pub fn generate_packet_codes_batch_with_format(
    code_format: String,
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
    company_prefix: Option<String>,
) -> Result<Vec<String>, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    let params = generators::packet::PacketGenerationParams {
        code_format: format,
        prefix,
        start_sequence,
        count,
        carton_code,
        factory_id,
        company_prefix,
        units_per_packet: None,
        unit_prefix: None,
    };
    generators::packet::generate_batch_with_format(&params)
        .map_err(|e| e.to_string())
}

/// Get all supported packet code format identifiers
#[frb]
pub fn get_packet_code_formats() -> Vec<String> {
    generators::carton::CartonCodeFormat::all_formats()
        .iter()
        .map(|s| s.to_string())
        .collect()
}

/// Validate a packet code against a specific format
#[frb]
pub fn validate_packet_code_with_format(
    code: String,
    code_format: String,
) -> Result<bool, String> {
    let format = generators::carton::CartonCodeFormat::from_str(&code_format)
        .map_err(|e| e.to_string())?;
    generators::packet::validate_code_with_format(&code, format)
        .map_err(|e| e.to_string())
}

/// Generate a single unit (authentication) code
#[frb]
pub fn generate_unit_code(
    prefix: String,
    sequence: u32,
    packet_code: String,
    factory_id: String,
) -> Result<String, String> {
    generators::unit::generate_single_code(prefix, sequence, packet_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate multiple unit codes in batch
#[frb]
pub fn generate_unit_codes_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packet_code: String,
    factory_id: String,
) -> Result<Vec<String>, String> {
    generators::unit::generate_batch(prefix, start_sequence, count, packet_code, factory_id)
        .map_err(|e| e.to_string())
}

/// Generate hierarchical codes (Bundle -> Carton -> Packet -> Unit)
#[frb]
pub fn generate_hierarchical_codes(
    bundle_prefix: String,
    carton_prefix: String,
    packet_prefix: String,
    unit_prefix: String,
    bundle_count: u32,
    cartons_per_bundle: u32,
    packets_per_carton: u32,
    units_per_packet: u32,
    factory_id: String,
) -> Result<models::HierarchicalCodes, String> {
    generators::hierarchical::generate_hierarchical(
        bundle_prefix,
        carton_prefix,
        packet_prefix,
        unit_prefix,
        bundle_count,
        cartons_per_bundle,
        packets_per_carton,
        units_per_packet,
        factory_id,
    )
    .map_err(|e| e.to_string())
}

/// Generate GS1-compliant international code
#[frb]
pub fn generate_gs1_code(
    company_prefix: String,
    item_reference: String,
    serial_number: String,
) -> Result<String, String> {
    international::gs1::generate_gs1_code(company_prefix, item_reference, serial_number)
        .map_err(|e| e.to_string())
}

/// Generate QR code data for a code
#[frb]
pub fn generate_qr_code_data(code: String, additional_data: Option<String>) -> Result<String, String> {
    international::qr::generate_qr_data(code, additional_data)
        .map_err(|e| e.to_string())
}

/// Generate barcode data for a code
#[frb]
pub fn generate_barcode_data(code: String, barcode_type: String) -> Result<String, String> {
    international::barcode::generate_barcode_data(code, barcode_type)
        .map_err(|e| e.to_string())
}

/// Validate a code format
#[frb]
pub fn validate_code_format(code: String, code_type: String) -> Result<bool, String> {
    utils::validation::validate_code_format(&code, &code_type)
        .map_err(|e| e.to_string())
}

/// Generate secure authentication code
#[frb]
pub fn generate_authentication_code(length: u32) -> Result<String, String> {
    algorithms::authentication::generate_secure_code(length)
        .map_err(|e| e.to_string())
}

/// Verify authentication code
#[frb]
pub fn verify_authentication_code(code: String, expected_length: u32) -> Result<bool, String> {
    algorithms::authentication::verify_code(&code, expected_length)
        .map_err(|e| e.to_string())
}

/// Calculate checksum for a code
#[frb]
pub fn calculate_checksum(code: String) -> Result<String, String> {
    algorithms::checksum::calculate(&code)
        .map_err(|e| e.to_string())
}

/// Encrypt code data
#[frb]
pub fn encrypt_code_data(data: String, key: String) -> Result<String, String> {
    algorithms::encryption::encrypt(&data, &key)
        .map_err(|e| e.to_string())
}

/// Decrypt code data
#[frb]
pub fn decrypt_code_data(encrypted_data: String, key: String) -> Result<String, String> {
    algorithms::encryption::decrypt(&encrypted_data, &key)
        .map_err(|e| e.to_string())
}

/// Get module version
#[frb]
pub fn get_module_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Get module information
#[frb]
pub fn get_module_info() -> models::ModuleInfo {
    models::ModuleInfo {
        name: "NexaTrace Rust Module".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        description: "High-performance code generation for NexaTrace System".to_string(),
        capabilities: vec![
            "Bundle code generation".to_string(),
            "Carton code generation".to_string(),
            "Packet code generation".to_string(),
            "Unit (authentication) code generation".to_string(),
            "GS1 international codes".to_string(),
            "QR code generation".to_string(),
            "Barcode generation".to_string(),
            "Secure authentication".to_string(),
            "Batch processing".to_string(),
            "Hierarchical code generation".to_string(),
        ],
    }
}
