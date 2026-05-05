//! Packet Code Generator
//!
//! This module provides functionality for generating packet codes across
//! six independent code format types:
//! - **itf14**: ITF-14 standard (14-digit numeric, outer shipping containers)
//! - **gs1_128**: GS1-128 barcode (Application Identifier based)
//! - **code128_industrial**: Code 128 for industrial/factory labeling
//! - **qr**: QR Code (default, existing generation logic)
//! - **datamatrix**: DataMatrix (compact 2D, pharma-grade)
//! - **code128_label**: Code 128 for handheld/label printers
//!
//! Packet codes are the third level in the packaging hierarchy:
//! 1 Packet contains multiple Units
//! Multiple Packets make up 1 Carton

use crate::generators::carton::CartonCodeFormat;
use crate::models::{CodeGenerationResponse, NexaTraceError, PacketCode};
use chrono::Utc;
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use uuid::Uuid;

// ---------------------------------------------------------------------------
// Generation Params
// ---------------------------------------------------------------------------

/// Packet-level generation parameters mirroring the Carton architecture.
///
/// All optional packaging parameters default to `None` so callers are not
/// forced to supply them. When `None`, hierarchy fields (`total_units`) are
/// set to 0 and no unit sub-codes are generated.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PacketGenerationParams {
    /// Code format selector. Defaults to `CartonCodeFormat::Qr`.
    pub code_format: CartonCodeFormat,
    /// 3 uppercase letter prefix (e.g., "YBZ").
    pub prefix: String,
    /// Starting sequence number (1-9999).
    pub start_sequence: u32,
    /// Number of codes to generate.
    pub count: u32,
    /// Parent carton code.
    pub carton_code: String,
    /// Factory identifier.
    pub factory_id: String,
    /// GS1 company prefix (required for itf14, gs1_128, datamatrix).
    pub company_prefix: Option<String>,
    /// Number of units inside each packet (optional, removes hardcoded assumption).
    pub units_per_packet: Option<u32>,
    /// Unit prefix used when `units_per_packet` is provided.
    pub unit_prefix: Option<String>,
}

impl PacketGenerationParams {
    /// Build a params struct with required fields; everything else defaults.
    pub fn new(
        code_format: CartonCodeFormat,
        prefix: String,
        start_sequence: u32,
        count: u32,
        carton_code: String,
        factory_id: String,
    ) -> Self {
        Self {
            code_format,
            prefix,
            start_sequence,
            count,
            carton_code,
            factory_id,
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        }
    }

