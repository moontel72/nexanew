//! Data models for NexaTrace Rust module

use serde::{Deserialize, Serialize};

/// Module information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleInfo {
    pub name: String,
    pub version: String,
    pub description: String,
    pub capabilities: Vec<String>,
}

/// Code generation request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodeGenerationRequest {
    pub prefix: String,
    pub start_sequence: u32,
    pub count: u32,
    pub factory_id: String,
    pub include_international: bool,
    pub generate_qr: bool,
    pub generate_barcode: bool,
}

/// Code generation response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodeGenerationResponse {
    pub success: bool,
    pub batch_id: String,
    pub codes_generated: u32,
    pub generated_codes: Vec<String>,
    pub qr_codes: Option<Vec<String>>,
    pub barcodes: Option<Vec<String>>,
    pub international_codes: Option<Vec<String>>,
    pub error: Option<String>,
}

/// Hierarchical codes structure
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HierarchicalCodes {
    pub bundles: Vec<BundleCode>,
    pub cartons: Vec<CartonCode>,
    pub packets: Vec<PacketCode>,
    pub units: Vec<UnitCode>,
    pub total_codes: u32,
    pub hierarchy_summary: HierarchySummary,
}

/// Bundle code with hierarchy
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BundleCode {
    pub code: String,
    pub sequence: u32,
    pub carton_codes: Vec<String>,
    pub total_cartons: u32,
    pub total_packets: u32,
    pub total_units: u32,
}

/// Carton code with hierarchy
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CartonCode {
    pub code: String,
    pub sequence: u32,
    pub bundle_code: String,
    pub packet_codes: Vec<String>,
    pub total_packets: u32,
    pub total_units: u32,
}

/// Packet code with hierarchy
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PacketCode {
    pub code: String,
    pub sequence: u32,
    pub carton_code: String,
    pub unit_codes: Vec<String>,
    pub total_units: u32,
}

/// Unit (authentication) code
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UnitCode {
    pub code: String,
    pub sequence: u32,
    pub packet_code: String,
    pub authentication_code: String,
    pub serial_number: String,
}

/// Hierarchy summary
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HierarchySummary {
    pub bundle_count: u32,
    pub cartons_per_bundle: u32,
    pub packets_per_carton: u32,
    pub units_per_packet: u32,
    pub total_bundles: u32,
    pub total_cartons: u32,
    pub total_packets: u32,
    pub total_units: u32,
}

/// GS1 code components
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Gs1Components {
    pub company_prefix: String,
    pub item_reference: String,
    pub serial_number: String,
    pub check_digit: char,
    pub full_code: String,
}

/// QR code data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct QrCodeData {
    pub code: String,
    pub qr_data: String,
    pub qr_version: u8,
    pub error_correction_level: String,
}

/// Barcode data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BarcodeData {
    pub code: String,
    pub barcode_data: String,
    pub barcode_type: String,
    pub checksum: Option<String>,
}

/// Authentication code
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthenticationCode {
    pub code: String,
    pub hash: String,
    pub salt: String,
    pub created_at: i64,
    pub expires_at: Option<i64>,
}

/// Batch processing statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BatchStatistics {
    pub total_codes: u32,
    pub processing_time_ms: u64,
    pub codes_per_second: f64,
    pub memory_usage_mb: f64,
    pub success_rate: f64,
    pub errors: Vec<String>,
}

/// Code validation result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValidationResult {
    pub is_valid: bool,
    pub code: String,
    pub code_type: String,
    pub errors: Vec<String>,
    pub warnings: Vec<String>,
    pub suggestions: Vec<String>,
}

/// Factory information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FactoryInfo {
    pub id: String,
    pub name: String,
    pub subscription_plan: String,
    pub code_prefixes: Vec<String>,
    pub monthly_limit: Option<u32>,
    pub monthly_usage: u32,
    pub remaining_codes: u32,
}

/// Subscription plan
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubscriptionPlan {
    pub id: String,
    pub name: String,
    pub description: String,
    pub monthly_limit: u32,
    pub features: Vec<String>,
    pub price_per_thousand_codes: f64,
    pub supports_international_codes: bool,
    pub supports_qr_codes: bool,
    pub supports_barcodes: bool,
    pub supports_batch_processing: bool,
}

/// Error types
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum NexaTraceError {
    GenerationError(String),
    ValidationError(String),
    EncryptionError(String),
    DecryptionError(String),
    InvalidInput(String),
    LimitExceeded(String),
    NetworkError(String),
    DatabaseError(String),
    UnknownError(String),
}

