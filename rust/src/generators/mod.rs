//! Code Generators Module
//!
//! This module provides code generation functionality for all code types:
//! - Bundle codes (highest level)
//! - Carton codes
//! - Packet codes
//! - Unit codes (authentication codes, lowest level)
//! - Hierarchical code generation
//!
//! Each generator follows the same pattern:
//! 1. Input validation
//! 2. Code generation with proper formatting
//! 3. Hash generation for hierarchy tracking
//! 4. Optional international standards integration

pub mod bundle;
pub mod carton;
pub mod packet;
pub mod unit;
pub mod hierarchical;

// Re-export public functions
pub use bundle::{
    generate_single_code as generate_bundle_code,
    generate_batch as generate_bundle_batch,
    generate_with_hierarchy as generate_bundle_with_hierarchy,
    generate_with_international as generate_bundle_with_international,
    validate_code as validate_bundle_code,
    parse_code as parse_bundle_code,
    generate_random_code as generate_random_bundle_code,
};

pub use carton::{
    generate_single_code as generate_carton_code,
    generate_batch as generate_carton_batch,
    generate_with_hierarchy as generate_carton_with_hierarchy,
    generate_with_international as generate_carton_with_international,
    validate_code as validate_carton_code,
    parse_code as parse_carton_code,
    generate_random_code as generate_random_carton_code,
    // Format-aware API
    CartonCodeFormat,
    CartonGenerationParams,
    generate_single_code_with_format as generate_carton_code_with_format,
    generate_batch_with_format as generate_carton_batch_with_format,
    generate_with_hierarchy_and_format as generate_carton_with_hierarchy_and_format,
    validate_code_with_format as validate_carton_code_with_format,
    generate_random_code_with_format as generate_random_carton_code_with_format,
};

pub use packet::{
    generate_single_code as generate_packet_code,
    generate_batch as generate_packet_batch,
    generate_with_hierarchy as generate_packet_with_hierarchy,
    generate_with_international as generate_packet_with_international,
    validate_code as validate_packet_code,
    parse_code as parse_packet_code,
    generate_random_code as generate_random_packet_code,
    // Format-aware API
    PacketGenerationParams,
    generate_single_code_with_format as generate_packet_code_with_format,
    generate_batch_with_format as generate_packet_batch_with_format,
    generate_with_hierarchy_and_format as generate_packet_with_hierarchy_and_format,
    validate_code_with_format as validate_packet_code_with_format,
    generate_random_code_with_format as generate_random_packet_code_with_format,
};

pub use unit::{
    generate_single_code as generate_unit_code,
    generate_batch as generate_unit_batch,
    generate_with_authentication as generate_unit_with_authentication,
    generate_with_master_codes as generate_unit_with_master_codes,
    generate_with_international as generate_unit_with_international,
    validate_code as validate_unit_code,
    parse_code as parse_unit_code,
    generate_random_code as generate_random_unit_code,
};

pub use hierarchical::{
    generate_hierarchical,
    generate_hierarchical_with_international,
    validate_hierarchical_config,
    calculate_hierarchy_totals,
};

/// Code generation configuration
#[derive(Debug, Clone)]
pub struct GenerationConfig {
    /// Factory ID
    pub factory_id: String,
    /// Include international standards
    pub include_international: bool,
    /// Generate QR codes
    pub generate_qr: bool,
    /// Generate barcodes
    pub generate_barcode: bool,
    /// Batch size for parallel processing
    pub batch_size: u32,
    /// Enable validation
    pub enable_validation: bool,
    /// Enable logging
    pub enable_logging: bool,
}

impl Default for GenerationConfig {
    fn default() -> Self {
        Self {
            factory_id: String::new(),
            include_international: true,
            generate_qr: true,
            generate_barcode: true,
            batch_size: 1000,
            enable_validation: true,
            enable_logging: false,
        }
    }
}

/// Code generation statistics
#[derive(Debug, Clone)]
pub struct GenerationStats {
    /// Total codes generated
    pub total_codes: u32,
    /// Generation time in milliseconds
    pub generation_time_ms: u64,
    /// Codes per second
    pub codes_per_second: f64,
    /// Memory usage in bytes
    pub memory_usage_bytes: u64,
    /// Validation errors
    pub validation_errors: Vec<String>,
    /// Generation errors
    pub generation_errors: Vec<String>,
}

impl GenerationStats {
    /// Create new statistics
    pub fn new() -> Self {
        Self {
            total_codes: 0,
            generation_time_ms: 0,
            codes_per_second: 0.0,
            memory_usage_bytes: 0,
            validation_errors: Vec::new(),
            generation_errors: Vec::new(),
        }
    }

    /// Calculate codes per second
    pub fn calculate_codes_per_second(&mut self) {
        if self.generation_time_ms > 0 {
            self.codes_per_second = (self.total_codes as f64) / (self.generation_time_ms as f64 / 1000.0);
        }
    }

    /// Check if generation was successful
    pub fn is_successful(&self) -> bool {
        self.validation_errors.is_empty() && self.generation_errors.is_empty()
    }