    /// Validate all supplied parameters.
    pub fn validate(&self) -> Result<(), NexaTraceError> {
        validate_prefix(&self.prefix)?;
        validate_sequence(self.start_sequence)?;
        validate_count(self.count)?;
        validate_carton_code(&self.carton_code)?;
        validate_factory_id(&self.factory_id)?;

        // Company prefix is required for GS1-based formats
        match self.code_format {
            CartonCodeFormat::Itf14
            | CartonCodeFormat::Gs1128
            | CartonCodeFormat::Datamatrix => {
                if self.company_prefix.is_none() {
                    return Err(NexaTraceError::ValidationError(format!(
                        "company_prefix is required for {} format",
                        self.code_format.display_name()
                    )));
                }
            }
            _ => {}
        }

        // Validate company prefix when provided
        if let Some(ref cp) = self.company_prefix {
            if cp.is_empty() || cp.len() > 12 || !cp.chars().all(|c| c.is_ascii_digit()) {
                return Err(NexaTraceError::ValidationError(
                    "company_prefix must be 1-12 digits".to_string(),
                ));
            }
        }

        // Validate units_per_packet when provided
        if let Some(upp) = self.units_per_packet {
            validate_units_per_packet(upp)?;
        }

        // unit_prefix required if units_per_packet is set
        if self.units_per_packet.is_some() && self.unit_prefix.is_none() {
            return Err(NexaTraceError::ValidationError(
                "unit_prefix is required when units_per_packet is specified".to_string(),
            ));
        }

        if let Some(ref up) = self.unit_prefix {
            validate_unit_prefix(up)?;
        }

        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Public API — format-aware generation
// ---------------------------------------------------------------------------

/// Generate a single packet code in the specified format.
///
/// This is the primary entry point for format-aware code generation.
pub fn generate_single_code_with_format(
    params: &PacketGenerationParams,
) -> Result<String, NexaTraceError> {
    params.validate()?;

    match params.code_format {
        CartonCodeFormat::Itf14 => generate_itf14_code(params),
        CartonCodeFormat::Gs1128 => generate_gs1_128_code(params),
        CartonCodeFormat::Code128Industrial => generate_code128_industrial_code(params),
        CartonCodeFormat::Qr => generate_qr_code(params),
        CartonCodeFormat::Datamatrix => generate_datamatrix_code(params),
        CartonCodeFormat::Code128Label => generate_code128_label_code(params),
    }
}

/// Generate multiple packet codes in batch with format selection.
///
/// Each code is generated independently using the same format and parameters;
/// only the sequence number increments.
pub fn generate_batch_with_format(
    params: &PacketGenerationParams,
) -> Result<Vec<String>, NexaTraceError> {
    params.validate()?;

    let mut codes = Vec::with_capacity(params.count as usize);
    for i in 0..params.count {
        let mut iter_params = params.clone();
        iter_params.start_sequence = params.start_sequence + i;
        iter_params.count = 1;
        codes.push(generate_single_code_with_format(&iter_params)?);
    }
    Ok(codes)
}

/// Generate packet codes with hierarchy (including unit codes) and format selection.
///
/// `units_per_packet` and `unit_prefix` are taken from `params` — no
/// hardcoded packaging ratios are used.
pub fn generate_with_hierarchy_and_format(
    params: &PacketGenerationParams,
) -> Result<Vec<PacketCode>, NexaTraceError> {
    params.validate()?;

    let units_per_packet = params.units_per_packet.unwrap_or(0);

    let mut packet_codes = Vec::with_capacity(params.count as usize);

    for packet_index in 0..params.count {
        let mut iter_params = params.clone();
        iter_params.start_sequence = params.start_sequence + packet_index;
        iter_params.count = 1;

        let packet_code = generate_single_code_with_format(&iter_params)?;

        // Generate unit sub-codes if units_per_packet is provided
        let unit_codes = if units_per_packet > 0 {
            let upfx = params.unit_prefix.clone().unwrap_or_default();
            let mut units = Vec::with_capacity(units_per_packet as usize);
            for unit_index in 0..units_per_packet {
                let unit_sequence = unit_index + 1;
                let unit_code = crate::generators::unit::generate_single_code(
                    upfx.clone(),
                    unit_sequence,
                    packet_code.clone(),
                    params.factory_id.clone(),
                )?;
                units.push(unit_code);
            }
            units
        } else {
            Vec::new()
        };

        let total_units = units_per_packet;

        let packet = PacketCode {
            code: packet_code,
            sequence: params.start_sequence + packet_index,
            carton_code: params.carton_code.clone(),
            unit_codes,
            total_units,
            code_format: params.code_format.as_str().to_string(),
        };

        packet_codes.push(packet);
    }

    Ok(packet_codes)
}

// ---------------------------------------------------------------------------
// Public API — backward-compatible wrappers (default to "qr" format)
// ---------------------------------------------------------------------------

/// Generate a single packet code (legacy — defaults to QR format).
///
/// This preserves the original `generate_single_code(prefix, sequence,
/// carton_code, factory_id)` signature.
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    carton_code: String,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    let params = PacketGenerationParams {
        code_format: CartonCodeFormat::Qr,
        prefix,
        start_sequence: sequence,
        count: 1,
        carton_code,
        factory_id,
        company_prefix: None,
        units_per_packet: None,
        unit_prefix: None,
    };
    generate_single_code_with_format(&params)
}

/// Generate multiple packet codes in batch (legacy — defaults to QR format).
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    let params = PacketGenerationParams {
        code_format: CartonCodeFormat::Qr,
        prefix,
        start_sequence,
        count,
        carton_code,
        factory_id,
        company_prefix: None,
        units_per_packet: None,
        unit_prefix: None,
    };
    generate_batch_with_format(&params)
}

/// Generate packet codes with hierarchy (legacy — defaults to QR format).
pub fn generate_with_hierarchy(
    prefix: String,
    start_sequence: u32,
    count: u32,
    units_per_packet: u32,
    unit_prefix: String,
    carton_code: String,
    factory_id: String,
) -> Result<Vec<PacketCode>, NexaTraceError> {
    let params = PacketGenerationParams {
        code_format: CartonCodeFormat::Qr,
        prefix,
        start_sequence,
        count,
        carton_code,
        factory_id,
        company_prefix: None,
        units_per_packet: Some(units_per_packet),
        unit_prefix: Some(unit_prefix),
    };
    generate_with_hierarchy_and_format(&params)
}

/// Generate packet codes with international standards (legacy).
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    carton_code: String,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes in QR format
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
            "PACKET".to_string(),
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

// ---------------------------------------------------------------------------
// Format-specific generators
// ---------------------------------------------------------------------------

/// Generate an ITF-14 compliant packet code.
///
/// ITF-14 is a 14-digit numeric code. Structure:
/// Indicator digit (1) + Company prefix (7) + Item reference (5) + Check digit (1)
fn generate_itf14_code(params: &PacketGenerationParams) -> Result<String, NexaTraceError> {
    let company_prefix = params.company_prefix.as_deref().unwrap_or("0000000");

    // Indicator digit: 1 for packet-level container
    let indicator = 1u32;

    // Build the 13-digit base (before check digit)
    let cp_padded = format!("{:0>7}", &company_prefix.chars().take(7).collect::<String>());

    // Item reference: 5 digits derived from sequence
    let item_ref = format!("{:05}", params.start_sequence % 100000);

    // 13 digits without check digit
    let base_13 = format!("{}{}{}", indicator, cp_padded, item_ref);

    // Compute GS1 check digit
    let check_digit = compute_gs1_check_digit(&base_13)?;

    Ok(format!("{}{}", base_13, check_digit))
}

