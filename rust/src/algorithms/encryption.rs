//! Encryption Algorithms Module
//! Provides cryptographic encryption and decryption for codes
//!
//! This module includes:
//! - Symmetric encryption (AES, ChaCha20)
//! - Key derivation (PBKDF2, Argon2)
//! - Secure key management
//! - Data integrity verification

use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    Aes256Gcm, Key, Nonce,
};
use chacha20poly1305::{ChaCha20Poly1305, Key as ChaChaKey, Nonce as ChaChaNonce};
use argon2::{
    password_hash::{
        rand_core::OsRng,
        PasswordHash, PasswordHasher, PasswordVerifier, SaltString,
    },
    Argon2, Params, Version,
};
use pbkdf2::pbkdf2_hmac;
use sha2::{Digest, Sha256, Sha512};
use hmac::{Hmac, Mac};
use base64::{Engine as _, engine::general_purpose::STANDARD as BASE64};
use rand::{RngCore, rngs::ThreadRng};
use std::time::{SystemTime, UNIX_EPOCH};

/// Encryption algorithm types
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum EncryptionAlgorithm {
    /// AES-256-GCM (Authenticated Encryption)
    Aes256Gcm,
    /// ChaCha20-Poly1305 (Authenticated Encryption)
    ChaCha20Poly1305,
    /// Simple XOR (for testing only)
    Xor,
}

/// Key derivation algorithm types
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum KeyDerivationAlgorithm {
    /// PBKDF2 with HMAC-SHA256
    Pbkdf2Sha256,
    /// PBKDF2 with HMAC-SHA512
    Pbkdf2Sha512,
    /// Argon2id (memory-hard)
    Argon2id,
}

/// Encryption configuration
#[derive(Debug, Clone)]
pub struct EncryptionConfig {
    /// Algorithm to use
    pub algorithm: EncryptionAlgorithm,
    /// Key derivation algorithm
    pub key_derivation: KeyDerivationAlgorithm,
    /// Include authentication tag
    pub include_auth_tag: bool,
    /// Include initialization vector
    pub include_iv: bool,
    /// Key length in bytes
    pub key_length: usize,
    /// Salt length in bytes
    pub salt_length: usize,
    /// Iterations for key derivation
    pub iterations: u32,
    /// Memory cost for Argon2 (in KiB)
    pub memory_cost: u32,
    /// Parallelism factor for Argon2
    pub parallelism: u32,
}

impl Default for EncryptionConfig {
    fn default() -> Self {
        Self {
            algorithm: EncryptionAlgorithm::Aes256Gcm,
            key_derivation: KeyDerivationAlgorithm::Pbkdf2Sha256,
            include_auth_tag: true,
            include_iv: true,
            key_length: 32, // 256 bits
            salt_length: 16,
            iterations: 100_000,
            memory_cost: 4096, // 4 MiB
            parallelism: 1,
        }
    }
}

/// Encrypt data with a key
pub fn encrypt(data: &str, key: &str) -> Result<String, String> {
    let config = EncryptionConfig::default();
    encrypt_with_config(data, key, &config)
}

/// Encrypt data with configuration
pub fn encrypt_with_config(
    data: &str,
    key: &str,
    config: &EncryptionConfig,
) -> Result<String, String> {
    if data.is_empty() {
        return Err("Data cannot be empty".to_string());
    }

    if key.is_empty() {
        return Err("Key cannot be empty".to_string());
    }

    // Generate salt
    let salt = generate_salt(config.salt_length)?;

    // Derive encryption key
    let encryption_key = derive_key(key, &salt, config)?;

    // Generate nonce/IV
    let nonce = generate_nonce(config)?;

    // Encrypt data
    let ciphertext = match config.algorithm {
        EncryptionAlgorithm::Aes256Gcm => {
            encrypt_aes256_gcm(data.as_bytes(), &encryption_key, &nonce, config)?
        }
        EncryptionAlgorithm::ChaCha20Poly1305 => {
            encrypt_chacha20_poly1305(data.as_bytes(), &encryption_key, &nonce, config)?
        }
        EncryptionAlgorithm::Xor => encrypt_xor(data.as_bytes(), &encryption_key)?,
    };

    // Build output
    let mut output = String::new();

    if config.include_iv {
        output.push_str(&BASE64.encode(&nonce));
        output.push('.');
    }

    output.push_str(&BASE64.encode(&ciphertext));

    if config.include_auth_tag && config.algorithm != EncryptionAlgorithm::Xor {
        // Auth tag is included in ciphertext for AEAD algorithms
    }

    output.push('.');
    output.push_str(&BASE64.encode(&salt));

    Ok(output)
}

