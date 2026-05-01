//! Authentication Algorithms Module
//! Provides secure authentication code generation and verification
//!
//! This module includes:
//! - Secure random code generation
//! - Authentication code verification
//! - Code format validation
//! - Cryptographic security features

use rand::{Rng, rngs::ThreadRng};
use sha2::{Sha256, Digest};
use hmac::{Hmac, Mac};
use base64::{Engine as _, engine::general_purpose::STANDARD as BASE64};
use std::time::{SystemTime, UNIX_EPOCH};

/// Character sets for authentication codes
const ALPHANUMERIC: &str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
const NUMERIC: &str = "0123456789";
const ALPHANUMERIC_UPPER: &str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
const ALPHANUMERIC_LOWER: &str = "abcdefghijklmnopqrstuvwxyz0123456789";

/// Authentication code types
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum AuthCodeType {
    /// Alphanumeric codes (mixed case)
    Alphanumeric,
    /// Numeric only codes
    Numeric,
    /// Uppercase alphanumeric codes
    UppercaseAlphanumeric,
    /// Lowercase alphanumeric codes
    LowercaseAlphanumeric,
}

/// Authentication code configuration
#[derive(Debug, Clone)]
pub struct AuthCodeConfig {
    /// Type of authentication code
    pub code_type: AuthCodeType,
    /// Length of the code
    pub length: u32,
    /// Include timestamp in generation
    pub include_timestamp: bool,
    /// Include checksum digit
    pub include_checksum: bool,
    /// Custom character set (overrides code_type if provided)
    pub custom_charset: Option<String>,
}

impl Default for AuthCodeConfig {
    fn default() -> Self {
        Self {
            code_type: AuthCodeType::Alphanumeric,
            length: 12,
            include_timestamp: true,
            include_checksum: true,
            custom_charset: None,
        }
    }
}

/// Generate a secure authentication code
pub fn generate_secure_code(length: u32) -> Result<String, String> {
    let config = AuthCodeConfig {
        length,
        ..Default::default()
    };
    generate_code_with_config(&config)
}

/// Generate authentication code with configuration
pub fn generate_code_with_config(config: &AuthCodeConfig) -> Result<String, String> {
    if config.length == 0 {
        return Err("Code length must be greater than 0".to_string());
    }

    if config.length > 100 {
        return Err("Code length cannot exceed 100 characters".to_string());
    }

    // Get character set based on configuration
    let charset = match &config.custom_charset {
        Some(custom) => custom,
        None => match config.code_type {
            AuthCodeType::Alphanumeric => ALPHANUMERIC,
            AuthCodeType::Numeric => NUMERIC,
            AuthCodeType::UppercaseAlphanumeric => ALPHANUMERIC_UPPER,
            AuthCodeType::LowercaseAlphanumeric => ALPHANUMERIC_LOWER,
        },
    };

    if charset.is_empty() {
        return Err("Character set cannot be empty".to_string());
    }

    let charset_bytes = charset.as_bytes();
    let charset_len = charset_bytes.len();

    if charset_len == 0 {
        return Err("Character set length cannot be 0".to_string());
    }

    let mut rng = rand::thread_rng();
    let mut code = String::with_capacity(config.length as usize);

    // Generate random characters
    for _ in 0..config.length {
        let idx = rng.gen_range(0..charset_len);
        code.push(charset_bytes[idx] as char);
    }

    // Add timestamp if requested
    if config.include_timestamp {
        let timestamp = get_current_timestamp();
        let timestamp_str = format!("{:x}", timestamp);
        code.push_str(&timestamp_str[..std::cmp::min(8, timestamp_str.len())]);
    }

    // Add checksum if requested
    if config.include_checksum {
        let checksum = calculate_checksum(&code);
        code.push(checksum);
    }

    Ok(code)
}

/// Verify an authentication code
pub fn verify_code(code: &str, expected_length: u32) -> Result<bool, String> {
    if code.is_empty() {
        return Err("Code cannot be empty".to_string());
    }

    if code.len() != expected_length as usize {
        return Err(format!(
            "Code length mismatch: expected {}, got {}",
            expected_length,
            code.len()
        ));
    }

    // Basic format validation
    if !is_valid_code_format(code) {
        return Ok(false);
    }

    // Check for suspicious patterns
    if has_suspicious_patterns(code) {
        return Ok(false);
    }

    Ok(true)
}

/// Generate a time-based one-time password (TOTP)
pub fn generate_totp(secret: &[u8], time_step: u64, digits: u32) -> Result<String, String> {
    if secret.is_empty() {
        return Err("Secret cannot be empty".to_string());
    }

    if digits < 6 || digits > 8 {
        return Err("Digits must be between 6 and 8".to_string());
    }

    let time = get_current_timestamp() / time_step;
    generate_hotp(secret, time, digits)
}

