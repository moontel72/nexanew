//! Carton Code Generator
//!
//! This module provides functionality for generating carton codes across
//! six independent code format types:
//! - **itf14**: ITF-14 standard (14-digit numeric, outer shipping containers)
//! - **gs1_128**: GS1-128 barcode (Application Identifier based)
//! - **code128_industrial**: Code 128 for industrial/factory labeling
//! - **qr**: QR Code (default, existing generation logic)
//! - **datamatrix**: DataMatrix (compact 2D, pharma-grade)
//! - **code128_label**: Code 128 for handheld/label printers
//!
//! Carton codes are the second level in the packaging hierarchy:
//! 1 Carton contains multiple Packets
//! Multiple Cartons make up 1 Bundle

use crate::models::{CartonCode, CodeGenerationResponse, NexaTraceError};
use chrono::Utc;
use rand::Rng;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use uuid::Uuid;

// ---------------------------------------------------------------------------
// Code Format Enum
// ---------------------------------------------------------------------------

/// Supported carton code formats.
///
/// Each format produces codes with format-appropriate structure and encoding.
/// The `qr` variant preserves the legacy PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH pattern.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum CartonCodeFormat {
    /// ITF-14: 14-digit numeric code for outer shipping containers.
    Itf14,
    /// GS1-128: Application-Identifier based barcode string.
    Gs1128,
    /// Code 128 Industrial: Alphanumeric for factory floor scanning.
    Code128Industrial,
    /// QR Code: Encodes JSON payload with code, batch, timestamp (default/legacy).
    Qr,
    /// DataMatrix: Compact 2D with GS1 AI codes, pharma-grade.
    Datamatrix,
    /// Code 128 Label: Shorter alphanumeric for handheld label printers.
    Code128Label,
}

impl CartonCodeFormat {
    /// Parse a format string (case-insensitive) into a `CartonCodeFormat`.
    ///
    /// Accepted values: "itf14", "gs1_128", "code128_industrial", "qr",
    /// "datamatrix", "code128_label".
    pub fn from_str(format: &str) -> Result<Self, NexaTraceError> {
        match format.to_lowercase().as_str() {
            "itf14" => Ok(CartonCodeFormat::Itf14),
            "gs1_128" => Ok(CartonCodeFormat::Gs1128),
            "code128_industrial" => Ok(CartonCodeFormat::Code128Industrial),
            "qr" => Ok(CartonCodeFormat::Qr),
            "datamatrix" => Ok(CartonCodeFormat::Datamatrix),
            "code128_label" => Ok(CartonCodeFormat::Code128Label),
            _ => Err(NexaTraceError::ValidationError(format!(
                "Unknown carton code format: '{}'. Supported: itf14, gs1_128, code128_industrial, qr, datamatrix, code128_label",
                format
            ))),
        }
    }

    /// Return the kebab-case identifier for this format.
    pub fn as_str(&self) -> &'static str {
        match self {
            CartonCodeFormat::Itf14 => "itf14",
            CartonCodeFormat::Gs1128 => "gs1_128",
            CartonCodeFormat::Code128Industrial => "code128_industrial",
            CartonCodeFormat::Qr => "qr",
            CartonCodeFormat::Datamatrix => "datamatrix",
            CartonCodeFormat::Code128Label => "code128_label",
        }
    }

    /// Human-readable display name.
    pub fn display_name(&self) -> &'static str {
        match self {
            CartonCodeFormat::Itf14 => "ITF-14",
            CartonCodeFormat::Gs1128 => "GS1-128",
            CartonCodeFormat::Code128Industrial => "Code 128 Industrial",
            CartonCodeFormat::Qr => "QR Code",
            CartonCodeFormat::Datamatrix => "DataMatrix",
            CartonCodeFormat::Code128Label => "Code 128 Label",
        }
    }

    /// Return all supported format identifiers.
    pub fn all_formats() -> Vec<&'static str> {
        vec![
            "itf14",
            "gs1_128",
            "code128_industrial",
            "qr",
            "datamatrix",
            "code128_label",
        ]
    }
}

// ---------------------------------------------------------------------------
// Generation Parameters
// ---------------------------------------------------------------------------

/// Parameters for carton code generation.
///
/// All optional packaging parameters default to `None` so callers are not
/// forced to supply them.  When `None`, hierarchy fields (`total_packets`,
/// `total_units`) are set to 0 and no packet sub-codes are generated.
#[derive(Debug, Clone)]
pub struct CartonGenerationParams {
    /// Code format selector. Defaults to `CartonCodeFormat::Qr`.
    pub code_format: CartonCodeFormat,
    /// 2-3 uppercase letter prefix (e.g., "YY").
    pub prefix: String,
    /// Starting sequence number (1-999).
    pub start_sequence: u32,
    /// Number of codes to generate.
    pub count: u32,
    /// Parent bundle code.
    pub bundle_code: String,
    /// Factory identifier.
    pub factory_id: String,
    /// GS1 company prefix (required for itf14, gs1_128, datamatrix).
    pub company_prefix: Option<String>,
    /// Number of packets inside each carton (optional, removes hardcoded assumption).
    pub packets_per_carton: Option<u32>,
    /// Number of units inside each packet (optional, removes hardcoded assumption).
    pub units_per_packet: Option<u32>,
    /// Packet prefix used when `packets_per_carton` is provided.
    pub packet_prefix: Option<String>,
}

