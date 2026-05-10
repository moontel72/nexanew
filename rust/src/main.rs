//! NexaTrace Rust CLI — High-volume code generation binary
//!
//! Called by the PHP backend (RustCodeGenerator.php) via stdin/stdout pipe.
//! Accepts JSON on stdin and returns JSON on stdout.
//!
//! Usage:
//!   echo '{"code_type":"unit","count":1000,...}' | nexatrace_rust generate
//!   nexatrace_rust --version

use serde::{Deserialize, Serialize};
use std::io::{self, Read};

mod algorithms;
mod generators;
mod international;
mod models;
mod utils;

/// Input JSON structure from PHP
#[derive(Debug, Deserialize)]
struct GenerateRequest {
    code_type: String,
    count: u32,
    company_id: String,
    plan_id: String,
    batch_id: String,
    prefix: String,
    #[serde(default)]
    timestamp: String,
}

/// Output JSON structure to PHP
#[derive(Debug, Serialize)]
struct GenerateResponse {
    success: bool,
    codes: Vec<CodeOutput>,
    stats: GenerationStats,
}

#[derive(Debug, Serialize)]
struct CodeOutput {
    id: String,
    code: String,
    store_keeper_code: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    international_code: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    qr_code_data: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    barcode_data: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    metadata: Option<serde_json::Value>,
}

#[derive(Debug, Serialize)]
struct GenerationStats {
    total: u32,
    time_ms: u64,
    codes_per_second: f64,
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // Handle --version / -V
    if args.len() >= 2 && (args[1] == "--version" || args[1] == "-V") {
        println!("nexatrace_rust {}", env!("CARGO_PKG_VERSION"));
        return;
    }

    // Require a subcommand
    if args.len() < 2 {
        eprintln!("Usage: nexatrace_rust <generate|--version>");
        std::process::exit(1);
    }

    match args[1].as_str() {
        "generate" => {
            if let Err(e) = handle_generate() {
                let err = serde_json::json!({
                    "success": false,
                    "error": e.to_string(),
                    "codes": []
                });
                println!("{}", serde_json::to_string(&err).unwrap());
                std::process::exit(1);
            }
        }
        other => {
            eprintln!("Unknown command: {}. Use 'generate' or '--version'", other);
            std::process::exit(1);
        }
    }
}

fn handle_generate() -> Result<(), Box<dyn std::error::Error>> {
    // Read JSON from stdin
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let request: GenerateRequest = serde_json::from_str(&input)?;

    let start = std::time::Instant::now();

    // Generate codes based on type
    let codes: Vec<CodeOutput> = match request.code_type.as_str() {
        "bundle" => generate_bundle_output(&request)?,
        "carton" => generate_carton_output(&request)?,
        "packet" => generate_packet_output(&request)?,
        "unit" => generate_unit_output(&request)?,
        other => return Err(format!("Unsupported code type: {}", other).into()),
    };

    let elapsed_ms = start.elapsed().as_millis() as u64;
    let total = codes.len() as u32;
    let codes_per_second = if elapsed_ms > 0 {
        total as f64 / (elapsed_ms as f64 / 1000.0)
    } else {
        0.0
    };

    let response = GenerateResponse {
        success: true,
        codes,
        stats: GenerationStats {
            total,
            time_ms: elapsed_ms,
            codes_per_second,
        },
    };

    println!("{}", serde_json::to_string(&response)?);
    Ok(())
}

fn generate_bundle_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let codes = generators::bundle::generate_batch(
        req.prefix.clone(),
        1,
        req.count,
        req.company_id.clone(),
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_carton_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let codes = generators::carton::generate_batch(
        req.prefix.clone(),
        1,
        req.count,
        String::new(), // bundle_code — not used for standalone
        req.company_id.clone(),
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_packet_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let codes = generators::packet::generate_batch(
        req.prefix.clone(),
        1,
        req.count,
        String::new(), // carton_code — not used for standalone
        req.company_id.clone(),
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_unit_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let codes = generators::unit::generate_batch(
        req.prefix.clone(),
        1,
        req.count,
        String::new(), // packet_code — not used for standalone
        req.company_id.clone(),
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

/// Map generated code strings to structured output
fn map_to_output(codes: Vec<String>, prefix: &str) -> Vec<CodeOutput> {
    codes
        .into_iter()
        .enumerate()
        .map(|(i, code)| CodeOutput {
            id: uuid::Uuid::new_v4().to_string(),
            code,
            store_keeper_code: format!("SK-{}-{:08}", prefix.to_uppercase(), i + 1),
            international_code: None,
            qr_code_data: None,
            barcode_data: None,
            metadata: None,
        })
        .collect()
}
