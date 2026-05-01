//! Algorithms Module
//! Provides cryptographic and mathematical algorithms for NexaTrace System
//!
//! This module includes:
//! - Authentication code generation and verification
//! - Checksum calculation and validation
//! - Encryption and decryption
//! - Key derivation and management
//! - Data integrity verification

pub mod authentication;
pub mod checksum;
pub mod encryption;

// Re-export public API
pub use authentication::{
    AuthCodeConfig, AuthCodeType, generate_secure_code, generate_code_with_config,
    verify_code, generate_totp, generate_hotp, generate_secure_token,
    hash_code, verify_hash, generate_code_with_expiry, verify_code_with_expiry,
    generate_batch_codes,
};

pub use checksum::{
    ChecksumAlgorithm, ChecksumConfig, ChecksumPosition, calculate, calculate_with_config,
    verify, calculate_isbn13, calculate_ean13, calculate_upca,
    validate_with_checksum, strip_checksum,
};

pub use encryption::{
    EncryptionAlgorithm, KeyDerivationAlgorithm, EncryptionConfig,
    encrypt, encrypt_with_config, decrypt, decrypt_with_config,
    generate_key, generate_key_from_password, hash_data, verify_integrity,
    generate_mac, verify_mac,
};

/// Algorithm utilities and helpers
pub mod utils {
    use rand::{Rng, rngs::ThreadRng};

    /// Generate random number within range
    pub fn random_range(min: u32, max: u32) -> u32 {
        let mut rng = rand::thread_rng();
        rng.gen_range(min..=max)
    }

    /// Generate random string with specified length and character set
    pub fn random_string(length: usize, charset: &str) -> String {
        let mut rng = rand::thread_rng();
        let charset_bytes = charset.as_bytes();
        let charset_len = charset_bytes.len();

        (0..length)
            .map(|_| {
                let idx = rng.gen_range(0..charset_len);
                charset_bytes[idx] as char
            })
            .collect()
    }

    /// Calculate simple hash for quick comparisons
    pub fn simple_hash(data: &str) -> u32 {
        let mut hash: u32 = 0;
        for byte in data.bytes() {
            hash = hash.wrapping_mul(31).wrapping_add(byte as u32);
        }
        hash
    }

    /// Normalize string for comparison
    pub fn normalize_string(s: &str) -> String {
        s.trim().to_lowercase()
    }

    /// Check if string contains only allowed characters
    pub fn contains_only(s: &str, allowed_chars: &str) -> bool {
        s.chars().all(|c| allowed_chars.contains(c))
    }

    /// Validate string length
    pub fn validate_length(s: &str, min: usize, max: usize) -> bool {
        let len = s.len();
        len >= min && len <= max
    }

    /// Generate sequential ID with prefix
    pub fn generate_sequential_id(prefix: &str, sequence: u32, padding: usize) -> String {
        format!("{}{:0width$}", prefix, sequence, width = padding)
    }

    /// Parse sequential ID
    pub fn parse_sequential_id(id: &str, prefix: &str) -> Option<u32> {
        if id.starts_with(prefix) {
            let number_part = &id[prefix.len()..];
            number_part.parse::<u32>().ok()
        } else {
            None
        }
    }
}

/// Algorithm errors
#[derive(Debug, thiserror::Error)]
pub enum AlgorithmError {
    #[error("Invalid input: {0}")]
    InvalidInput(String),

    #[error("Encryption error: {0}")]
    EncryptionError(String),

    #[error("Decryption error: {0}")]
    DecryptionError(String),

    #[error("Hash error: {0}")]
    HashError(String),

    #[error("Checksum error: {0}")]
    ChecksumError(String),

    #[error("Authentication error: {0}")]
    AuthenticationError(String),

    #[error("Key derivation error: {0}")]
    KeyDerivationError(String),

    #[error("Random generation error: {0}")]
    RandomGenerationError(String),
}

/// Result type for algorithm operations
pub type AlgorithmResult<T> = std::result::Result<T, AlgorithmError>;

/// Algorithm configuration
#[derive(Debug, Clone)]
pub struct AlgorithmConfig {
    /// Default authentication code length
    pub default_auth_code_length: u32,
    /// Default encryption key length
    pub default_key_length: usize,
    /// Default checksum algorithm
    pub default_checksum_algorithm: ChecksumAlgorithm,
    /// Default encryption algorithm
    pub default_encryption_algorithm: EncryptionAlgorithm,
    /// Enable strong cryptography
    pub enable_strong_crypto: bool,
    /// Enable logging
    pub enable_logging: bool,
}