impl CartonGenerationParams {
    /// Build a params struct with required fields; everything else defaults.
    pub fn new(
        code_format: CartonCodeFormat,
        prefix: String,
        start_sequence: u32,
        count: u32,
        bundle_code: String,
        factory_id: String,
    ) -> Self {
        Self {
            code_format,
            prefix,
            start_sequence,
            count,
            bundle_code,
            factory_id,
            company_prefix: None,
            packets_per_carton: None,
            units_per_packet: None,
            packet_prefix: None,
        }
    }

    /// Validate all supplied parameters.
    pub fn validate(&self) -> Result<(), NexaTraceError> {
        validate_prefix(&self.prefix)?;
        validate_sequence(self.start_sequence)?;
        validate_count(self.count)?;
        validate_bundle_code(&self.bundle_code)?;
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

        // Validate packets_per_carton when provided
        if let Some(ppc) = self.packets_per_carton {
            validate_packets_per_carton(ppc)?;
        }

        // Validate units_per_packet when provided
        if let Some(upp) = self.units_per_packet {
            validate_units_per_packet(upp)?;
        }

        // packet_prefix required if packets_per_carton is set
        if self.packets_per_carton.is_some() && self.packet_prefix.is_none() {
            return Err(NexaTraceError::ValidationError(
                "packet_prefix is required when packets_per_carton is specified".to_string(),
            ));
        }

        if let Some(ref pp) = self.packet_prefix {
            validate_prefix(pp)?;
        }

        Ok(())
    }
}

// ---------------------------------------------------------------------------
// Public API — format-aware generation
// ---------------------------------------------------------------------------

