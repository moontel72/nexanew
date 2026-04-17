//! Checksum Algorithms Module
//! Provides checksum calculation and verification for codes
//!
//! This module includes:
//! - Various checksum algorithms (Luhn, Verhoeff, Damm, etc.)
//! - Checksum validation
//! - Error detection and correction
//! - Support for different code types

use std::collections::HashMap;

/// Checksum algorithm types
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ChecksumAlgorithm {
    /// Luhn algorithm (modulus 10)
    Luhn,
    /// Verhoeff algorithm (dihedral group D5)
    Verhoeff,
    /// Damm algorithm (quasigroup)
    Damm,
    /// Modulus 11 algorithm
    Modulus11,
    /// Modulus 16 algorithm (hexadecimal)
    Modulus16,
    /// Simple sum algorithm
    SimpleSum,
    /// Weighted sum algorithm
    WeightedSum,
}

/// Checksum configuration
#[derive(Debug, Clone)]
pub struct ChecksumConfig {
    /// Algorithm to use
    pub algorithm: ChecksumAlgorithm,
    /// Include checksum in output
    pub include_in_output: bool,
    /// Position of checksum (start or end)
    pub position: ChecksumPosition,
    /// Custom weights for weighted algorithms
    pub custom_weights: Option<Vec<u32>>,
}

/// Checksum position in code
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum ChecksumPosition {
    /// Checksum at the beginning of code
    Prefix,
    /// Checksum at the end of code
    Suffix,
}

impl Default for ChecksumConfig {
    fn default() -> Self {
        Self {
            algorithm: ChecksumAlgorithm::Luhn,
            include_in_output: true,
            position: ChecksumPosition::Suffix,
            custom_weights: None,
        }
    }
}

/// Calculate checksum for a code
pub fn calculate(code: &str) -> Result<String, String> {
    let config = ChecksumConfig::default();
    calculate_with_config(code, &config)
}

/// Calculate checksum with configuration
pub fn calculate_with_config(code: &str, config: &ChecksumConfig) -> Result<String, String> {
    if code.is_empty() {
        return Err("Code cannot be empty".to_string());
    }

    let checksum = match config.algorithm {
        ChecksumAlgorithm::Luhn => calculate_luhn(code),
        ChecksumAlgorithm::Verhoeff => calculate_verhoeff(code),
        ChecksumAlgorithm::Damm => calculate_damm(code),
        ChecksumAlgorithm::Modulus11 => calculate_modulus11(code),
        ChecksumAlgorithm::Modulus16 => calculate_modulus16(code),
        ChecksumAlgorithm::SimpleSum => calculate_simple_sum(code),
        ChecksumAlgorithm::WeightedSum => calculate_weighted_sum(code, config.custom_weights.as_deref()),
    };

    if config.include_in_output {
        match config.position {
            ChecksumPosition::Prefix => Ok(format!("{}{}", checksum, code)),
            ChecksumPosition::Suffix => Ok(format!("{}{}", code, checksum)),
        }
    } else {
        Ok(checksum)
    }
}

/// Verify checksum for a code
pub fn verify(code: &str, config: &ChecksumConfig) -> Result<bool, String> {
    if code.is_empty() {
        return Err("Code cannot be empty".to_string());
    }

    if !config.include_in_output {
        return Err("Cannot verify checksum when not included in output".to_string());
    }

    let (data_part, checksum_part) = match config.position {
        ChecksumPosition::Prefix => {
            if code.len() < 2 {
                return Err("Code too short to contain checksum".to_string());
            }
            (&code[1..], &code[0..1])
        }
        ChecksumPosition::Suffix => {
            if code.len() < 2 {
                return Err("Code too short to contain checksum".to_string());
            }
            (&code[0..code.len() - 1], &code[code.len() - 1..])
        }
    };

    let expected_checksum = match config.algorithm {
        ChecksumAlgorithm::Luhn => calculate_luhn(data_part),
        ChecksumAlgorithm::Verhoeff => calculate_verhoeff(data_part),
        ChecksumAlgorithm::Damm => calculate_damm(data_part),
        ChecksumAlgorithm::Modulus11 => calculate_modulus11(data_part),
        ChecksumAlgorithm::Modulus16 => calculate_modulus16(data_part),
        ChecksumAlgorithm::SimpleSum => calculate_simple_sum(data_part),
        ChecksumAlgorithm::WeightedSum => calculate_weighted_sum(data_part, config.custom_weights.as_deref()),
    };

    Ok(checksum_part == expected_checksum)
}

