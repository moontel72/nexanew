//! Dev helper: mints a JWT for testing the Studio API.
//!
//! Usage:
//!   JWT_SECRET=<secret> cargo run -p todd-common --example mint_token -- admin
//!   JWT_SECRET=<secret> cargo run -p todd-common --example mint_token -- publisher <room_id> <camera_id>
//!   JWT_SECRET=<secret> TOKEN_TTL_SECS=300 cargo run -p todd-common --example mint_token -- viewer <room_id>

use todd_common::auth::{mint_token, TokenRole};

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let (role, room, camera) = match args.get(1).map(String::as_str) {
        Some("publisher") => (
            TokenRole::Publisher,
            args.get(2).cloned(),
            args.get(3).cloned(),
        ),
        Some("viewer") => (TokenRole::Viewer, args.get(2).cloned(), None),
        _ => (TokenRole::Admin, None, None),
    };

    let secret = std::env::var("JWT_SECRET").expect("JWT_SECRET env var is required");
    let issuer = std::env::var("JWT_ISSUER").unwrap_or_else(|_| "traceodd".to_string());
    let ttl: i64 = std::env::var("TOKEN_TTL_SECS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(3600);

    let token = mint_token(
        &secret,
        &issuer,
        "dev-cli",
        role,
        room.as_deref(),
        camera.as_deref(),
        &[],
        ttl,
    )
    .expect("token minting failed");

    println!("{token}");
}