impl Default for AlgorithmConfig {
    fn default() -> Self {
        Self {
            default_auth_code_length: 12,
            default_key_length: 32,
            default_checksum_algorithm: ChecksumAlgorithm::Luhn,
            default_encryption_algorithm: EncryptionAlgorithm::Aes256Gcm,
            enable_strong_crypto: true,
            enable_logging: false,
        }
    }
}

/// Algorithm manager
pub struct AlgorithmManager {
    config: AlgorithmConfig,
}

impl AlgorithmManager {
    /// Create new algorithm manager with default configuration
    pub fn new() -> Self {
        Self {
            config: AlgorithmConfig::default(),
        }
    }

    /// Create new algorithm manager with custom configuration
    pub fn with_config(config: AlgorithmConfig) -> Self {
        Self { config }
    }

    /// Get configuration
    pub fn config(&self) -> &AlgorithmConfig {
        &self.config
    }

    /// Generate authentication code with default settings
    pub fn generate_auth_code(&self) -> AlgorithmResult<String> {
        generate_secure_code(self.config.default_auth_code_length)
            .map_err(|e| AlgorithmError::AuthenticationError(e))
    }

    /// Calculate checksum with default algorithm
    pub fn calculate_checksum(&self, code: &str) -> AlgorithmResult<String> {
        let config = checksum::ChecksumConfig {
            algorithm: self.config.default_checksum_algorithm,
            ..Default::default()
        };
        calculate_with_config(code, &config)
            .map_err(|e| AlgorithmError::ChecksumError(e))
    }

    /// Encrypt data with default algorithm
    pub fn encrypt_data(&self, data: &str, key: &str) -> AlgorithmResult<String> {
        let config = encryption::EncryptionConfig {
            algorithm: self.config.default_encryption_algorithm,
            ..Default::default()
        };
        encrypt_with_config(data, key, &config)
            .map_err(|e| AlgorithmError::EncryptionError(e))
    }

    /// Decrypt data with default algorithm
    pub fn decrypt_data(&self, encrypted_data: &str, key: &str) -> AlgorithmResult<String> {
        let config = encryption::EncryptionConfig {
            algorithm: self.config.default_encryption_algorithm,
            ..Default::default()
        };
        decrypt_with_config(encrypted_data, key, &config)
            .map_err(|e| AlgorithmError::DecryptionError(e))
    }

    /// Generate secure key
    pub fn generate_key(&self) -> AlgorithmResult<Vec<u8>> {
        generate_key(self.config.default_key_length)
            .map_err(|e| AlgorithmError::RandomGenerationError(e))
    }

    /// Hash data with SHA-256
    pub fn hash_data(&self, data: &[u8]) -> AlgorithmResult<String> {
        hash_data(data, "sha256")
            .map_err(|e| AlgorithmError::HashError(e))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_algorithm_manager() {
        let manager = AlgorithmManager::new();

        // Test authentication code generation
        let auth_code = manager.generate_auth_code().unwrap();
        assert!(!auth_code.is_empty());

        // Test checksum calculation
        let checksum = manager.calculate_checksum("123456789").unwrap();
        assert!(!checksum.is_empty());

        // Test hashing
        let hash = manager.hash_data(b"test data").unwrap();
        assert!(!hash.is_empty());
    }

    #[test]
    fn test_utils() {
        // Test random range
        let num = utils::random_range(1, 100);
        assert!(num >= 1 && num <= 100);

        // Test random string
        let random_str = utils::random_string(10, "ABC123");
        assert_eq!(random_str.len(), 10);

        // Test simple hash
        let hash = utils::simple_hash("test");
        assert_ne!(hash, 0);

        // Test normalize string
        let normalized = utils::normalize_string("  TEST  ");
        assert_eq!(normalized, "test");

        // Test contains only
        assert!(utils::contains_only("ABC123", "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"));
        assert!(!utils::contains_only("ABC!123", "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"));

        // Test validate length
        assert!(utils::validate_length("test", 1, 10));
        assert!(!utils::validate_length("", 1, 10));
        assert!(!utils::validate_length("testtesttest", 1, 10));

        // Test generate sequential ID
        let id = utils::generate_sequential_id("ID", 123, 6);
        assert_eq!(id, "ID000123");

        // Test parse sequential ID
        let parsed = utils::parse_sequential_id("ID000123", "ID");
        assert_eq!(parsed, Some(123));
        let parsed_invalid = utils::parse_sequential_id("WRONG000123", "ID");
        assert_eq!(parsed_invalid, None);
    }
}