/// Generate HMAC-based one-time password (HOTP)
pub fn generate_hotp(secret: &[u8], counter: u64, digits: u32) -> Result<String, String> {
    if secret.is_empty() {
        return Err("Secret cannot be empty".to_string());
    }

    if digits < 6 || digits > 8 {
        return Err("Digits must be between 6 and 8".to_string());
    }

    // Create HMAC-SHA256
    let mut mac = Hmac::<Sha256>::new_from_slice(secret)
        .map_err(|e| format!("Failed to create HMAC: {}", e))?;

    // Update with counter (big-endian)
    let counter_bytes = counter.to_be_bytes();
    mac.update(&counter_bytes);

    // Get HMAC result
    let result = mac.finalize().into_bytes();

    // Dynamic truncation
    let offset = (result[result.len() - 1] & 0x0F) as usize;
    let truncated = &result[offset..offset + 4];

    // Convert to u32
    let mut code = u32::from_be_bytes([
        truncated[0],
        truncated[1],
        truncated[2],
        truncated[3],
    ]);

    // Mask most significant bit
    code &= 0x7FFFFFFF;

    // Modulo to get required digits
    code %= 10u32.pow(digits);

    // Format with leading zeros
    Ok(format!("{:0width$}", code, width = digits as usize))
}

/// Generate a secure random token
pub fn generate_secure_token(length: usize) -> Result<String, String> {
    if length == 0 {
        return Err("Token length must be greater than 0".to_string());
    }

    if length > 1024 {
        return Err("Token length cannot exceed 1024 characters".to_string());
    }

    let mut rng = rand::thread_rng();
    let mut token = String::with_capacity(length);

    // Use URL-safe base64 characters
    const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    for _ in 0..length {
        let idx = rng.gen_range(0..CHARSET.len());
        token.push(CHARSET[idx] as char);
    }

    Ok(token)
}

/// Generate a cryptographic hash of a code
pub fn hash_code(code: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(code.as_bytes());
    let result = hasher.finalize();
    BASE64.encode(result)
}

/// Verify code against hash
pub fn verify_hash(code: &str, hash: &str) -> bool {
    let code_hash = hash_code(code);
    code_hash == hash
}

/// Generate a code with expiration
pub fn generate_code_with_expiry(
    config: &AuthCodeConfig,
    expiry_seconds: u64,
) -> Result<(String, u64), String> {
    let code = generate_code_with_config(config)?;
    let expiry_time = get_current_timestamp() + expiry_seconds;
    Ok((code, expiry_time))
}

/// Verify code with expiry
pub fn verify_code_with_expiry(code: &str, expected_length: u32, expiry_time: u64) -> Result<bool, String> {
    if get_current_timestamp() > expiry_time {
        return Ok(false);
    }

    verify_code(code, expected_length)
}

/// Calculate checksum digit for a code
fn calculate_checksum(code: &str) -> char {
    let mut sum = 0;
    let charset = ALPHANUMERIC_UPPER;

    for (i, c) in code.chars().enumerate() {
        if let Some(pos) = charset.find(c) {
            // Weighted sum: position * character value
            sum += (i + 1) * (pos + 1);
        }
    }

    // Modulo to get index in charset
    let idx = sum % charset.len();
    charset.chars().nth(idx).unwrap_or('0')
}

/// Get current timestamp in seconds
fn get_current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

/// Validate code format
fn is_valid_code_format(code: &str) -> bool {
    // Check for minimum length
    if code.len() < 6 {
        return false;
    }

    // Check for invalid characters
    for c in code.chars() {
        if !c.is_ascii_alphanumeric() {
            return false;
        }
    }

    // Check for sequential patterns
    if has_sequential_patterns(code) {
        return false;
    }

    true
}

/// Check for sequential patterns (e.g., 123456, abcdef)
fn has_sequential_patterns(code: &str) -> bool {
    if code.len() < 3 {
        return false;
    }

    let chars: Vec<char> = code.chars().collect();

    for i in 0..chars.len() - 2 {
        let c1 = chars[i] as u8;
        let c2 = chars[i + 1] as u8;
        let c3 = chars[i + 2] as u8;

        // Check for increasing sequence
        if c1 + 1 == c2 && c2 + 1 == c3 {
            return true;
        }

        // Check for decreasing sequence
        if c1 - 1 == c2 && c2 - 1 == c3 {
            return true;
        }
    }

    false
}