/// Generate a GS1-128 barcode packet code string.
///
/// Format: (01)GTIN-14(10)Batch(17)YYMMDD
fn generate_gs1_128_code(params: &PacketGenerationParams) -> Result<String, NexaTraceError> {
    let gtin14 = generate_itf14_code(params)?;

    // Batch number derived from carton_code hash + sequence
    let batch = format!("P{}", params.start_sequence);

    // Expiry date: 2 years from now, formatted as YYMMDD for AI(17)
    let expiry = Utc::now()
        .checked_add_signed(chrono::Duration::days(730))
        .map(|dt| dt.format("%y%m%d").to_string())
        .unwrap_or_else(|| "280101".to_string());

    Ok(format!("(01){}(10){}(17){}", gtin14, batch, expiry))
}

/// Generate a Code 128 Industrial packet code.
///
/// Pattern: PKT-PREFIX-SEQUENCE-HASH
/// Designed for factory floor scanning with full traceability.
fn generate_code128_industrial_code(
    params: &PacketGenerationParams,
) -> Result<String, NexaTraceError> {
    let sequence_part = format!("{:04}", params.start_sequence);

    // Generate traceability hash from carton + factory + sequence
    let trace_hash = generate_short_hash(
        &params.carton_code,
        &params.factory_id,
        params.start_sequence,
    );

    Ok(format!("PKT-{}-{}-{}", params.prefix, sequence_part, trace_hash))
}

/// Generate a QR-code payload (legacy format, default).
///
/// Pattern: PREFIX-SEQUENCE-CARTONHASH-FACTORYHASH
fn generate_qr_code(params: &PacketGenerationParams) -> Result<String, NexaTraceError> {
    let code = format!("{}-{:04}", params.prefix, params.start_sequence);
    let carton_hash = generate_carton_hash(&params.carton_code, &code);
    let factory_hash = generate_factory_hash(&params.factory_id, &code);
    Ok(format!("{}-{}-{}", code, carton_hash, factory_hash))
}

/// Generate a DataMatrix packet code string.
///
/// GS1 DataMatrix structure using FNC1 + AI codes.
/// Compact format suitable for pharmaceutical and small-item labeling.
fn generate_datamatrix_code(params: &PacketGenerationParams) -> Result<String, NexaTraceError> {
    // GTIN-14 as core identifier
    let gtin14 = generate_itf14_code(params)?;

    // Serial number: 8 digits from sequence
    let serial = format!("{:08}", params.start_sequence);

    // Production date (AI 11) — today
    let prod_date = Utc::now().format("%y%m%d").to_string();

    // GS1 DataMatrix: [FNC1](01)GTIN14(11)YYMMDD(21)SERIAL
    Ok(format!("\x1d(01){}(11){}(21){}", gtin14, prod_date, serial))
}

/// Generate a Code 128 Label packet code.
///
/// Pattern: P-PREFIX-SEQUENCE
/// Shorter alphanumeric pattern for handheld label printers.
fn generate_code128_label_code(
    params: &PacketGenerationParams,
) -> Result<String, NexaTraceError> {
    let sequence_part = format!("{:04}", params.start_sequence);
    Ok(format!("P-{}-{}", params.prefix, sequence_part))
}

// ---------------------------------------------------------------------------
// Check-digit & hash helpers
// ---------------------------------------------------------------------------

/// Compute the GS1 modular-10 check digit for a numeric string.
fn compute_gs1_check_digit(digits: &str) -> Result<char, NexaTraceError> {
    if !digits.chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(
            "GS1 check digit input must be all digits".to_string(),
        ));
    }

    let digits_vec: Vec<u32> = digits
        .chars()
        .map(|c| c.to_digit(10).unwrap())
        .collect();

    // GS1 weights: from right to left, 3, 1, 3, 1, ...
    let mut sum: u32 = 0;
    for (i, &d) in digits_vec.iter().rev().enumerate() {
        let weight = if i % 2 == 0 { 3 } else { 1 };
        sum += d * weight;
    }

    let check = (10 - (sum % 10)) % 10;
    Ok(char::from_digit(check, 10).unwrap())
}

/// Generate carton hash for packet code (SHA256, 8-char hex).
fn generate_carton_hash(carton_code: &str, packet_code: &str) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}", carton_code, packet_code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 8 characters of hex representation
    hex::encode(result)[0..8].to_string()
}

/// Generate factory hash for packet code (SHA256, 4-char hex).
fn generate_factory_hash(factory_id: &str, code: &str) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}", factory_id, code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();

    // Take first 4 characters of hex representation
    hex::encode(result)[0..4].to_string()
}

/// Generate a short traceability hash (SHA256, 8-char hex).
///
/// Used by the industrial code128 format for traceability linking
/// back to carton and factory.
fn generate_short_hash(carton_code: &str, factory_id: &str, sequence: u32) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}-{}", carton_code, factory_id, sequence);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();
    hex::encode(result)[0..8].to_string()
}

// ---------------------------------------------------------------------------
// Validation & parsing
// ---------------------------------------------------------------------------