/// Calculate Luhn checksum (modulus 10)
fn calculate_luhn(code: &str) -> String {
    let digits: Vec<u32> = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .collect();

    if digits.is_empty() {
        return "0".to_string();
    }

    let mut sum = 0;
    let mut double = false;

    // Process from right to left
    for &digit in digits.iter().rev() {
        let mut value = digit;

        if double {
            value *= 2;
            if value > 9 {
                value -= 9;
            }
        }

        sum += value;
        double = !double;
    }

    let check_digit = (10 - (sum % 10)) % 10;
    check_digit.to_string()
}

/// Calculate Verhoeff checksum
fn calculate_verhoeff(code: &str) -> String {
    // Verhoeff multiplication table
    let d = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
        [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
        [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
        [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
        [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
        [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
        [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
        [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
    ];

    // Verhoeff permutation table
    let p = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
        [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
        [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
        [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
        [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
        [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
        [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
    ];

    // Inverse table
    let inv = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9];

    let digits: Vec<usize> = code
        .chars()
        .filter_map(|c| c.to_digit(10).map(|d| d as usize))
        .collect();

    let mut c = 0;
    let len = digits.len();

    for i in 0..len {
        c = d[c][p[(i + 1) % 8][digits[len - 1 - i]]];
    }

    inv[c].to_string()
}

/// Calculate Damm checksum
fn calculate_damm(code: &str) -> String {
    // Damm quasigroup table
    let table = [
        [0, 3, 1, 7, 5, 9, 8, 6, 4, 2],
        [7, 0, 9, 2, 1, 5, 4, 8, 6, 3],
        [4, 2, 0, 6, 8, 7, 1, 3, 5, 9],
        [1, 7, 5, 0, 9, 8, 3, 4, 2, 6],
        [6, 1, 2, 3, 0, 4, 5, 9, 7, 8],
        [3, 6, 7, 4, 2, 0, 9, 5, 8, 1],
        [5, 8, 6, 9, 7, 2, 0, 1, 3, 4],
        [8, 9, 4, 5, 3, 6, 2, 0, 1, 7],
        [9, 4, 3, 8, 6, 1, 7, 2, 0, 5],
        [2, 5, 8, 1, 4, 3, 6, 7, 9, 0],
    ];

    let digits: Vec<usize> = code
        .chars()
        .filter_map(|c| c.to_digit(10).map(|d| d as usize))
        .collect();

    let mut interim = 0;

    for &digit in &digits {
        interim = table[interim][digit];
    }

    interim.to_string()
}

/// Calculate Modulus 11 checksum
fn calculate_modulus11(code: &str) -> String {
    let digits: Vec<u32> = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .collect();

    if digits.is_empty() {
        return "0".to_string();
    }

    let mut sum = 0;
    let mut weight = 2;

    // Process from right to left
    for &digit in digits.iter().rev() {
        sum += digit * weight;
        weight += 1;
        if weight > 7 {
            weight = 2;
        }
    }

    let remainder = sum % 11;

    match remainder {
        0 => "0".to_string(),
        1 => "X".to_string(),
        r => (11 - r).to_string(),
    }
}

/// Calculate Modulus 16 checksum (hexadecimal)
fn calculate_modulus16(code: &str) -> String {
    let mut sum: u32 = 0;

    for c in code.chars() {
        sum = sum.wrapping_add(c as u32);
    }

    let checksum = sum % 16;
    format!("{:X}", checksum)
}

/// Calculate simple sum checksum
fn calculate_simple_sum(code: &str) -> String {
    let sum: u32 = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .sum();

    let checksum = sum % 10;
    checksum.to_string()
}

/// Calculate weighted sum checksum
fn calculate_weighted_sum(code: &str, weights: Option<&[u32]>) -> String {
    let digits: Vec<u32> = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .collect();

    if digits.is_empty() {
        return "0".to_string();
    }

    let default_weights: Vec<u32> = (1..=digits.len() as u32).collect();
    let weights = weights.unwrap_or(&default_weights);

    let mut sum = 0;
    let min_len = digits.len().min(weights.len());

    for i in 0..min_len {
        sum += digits[i] * weights[i];
    }

    let checksum = sum % 10;
    checksum.to_string()
}

/// Generate check digit for ISBN-13
pub fn calculate_isbn13(code: &str) -> Result<String, String> {
    if code.len() != 12 {
        return Err("ISBN-13 code must be 12 digits long".to_string());
    }

    let digits: Vec<u32> = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .collect();

    if digits.len() != 12 {
        return Err("ISBN-13 code must contain only digits".to_string());
    }

    let mut sum = 0;

    for (i, &digit) in digits.iter().enumerate() {
        let weight = if i % 2 == 0 { 1 } else { 3 };
        sum += digit * weight;
    }

    let check_digit = (10 - (sum % 10)) % 10;
    Ok(check_digit.to_string())
}

/// Generate check digit for EAN-13
pub fn calculate_ean13(code: &str) -> Result<String, String> {
    calculate_isbn13(code)
}

/// Generate check digit for UPC-A
pub fn calculate_upca(code: &str) -> Result<String, String> {
    if code.len() != 11 {
        return Err("UPC-A code must be 11 digits long".to_string());
    }

    let digits: Vec<u32> = code
        .chars()
        .filter_map(|c| c.to_digit(10))
        .collect();

    if digits.len() != 11 {
        return Err("UPC-A code must contain only digits".to_string());
    }

    let mut sum = 0;

    for (i, &digit) in digits.iter().enumerate() {
        let weight = if i % 2 == 0 { 3 } else { 1 };
        sum += digit * weight;
    }

    let check_digit = (10 - (sum % 10)) % 10;
    Ok(check_digit.to_string())
}

/// Validate code with checksum
pub fn validate_with_checksum(code: &str, algorithm: ChecksumAlgorithm) -> bool {
    let config = ChecksumConfig {
        algorithm,
        include_in_output: true,
        position: ChecksumPosition::Suffix,
        custom_weights: None,
    };

    verify(code, &config).unwrap_or(false)
}

/// Strip checksum from code
pub fn strip_checksum(code: &str, config: &ChecksumConfig) -> String {
    if !config.include_in_output {
        return code.to_string();
    }

    match config.position {
        ChecksumPosition::Prefix => {
            if code.len() > 1 {
                code[1..].to_string()
            } else {
                code.to_string()
            }
        }
        ChecksumPosition::Suffix => {
            if code.len() > 1 {
                code[..code.len() - 1].to_string()
            } else {
                code.to_string()
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_luhn() {
        assert_eq!(calculate_luhn("7992739871"), "3");
        assert_eq!(calculate_luhn("123456781234567"), "0");
        assert_eq!(calculate_luhn("4992739871"), "6");
    }

    #[test]
    fn test_calculate_verhoeff() {
        assert_eq!(calculate_verhoeff("236"), "3");
        assert_eq!(calculate_verhoeff("12345"), "1");
        assert_eq!(calculate_verhoeff("112233"), "0");
    }

    #[test]
    fn test_calculate_damm() {
        assert_eq!(calculate_damm("572"), "4");
        assert_eq!(calculate_damm("112233"), "9");
        assert_eq!(calculate_damm("12345"), "9");
    }

    #[test]
    fn test_calculate_modulus11() {
        assert_eq!(calculate_modulus11("036532"), "6");
        assert_eq!(calculate_modulus11("111111"), "X");
        assert_eq!(calculate_modulus11("123456"), "2");
    }

    #[test]
    fn test_calculate_modulus16() {
        assert_eq!(calculate_modulus16("ABC123"), "E");
        assert_eq!(calculate_modulus16("123456"), "6");
        assert_eq!(calculate_modulus16("TEST"), "4");
    }

    #[test]
    fn test_calculate_isbn13() {
        assert_eq!(calculate_isbn13("978030640615").unwrap(), "7");
        assert_eq!(calculate_isbn13("978316148410").unwrap(), "0");
        assert_eq!(calculate_isbn13("123456789012").unwrap(), "8");
    }

    #[test]
    fn test_calculate_upca() {
        assert_eq!(calculate_upca("01234567890").unwrap(), "5");
        assert_eq!(calculate_upca("12345678901").unwrap(), "2");
        assert_eq!(calculate_upca("99999999999").unwrap(), "7");
    }

    #[test]
    fn test_verify() {
        let config = ChecksumConfig {
            algorithm: ChecksumAlgorithm::Luhn,
            include_in_output: true,
            position: ChecksumPosition::Suffix,
            custom_weights: None,
        };

        assert!(verify("799273987