/// Decrypt data with a key
pub fn decrypt(encrypted_data: &str, key: &str) -> Result<String, String> {
    let config = EncryptionConfig::default();
    decrypt_with_config(encrypted_data, key, &config)
}

/// Decrypt data with configuration
pub fn decrypt_with_config(
    encrypted_data: &str,
    key: &str,
    config: &EncryptionConfig,
) -> Result<String, String> {
    if encrypted_data.is_empty() {
        return Err("Encrypted data cannot be empty".to_string());
    }

    if key.is_empty() {
        return Err("Key cannot be empty".to_string());
    }

    // Parse encrypted data
    let parts: Vec<&str> = encrypted_data.split('.').collect();
    if parts.len() < 2 {
        return Err("Invalid encrypted data format".to_string());
    }

    let (nonce, ciphertext, salt) = if config.include_iv {
        if parts.len() < 3 {
            return Err("Missing components in encrypted data".to_string());
        }
        (
            BASE64.decode(parts[0]).map_err(|e| format!("Failed to decode nonce: {}", e))?,
            BASE64.decode(parts[1]).map_err(|e| format!("Failed to decode ciphertext: {}", e))?,
            BASE64.decode(parts[2]).map_err(|e| format!("Failed to decode salt: {}", e))?,
        )
    } else {
        (
            vec![], // Will be generated from key
            BASE64.decode(parts[0]).map_err(|e| format!("Failed to decode ciphertext: {}", e))?,
            BASE64.decode(parts[1]).map_err(|e| format!("Failed to decode salt: {}", e))?,
        )
    };

    // Derive encryption key
    let encryption_key = derive_key(key, &salt, config)?;

    // Decrypt data
    let plaintext = match config.algorithm {
        EncryptionAlgorithm::Aes256Gcm => {
            let actual_nonce = if nonce.is_empty() {
                generate_nonce_from_key(&encryption_key, config.key_length)?
            } else {
                nonce
            };
            decrypt_aes256_gcm(&ciphertext, &encryption_key, &actual_nonce, config)?
        }
        EncryptionAlgorithm::ChaCha20Poly1305 => {
            let actual_nonce = if nonce.is_empty() {
                generate_nonce_from_key(&encryption_key, config.key_length)?
            } else {
                nonce
            };
            decrypt_chacha20_poly1305(&ciphertext, &encryption_key, &actual_nonce, config)?
        }
        EncryptionAlgorithm::Xor => decrypt_xor(&ciphertext, &encryption_key)?,
    };

    String::from_utf8(plaintext).map_err(|e| format!("Failed to convert to UTF-8: {}", e))
}

/// Generate secure random key
pub fn generate_key(length: usize) -> Result<Vec<u8>, String> {
    if length == 0 {
        return Err("Key length must be greater than 0".to_string());
    }

    if length > 1024 {
        return Err("Key length cannot exceed 1024 bytes".to_string());
    }

    let mut key = vec![0u8; length];
    let mut rng = OsRng;
    rng.fill_bytes(&mut key);
    Ok(key)
}

/// Generate key from password
pub fn generate_key_from_password(
    password: &str,
    salt: &[u8],
    config: &EncryptionConfig,
) -> Result<Vec<u8>, String> {
    derive_key(password, salt, config)
}