/// Generate a single carton code in the specified format.
///
/// This is the primary entry point for format-aware code generation.
pub fn generate_single_code_with_format(
    params: &CartonGenerationParams,
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

/// Generate multiple carton codes in batch with format selection.
///
/// Each code is generated independently using the same format and parameters;
/// only the sequence number increments.
pub fn generate_batch_with_format(
    params: &CartonGenerationParams,
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

/// Generate carton codes with hierarchy (including packet codes) and format selection.
///
/// `packets_per_carton` and `units_per_packet` are taken from `params` — no
/// hardcoded packaging ratios are used.
pub fn generate_with_hierarchy_and_format(
    params: &CartonGenerationParams,
) -> Result<Vec<CartonCode>, NexaTraceError> {
    params.validate()?;

    let packets_per_carton = params.packets_per_carton.unwrap_or(0);
    let units_per_packet = params.units_per_packet.unwrap_or(0);

    let mut carton_codes = Vec::with_capacity(params.count as usize);

    for carton_index in 0..params.count {
        let mut iter_params = params.clone();
        iter_params.start_sequence = params.start_sequence + carton_index;
        iter_params.count = 1;

        let carton_code = generate_single_code_with_format(&iter_params)?;

        // Generate packet sub-codes if packets_per_carton is provided
        let packet_codes = if packets_per_carton > 0 {
            let pfx = params.packet_prefix.clone().unwrap_or_default();
            let mut pkts = Vec::with_capacity(packets_per_carton as usize);
            for packet_index in 0..packets_per_carton {
                let packet_sequence = packet_index + 1;
                let packet_code = crate::generators::packet::generate_single_code(
                    pfx.clone(),
                    packet_sequence,
                    carton_code.clone(),
                    params.factory_id.clone(),
                )?;
                pkts.push(packet_code);
            }
            pkts
        } else {
            Vec::new()
        };

        let total_packets = packets_per_carton;
        let total_units = total_packets * units_per_packet;

        let carton = CartonCode {
            code: carton_code,
            sequence: params.start_sequence + carton_index,
            bundle_code: params.bundle_code.clone(),
            packet_codes,
            total_packets,
            total_units,
        };

        carton_codes.push(carton);
    }

    Ok(carton_codes)
}

// ---------------------------------------------------------------------------
// Public API — backward-compatible wrappers (default to "qr" format)
// ---------------------------------------------------------------------------

/// Generate a single carton code (legacy API, defaults to QR format).
pub fn generate_single_code(
    prefix: String,
    sequence: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<String, NexaTraceError> {
    let params = CartonGenerationParams::new(
        CartonCodeFormat::Qr,
        prefix,
        sequence,
        1,
        bundle_code,
        factory_id,
    );
    generate_single_code_with_format(&params)
}

/// Generate multiple carton codes in batch (legacy API, defaults to QR format).
pub fn generate_batch(
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
) -> Result<Vec<String>, NexaTraceError> {
    let params = CartonGenerationParams::new(
        CartonCodeFormat::Qr,
        prefix,
        start_sequence,
        count,
        bundle_code,
        factory_id,
    );
    generate_batch_with_format(&params)
}

/// Generate carton codes with hierarchy (legacy API, defaults to QR format).
///
/// **Note:** The hardcoded `24 units per packet` assumption has been removed.
/// Callers should use `generate_with_hierarchy_and_format` with explicit
/// `units_per_packet` for accurate totals.  This wrapper uses 0 for
/// `total_units` when `units_per_packet` is not conveyed through the
/// existing signature — the `total_packets` is set from the provided
/// `packets_per_carton`, and `total_units` equals `packets_per_carton * 24`
/// only for backward compatibility of the *count*, but callers are
/// encouraged to migrate.
pub fn generate_with_hierarchy(
    prefix: String,
    start_sequence: u32,
    count: u32,
    packets_per_carton: u32,
    packet_prefix: String,
    bundle_code: String,
    factory_id: String,
) -> Result<Vec<CartonCode>, NexaTraceError> {
    let mut params = CartonGenerationParams::new(
        CartonCodeFormat::Qr,
        prefix,
        start_sequence,
        count,
        bundle_code,
        factory_id,
    );
    params.packets_per_carton = Some(packets_per_carton);
    params.units_per_packet = Some(24); // backward-compatible default
    params.packet_prefix = Some(packet_prefix);
    generate_with_hierarchy_and_format(&params)
}

/// Generate carton codes with international standards (legacy API).
///
/// This function requires the `international` sub-modules (gs1, qr, barcode)
/// to be available at runtime.
pub fn generate_with_international(
    prefix: String,
    start_sequence: u32,
    count: u32,
    bundle_code: String,
    factory_id: String,
    company_prefix: String,
) -> Result<CodeGenerationResponse, NexaTraceError> {
    // Generate base codes using legacy QR format
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
            "CARTON".to_string(),
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
// Format-specific code generation (internal)
// ---------------------------------------------------------------------------

/// Generate an ITF-14 compliant code.
///
/// ITF-14 is a 14-digit numeric code used on outer shipping containers.
/// Structure: Indicator digit (1) + Company prefix (7) + Item reference (5) + Check digit (1)
fn generate_itf14_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    let company_prefix = params.company_prefix.as_deref().unwrap_or("0000000");

    // Indicator digit: 0-9 (using 1 as default for outer container)
    let indicator = 1u32;

    // Build the 13-digit base (before check digit)
    // We take up to 7 digits from company_prefix, pad if shorter
    let cp_padded = format!("{:0>7}", &company_prefix.chars().take(7).collect::<String>());

    // Item reference: 5 digits derived from sequence
    let item_ref = format!("{:05}", params.start_sequence % 100000);

    // 13 digits without check digit
    let base_13 = format!("{}{}{}", indicator, cp_padded, item_ref);

    // Compute GS1 check digit (modular 10, weighted)
    let check_digit = compute_gs1_check_digit(&base_13)?;

    Ok(format!("{}{}", base_13, check_digit))
}

/// Generate a GS1-128 barcode string.
///
/// Format: (01)GTIN-14(10)Batch(17)YYMMDD
fn generate_gs1_128_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    // Build GTIN-14 using the ITF-14 logic (same 14-digit code)
    let gtin14 = generate_itf14_code(params)?;

    // Batch number derived from bundle_code + sequence
    let batch = format!("B{}", params.start_sequence);

    // Expiry date: 2 years from now, formatted as YYMMDD for AI(17)
    let expiry = Utc::now()
        .checked_add_signed(chrono::Duration::days(730))
        .map(|dt| dt.format("%y%m%d").to_string())
        .unwrap_or_else(|| "280101".to_string());

    Ok(format!("(01){}(10){}(17){}", gtin14, batch, expiry))
}

/// Generate a Code 128 Industrial code.
///
/// Pattern: FACTORY_PREFIX-CARTON_SEQUENCE-HASH
/// Designed for factory floor scanning with full traceability.
fn generate_code128_industrial_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    // Use prefix as factory prefix, zero-padded 4-digit sequence
    let sequence_part = format!("{:04}", params.start_sequence);

    // Generate traceability hash from bundle + factory + sequence
    let trace_hash = generate_trace_hash(&params.bundle_code, &params.factory_id, params.start_sequence);

    Ok(format!("{}-{}-{}", params.prefix, sequence_part, trace_hash))
}

/// Generate a QR-code payload (legacy format, default).
///
/// Pattern: PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH
fn generate_qr_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    let code = format!("{}-{:03}", params.prefix, params.start_sequence);
    let bundle_hash = generate_bundle_hash(&params.bundle_code, &code);
    let factory_hash = generate_factory_hash(&params.factory_id, &code);
    Ok(format!("{}-{}-{}", code, bundle_hash, factory_hash))
}

/// Generate a DataMatrix code string.
///
/// GS1 DataMatrix structure using FNC1 + AI codes.
/// Compact format suitable for pharmaceutical and small-item labeling.
fn generate_datamatrix_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    // GTIN-14 as core identifier
    let gtin14 = generate_itf14_code(params)?;

    // Serial number: 8 digits from sequence
    let serial = format!("{:08}", params.start_sequence);

    // Production date (AI 11) — today
    let prod_date = Utc::now().format("%y%m%d").to_string();

    // GS1 DataMatrix uses FNC1 as field separator
    // Format: [FNC1](01)GTIN14(11)YYMMDD(21)SERIAL
    Ok(format!("\x1d(01){}(11){}(21){}", gtin14, prod_date, serial))
}