/// Validate packet code format.
///
/// For QR-format codes the existing 4-part pattern is enforced.
/// For other formats, format-specific validation is applied.
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Try to detect format from code structure
    // QR (legacy): PREFIX-SEQUENCE-CARTONHASH-FACTORYHASH (4 parts, dash-separated)
    if let Ok(result) = validate_qr_format_code(code) {
        return Ok(result);
    }

    // ITF-14: 14-digit numeric
    if code.len() == 14 && code.chars().all(|c| c.is_ascii_digit()) {
        return validate_itf14_code(code);
    }

    // GS1-128: contains "(01)"
    if code.starts_with("(01)") {
        return validate_gs1_128_code(code);
    }

    // Code 128 Industrial: PKT-PREFIX-SEQUENCE-HASH (4 parts)
    if let Ok(result) = validate_code128_industrial_code(code) {
        return Ok(result);
    }

    // Code 128 Label: P-PREFIX-SEQUENCE (3 parts, starts with "P-")
    if let Ok(result) = validate_code128_label_code(code) {
        return Ok(result);
    }

    // DataMatrix: starts with FNC1 + (01)
    if code.starts_with("\x1d(01)") {
        return validate_datamatrix_code(code);
    }

    Err(NexaTraceError::ValidationError(
        format!("Unrecognized packet code format for: {}", code),
    ))
}

/// Validate a packet code with an explicit format hint.
pub fn validate_code_with_format(
    code: &str,
    code_format: CartonCodeFormat,
) -> Result<bool, NexaTraceError> {
    match code_format {
        CartonCodeFormat::Qr => validate_qr_format_code(code),
        CartonCodeFormat::Itf14 => validate_itf14_code(code),
        CartonCodeFormat::Gs1128 => validate_gs1_128_code(code),
        CartonCodeFormat::Code128Industrial => validate_code128_industrial_code(code),
        CartonCodeFormat::Datamatrix => validate_datamatrix_code(code),
        CartonCodeFormat::Code128Label => validate_code128_label_code(code),
    }
}

/// Parse packet code into components.
///
/// Returns a `HashMap` with format-specific fields plus a `code_format` key.
pub fn parse_code(code: &str) -> Result<HashMap<String, String>, NexaTraceError> {
    validate_code(code)?;

    let mut components = HashMap::new();

    // Detect and parse by format
    if code.len() == 14 && code.chars().all(|c| c.is_ascii_digit()) {
        components.insert("code_format".to_string(), "itf14".to_string());
        components.insert("indicator".to_string(), code[0..1].to_string());
        components.insert("company_prefix".to_string(), code[1..8].to_string());
        components.insert("item_reference".to_string(), code[8..13].to_string());
        components.insert("check_digit".to_string(), code[13..14].to_string());
        components.insert("code_type".to_string(), "packet".to_string());
    } else if code.starts_with("(01)") {
        components.insert("code_format".to_string(), "gs1_128".to_string());
        if code.len() >= 18 {
            components.insert("gtin14".to_string(), code[4..18].to_string());
        }
        if let Some(pos) = code.find("(10)") {
            let batch_start = pos + 4;
            let batch_end = code.find("(17)").unwrap_or(code.len());
            components.insert("batch".to_string(), code[batch_start..batch_end].to_string());
        }
        if let Some(pos) = code.find("(17)") {
            let expiry_start = pos + 4;
            let expiry_end = (expiry_start + 6).min(code.len());
            components.insert("expiry".to_string(), code[expiry_start..expiry_end].to_string());
        }
        components.insert("code_type".to_string(), "packet".to_string());
    } else if code.starts_with("\x1d(01)") {
        components.insert("code_format".to_string(), "datamatrix".to_string());
        if code.len() >= 19 {
            components.insert("gtin14".to_string(), code[5..19].to_string());
        }
        components.insert("code_type".to_string(), "packet".to_string());
    } else {
        let parts: Vec<&str> = code.split('-').collect();
        if parts.len() == 4 && !parts[0].starts_with("PKT") && !parts[0].starts_with('P') {
            // QR (legacy) format: PREFIX-SEQUENCE-CARTONHASH-FACTORYHASH
            // Only match 4-part codes that don't start with PKT or P- prefix
            components.insert("code_format".to_string(), "qr".to_string());
            components.insert("prefix".to_string(), parts[0].to_string());
            components.insert("sequence".to_string(), parts[1].to_string());
            components.insert("carton_hash".to_string(), parts[2].to_string());
            components.insert("factory_hash".to_string(), parts[3].to_string());
            components.insert("carton_hint".to_string(), format!("CARTON-{}", &parts[2][0..4]));
            components.insert("factory_hint".to_string(), format!("FACTORY-{}", &parts[3][0..2]));
        } else if parts.len() == 4 && parts[0] == "PKT" {
            // Code 128 Industrial: PKT-PREFIX-SEQUENCE-HASH
            components.insert("code_format".to_string(), "code128_industrial".to_string());
            components.insert("prefix".to_string(), parts[1].to_string());
            components.insert("sequence".to_string(), parts[2].to_string());
            components.insert("trace_hash".to_string(), parts[3].to_string());
        } else if parts.len() == 3 && parts[0] == "P" {
            // Code 128 Label: P-PREFIX-SEQUENCE
            components.insert("code_format".to_string(), "code128_label".to_string());
            components.insert("prefix".to_string(), parts[1].to_string());
            components.insert("sequence".to_string(), parts[2].to_string());
        }
        components.insert("code_type".to_string(), "packet".to_string());
    }

    Ok(components)
}