/// Check for suspicious patterns
fn has_suspicious_patterns(code: &str) -> bool {
    // Check for repeated characters
    if has_repeated_characters(code, 4) {
        return true;
    }

    // Check for common patterns
    let common_patterns = [
        "123456", "654321", "000000", "111111", "222222", "333333",
        "444444", "555555", "666666", "777777", "888888", "999999",
        "abcdef", "ABCDEF", "qwerty", "password", "admin123",
    ];

    for pattern in common_patterns.iter() {
        if code.contains(pattern) {
            return true;
        }
    }

    false
}

/// Check for repeated characters
fn has_repeated_characters(code: &str, threshold: usize) -> bool {
    if code.len() < threshold {
        return false;
    }

    let chars: Vec<char> = code.chars().collect();
    let mut current_char = chars[0];
    let mut count = 1;

    for &c in &chars[1..] {
        if c == current_char {
            count += 1;
            if count >= threshold {
                return true;
            }
        } else {
            current_char = c;
            count = 1;
        }
    }

    false
}

/// Generate batch of authentication codes
pub fn generate_batch_codes(
    config: &AuthCodeConfig,
    count: u32,
) -> Result<Vec<String>, String> {
    if count == 0 {
        return Err("Count must be greater than 0".to_string());
    }

    if count > 100000 {
        return Err("Cannot generate more than 100,000 codes at once".to_string());
    }

    let mut codes = Vec::with_capacity(count as usize);
    let mut generated = std::collections::HashSet::new();

    for _ in 0..count {
        let mut attempts = 0;
        let max_attempts = 100;

        loop {
            if attempts >= max_attempts {
                return Err("Failed to generate unique code after maximum attempts".to_string());
            }

            match generate_code_with_config(config) {
                Ok(code) => {
                    if generated.insert(code.clone()) {
                        codes.push(code);
                        break;
                    }
                }
                Err(e) => return Err(e),
            }

            attempts += 1;
        }
    }

    Ok(codes)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_secure_code() {
        let code = generate_secure_code(12).unwrap();
        assert_eq!(code.len(), 12);
        assert!(code.chars().all(|c| c.is_ascii_alphanumeric()));
    }

    #[test]
    fn test_generate_code_with_config() {
        let config = AuthCodeConfig {
            code_type: AuthCodeType::Numeric,
            length: 6,
            include_timestamp: false,
            include_checksum: false,
            custom_charset: None,
        };

        let code = generate_code_with_config(&config).unwrap();
        assert_eq!(code.len(), 6);
        assert!(code.chars().all(|c| c.is_ascii_digit()));
    }

    #[test]
    fn test_verify_code() {
        let code = generate_secure_code(12).unwrap();
        let result = verify_code(&code, 12).unwrap();
        assert!(result);
    }

    #[test]
    fn test_generate_totp() {
        let secret = b"test_secret";
        let totp = generate_totp(secret, 30, 6).unwrap();
        assert_eq!(totp.len(), 6);
        assert!(totp.chars().all(|c| c.is_ascii_digit()));
    }

    #[test]
    fn test_generate_hotp() {
        let secret = b"test_secret";
        let hotp = generate_hotp(secret, 123456, 6).unwrap();
        assert_eq!(hotp.len(), 6);
        assert!(hotp.chars().all(|c| c.is_ascii_digit()));
    }

    #[test]
    fn test_hash_code() {
        let code = "TEST123";
        let hash = hash_code(code);
        assert!(!hash.is_empty());
        assert!(hash.len() > 10);
    }

    #[test]
    fn test_verify_hash() {
        let code = "TEST123";
        let hash = hash_code(code);
        assert!(verify_hash(code, &hash));
        assert!(!verify_hash("WRONG", &hash));
    }

    #[test]
    fn test_generate_batch_codes() {
        let config = AuthCodeConfig::default();
        let codes = generate_batch_codes(&config, 10).unwrap();
        assert_eq!(codes.len(), 10);

        // Check all codes are unique
        let unique_codes: std::collections::HashSet<_> = codes.iter().collect();
        assert_eq!(unique_codes.len(), 10);
    }

    #[test]
    fn test_calculate_checksum() {
        let code = "ABC123";
        let checksum = calculate_checksum(code);
        assert!(ALPHANUMERIC_UPPER.contains(checksum));
    }

    #[test]
    fn test_has_sequential_patterns() {
        assert!(has_sequential_patterns("123ABC"));
        assert!(has_sequential_patterns("ABC456DEF"));
        assert!(!has_sequential_patterns("A1B2C3"));
    }

    #[test]
    fn test_has_repeated_characters() {
        assert!(has_repeated_characters("AAAABCD", 4));
        assert!(!has_repeated_characters("AAABCD", 4));
        assert!(has_repeated_characters("1111", 4));
    }
}