/// Generate a Code 128 Label code.
///
/// Shorter alphanumeric pattern: PREFIX-SEQUENCE (no hash components).
/// Designed for handheld label printers where space is limited.
fn generate_code128_label_code(params: &CartonGenerationParams) -> Result<String, NexaTraceError> {
    // Simple PREFIX-SEQUENCE with zero-padded 4-digit sequence
    let sequence_part = format!("{:04}", params.start_sequence);
    Ok(format!("{}-{}", params.prefix, sequence_part))
}

// ---------------------------------------------------------------------------
// Check-digit & hash helpers
// ---------------------------------------------------------------------------

/// Compute the GS1 modular-10 check digit for a numeric string.
///
/// The algorithm alternates weight 3 and 1 starting from the rightmost digit.
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

/// Generate bundle hash for code (SHA256, 6-char hex).
fn generate_bundle_hash(bundle_code: &str, carton_code: &str) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}", bundle_code, carton_code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();
    hex::encode(result)[0..6].to_string()
}

/// Generate factory hash for code (SHA256, 6-char hex).
fn generate_factory_hash(factory_id: &str, code: &str) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}", factory_id, code);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();
    hex::encode(result)[0..6].to_string()
}

/// Generate traceability hash for industrial codes (SHA256, 8-char hex).
fn generate_trace_hash(bundle_code: &str, factory_id: &str, sequence: u32) -> String {
    use sha2::{Digest, Sha256};

    let data = format!("{}-{}-{}", bundle_code, factory_id, sequence);
    let mut hasher = Sha256::new();
    hasher.update(data.as_bytes());
    let result = hasher.finalize();
    hex::encode(result)[0..8].to_string()
}

// ---------------------------------------------------------------------------
// Validation & parsing
// ---------------------------------------------------------------------------

/// Validate carton code format.
///
/// For QR-format codes the existing 4-part pattern is enforced.
/// For other formats, format-specific validation is applied.
pub fn validate_code(code: &str) -> Result<bool, NexaTraceError> {
    // Try to detect format from code structure
    // QR (legacy): PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH (4 parts, dash-separated)
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

    // Code 128 Industrial: PREFIX-SEQUENCE-HASH (3 parts, hash is 8 chars hex)
    if let Ok(result) = validate_code128_industrial_code(code) {
        return Ok(result);
    }

    // Code 128 Label: PREFIX-SEQUENCE (2 parts)
    if let Ok(result) = validate_code128_label_code(code) {
        return Ok(result);
    }

    // DataMatrix: starts with FNC1 + (01)
    if code.starts_with("\x1d(01)") {
        return validate_datamatrix_code(code);
    }

    Err(NexaTraceError::ValidationError(
        format!("Unrecognized carton code format for: {}", code),
    ))
}

/// Validate a carton code with an explicit format hint.
pub fn validate_code_with_format(code: &str, code_format: CartonCodeFormat) -> Result<bool, NexaTraceError> {
    match code_format {
        CartonCodeFormat::Qr => validate_qr_format_code(code),
        CartonCodeFormat::Itf14 => validate_itf14_code(code),
        CartonCodeFormat::Gs1128 => validate_gs1_128_code(code),
        CartonCodeFormat::Code128Industrial => validate_code128_industrial_code(code),
        CartonCodeFormat::Datamatrix => validate_datamatrix_code(code),
        CartonCodeFormat::Code128Label => validate_code128_label_code(code),
    }
}

/// Parse carton code into components.
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
        components.insert("code_type".to_string(), "carton".to_string());
    } else if code.starts_with("(01)") {
        components.insert("code_format".to_string(), "gs1_128".to_string());
        // Extract GTIN-14 after (01)
        if code.len() >= 18 {
            components.insert("gtin14".to_string(), code[4..18].to_string());
        }
        // Extract batch after (10)
        if let Some(pos) = code.find("(10)") {
            let batch_start = pos + 4;
            let batch_end = code.find("(17)").unwrap_or(code.len());
            components.insert("batch".to_string(), code[batch_start..batch_end].to_string());
        }
        // Extract expiry after (17)
        if let Some(pos) = code.find("(17)") {
            let expiry_start = pos + 4;
            let expiry_end = (expiry_start + 6).min(code.len());
            components.insert("expiry".to_string(), code[expiry_start..expiry_end].to_string());
        }
        components.insert("code_type".to_string(), "carton".to_string());
    } else if code.starts_with("\x1d(01)") {
        components.insert("code_format".to_string(), "datamatrix".to_string());
        if code.len() >= 19 {
            components.insert("gtin14".to_string(), code[5..19].to_string());
        }
        components.insert("code_type".to_string(), "carton".to_string());
    } else {
        let parts: Vec<&str> = code.split('-').collect();
        if parts.len() == 4 {
            // QR (legacy) format: PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH
            components.insert("code_format".to_string(), "qr".to_string());
            components.insert("prefix".to_string(), parts[0].to_string());
            components.insert("sequence".to_string(), parts[1].to_string());
            components.insert("bundle_hash".to_string(), parts[2].to_string());
            components.insert("factory_hash".to_string(), parts[3].to_string());
            components.insert("bundle_hint".to_string(), format!("BUNDLE-{}", &parts[2][0..3]));
            components.insert("factory_hint".to_string(), format!("FACTORY-{}", &parts[3][0..3]));
        } else if parts.len() == 3 {
            // Code 128 Industrial: PREFIX-SEQUENCE-HASH
            components.insert("code_format".to_string(), "code128_industrial".to_string());
            components.insert("prefix".to_string(), parts[0].to_string());
            components.insert("sequence".to_string(), parts[1].to_string());
            components.insert("trace_hash".to_string(), parts[2].to_string());
        } else if parts.len() == 2 {
            // Code 128 Label: PREFIX-SEQUENCE
            components.insert("code_format".to_string(), "code128_label".to_string());
            components.insert("prefix".to_string(), parts[0].to_string());
            components.insert("sequence".to_string(), parts[1].to_string());
        }
        components.insert("code_type".to_string(), "carton".to_string());
    }

    Ok(components)
}