// ---------------------------------------------------------------------------
// Format-specific validators (internal)
// ---------------------------------------------------------------------------

/// Validate QR-format (legacy) packet code: PREFIX-SEQUENCE-CARTONHASH-FACTORYHASH
fn validate_qr_format_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid QR packet code format. Expected 4 parts, got {}",
            parts.len()
        )));
    }

    if !is_valid_prefix(parts[0]) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid prefix: {}",
            parts[0]
        )));
    }

    let sequence: u32 = parts[1].parse().map_err(|_| {
        NexaTraceError::ValidationError(format!("Invalid sequence number: {}", parts[1]))
    })?;

    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string(),
        ));
    }

    // Carton hash: 8 chars alphanumeric
    if parts[2].len() != 8 || !parts[2].chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid carton hash: {}",
            parts[2]
        )));
    }

    // Factory hash: 4 chars alphanumeric
    if parts[3].len() != 4 || !parts[3].chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid factory hash: {}",
            parts[3]
        )));
    }

    Ok(true)
}

/// Validate ITF-14 packet code: 14-digit numeric with valid check digit.
fn validate_itf14_code(code: &str) -> Result<bool, NexaTraceError> {
    if code.len() != 14 {
        return Err(NexaTraceError::ValidationError(format!(
            "ITF-14 code must be 14 digits, got {} characters",
            code.len()
        )));
    }
    if !code.chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(
            "ITF-14 code must contain only digits".to_string(),
        ));
    }

    // Verify check digit
    let base_13 = &code[0..13];
    let expected_check = compute_gs1_check_digit(base_13)?;
    if code.chars().nth(13).unwrap() != expected_check {
        return Err(NexaTraceError::ValidationError(
            "ITF-14 check digit mismatch".to_string(),
        ));
    }

    Ok(true)
}

/// Validate GS1-128 packet code: must contain (01)GTIN-14 and optionally (10) and (17).
fn validate_gs1_128_code(code: &str) -> Result<bool, NexaTraceError> {
    if !code.starts_with("(01)") {
        return Err(NexaTraceError::ValidationError(
            "GS1-128 code must start with (01)".to_string(),
        ));
    }

    // GTIN-14 must follow (01)
    if code.len() < 18 {
        return Err(NexaTraceError::ValidationError(
            "GS1-128 code too short: GTIN-14 required after (01)".to_string(),
        ));
    }

    let gtin14 = &code[4..18];
    if !gtin14.chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(
            "GTIN-14 must be all digits".to_string(),
        ));
    }

    // Validate the GTIN-14 check digit
    validate_itf14_code(gtin14)?;

    Ok(true)
}

/// Validate Code 128 Industrial packet code: PKT-PREFIX-SEQUENCE-HASH.
fn validate_code128_industrial_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(format!(
            "Code 128 Industrial code must have 4 parts, got {}",
            parts.len()
        )));
    }

    if parts[0] != "PKT" {
        return Err(NexaTraceError::ValidationError(
            "Code 128 Industrial packet code must start with PKT".to_string(),
        ));
    }

    if !is_valid_prefix(parts[1]) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid prefix: {}",
            parts[1]
        )));
    }

    // Sequence: 4-digit zero-padded
    if parts[2].len() != 4 || !parts[2].chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid sequence: {}. Must be 4 digits",
            parts[2]
        )));
    }

    // Trace hash: 8-char hex
    if parts[3].len() != 8 || !parts[3].chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid trace hash: {}. Must be 8 hex characters",
            parts[3]
        )));
    }

    Ok(true)
}

/// Validate DataMatrix packet code: FNC1 + (01)GTIN-14 + optional AIs.
fn validate_datamatrix_code(code: &str) -> Result<bool, NexaTraceError> {
    if !code.starts_with("\x1d(01)") {
        return Err(NexaTraceError::ValidationError(
            "DataMatrix code must start with FNC1+(01)".to_string(),
        ));
    }

    // Extract and validate GTIN-14
    if code.len() < 19 {
        return Err(NexaTraceError::ValidationError(
            "DataMatrix code too short for GTIN-14".to_string(),
        ));
    }

    let gtin14 = &code[5..19];
    validate_itf14_code(gtin14)?;

    Ok(true)
}

/// Validate Code 128 Label packet code: P-PREFIX-SEQUENCE.
fn validate_code128_label_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 3 {
        return Err(NexaTraceError::ValidationError(format!(
            "Code 128 Label code must have 3 parts, got {}",
            parts.len()
        )));
    }

    if parts[0] != "P" {
        return Err(NexaTraceError::ValidationError(
            "Code 128 Label packet code must start with P".to_string(),
        ));
    }

    if !is_valid_prefix(parts[1]) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid prefix: {}",
            parts[1]
        )));
    }

    // Sequence: 4-digit zero-padded
    if parts[2].len() != 4 || !parts[2].chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid sequence: {}. Must be 4 digits",
            parts[2]
        )));
    }

    Ok(true)
}

