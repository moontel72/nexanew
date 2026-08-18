//! Shared building blocks of the T-Odd media engine:
//! auth (JWTs minted by Laravel), environment config, DTOs and the
//! unified error type.

pub mod auth;
pub mod config;
pub mod error;
pub mod http;
pub mod media;
pub mod types;
