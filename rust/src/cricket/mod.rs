//! Cricket scoring math — pure, deterministic aggregation over a delivery
//! log. Phase 2's correction engine calls this via:
//!
//!   trace_odd_rust cricket --recompute
//!
//! consuming a JSON payload on stdin:
//!
//! ```json
//! {
//!   "overs_per_side": 20,
//!   "player_names": { "<player-uuid>": "Rahman Khan" },
//!   "deliveries": [ { "ball_id": "...", "runs": 4, "batter_id": "...", ... } ]
//! }
//! ```
//!
//! The math mirrors `LiveScoreService` (PHP) rule-for-rule so the two
//! implementations never drift:
//!   - Wide / bye / leg-bye runs are not credited to the striker.
//!   - No-ball: only the runs beyond the penalty run are credited.
//!   - Byes and leg-byes are never charged to the bowler; wide/no-ball
//!     penalty runs are.
//!   - Bowlers are not credited for run outs.
//!   - Strike rotation: odd runs cross, over completion swaps ends,
//!     wickets bring in `next_batter_id`.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::io::Read;

/// Legal deliveries per over.
pub const BALLS_PER_OVER: i64 = 6;

/// One recorded delivery. Tolerates legacy rows that only carry
/// `runs` / `extras_type` / `is_wicket`.
#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "snake_case", default)]
pub struct Delivery {
    pub ball_id: Option<String>,
    pub over_number: u32,
    pub ball_number: u32,
    pub is_legal: Option<bool>,
    pub batter_id: Option<String>,
    pub non_striker_id: Option<String>,
    pub bowler_id: Option<String>,
    pub runs: i64,
    pub batter_runs: Option<i64>,
    pub extras_type: Option<String>,
    pub is_wicket: bool,
    pub wicket_type: Option<String>,
    pub dismissed_player_id: Option<String>,
    pub retired_player_id: Option<String>,
    pub fielder_id: Option<String>,
    pub next_batter_id: Option<String>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "snake_case")]