// ---------------------------------------------------------------------------
// Shared validation helpers
// ---------------------------------------------------------------------------

/// Validate prefix: 3 uppercase ASCII letters.
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid prefix: {}. Must be 3 uppercase letters",
            prefix
        )));
    }
    Ok(())
}

/// Check if prefix is valid: exactly 3 uppercase ASCII letters.
fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 3 && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate unit prefix: 4 uppercase ASCII letters (matches unit generator).
fn validate_unit_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_unit_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(format!(
            "Invalid unit prefix: {}. Must be 4 uppercase letters",
            prefix
        )));
    }
    Ok(())
}

/// Check if unit prefix is valid: exactly 4 uppercase ASCII letters.
fn is_valid_unit_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    len == 4 && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate sequence number (1-9999).
fn validate_sequence(sequence: u32) -> Result<(), NexaTraceError> {
    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string(),
        ));
    }
    if sequence > 9999 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot exceed 9999".to_string(),
        ));
    }
    Ok(())
}

/// Validate count.
fn validate_count(count: u32) -> Result<(), NexaTraceError> {
    if count == 0 {
        return Err(NexaTraceError::ValidationError(
            "Count cannot be zero".to_string(),
        ));
    }
    if count > 10000 {
        return Err(NexaTraceError::ValidationError(
            "Cannot generate more than 10,000 codes at once".to_string(),
        ));
    }
    Ok(())
}

/// Validate units per packet.
fn validate_units_per_packet(units_per_packet: u32) -> Result<(), NexaTraceError> {
    if units_per_packet == 0 {
        return Err(NexaTraceError::ValidationError(
            "Units per packet cannot be zero".to_string(),
        ));
    }
    if units_per_packet > 100 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 100 units per packet".to_string(),
        ));
    }
    Ok(())
}

/// Validate carton code.
fn validate_carton_code(carton_code: &str) -> Result<(), NexaTraceError> {
    if carton_code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Carton code cannot be empty".to_string(),
        ));
    }

    // Basic validation — should contain at least two dashes
    let dash_count = carton_code.chars().filter(|c| *c == '-').count();
    if dash_count < 2 {
        return Err(NexaTraceError::ValidationError(
            "Invalid carton code format".to_string(),
        ));
    }

    Ok(())
}

/// Validate factory ID.
fn validate_factory_id(factory_id: &str) -> Result<(), NexaTraceError> {
    if factory_id.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Factory ID cannot be empty".to_string(),
        ));
    }
    if factory_id.len() > 50 {
        return Err(NexaTraceError::ValidationError(
            "Factory ID cannot exceed 50 characters".to_string(),
        ));
    }
    Ok(())
}

// ---------------------------------------------------------------------------
// Random code generation (for testing/demo)
// ---------------------------------------------------------------------------

/// Generate a random packet code (QR format) for testing/demo.
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    // Random prefix (3 uppercase letters)
    let prefix_chars: String = (0..3)
        .map(|_| (b'A' + rng.gen_range(0..26)) as char)
        .collect();
    let prefix = prefix_chars;

    // Random sequence (1-9999)
    let sequence = rng.gen_range(1..10000);

    // Random carton hash (8 chars alphanumeric)
    let carton_hash: String = (0..8)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    // Random factory hash (4 chars alphanumeric)
    let factory_hash: String = (0..4)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    format!(
        "{}-{:04}-{}-{}",
        prefix, sequence, carton_hash, factory_hash
    )
}