// ---------------------------------------------------------------------------
// Format-specific validators (internal)
// ---------------------------------------------------------------------------

/// Validate QR-format (legacy) carton code: PREFIX-SEQUENCE-BUNDLEHASH-FACTORYHASH
fn validate_qr_format_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 4 {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid QR carton code format. Expected 4 parts, got {}", parts.len()),
        ));
    }

    if !is_valid_prefix(parts[0]) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}", parts[0]),
        ));
    }

    let sequence: u32 = parts[1].parse().map_err(|_| {
        NexaTraceError::ValidationError(format!("Invalid sequence number: {}", parts[1]))
    })?;

    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string(),
        ));
    }

    if parts[2].len() != 6 || !parts[2].chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid bundle hash: {}", parts[2]),
        ));
    }

    if parts[3].len() != 6 || !parts[3].chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid factory hash: {}", parts[3]),
        ));
    }

    Ok(true)
}

/// Validate ITF-14 code: 14-digit numeric with valid check digit.
fn validate_itf14_code(code: &str) -> Result<bool, NexaTraceError> {
    if code.len() != 14 {
        return Err(NexaTraceError::ValidationError(
            format!("ITF-14 code must be 14 digits, got {} characters", code.len()),
        ));
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

/// Validate GS1-128 code: must contain (01)GTIN-14 and optionally (10) and (17).
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

/// Validate Code 128 Industrial code: PREFIX-SEQUENCE-HASH.
fn validate_code128_industrial_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 3 {
        return Err(NexaTraceError::ValidationError(
            format!("Code 128 Industrial code must have 3 parts, got {}", parts.len()),
        ));
    }

    if !is_valid_prefix(parts[0]) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}", parts[0]),
        ));
    }

    // Sequence: 4-digit zero-padded
    if parts[1].len() != 4 || !parts[1].chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid sequence: {}. Must be 4 digits", parts[1]),
        ));
    }

    // Trace hash: 8-char hex
    if parts[2].len() != 8 || !parts[2].chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid trace hash: {}. Must be 8 hex characters", parts[2]),
        ));
    }

    Ok(true)
}

/// Validate DataMatrix code: FNC1 + (01)GTIN-14 + optional AIs.
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

/// Validate Code 128 Label code: PREFIX-SEQUENCE.
fn validate_code128_label_code(code: &str) -> Result<bool, NexaTraceError> {
    let parts: Vec<&str> = code.split('-').collect();
    if parts.len() != 2 {
        return Err(NexaTraceError::ValidationError(
            format!("Code 128 Label code must have 2 parts, got {}", parts.len()),
        ));
    }

    if !is_valid_prefix(parts[0]) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}", parts[0]),
        ));
    }

    // Sequence: 4-digit zero-padded
    if parts[1].len() != 4 || !parts[1].chars().all(|c| c.is_ascii_digit()) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid sequence: {}. Must be 4 digits", parts[1]),
        ));
    }

    Ok(true)
}

// ---------------------------------------------------------------------------
// Shared validation helpers
// ---------------------------------------------------------------------------

/// Validate prefix: 2-3 uppercase ASCII letters.
fn validate_prefix(prefix: &str) -> Result<(), NexaTraceError> {
    if !is_valid_prefix(prefix) {
        return Err(NexaTraceError::ValidationError(
            format!("Invalid prefix: {}. Must be 2-3 uppercase letters", prefix),
        ));
    }
    Ok(())
}

fn is_valid_prefix(prefix: &str) -> bool {
    let len = prefix.len();
    (2..=3).contains(&len) && prefix.chars().all(|c| c.is_ascii_uppercase())
}