/// Hash data for integrity verification
pub fn hash_data(data: &[u8], algorithm: &str) -> Result<String, String> {
    match algorithm.to_lowercase().as_str() {
        "sha256" => {
            let mut hasher = Sha256::new();
            hasher.update(data);
            let result = hasher.finalize();
            Ok(hex::encode(result))
        }
        "sha512" => {
            let mut hasher = Sha512::new();
            hasher.update(data);
            let result = hasher.finalize();
            Ok(hex::encode(result))
        }
        _ => Err(format!("Unsupported hash algorithm: {}", algorithm)),
    }
}

/// Verify data integrity
pub fn verify_integrity(data: &[u8], hash: &str, algorithm: &str) -> Result<bool, String> {
    let computed_hash = hash_data(data, algorithm)?;
    Ok(computed_hash == hash)
}

/// Generate message authentication code (MAC)
pub fn generate_mac(data: &[u8], key: &[u8]) -> Result<String, String> {
    let mut mac = Hmac::<Sha256>::new_from_slice(key)
        .map_err(|e| format!("Failed to create HMAC: {}", e))?;
    mac.update(data);
    let result = mac.finalize().into_bytes();
    Ok(hex::encode(result))
}

/// Verify message authentication code (MAC)
pub fn verify_mac(data: &[u8], key: &[u8], mac: &str) -> Result<bool, String> {
    let computed_mac = generate_mac(data, key)?;
    Ok(computed_mac == mac)
}

/// Encrypt with AES-256-GCM
fn encrypt_aes256_gcm(
    data: &[u8],
    key: &[u8],
    nonce: &[u8],
    config: &EncryptionConfig,
) -> Result<Vec<u8>, String> {
    if key.len() != 32 {
        return Err("AES-256-GCM requires 32-byte key".to_string());
    }

    if nonce.len() != 12 {
        return Err("AES-256-GCM requires 12-byte nonce".to_string());
    }

    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key));
    let nonce = Nonce::from_slice(nonce);

    cipher
        .encrypt(nonce, data)
        .map_err(|e| format!("Encryption failed: {}", e))
}

/// Decrypt with AES-256-GCM
fn decrypt_aes256_gcm(
    ciphertext: &[u8],
    key: &[u8],
    nonce: &[u8],
    config: &EncryptionConfig,
) -> Result<Vec<u8>, String> {
    if key.len() != 32 {
        return Err("AES-256-GCM requires 32-byte key".to_string());
    }

    if nonce.len() != 12 {
        return Err("AES-256-GCM requires 12-byte nonce".to_string());
    }

    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key));
    let nonce = Nonce::from_slice(nonce);

    cipher
        .decrypt(nonce, ciphertext)
        .map_err(|e| format!("Decryption failed: {}", e))
}

/// Encrypt with ChaCha20-Poly1305
fn encrypt_chacha20_poly1305(
    data: &[u8],
    key: &[u8],
    nonce: &[u8],
    config: &EncryptionConfig,
) -> Result<Vec<u8>, String> {
    if key.len() != 32 {
        return Err("ChaCha20-Poly1305 requires 32-byte key".to_string());
    }

    if nonce.len() != 12 {
        return Err("ChaCha20-Poly1305 requires 12-byte nonce".to_string());
    }

    let cipher = ChaCha20Poly1305::new(ChaChaKey::from_slice(key));
    let nonce = ChaChaNonce::from_slice(nonce);

    cipher
        .encrypt(nonce, data)
        .map_err(|e| format!("Encryption failed: {}", e))
}

/// Decrypt with ChaCha20-Poly1305
fn decrypt_chacha20_poly1305(
    ciphertext: &[u8],
    key: &[u8],
    nonce: &[u8],
    config: &EncryptionConfig,
) -> Result<Vec<u8>, String> {
    if key.len() != 32 {
        return Err("ChaCha20-Poly1305 requires 32-byte key".to_string());
    }

    if nonce.len() != 12 {
        return Err("ChaCha20-Poly1305 requires 12-byte nonce".to_string());
    }

    let cipher = ChaCha20Poly1305::new(ChaChaKey::from_slice(key));
    let nonce = ChaChaNonce::from_slice(nonce);

    cipher
        .decrypt(nonce, ciphertext)
        .map_err(|e| format!("Decryption failed: {}", e))
}