    /// Get error count
    pub fn error_count(&self) -> usize {
        self.validation_errors.len() + self.generation_errors.len()
    }
}

/// Code type for generation
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CodeType {
    Bundle,
    Carton,
    Packet,
    Unit,
}

impl CodeType {
    /// Get display name
    pub fn display_name(&self) -> &'static str {
        match self {
            CodeType::Bundle => "Bundle",
            CodeType::Carton => "Carton",
            CodeType::Packet => "Packet",
            CodeType::Unit => "Unit",
        }
    }

    /// Get default prefix
    pub fn default_prefix(&self) -> &'static str {
        match self {
            CodeType::Bundle => "A",
            CodeType::Carton => "YY",
            CodeType::Packet => "YBZ",
            CodeType::Unit => "TSFG",
        }
    }

    /// Get sequence digits
    pub fn sequence_digits(&self) -> u8 {
        match self {
            CodeType::Bundle => 2,
            CodeType::Carton => 3,
            CodeType::Packet => 4,
            CodeType::Unit => 5,
        }
    }

    /// Get maximum sequence
    pub fn max_sequence(&self) -> u32 {
        match self {
            CodeType::Bundle => 99,
            CodeType::Carton => 999,
            CodeType::Packet => 9999,
            CodeType::Unit => 99999,
        }
    }

    /// Get maximum batch size
    pub fn max_batch_size(&self) -> u32 {
        match self {
            CodeType::Bundle => 10000,
            CodeType::Carton => 1000,
            CodeType::Packet => 10000,
            CodeType::Unit => 100000,
        }
    }
}

/// Batch generation request
#[derive(Debug, Clone)]
pub struct BatchRequest {
    /// Code type
    pub code_type: CodeType,
    /// Prefix
    pub prefix: String,
    /// Start sequence
    pub start_sequence: u32,
    /// Count
    pub count: u32,
    /// Parent code (for carton, packet, unit)
    pub parent_code: Option<String>,
    /// Configuration
    pub config: GenerationConfig,
}

impl BatchRequest {
    /// Create new batch request
    pub fn new(
        code_type: CodeType,
        prefix: String,
        start_sequence: u32,
        count: u32,
        parent_code: Option<String>,
        config: GenerationConfig,
    ) -> Self {
        Self {
            code_type,
            prefix,
            start_sequence,
            count,
            parent_code,
            config,
        }
    }

    /// Validate the request
    pub fn validate(&self) -> Result<(), Vec<String>> {
        let mut errors = Vec::new();

        // Validate prefix
        if self.prefix.is_empty() {
            errors.push("Prefix cannot be empty".to_string());
        }

        // Validate start sequence
        if self.start_sequence == 0 {
            errors.push("Start sequence cannot be zero".to_string());
        }

        if self.start_sequence > self.code_type.max_sequence() {
            errors.push(format!(
                "Start sequence cannot exceed {} for {} codes",
                self.code_type.max_sequence(),
                self.code_type.display_name()
            ));
        }

        // Validate count
        if self.count == 0 {
            errors.push("Count cannot be zero".to_string());
        }

        if self.count > self.code_type.max_batch_size() {
            errors.push(format!(
                "Cannot generate more than {} {} codes at once",
                self.code_type.max_batch_size(),
                self.code_type.display_name()
            ));
        }

        // Check if sequence will exceed maximum
        let max_possible_sequence = self.start_sequence + self.count - 1;
        if max_possible_sequence > self.code_type.max_sequence() {
            errors.push(format!(
                "Sequence will exceed maximum of {} for {} codes",
                self.code_type.max_sequence(),
                self.code_type.display_name()
            ));
        }

        // Validate parent code for non-bundle codes
        match self.code_type {
            CodeType::Bundle => {
                // No parent required
            }
            CodeType::Carton | CodeType::Packet | CodeType::Unit => {
                if self.parent_code.is_none() {
                    errors.push(format!(
                        "Parent code is required for {} codes",
                        self.code_type.display_name()
                    ));
                }
            }
        }

        if errors.is_empty() {
            Ok(())
        } else {
            Err(errors)
        }
    }
}

/// Batch generation result
#[derive(Debug, Clone)]
pub struct BatchResult {
    /// Generated codes
    pub codes: Vec<String>,
    /// Statistics
    pub stats: GenerationStats,
    /// Batch ID
    pub batch_id: String,
    /// Warnings
    pub warnings: Vec<String>,
}

impl BatchResult {
    /// Create new batch result
    pub fn new(codes: Vec<String>, stats: GenerationStats, batch_id: String) -> Self {
        Self {
            codes,
            stats,
            batch_id,
            warnings: Vec::new(),
        }
    }

    /// Check if generation was successful
    pub fn is_successful(&self) -> bool {
        self.stats.is_successful()
    }

    /// Get total codes generated
    pub fn total_codes(&self) -> u32 {
        self.codes.len() as u32
    }

    /// Add warning
    pub fn add_warning(&mut self, warning: String) {
        self.warnings.push(warning);
    }
}