pub struct RecomputeRequest {
    pub overs_per_side: u32,
    pub deliveries: Vec<Delivery>,
    #[serde(default)]
    pub player_names: BTreeMap<String, String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct RecomputeResult {
    pub total_runs: i64,
    pub total_wickets: i64,
    pub total_balls: i64,
    pub total_overs: f64,
    pub extras: ExtrasSummary,
    pub fall_of_wickets: Vec<FallOfWicket>,
    pub batting_scorecard: Vec<BatterAgg>,
    pub bowling_scorecard: Vec<BowlerAgg>,
    pub current: CurrentPlayers,
    pub partnership: Partnership,
    pub max_overs_per_bowler: u32,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct ExtrasSummary {
    pub wides: i64,
    pub no_balls: i64,
    pub byes: i64,
    pub leg_byes: i64,
    pub total: i64,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct FallOfWicket {
    pub wicket_number: i64,
    pub runs: i64,
    pub overs: f64,
    pub player_out_id: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct BatterAgg {
    pub player_id: String,
    pub name: String,
    pub batting_order: Option<i64>,
    pub runs: i64,
    pub balls: i64,
    pub fours: i64,
    pub sixes: i64,
    pub strike_rate: f64,
    pub dismissed: bool,
    pub dismissal: Option<String>,
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct BowlerAgg {
    pub player_id: String,
    pub name: String,
    pub balls: i64,
    pub overs: f64,
    pub maidens: i64,
    pub runs: i64,
    pub wickets: i64,
    pub economy: f64,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct CurrentPlayers {
    pub striker_id: Option<String>,
    pub non_striker_id: Option<String>,
    pub bowler_id: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct Partnership {
    pub runs: i64,
    pub balls: i64,
}

/// Runs credited to the striker for a delivery.
pub fn batter_runs(runs: i64, extras: Option<&str>) -> i64 {
    match extras {
        Some("wide") | Some("bye") | Some("leg_bye") => 0,
        Some("no_ball") => (runs - 1).max(0),
        _ => runs,
    }
}

/// A delivery counts toward the over unless it is a wide or no-ball.
pub fn is_legal(d: &Delivery) -> bool {
    if let Some(v) = d.is_legal {
        return v;
    }
    !matches!(d.extras_type.as_deref(), Some("wide") | Some("no_ball"))
}

/// A wicket stands unless it is a non-run-out dismissal off a no-ball.
pub fn is_wicket(d: &Delivery) -> bool {
    if !d.is_wicket {
        return false;
    }
    // Off a no-ball the only possible dismissal is a run out.
    !(d.extras_type.as_deref() == Some("no_ball") && d.wicket_type.as_deref() != Some("run_out"))
}

/// Cricket overs notation: 10 legal balls = 1.4 overs.
pub fn overs_for_balls(balls: i64) -> f64 {
    (balls / BALLS_PER_OVER) as f64 + ((balls % BALLS_PER_OVER) as f64) / 10.0
}

/// A bowler may bowl at most 20% of the innings overs, rounded up
/// (T20 = 4, ODI = 10, T10 = 2).
pub fn max_overs_per_bowler(overs_per_side: u32) -> u32 {
    let overs = overs_per_side.max(1);
    ((overs as f64) / 5.0).ceil().max(1.0) as u32
}

fn extras_increments(d: &Delivery) -> (i64, i64, i64, i64) {
    match d.extras_type.as_deref() {
        Some("wide") => (1, 0, (d.runs - 1).max(0), 0),
        Some("no_ball") => (0, 1, 0, 0),
        Some("bye") => (0, 0, d.runs, 0),
        Some("leg_bye") => (0, 0, 0, d.runs),
        _ => (0, 0, 0, 0),
    }
}

fn round2(x: f64) -> f64 {
    (x * 100.0).round() / 100.0
}

/// Rebuild every aggregate from the delivery log. Mirrors
/// `LiveScoreService::rebuildInningsAggregates` in PHP.
pub fn recompute(req: &RecomputeRequest) -> RecomputeResult {
    let mut runs: i64 = 0;
    let mut wickets: i64 = 0;
    let mut balls: i64 = 0;
    let mut legal_balls: i64 = 0;
    let mut wides: i64 = 0;
    let mut no_balls: i64 = 0;
    let mut byes: i64 = 0;
    let mut leg_byes: i64 = 0;
    let mut fall_of_wickets: Vec<FallOfWicket> = Vec::new();

    let mut batting: BTreeMap<String, BatterAgg> = BTreeMap::new();
    let mut bowling: BTreeMap<String, BowlerAgg> = BTreeMap::new();

    let mut striker: Option<String> = None;
    let mut non_striker: Option<String> = None;
    let mut bowler: Option<String> = None;

    // Phase 5 — free-hit tracking: the legal ball after a no-ball.
    let mut prev_was_no_ball = false;

    let name_of = |id: &str| {
        req.player_names
            .get(id)
            .cloned()
            .unwrap_or_else(|| id.to_string())
    };

    for d in &req.deliveries {
        let legal = is_legal(d);
        let free_hit = prev_was_no_ball && legal;
        // On a free hit only a run out can dismiss the batter.
        let wicket = is_wicket(d) && !(free_hit && d.wicket_type.as_deref() != Some("run_out"));
        let br = batter_runs(d.runs, d.extras_type.as_deref());
        let (w, nb, b, lb) = extras_increments(d);
        prev_was_no_ball = d.extras_type.as_deref() == Some("no_ball");

        runs += d.runs;
        if wicket {
            wickets += 1;
        }
        if legal {
            balls += 1;
            legal_balls += 1;
        }
        wides += w;
        no_balls += nb;
        byes += b;
        leg_byes += lb;

        if wicket {
            fall_of_wickets.push(FallOfWicket {
                wicket_number: wickets,
                runs,
                overs: overs_for_balls(balls),
                player_out_id: d.dismissed_player_id.clone(),
            });
        }

        // Batting — ensure rows for the striker and the dismissed batter.
        let batter_id = d.batter_id.clone();
        let out_id = d.dismissed_player_id.clone();
        for pid in [batter_id.as_deref(), out_id.as_deref()]
            .into_iter()
            .flatten()
        {
            batting.entry(pid.to_string()).or_insert_with(|| BatterAgg {
                player_id: pid.to_string(),
                name: name_of(pid),
                batting_order: None,
                runs: 0,
                balls: 0,
                fours: 0,
                sixes: 0,
                strike_rate: 0.0,
                dismissed: false,
                dismissal: None,
            });
        }
        if let Some(pid) = &batter_id {
            let entry = batting.get_mut(pid).expect("row created above");
            entry.runs += br;
            if legal {
                entry.balls += 1;
            }
            if br == 4 {
                entry.fours += 1;
            }
            if br == 6 {
                entry.sixes += 1;
            }
        }
        if wicket {
            if let Some(pid) = &out_id {
                let entry = batting.get_mut(pid).expect("row created above");
                entry.dismissed = true;
                entry.dismissal = Some(d.wicket_type.clone().unwrap_or_else(|| "out".into()));
            }
        }

        // Bowling — byes/leg-byes not charged; wide/no-ball penalty is.
        if let Some(bid) = &d.bowler_id {
            let charged = br
                + if matches!(d.extras_type.as_deref(), Some("wide") | Some("no_ball")) {
                    1
                } else {
                    0
                };
            let entry = bowling.entry(bid.clone()).or_insert_with(|| BowlerAgg {
                player_id: bid.clone(),
                name: name_of(bid),
                balls: 0,
                overs: 0.0,
                maidens: 0,
                runs: 0,
                wickets: 0,
                economy: 0.0,
            });
            if legal {
                entry.balls += 1;
            }
            entry.runs += charged;
            if wicket && d.wicket_type.as_deref() != Some("run_out") {
                entry.wickets += 1;
            }
        }

        // Current-state replay (same rules as PHP).
        if let Some(id) = &d.batter_id {
            striker = Some(id.clone());
        }
        if let Some(id) = &d.non_striker_id {
            non_striker = Some(id.clone());
        }
        if let Some(id) = &d.bowler_id {
            bowler = Some(id.clone());
        }

        if wicket || d.retired_player_id.is_some() {
            let out_id = d
                .dismissed_player_id
                .clone()
                .or_else(|| d.retired_player_id.clone());
            if let Some(out) = out_id {
                if striker.as_deref() == Some(out.as_str()) {
                    striker = d.next_batter_id.clone();
                } else if non_striker.as_deref() == Some(out.as_str()) {
                    non_striker = d.next_batter_id.clone();
                }
            }
        }

        if legal && legal_balls % BALLS_PER_OVER == 0 {
            std::mem::swap(&mut striker, &mut non_striker);
            bowler = None;
        } else if legal && !wicket && br % 2 == 1 {
            std::mem::swap(&mut striker, &mut non_striker);
        }
    }

    // Finalize rates + deterministic ordering.
    let mut batting: Vec<BatterAgg> = batting.into_values().collect();
    for entry in &mut batting {
        if entry.balls > 0 {
            entry.strike_rate = round2((entry.runs as f64 / entry.balls as f64) * 100.0);
        }
    }
    batting.sort_by(|a, b| {
        let ao = a.batting_order.unwrap_or(i64::MAX);
        let bo = b.batting_order.unwrap_or(i64::MAX);
        ao.cmp(&bo).then_with(|| a.name.cmp(&b.name))
    });

    let mut bowling: Vec<BowlerAgg> = bowling.into_values().collect();
    for entry in &mut bowling {
        entry.overs = overs_for_balls(entry.balls);
        if entry.balls > 0 {
            entry.economy = round2(entry.runs as f64 / (entry.balls as f64 / 6.0));
        }
    }

    // Partnership — runs & balls since the last wicket.
    let (p_runs, p_balls) = {
        let mut pr: i64 = 0;
        let mut pb: i64 = 0;
        let mut active = false;
        for d in &req.deliveries {
            if is_wicket(d) {
                active = true;
                pr = 0;
                pb = 0;
                continue;
            }
            if active {
                pr += d.runs;
                if is_legal(d) {
                    pb += 1;
                }
            }
        }
        (pr, pb)
    };

    RecomputeResult {
        total_runs: runs,
        total_wickets: wickets,
        total_balls: balls,
        total_overs: overs_for_balls(balls),
        extras: ExtrasSummary {
            wides,
            no_balls,
            byes,
            leg_byes,
            total: wides + no_balls + byes + leg_byes,
        },
        fall_of_wickets,
        batting_scorecard: batting,
        bowling_scorecard: bowling,
        current: CurrentPlayers {
            striker_id: striker,
            non_striker_id: non_striker,
            bowler_id: bowler,
        },
        partnership: Partnership {
            runs: p_runs,
            balls: p_balls,
        },
        max_overs_per_bowler: max_overs_per_bowler(req.overs_per_side),
    }
}

/// CLI entry: `trace_odd_rust cricket --recompute` (JSON on stdin).
pub fn handle_recompute_command() -> Result<(), Box<dyn std::error::Error>> {
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input)?;
    let request: RecomputeRequest = serde_json::from_str(&input)?;
    let result = recompute(&request);
    println!("{}", serde_json::to_string(&result)?);
    Ok(())
}

// ── Tests ──────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn ball(batter: Option<&str>, non_striker: Option<&str>, bowler: Option<&str>) -> Delivery {
        Delivery {
            batter_id: batter.map(String::from),
            non_striker_id: non_striker.map(String::from),
            bowler_id: bowler.map(String::from),
            ..Default::default()
        }
    }

    fn extras_ball(
        runs: i64,
        extras: &str,
        batter: Option<&str>,
        non_striker: Option<&str>,
        bowler: Option<&str>,
    ) -> Delivery {
        Delivery {
            runs,
            extras_type: Some(extras.to_string()),
            batter_id: batter.map(String::from),
            non_striker_id: non_striker.map(String::from),
            bowler_id: bowler.map(String::from),
            ..Default::default()
        }
    }

    fn recompute_with(deliveries: Vec<Delivery>) -> RecomputeResult {
        let mut names = BTreeMap::new();
        for (id, name) in [
            ("a", "Batter A"),
            ("b", "Batter B"),
            ("c", "Batter C"),
            ("x", "Bowler X"),
            ("y", "Bowler Y"),
        ] {
            names.insert(id.to_string(), name.to_string());
        }
        recompute(&RecomputeRequest {
            overs_per_side: 20,
            deliveries,
            player_names: names,
        })
    }

    #[test]
    fn batter_runs_attribution_rules() {
        assert_eq!(batter_runs(4, None), 4);
        assert_eq!(batter_runs(1, Some("wide")), 0);
        assert_eq!(batter_runs(2, Some("bye")), 0);
        assert_eq!(batter_runs(3, Some("leg_bye")), 0);
        assert_eq!(batter_runs(5, Some("no_ball")), 4);
        assert_eq!(batter_runs(1, Some("no_ball")), 0);
    }

    #[test]
    fn bowler_over_limits() {
        assert_eq!(max_overs_per_bowler(20), 4);
        assert_eq!(max_overs_per_bowler(50), 10);
        assert_eq!(max_overs_per_bowler(10), 2);
        assert_eq!(max_overs_per_bowler(5), 1);
        assert_eq!(max_overs_per_bowler(17), 4);
    }

    #[test]
    fn full_over_swaps_ends_and_resets_bowler() {
        let deliveries: Vec<Delivery> = [0, 1, 0, 2, 1, 0]
            .iter()
            .map(|&runs| ball(Some("a"), Some("b"), Some("x")).with_runs(runs))
            .collect();

        let result = recompute_with(deliveries);

        assert_eq!(result.total_runs, 4);
        assert_eq!(result.total_balls, 6);
        assert_eq!(result.total_overs, 1.0);
        // Ends swapped, new bowler required.
        assert_eq!(result.current.striker_id.as_deref(), Some("b"));
        assert_eq!(result.current.non_striker_id.as_deref(), Some("a"));
        assert_eq!(result.current.bowler_id, None);
    }

    #[test]
    fn wide_and_no_ball_do_not_advance_the_over() {
        let mut deliveries: Vec<Delivery> = [0, 1, 0, 2, 0, 1]
            .iter()
            .map(|&runs| ball(Some("a"), Some("b"), Some("x")).with_runs(runs))
            .collect();
        deliveries.push(extras_ball(1, "wide", Some("a"), Some("b"), Some("x")));
        deliveries.push(extras_ball(2, "no_ball", Some("a"), Some("b"), Some("x")));

        let result = recompute_with(deliveries.clone());
        assert_eq!(result.total_balls, 6);
        assert_eq!(result.total_runs, 7); // 4 + 1 wide + 2 nb
        assert_eq!(result.extras.wides, 1);
        assert_eq!(result.extras.no_balls, 1);
        assert_eq!(result.extras.total, 2);
        assert_eq!(result.total_overs, 1.0);

        // The next legal delivery starts over two.
        deliveries.push(ball(Some("a"), Some("b"), Some("x")).with_runs(0));
        let result = recompute_with(deliveries);
        assert_eq!(result.total_balls, 7);
        assert_eq!(result.total_overs, 1.1);
        assert_eq!(result.current.bowler_id.as_deref(), Some("x"));
    }

    #[test]
    fn wicket_replacement_and_fall_of_wickets() {
        let deliveries = vec![
            ball(Some("a"), Some("b"), Some("x")).with_runs(2),
            ball(Some("a"), Some("b"), Some("x")).with_wicket("bowled", Some("a"), Some("c")),
            ball(Some("c"), Some("b"), Some("x")).with_runs(1),
        ];
        let result = recompute_with(deliveries);

        assert_eq!(result.total_wickets, 1);
        assert_eq!(result.fall_of_wickets.len(), 1);
        let fow = &result.fall_of_wickets[0];
        assert_eq!(fow.wicket_number, 1);
        assert_eq!(fow.runs, 2);
        assert_eq!(fow.player_out_id.as_deref(), Some("a"));

        // Replacement batter faced the next ball; odd run crossed after.
        assert_eq!(result.current.striker_id.as_deref(), Some("b"));
        assert_eq!(result.current.non_striker_id.as_deref(), Some("c"));

        // Batter A dismissed; bowler X credited with the wicket.
        let a = result
            .batting_scorecard
            .iter()
            .find(|e| e.player_id == "a")
            .expect("batter A present");
        assert!(a.dismissed);
        assert_eq!(a.dismissal.as_deref(), Some("bowled"));

        let x = result
            .bowling_scorecard
            .iter()
            .find(|e| e.player_id == "x")
            .expect("bowler X present");
        assert_eq!(x.wickets, 1);
        assert_eq!(x.balls, 3);
        assert_eq!(x.runs, 3); // 2 + 0 + 1
    }

    #[test]
    fn bowler_is_not_charged_byes_or_credited_run_outs() {
        let deliveries = vec![
            ball(Some("a"), Some("b"), Some("x")).with_runs(4),
            extras_ball(2, "bye", Some("a"), Some("b"), Some("x")),
            ball(Some("a"), Some("b"), Some("x")).with_wicket("run_out", Some("a"), Some("c")),
        ];
        let result = recompute_with(deliveries);

        let x = result
            .bowling_scorecard
            .iter()
            .find(|e| e.player_id == "x")
            .expect("bowler X present");
        assert_eq!(x.runs, 4); // byes not charged
        assert_eq!(x.wickets, 0); // run out not credited

        // Batter A dismissed via run out; runs stay at 4.
        let a = result
            .batting_scorecard
            .iter()
            .find(|e| e.player_id == "a")
            .expect("batter A present");
        assert!(a.dismissed);
        assert_eq!(a.runs, 4);
    }

    #[test]
    fn no_ball_hit_for_four_credits_batter_and_bowler() {
        let deliveries = vec![extras_ball(5, "no_ball", Some("a"), Some("b"), Some("x"))];
        let result = recompute_with(deliveries);

        assert_eq!(result.total_runs, 5);
        assert_eq!(result.extras.no_balls, 1);

        let a = result
            .batting_scorecard
            .iter()
            .find(|e| e.player_id == "a")
            .expect("batter A present");
        assert_eq!(a.runs, 4);
        assert_eq!(a.fours, 1);

        let x = result
            .bowling_scorecard
            .iter()
            .find(|e| e.player_id == "x")
            .expect("bowler X present");
        assert_eq!(x.runs, 5); // 4 off the bat + 1 penalty
        assert_eq!(x.balls, 0); // no-ball does not count as a legal delivery
    }

    #[test]
    fn partnership_counts_since_last_wicket() {
        let deliveries = vec![
            ball(Some("a"), Some("b"), Some("x")).with_runs(1),
            ball(Some("b"), Some("a"), Some("x")).with_wicket("caught", Some("b"), Some("c")),
            ball(Some("a"), Some("c"), Some("x")).with_runs(2),
            ball(Some("a"), Some("c"), Some("x")).with_runs(0),
        ];
        let result = recompute_with(deliveries);

        assert_eq!(result.partnership.runs, 2);
        assert_eq!(result.partnership.balls, 2);
    }

    #[test]
    fn legacy_deliveries_without_attribution_recompute_cleanly() {
        let deliveries = vec![
            Delivery {
                runs: 1,
                ..Default::default()
            },
            Delivery {
                runs: 0,
                ..Default::default()
            },
            Delivery {
                runs: 4,
                extras_type: Some("wide".into()),
                ..Default::default()
            },
        ];
        let result = recompute_with(deliveries);

        assert_eq!(result.total_runs, 5);
        assert_eq!(result.total_balls, 2);
        assert_eq!(result.extras.wides, 1);
        assert_eq!(result.extras.byes, 3); // 4-run wide = 1 penalty + 3 byes
        assert_eq!(result.current.striker_id, None);
        assert_eq!(result.batting_scorecard.len(), 0);
        assert_eq!(result.bowling_scorecard.len(), 0);
    }

    #[test]
    fn free_hit_only_allows_run_outs() {
        // No-ball, then a legal delivery that is the free hit.
        let deliveries = vec![
            extras_ball(1, "no_ball", Some("a"), Some("b"), Some("x")),
            ball(Some("a"), Some("b"), Some("x")).with_wicket("bowled", Some("a"), Some("c")),
        ];
        let result = recompute_with(deliveries.clone());

        // Bowled on a free hit does not stand.
        assert_eq!(result.total_wickets, 0);
        assert_eq!(result.fall_of_wickets.len(), 0);

        // Run out on a free hit DOES stand.
        let deliveries = vec![
            extras_ball(1, "no_ball", Some("a"), Some("b"), Some("x")),
            ball(Some("a"), Some("b"), Some("x")).with_wicket("run_out", Some("a"), Some("c")),
        ];
        let result = recompute_with(deliveries);
        assert_eq!(result.total_wickets, 1);
        assert_eq!(result.current.striker_id.as_deref(), Some("c"));
    }

    #[test]
    fn retired_hurt_replaces_batter_without_a_wicket() {
        let deliveries = vec![
            ball(Some("a"), Some("b"), Some("x")).with_runs(2),
            Delivery {
                batter_id: Some("a".into()),
                non_striker_id: Some("b".into()),
                bowler_id: Some("x".into()),
                retired_player_id: Some("a".into()),
                next_batter_id: Some("c".into()),
                ..Default::default()
            },
            ball(Some("c"), Some("b"), Some("x")).with_runs(1),
        ];
        let result = recompute_with(deliveries);

        assert_eq!(result.total_wickets, 0);
        assert_eq!(result.fall_of_wickets.len(), 0);
        // Odd run crossed after the replacement.
        assert_eq!(result.current.striker_id.as_deref(), Some("b"));
        assert_eq!(result.current.non_striker_id.as_deref(), Some("c"));
    }

    // Test builders
    impl Delivery {
        fn with_runs(self, runs: i64) -> Delivery {
            Delivery { runs, ..self }
        }

        fn with_wicket(
            self,
            wicket_type: &str,
            dismissed: Option<&str>,
            next_batter: Option<&str>,
        ) -> Delivery {
            Delivery {
                is_wicket: true,
                wicket_type: Some(wicket_type.to_string()),
                dismissed_player_id: dismissed.map(String::from),
                next_batter_id: next_batter.map(String::from),
                ..self
            }
        }
    }
}