impl std::fmt::Display for NexaTraceError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            NexaTraceError::GenerationError(msg) => write!(f, "Generation Error: {}", msg),
            NexaTraceError::ValidationError(msg) => write!(f, "Validation Error: {}", msg),
            NexaTraceError::EncryptionError(msg) => write!(f, "Encryption Error: {}", msg),
            NexaTraceError::DecryptionError(msg) => write!(f, "Decryption Error: {}", msg),
            NexaTraceError::InvalidInput(msg) => write!(f, "Invalid Input: {}", msg),
            NexaTraceError::LimitExceeded(msg) => write!(f, "Limit Exceeded: {}", msg),
            NexaTraceError::NetworkError(msg) => write!(f, "Network Error: {}", msg),
            NexaTraceError::DatabaseError(msg) => write!(f, "Database Error: {}", msg),
            NexaTraceError::UnknownError(msg) => write!(f, "Unknown Error: {}", msg),
        }
    }
}

impl std::error::Error for NexaTraceError {}

/// Code type enum
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum CodeType {
    Bundle,
    Carton,
    Packet,
    Unit,
}

impl CodeType {
    pub fn as_str(&self) -> &'static str {
        match self {
            CodeType::Bundle => "bundle",
            CodeType::Carton => "carton",
            CodeType::Packet => "packet",
            CodeType::Unit => "unit",
        }
    }

    pub fn from_str(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "bundle" => Some(CodeType::Bundle),
            "carton" => Some(CodeType::Carton),
            "packet" => Some(CodeType::Packet),
            "unit" => Some(CodeType::Unit),
            _ => None,
        }
    }
}

/// Code status enum
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq)]
pub enum CodeStatus {
    Generated,
    Linked,
    Published,
    Deactivated,
    Expired,
}

impl CodeStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            CodeStatus::Generated => "generated",
            CodeStatus::Linked => "linked",
            CodeStatus::Published => "published",
            CodeStatus::Deactivated => "deactivated",
            CodeStatus::Expired => "expired",
        }
    }
}

/// Code format configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodeFormatConfig {
    pub prefix: String,
    pub sequence_digits: u8,
    pub separator: char,
    pub include_checksum: bool,
    pub checksum_position: ChecksumPosition,
    pub case_sensitive: bool,
    pub allowed_characters: String,
}

/// Checksum position
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum ChecksumPosition {
    Prefix,
    Suffix,
    None,
}

/// International standard type
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum InternationalStandard {
    Gs1,
    Isbn,
    Upc,
    Ean,
    Other(String),
}

impl InternationalStandard {
    pub fn as_str(&self) -> String {
        match self {
            InternationalStandard::Gs1 => "GS1".to_string(),
            InternationalStandard::Isbn => "ISBN".to_string(),
            InternationalStandard::Upc => "UPC".to_string(),
            InternationalStandard::Ean => "EAN".to_string(),
            InternationalStandard::Other(name) => name.clone(),
        }
    }
}

/// Security configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SecurityConfig {
    pub encryption_key: String,
    pub hash_algorithm: HashAlgorithm,
    pub salt_length: usize,
    pub iteration_count: u32,
    pub key_length: usize,
}

/// Hash algorithm
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum HashAlgorithm {
    Sha256,
    Sha512,
    Blake3,
    Argon2,
}

impl HashAlgorithm {
    pub fn as_str(&self) -> &'static str {
        match self {
            HashAlgorithm::Sha256 => "SHA-256",
            HashAlgorithm::Sha512 => "SHA-512",
            HashAlgorithm::Blake3 => "BLAKE3",
            HashAlgorithm::Argon2 => "Argon2",
        }
    }
}

/// Performance configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PerformanceConfig {
    pub batch_size: u32,
    pub thread_count: usize,
    pub memory_limit_mb: u64,
    pub timeout_seconds: u64,
    pub retry_count: u32,
    pub retry_delay_ms: u64,
}

/// Export format
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum ExportFormat {
    Csv,
    Json,
    Xml,
    Pdf,
    Excel,
}

impl ExportFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            ExportFormat::Csv => "csv",
            ExportFormat::Json => "json",
            ExportFormat::Xml => "xml",
            ExportFormat::Pdf => "pdf",
            ExportFormat::Excel => "excel",
        }
    }

    pub fn file_extension(&self) -> &'static str {
        match self {
            ExportFormat::Csv => ".csv",
            ExportFormat::Json => ".json",
            ExportFormat::Xml => ".xml",
            ExportFormat::Pdf => ".pdf",
            ExportFormat::Excel => ".xlsx",
        }
    }
}