/// Generate a random packet code in the specified format (for testing/demo).
pub fn generate_random_code_with_format(code_format: CartonCodeFormat) -> String {
    let mut rng = rand::thread_rng();

    match code_format {
        CartonCodeFormat::Itf14 => {
            // Generate a valid random ITF-14
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let item: String = (0..5)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let base_13 = format!("{}{}{}", indicator, company, item);
            let check = compute_gs1_check_digit(&base_13).unwrap();
            format!("{}{}", base_13, check)
        }
        CartonCodeFormat::Gs1128 => {
            // Random GTIN-14 + batch + expiry
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let item: String = (0..5)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let base_13 = format!("{}{}{}", indicator, company, item);
            let check = compute_gs1_check_digit(&base_13).unwrap();
            let gtin14 = format!("{}{}", base_13, check);
            let batch: u32 = rng.gen_range(1..10000);
            let expiry_year = rng.gen_range(25..30);
            let expiry_month = rng.gen_range(1..13);
            let expiry_day = rng.gen_range(1..29);
            format!(
                "(01){}(10)P{:04}(17){:02}{:02}{:02}",
                gtin14, batch, expiry_year, expiry_month, expiry_day
            )
        }
        CartonCodeFormat::Code128Industrial => {
            let prefix_chars: String = (0..3)
                .map(|_| (b'A' + rng.gen_range(0..26)) as char)
                .collect();
            let sequence = rng.gen_range(1..10000);
            let hash: String = (0..8)
                .map(|_| {
                    let chars = "0123456789abcdef";
                    let idx = rng.gen_range(0..chars.len());
                    chars.chars().nth(idx).unwrap()
                })
                .collect();
            format!("PKT-{}-{:04}-{}", prefix_chars, sequence, hash)
        }
        CartonCodeFormat::Qr => generate_random_code(),
        CartonCodeFormat::Datamatrix => {
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let item: String = (0..5)
                .map(|_| rng.gen_range(0..10).to_string())
                .collect();
            let base_13 = format!("{}{}{}", indicator, company, item);
            let check = compute_gs1_check_digit(&base_13).unwrap();
            let gtin14 = format!("{}{}", base_13, check);
            let serial: u32 = rng.gen_range(1..100000000);
            let prod_year = rng.gen_range(24..27);
            let prod_month = rng.gen_range(1..13);
            let prod_day = rng.gen_range(1..29);
            format!(
                "\x1d(01){}(11){:02}{:02}{:02}(21){:08}",
                gtin14, prod_year, prod_month, prod_day, serial
            )
        }
        CartonCodeFormat::Code128Label => {
            let prefix_chars: String = (0..3)
                .map(|_| (b'A' + rng.gen_range(0..26)) as char)
                .collect();
            let sequence = rng.gen_range(1..10000);
            format!("P-{}-{:04}", prefix_chars, sequence)
        }
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    // -----------------------------------------------------------------------
    // Legacy tests — must keep working
    // -----------------------------------------------------------------------

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code(
            "YBZ".to_string(),
            1,
            "YY-001-ABC123-DEF456".to_string(),
            "factory_123".to_string(),
        )
        .unwrap();
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
        )
        .unwrap();
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

    // -----------------------------------------------------------------------
    // Format-aware generation tests
    // -----------------------------------------------------------------------

    #[test]
    fn test_generate_itf14_code() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Itf14,
            prefix: "YBZ".to_string(),
            start_sequence: 42,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: Some("1234567".to_string()),
            units_per_packet: None,
            unit_prefix: None,
        };

        let code = generate_single_code_with_format(&params).unwrap();
        assert_eq!(code.len(), 14);
        assert!(code.chars().all(|c| c.is_ascii_digit()));
        assert!(validate_itf14_code(&code).is_ok());
    }

    #[test]
    fn test_validate_itf14_code() {
        // Valid ITF-14
        let base = "1123456700042";
        let check = compute_gs1_check_digit(base).unwrap();
        let valid = format!("{}{}", base, check);
        assert!(validate_itf14_code(&valid).is_ok());

        // Wrong length
        assert!(validate_itf14_code("123").is_err());
        // Non-digit
        assert!(validate_itf14_code("1123456700042X").is_err());
    }

    #[test]
    fn test_generate_gs1_128_code() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Gs1128,
            prefix: "YBZ".to_string(),
            start_sequence: 42,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: Some("1234567".to_string()),
            units_per_packet: None,
            unit_prefix: None,
        };

        let code = generate_single_code_with_format(&params).unwrap();
        assert!(code.starts_with("(01)"));
        assert!(code.contains("(10)P42"));
        assert!(code.contains("(17)"));
        assert!(validate_gs1_128_code(&code).is_ok());
    }

    #[test]
    fn test_validate_gs1_128_code() {
        // Need a valid GTIN-14 first
        let base = "1123456700042";
        let check = compute_gs1_check_digit(base).unwrap();
        let gtin14 = format!("{}{}", base, check);
        let valid = format!("(01){}(10)P0042(17)280101", gtin14);
        assert!(validate_gs1_128_code(&valid).is_ok());

        // No (01) prefix
        assert!(validate_gs1_128_code("NO").is_err());
    }

    #[test]
    fn test_generate_code128_industrial_code() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Code128Industrial,
            prefix: "YBZ".to_string(),
            start_sequence: 42,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        };

        let code = generate_single_code_with_format(&params).unwrap();
        assert!(code.starts_with("PKT-YBZ-0042-"));
        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 4);
        assert_eq!(parts[0], "PKT");
        assert!(validate_code128_industrial_code(&code).is_ok());
    }

    #[test]
    fn test_validate_code128_industrial() {
        let valid = "PKT-YBZ-0042-ABCDEF01";
        assert!(validate_code128_industrial_code(valid).is_ok());

        // Wrong number of parts
        assert!(validate_code128_industrial_code("YBZ-0042-HASH").is_err());
        // Doesn't start with PKT
        assert!(validate_code128_industrial_code("XX-YBZ-0042-ABCDEF01").is_err());
    }

    #[test]
    fn test_generate_code128_label_code() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Code128Label,
            prefix: "YBZ".to_string(),
            start_sequence: 42,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        };

        let code = generate_single_code_with_format(&params).unwrap();
        assert!(code.starts_with("P-YBZ-0042"));
        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 3);
        assert_eq!(parts[0], "P");
        assert!(validate_code128_label_code(&code).is_ok());
    }

    #[test]
    fn test_validate_code128_label() {
        let valid = "P-YBZ-0042";
        assert!(validate_code128_label_code(valid).is_ok());

        // Wrong number of parts
        assert!(validate_code128_label_code("YBZ-0042").is_err());
        // Doesn't start with P
        assert!(validate_code128_label_code("X-YBZ-0042").is_err());
    }

    #[test]
    fn test_generate_datamatrix_code() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Datamatrix,
            prefix: "YBZ".to_string(),
            start_sequence: 42,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: Some("1234567".to_string()),
            units_per_packet: None,
            unit_prefix: None,
        };

        let code = generate_single_code_with_format(&params).unwrap();
        assert!(code.starts_with("\x1d(01)"));
        assert!(code.contains("(11)"));
        assert!(code.contains("(21)"));
        assert!(validate_datamatrix_code(&code).is_ok());
    }

    #[test]
    fn test_validate_datamatrix_code() {
        let base = "1123456700042";
        let check = compute_gs1_check_digit(base).unwrap();
        let gtin14 = format!("{}{}", base, check);
        let valid = format!("\x1d(01){}(11)250101(21)00000042", gtin14);
        assert!(validate_datamatrix_code(&valid).is_ok());

        // No FNC1 prefix
        assert!(validate_datamatrix_code("(01)12345678901231").is_err());
    }

    #[test]
    fn test_generate_batch_with_format_itf14() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Itf14,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 5,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: Some("1234567".to_string()),
            units_per_packet: None,
            unit_prefix: None,
        };

        let codes = generate_batch_with_format(&params).unwrap();
        assert_eq!(codes.len(), 5);
        for code in &codes {
            assert_eq!(code.len(), 14);
            assert!(validate_itf14_code(code).is_ok());
        }
    }

    #[test]
    fn test_generate_batch_with_format_label() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Code128Label,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 3,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        };

        let codes = generate_batch_with_format(&params).unwrap();
        assert_eq!(codes.len(), 3);
        assert!(codes[0].starts_with("P-YBZ-0001"));
        assert!(codes[2].starts_with("P-YBZ-0003"));
    }

    #[test]
    fn test_generate_with_hierarchy_and_format() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Qr,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 2,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: Some(3),
            unit_prefix: Some("UNIT".to_string()),
        };

        let packets = generate_with_hierarchy_and_format(&params).unwrap();
        assert_eq!(packets.len(), 2);
        assert_eq!(packets[0].unit_codes.len(), 3);
        assert_eq!(packets[0].total_units, 3);
        assert!(packets[0].code.starts_with("YBZ-0001-"));
    }

    #[test]
    fn test_generate_with_hierarchy_no_units() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Qr,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 2,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        };

        let packets = generate_with_hierarchy_and_format(&params).unwrap();
        assert_eq!(packets.len(), 2);
        assert_eq!(packets[0].unit_codes.len(), 0);
        assert_eq!(packets[0].total_units, 0);
    }

    #[test]
    fn test_gs1_check_digit() {
        let base = "1123456700042";
        let check = compute_gs1_check_digit(base).unwrap();
        let full = format!("{}{}", base, check);
        assert_eq!(full.len(), 14);
        // Re-verify
        let recomputed = compute_gs1_check_digit(&full[0..13]).unwrap();
        assert_eq!(check, recomputed);
    }

    #[test]
    fn test_generate_random_code_with_format() {
        for format_str in CartonCodeFormat::all_formats() {
            let format = CartonCodeFormat::from_str(format_str).unwrap();
            let code = generate_random_code_with_format(format);
            assert!(validate_code_with_format(&code, format).is_ok());
        }
    }

    #[test]
    fn test_parse_itf14_code() {
        let base = "1123456700042";
        let check = compute_gs1_check_digit(base).unwrap();
        let code = format!("{}{}", base, check);
        let components = parse_code(&code).unwrap();
        assert_eq!(components.get("code_format").unwrap(), "itf14");
        assert_eq!(components.get("code_type").unwrap(), "packet");
    }

    #[test]
    fn test_parse_label_code() {
        let code = "P-YBZ-0042";
        let components = parse_code(&code).unwrap();
        assert_eq!(components.get("code_format").unwrap(), "code128_label");
        assert_eq!(components.get("prefix").unwrap(), "YBZ");
        assert_eq!(components.get("sequence").unwrap(), "0042");
    }

    #[test]
    fn test_params_validation_requires_company_prefix_for_itf14() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Itf14,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: None,
            unit_prefix: None,
        };
        assert!(params.validate().is_err());
    }

    #[test]
    fn test_params_validation_ok_with_company_prefix() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Itf14,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: Some("1234567".to_string()),
            units_per_packet: None,
            unit_prefix: None,
        };
        assert!(params.validate().is_ok());
    }

    #[test]
    fn test_params_validation_units_per_packet() {
        let params = PacketGenerationParams {
            code_format: CartonCodeFormat::Qr,
            prefix: "YBZ".to_string(),
            start_sequence: 1,
            count: 1,
            carton_code: "YY-001-ABC123-DEF456".to_string(),
            factory_id: "factory_123".to_string(),
            company_prefix: None,
            units_per_packet: Some(5),
            unit_prefix: None, // Missing unit_prefix → should fail
        };
        assert!(params.validate().is_err());
    }
}