/// Encrypt with XOR (for testing only)
fn encrypt_xor(data: &[u8], key: &[u8]) -> Result<Vec<u8>, String> {
    if key.is_empty() {
        return Err("XOR key cannot be empty".to_string());
    }

    let mut result = Vec::with_capacity(data.len());
    for (i, &byte) in data.iter().enumerate() {
        let key_byte = key[i % key.len()];
        result.push(byte ^ key_byte);
    }
    Ok(result)
}

/// Decrypt with XOR (for testing only)
fn decrypt_xor(ciphertext: &[u8], key: &[u8]) -> Result<Vec<u8>, String> {
    encrypt_xor(ciphertext, key)
}

/// Derive key from password
fn derive_key(password: &str, salt: &[u8], config: &EncryptionConfig) -> Result<Vec<u8>, String> {
    let mut key = vec![0u8; config.key_length];

    match config.key_derivation {
        KeyDerivationAlgorithm::Pbkdf2Sha256 => {
            pbkdf2_hmac::<Sha256>(
                password.as_bytes(),
                salt,
                config.iterations,
                &mut key,
            );
        }
        KeyDerivationAlgorithm::Pbkdf2Sha512 => {
            pbkdf2_hmac::<Sha512>(
                password.as_bytes(),
                salt,
                config.iterations,
                &mut key,
            );
        }
        KeyDerivationAlgorithm::Argon2id => {
            let argon2 = Argon2::new(
                argon2::Algorithm::Argon2id,
                Version::V0x13,
                Params::new(
                    config.memory_cost,
                    config.iterations,
                    config.parallelism,
                    Some(config.key_length),
                )
                .map_err(|e| format!("Failed to create Argon2 params: {}", e))?,
            );

            let password_hash = argon2
                .hash_password(password.as_bytes(), &SaltString::encode_b64(salt).map_err(|e| format!("Failed to encode salt: {}", e))?)
                .map_err(|e| format!("Failed to hash password: {}", e))?;

            let hash_bytes = password_hash.hash.ok_or("Failed to get hash bytes")?;
            key.copy_from_slice(&hash_bytes.as_bytes()[..config.key_length.min(hash_bytes.as_bytes().len())]);
        }
    }

    Ok(key)
}

/// Generate random salt
fn generate_salt(length: usize) -> Result<Vec<u8>, String> {
    if length == 0 {
        return Err("Salt length must be greater than 0".to_string());
    }

    let mut salt = vec![0u8; length];
    let mut rng = OsRng;
    rng.fill_bytes(&mut salt);
    Ok(salt)
}

/// Generate random nonce/IV
fn generate_nonce(config: &EncryptionConfig) -> Result<Vec<u8>, String> {
    let nonce_length = match config.algorithm {
        EncryptionAlgorithm::Aes256Gcm => 12,
        EncryptionAlgorithm::ChaCha20Poly1305 => 12,
        EncryptionAlgorithm::Xor => 0,
    };

    if nonce_length == 0 {
        return Ok(vec![]);
    }

    let mut nonce = vec![0u8; nonce_length];
    let mut rng = OsRng;
    rng.fill_bytes(&mut nonce);
    Ok(nonce)
}

/// Generate nonce from key
fn generate_nonce_from_key(key: &[u8], key_length: usize) -> Result<Vec<u8>, String> {
    if key.is_empty() {
        return Err("Key cannot be empty".to_string());
    }

    let mut hasher = Sha256::new();
    hasher.update(key);
    hasher.update(&get_current_timestamp().to_be_bytes());
    let result = hasher.finalize();

    // Take first 12 bytes for nonce
    Ok(result[..12].to_vec())
}

/// Get current timestamp in seconds
fn get_current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt_aes() {
        let data = "Test encryption data";
        let key = "test_password_123";
        let config = EncryptionConfig::default();

        let encrypted = encrypt_with_config(data, key, &config).unwrap();
        let decrypted = decrypt_with_config(&encrypted, key, &config).unwrap();
        assert_eq!(decrypted, data);
    }
}