/// Validate sequence number (1-999).
fn validate_sequence(sequence: u32) -> Result<(), NexaTraceError> {
    if sequence == 0 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot be zero".to_string(),
        ));
    }
    if sequence > 999 {
        return Err(NexaTraceError::ValidationError(
            "Sequence number cannot exceed 999".to_string(),
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

/// Validate packets per carton.
fn validate_packets_per_carton(packets_per_carton: u32) -> Result<(), NexaTraceError> {
    if packets_per_carton == 0 {
        return Err(NexaTraceError::ValidationError(
            "Packets per carton cannot be zero".to_string(),
        ));
    }
    if packets_per_carton > 50 {
        return Err(NexaTraceError::ValidationError(
            "Cannot have more than 50 packets per carton".to_string(),
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

/// Validate bundle code.
fn validate_bundle_code(bundle_code: &str) -> Result<(), NexaTraceError> {
    if bundle_code.is_empty() {
        return Err(NexaTraceError::ValidationError(
            "Bundle code cannot be empty".to_string(),
        ));
    }
    if !bundle_code.contains('-') {
        return Err(NexaTraceError::ValidationError(
            "Invalid bundle code format".to_string(),
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

/// Generate a random carton code (QR format) for testing/demo.
pub fn generate_random_code() -> String {
    let mut rng = rand::thread_rng();

    let prefix_chars: String = (0..2)
        .map(|_| (b'A' + rng.gen_range(0..26)) as char)
        .collect();

    let sequence = rng.gen_range(1..1000);

    let bundle_hash: String = (0..6)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    let factory_hash: String = (0..6)
        .map(|_| {
            let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            let idx = rng.gen_range(0..chars.len());
            chars.chars().nth(idx).unwrap()
        })
        .collect();

    format!("{}-{:03}-{}-{}", prefix_chars, sequence, bundle_hash, factory_hash)
}

/// Generate a random carton code in the specified format (for testing/demo).
pub fn generate_random_code_with_format(code_format: CartonCodeFormat) -> String {
    let mut rng = rand::thread_rng();

    match code_format {
        CartonCodeFormat::Itf14 => {
            // Generate a valid random ITF-14
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7).map(|_| rng.gen_range(0..10).to_string()).collect();
            let item: String = (0..5).map(|_| rng.gen_range(0..10).to_string()).collect();
            let base_13 = format!("{}{}{}", indicator, company, item);
            let check = compute_gs1_check_digit(&base_13).unwrap();
            format!("{}{}", base_13, check)
        }
        CartonCodeFormat::Gs1128 => {
            // Random GTIN-14 + batch + expiry
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7).map(|_| rng.gen_range(0..10).to_string()).collect();
            let item: String = (0..5).map(|_| rng.gen_range(0..10).to_string()).collect();
            let base_13 = format!("{}{}{}", indicator, company, item);
            let check = compute_gs1_check_digit(&base_13).unwrap();
            let gtin14 = format!("{}{}", base_13, check);
            let batch: u32 = rng.gen_range(1..10000);
            let expiry_year = rng.gen_range(25..30);
            let expiry_month = rng.gen_range(1..13);
            let expiry_day = rng.gen_range(1..29);
            format!(
                "(01){}(10)B{:04}(17){:02}{:02}{:02}",
                gtin14, batch, expiry_year, expiry_month, expiry_day
            )
        }
        CartonCodeFormat::Code128Industrial => {
            let prefix_chars: String = (0..2)
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
            format!("{}-{:04}-{}", prefix_chars, sequence, hash)
        }
        CartonCodeFormat::Qr => generate_random_code(),
        CartonCodeFormat::Datamatrix => {
            let indicator = rng.gen_range(0..10);
            let company: String = (0..7).map(|_| rng.gen_range(0..10).to_string()).collect();
            let item: String = (0..5).map(|_| rng.gen_range(0..10).to_string()).collect();
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
            let prefix_chars: String = (0..2)
                .map(|_| (b'A' + rng.gen_range(0..26)) as char)
                .collect();
            let sequence = rng.gen_range(1..10000);
            format!("{}-{:04}", prefix_chars, sequence)
        }
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    // --- Legacy API tests (backward compatibility) ---

    #[test]
    fn test_generate_single_code() {
        let code = generate_single_code(
            "YY".to_string(),
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        )
        .unwrap();
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
        )
        .unwrap();
        assert_eq!(codes.len(), 5);
        assert!(codes[0].starts_with("ZZ-001-"));
        assert!(codes[4].starts_with("ZZ-005-"));
    }

    #[test]
    fn test_validate_code_legacy() {
        let valid_code = "YY-001-ABC123-DEF456";
        assert!(validate_code(valid_code).unwrap());

        assert!(validate_code("YY-001-ABC123").is_err());
        assert!(validate_code("YY-001-ABC12345-DEF456").is_err());
        assert!(validate_code("yy-001-ABC123-DEF456").is_err());
        assert!(validate_code("Y-001-ABC123-DEF456").is_err());
        assert!(validate_code("YY-000-ABC123-DEF456").is_err());
    }

    #[test]
    fn test_parse_code_legacy() {
        let code = "ZZ-042-ABC123-DEF456";
        let components = parse_code(code).unwrap();

        assert_eq!(components.get("prefix").unwrap(), "ZZ");
        assert_eq!(components.get("sequence").unwrap(), "042");
        assert_eq!(components.get("bundle_hash").unwrap(), "ABC123");
        assert_eq!(components.get("factory_hash").unwrap(), "DEF456");
        assert_eq!(components.get("code_type").unwrap(), "carton");
        assert_eq!(components.get("code_format").unwrap(), "qr");
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
        assert!(!is_valid_prefix("Y"));
        assert!(!is_valid_prefix("YYYY"));
        assert!(!is_valid_prefix("yy"));
        assert!(!is_valid_prefix("Y1"));
    }

    #[test]
    fn test_validate_bundle_code() {
        assert!(validate_bundle_code("A-01-ABCD1234").is_ok());
        assert!(validate_bundle_code("").is_err());
        assert!(validate_bundle_code("NO_DASH").is_err());
    }

    // --- Format enum tests ---

    #[test]
    fn test_carton_code_format_from_str() {
        assert_eq!(CartonCodeFormat::from_str("itf14").unwrap(), CartonCodeFormat::Itf14);
        assert_eq!(CartonCodeFormat::from_str("GS1_128").unwrap(), CartonCodeFormat::Gs1128);
        assert_eq!(
            CartonCodeFormat::from_str("code128_industrial").unwrap(),
            CartonCodeFormat::Code128Industrial
        );
        assert_eq!(CartonCodeFormat::from_str("qr").unwrap(), CartonCodeFormat::Qr);
        assert_eq!(CartonCodeFormat::from_str("datamatrix").unwrap(), CartonCodeFormat::Datamatrix);
        assert_eq!(
            CartonCodeFormat::from_str("code128_label").unwrap(),
            CartonCodeFormat::Code128Label
        );
        assert!(CartonCodeFormat::from_str("unknown").is_err());
    }

    #[test]
    fn test_carton_code_format_as_str() {
        assert_eq!(CartonCodeFormat::Itf14.as_str(), "itf14");
        assert_eq!(CartonCodeFormat::Gs1128.as_str(), "gs1_128");
        assert_eq!(CartonCodeFormat::Code128Industrial.as_str(), "code128_industrial");
        assert_eq!(CartonCodeFormat::Qr.as_str(), "qr");
        assert_eq!(CartonCodeFormat::Datamatrix.as_str(), "datamatrix");
        assert_eq!(CartonCodeFormat::Code128Label.as_str(), "code128_label");
    }

    #[test]
    fn test_all_formats() {
        let formats = CartonCodeFormat::all_formats();
        assert_eq!(formats.len(), 6);
        assert!(formats.contains(&"itf14"));
        assert!(formats.contains(&"qr"));
    }

    // --- ITF-14 tests ---

    #[test]
    fn test_generate_itf14_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Itf14,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(
            &CartonGenerationParams {
                company_prefix: Some("1234567".to_string()),
                ..params
            },
        )
        .unwrap();

        assert_eq!(code.len(), 14);
        assert!(code.chars().all(|c| c.is_ascii_digit()));
        // Verify check digit
        let base_13 = &code[0..13];
        let expected_check = compute_gs1_check_digit(base_13).unwrap();
        assert_eq!(code.chars().nth(13).unwrap(), expected_check);
    }

    #[test]
    fn test_validate_itf14_code() {
        // Generate a valid code and validate it
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Itf14,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..params
        })
        .unwrap();

        assert!(validate_code_with_format(&code, CartonCodeFormat::Itf14).unwrap());
        assert!(validate_code(&code).unwrap());

        // Invalid: wrong length
        assert!(validate_code_with_format("12345", CartonCodeFormat::Itf14).is_err());
    }

    // --- GS1-128 tests ---

    #[test]
    fn test_generate_gs1_128_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Gs1128,
            "YY".to_string(),
            42,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..params
        })
        .unwrap();

        assert!(code.starts_with("(01)"));
        assert!(code.contains("(10)B42"));
        assert!(code.contains("(17)"));
    }

    #[test]
    fn test_validate_gs1_128_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Gs1128,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..params
        })
        .unwrap();

        assert!(validate_code_with_format(&code, CartonCodeFormat::Gs1128).unwrap());
    }

    // --- Code 128 Industrial tests ---

    #[test]
    fn test_generate_code128_industrial_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Industrial,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&params).unwrap();

        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 3);
        assert_eq!(parts[0], "YY");
        assert_eq!(parts[1], "0001");
        assert_eq!(parts[2].len(), 8);
    }

    #[test]
    fn test_validate_code128_industrial() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Industrial,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&params).unwrap();
        assert!(validate_code_with_format(&code, CartonCodeFormat::Code128Industrial).unwrap());
    }

    // --- Code 128 Label tests ---

    #[test]
    fn test_generate_code128_label_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Label,
            "YY".to_string(),
            42,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&params).unwrap();

        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 2);
        assert_eq!(parts[0], "YY");
        assert_eq!(parts[1], "0042");
    }

    #[test]
    fn test_validate_code128_label() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Label,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&params).unwrap();
        assert!(validate_code_with_format(&code, CartonCodeFormat::Code128Label).unwrap());
        assert!(validate_code(&code).unwrap());
    }

    // --- DataMatrix tests ---

    #[test]
    fn test_generate_datamatrix_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Datamatrix,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..params
        })
        .unwrap();

        assert!(code.starts_with("\x1d(01)"));
        assert!(code.contains("(11)"));
        assert!(code.contains("(21)"));
    }

    #[test]
    fn test_validate_datamatrix_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Datamatrix,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..params
        })
        .unwrap();

        assert!(validate_code_with_format(&code, CartonCodeFormat::Datamatrix).unwrap());
    }

    // --- Batch generation with format ---

    #[test]
    fn test_generate_batch_with_format_itf14() {
        let params = CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..CartonGenerationParams::new(
                CartonCodeFormat::Itf14,
                "YY".to_string(),
                1,
                5,
                "A-01-ABCD1234".to_string(),
                "factory_123".to_string(),
            )
        };
        let codes = generate_batch_with_format(&params).unwrap();
        assert_eq!(codes.len(), 5);
        for code in &codes {
            assert_eq!(code.len(), 14);
            assert!(code.chars().all(|c| c.is_ascii_digit()));
        }
    }

    #[test]
    fn test_generate_batch_with_format_label() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Label,
            "ZZ".to_string(),
            1,
            3,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let codes = generate_batch_with_format(&params).unwrap();
        assert_eq!(codes.len(), 3);
        assert!(codes[0].contains("ZZ-0001"));
        assert!(codes[2].contains("ZZ-0003"));
    }

    // --- Hierarchy with format ---

    #[test]
    fn test_generate_with_hierarchy_and_format() {
        let params = CartonGenerationParams {
            packets_per_carton: Some(4),
            units_per_packet: Some(12),
            packet_prefix: Some("YBZ".to_string()),
            ..CartonGenerationParams::new(
                CartonCodeFormat::Qr,
                "YY".to_string(),
                1,
                2,
                "A-01-ABCD1234".to_string(),
                "factory_123".to_string(),
            )
        };

        let cartons = generate_with_hierarchy_and_format(&params).unwrap();
        assert_eq!(cartons.len(), 2);
        assert_eq!(cartons[0].total_packets, 4);
        assert_eq!(cartons[0].total_units, 48); // 4 * 12
        assert_eq!(cartons[0].packet_codes.len(), 4);
    }

    #[test]
    fn test_generate_with_hierarchy_no_packets() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Label,
            "YY".to_string(),
            1,
            2,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );

        let cartons = generate_with_hierarchy_and_format(&params).unwrap();
        assert_eq!(cartons.len(), 2);
        assert_eq!(cartons[0].total_packets, 0);
        assert_eq!(cartons[0].total_units, 0);
        assert!(cartons[0].packet_codes.is_empty());
    }

    // --- GS1 check digit tests ---

    #[test]
    fn test_gs1_check_digit() {
        // Known test vectors for GS1 check digit
        // GTIN-14: 1 0614141 23456 ?
        let base = "1061414123456";
        let check = compute_gs1_check_digit(base).unwrap();
        assert_eq!(check, '8');
    }

    // --- Random code with format tests ---

    #[test]
    fn test_generate_random_code_with_format() {
        let code = generate_random_code_with_format(CartonCodeFormat::Itf14);
        assert_eq!(code.len(), 14);

        let code = generate_random_code_with_format(CartonCodeFormat::Code128Label);
        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 2);

        let code = generate_random_code_with_format(CartonCodeFormat::Qr);
        let parts: Vec<&str> = code.split('-').collect();
        assert_eq!(parts.len(), 4);
    }

    // --- Parse code with format detection ---

    #[test]
    fn test_parse_itf14_code() {
        let params = CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..CartonGenerationParams::new(
                CartonCodeFormat::Itf14,
                "YY".to_string(),
                1,
                1,
                "A-01-ABCD1234".to_string(),
                "factory_123".to_string(),
            )
        };
        let code = generate_single_code_with_format(&params).unwrap();
        let components = parse_code(&code).unwrap();

        assert_eq!(components.get("code_format").unwrap(), "itf14");
        assert!(components.contains_key("indicator"));
        assert!(components.contains_key("company_prefix"));
        assert!(components.contains_key("item_reference"));
        assert!(components.contains_key("check_digit"));
    }

    #[test]
    fn test_parse_label_code() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Code128Label,
            "YY".to_string(),
            42,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        let code = generate_single_code_with_format(&params).unwrap();
        let components = parse_code(&code).unwrap();

        assert_eq!(components.get("code_format").unwrap(), "code128_label");
        assert_eq!(components.get("prefix").unwrap(), "YY");
        assert_eq!(components.get("sequence").unwrap(), "0042");
    }

    // --- Params validation ---

    #[test]
    fn test_params_validation_requires_company_prefix_for_itf14() {
        let params = CartonGenerationParams::new(
            CartonCodeFormat::Itf14,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        assert!(params.validate().is_err());
    }

    #[test]
    fn test_params_validation_ok_with_company_prefix() {
        let params = CartonGenerationParams {
            company_prefix: Some("1234567".to_string()),
            ..CartonGenerationParams::new(
                CartonCodeFormat::Itf14,
                "YY".to_string(),
                1,
                1,
                "A-01-ABCD1234".to_string(),
                "factory_123".to_string(),
            )
        };
        assert!(params.validate().is_ok());
    }

    #[test]
    fn test_params_validation_units_per_packet() {
        let mut params = CartonGenerationParams::new(
            CartonCodeFormat::Qr,
            "YY".to_string(),
            1,
            1,
            "A-01-ABCD1234".to_string(),
            "factory_123".to_string(),
        );
        params.units_per_packet = Some(0);
        assert!(params.validate().is_err());

        params.units_per_packet = Some(101);
        assert!(params.validate().is_err());

        params.units_per_packet = Some(24);
        assert!(params.validate().is_ok());
    }
}
