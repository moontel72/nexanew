//! NexaTrace Rust CLI — High-volume code generation binary
//!
//! Called by the PHP backend (RustCodeGenerator.php) via stdin/stdout pipe.
//! Accepts JSON on stdin and returns JSON on stdout.
//!
//! Usage:
//!   echo '{"code_type":"unit","count":1000,...}' | trace_odd_rust generate
//!   echo '{"overs_per_side":20,"deliveries":[...]}' | trace_odd_rust cricket --recompute
//!   trace_odd_rust --version

use serde::{Deserialize, Serialize};
use std::io::{self, Read};

mod algorithms;
mod cricket;
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

    if args.len() >= 2 && (args[1] == "--version" || args[1] == "-V") {
        println!("trace_odd_rust {}", env!("CARGO_PKG_VERSION"));
        return;
    }

    if args.len() < 2 {
        eprintln!("Usage: trace_odd_rust <generate|cricket|--version>");
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
        "cricket" => {
            let sub = args.get(2).map(|s| s.as_str()).unwrap_or("");
            match sub {
                "--recompute" => {
                    if let Err(e) = cricket::handle_recompute_command() {
                        let err = serde_json::json!({
                            "success": false,
                            "error": e.to_string()
                        });
                        println!("{}", serde_json::to_string(&err).unwrap());
                        std::process::exit(1);
                    }
                }
                _ => {
                    eprintln!("Usage: trace_odd_rust cricket --recompute (reads JSON from stdin)");
                    std::process::exit(1);
                }
            }
        }
        other => {
            eprintln!(
                "Unknown command: {}. Use 'generate', 'cricket' or '--version'",
                other
            );
            std::process::exit(1);
        }
    }
}

fn handle_generate() -> Result<(), Box<dyn std::error::Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let request: GenerateRequest = serde_json::from_str(&input)?;
    let start = std::time::Instant::now();

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

// ─── Per-type generators with sensible defaults ──────────────────

fn generate_bundle_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let prefix = sanitize_prefix(&req.prefix, "BNDL");
    let factory_id = sanitize_factory_id(&req.company_id);

    let codes = generators::bundle::generate_batch(prefix, 1, req.count, factory_id)
        .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_carton_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let prefix = sanitize_prefix(&req.prefix, "CART");
    let factory_id = sanitize_factory_id(&req.company_id);

    let codes = generators::carton::generate_batch(
        prefix,
        1,
        req.count,
        "BUNDLE-STANDALONE-001-ABC-DEF".to_string(),
        factory_id,
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_packet_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let prefix = sanitize_prefix(&req.prefix, "PKTZ");
    let factory_id = sanitize_factory_id(&req.company_id);

    let codes = generators::packet::generate_batch(
        prefix,
        1,
        req.count,
        "CARTON-STANDALONE-001-ABC-DEF".to_string(),
        factory_id,
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

fn generate_unit_output(req: &GenerateRequest) -> Result<Vec<CodeOutput>, String> {
    let prefix = sanitize_prefix(&req.prefix, "TSFG");
    let factory_id = sanitize_factory_id(&req.company_id);

    let codes = generators::unit::generate_batch(
        prefix,
        1,
        req.count,
        "PACKET-STANDALONE-001-ABC-DEF".to_string(),
        factory_id,
    )
    .map_err(|e| e.to_string())?;

    Ok(map_to_output(codes, &req.prefix))
}

// ─── Helpers ─────────────────────────────────────────────────────

/// Ensure prefix is 4 uppercase letters. Falls back to default if invalid.
fn sanitize_prefix(input: &str, default: &str) -> String {
    let trimmed = input.trim().to_uppercase();
    if trimmed.len() == 4 && trimmed.chars().all(|c| c.is_ascii_uppercase()) {
        trimmed
    } else {
        default.to_string()
    }
}

/// Ensure factory_id is non-empty.
fn sanitize_factory_id(input: &str) -> String {
    let trimmed = input.trim().to_string();
    if trimmed.is_empty() {
        "DEFAULT-FACTORY".to_string()
    } else {
        trimmed
    }
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
