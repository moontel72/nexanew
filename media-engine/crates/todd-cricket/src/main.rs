//! `todd-cricket` CLI — drop-in replacement for the legacy
//! `trace_odd_rust cricket --recompute` command.
//!
//! Reads a [`todd_cricket::RecomputeRequest`] JSON payload on stdin and
//! prints the [`todd_cricket::RecomputeResult`] JSON on stdout:
//!
//! ```json
//! {
//!   "overs_per_side": 20,
//!   "player_names": { "<player-uuid>": "Rahman Khan" },
//!   "deliveries": [ { "ball_id": "...", "runs": 4, "batter_id": "...", ... } ]
//! }
//! ```

use std::io::Read;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input)?;
    let request: todd_cricket::RecomputeRequest = serde_json::from_str(&input)?;
    let result = todd_cricket::recompute(&request);
    println!("{}", serde_json::to_string(&result)?);
    Ok(())
}
