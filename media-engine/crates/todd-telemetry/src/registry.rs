//! Prometheus-style metrics registry.
//!
//! The metric set is fixed at construction (a static table of
//! name/help/kind), which keeps the registry lock-free on the hot path
//! (every metric is an independent `AtomicU64`) and makes the Prometheus
//! text exposition a trivial linear scan. Unknown metric names are
//! ignored with a warning — the engine must never panic on a metrics
//! typo.

use std::sync::atomic::{AtomicU64, Ordering};

/// Metric type, as exposed in the Prometheus text format.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MetricKind {
    Counter,
    Gauge,
}

impl MetricKind {
    fn as_str(self) -> &'static str {
        match self {
            MetricKind::Counter => "counter",
            MetricKind::Gauge => "gauge",
        }
    }
}

struct Metric {
    name: &'static str,
    help: &'static str,
    kind: MetricKind,
    value: AtomicU64,
}

/// The fixed metric table. Additions are cheap; removals/renames break
/// dashboards, so treat names as a public contract.
const METRICS: &[(&str, &str, MetricKind)] = &[
    (
        "todd_whip_ingests_total",
        "WHIP ingest sessions accepted since start.",
        MetricKind::Counter,
    ),
    (
        "todd_whip_sessions_replaced_total",
        "WHIP sessions replaced by takeover reconnects.",
        MetricKind::Counter,
    ),
    (
        "todd_whep_watches_total",
        "WHEP viewer sessions accepted since start.",
        MetricKind::Counter,
    ),
    (
        "todd_program_transitions_total",
        "Vision-switch program transitions applied.",
        MetricKind::Counter,
    ),
    (
        "todd_sessions_active",
        "Live WHIP ingest sessions.",
        MetricKind::Gauge,
    ),
    (
        "todd_viewers_active",
        "Live WHEP viewer sessions.",
        MetricKind::Gauge,
    ),
    (
        "todd_rtp_packets_in_total",
        "RTP packets read from ingest tracks.",
        MetricKind::Counter,
    ),
    (
        "todd_rtp_bytes_in_total",
        "RTP bytes read from ingest tracks.",
        MetricKind::Counter,
    ),
    (
        "todd_rtp_packets_forwarded_total",
        "RTP packets fanned out to subscribers.",
        MetricKind::Counter,
    ),
    (
        "todd_rtp_packets_dropped_total",
        "RTP packets dropped by router backpressure.",
        MetricKind::Counter,
    ),
    (
        "todd_ice_disconnects_total",
        "ICE `Disconnected` transitions observed.",
        MetricKind::Counter,
    ),
    (
        "todd_ice_failures_total",
        "ICE `Failed` transitions observed.",
        MetricKind::Counter,
    ),
    (
        "todd_ice_disconnected_closures_total",
        "Sessions proactively closed after the Disconnected grace period.",
        MetricKind::Counter,
    ),
    (
        "todd_whip_no_media_total",
        "WHIP sessions accepted but no RTP tracks registered within 10s.",
        MetricKind::Counter,
    ),
    (
        "todd_rtt_ms",
        "Last sampled ICE round-trip time in milliseconds.",
        MetricKind::Gauge,
    ),
    (
        "todd_jitter_ms",
        "Last sampled RTP interarrival jitter in milliseconds.",
        MetricKind::Gauge,
    ),
    (
        "todd_ingress_bitrate_bps",
        "Aggregate ingest bitrate in bits per second.",
        MetricKind::Gauge,
    ),
    (
        "todd_egress_bitrate_bps",
        "Aggregate fan-out bitrate in bits per second.",
        MetricKind::Gauge,
    ),
];

/// Thread-safe metrics registry over the fixed [`METRICS`] table.
pub struct Registry {
    metrics: Vec<Metric>,
}

impl Default for Registry {
    fn default() -> Self {
        Self::new()
    }
}

impl Registry {
    pub fn new() -> Self {
        let metrics = METRICS
            .iter()
            .map(|(name, help, kind)| Metric {
                name,
                help,
                kind: *kind,
                value: AtomicU64::new(0),
            })
            .collect();
        Self { metrics }
    }

    fn find(&self, name: &str) -> Option<&Metric> {
        self.metrics.iter().find(|m| m.name == name)
    }

    /// Increments a counter by one.
    pub fn inc(&self, name: &str) {
        self.add(name, 1);
    }

    /// Adds a delta (counters) or adjusts a gauge.
    pub fn add(&self, name: &str, delta: u64) {
        match self.find(name) {
            Some(metric) => {
                metric.value.fetch_add(delta, Ordering::Relaxed);
            }
            None => tracing::warn!(metric = name, "unknown metric name (ignored)"),
        }
    }

    /// Sets a gauge to an absolute value.
    pub fn set(&self, name: &str, value: u64) {
        match self.find(name) {
            Some(metric) => {
                metric.value.store(value, Ordering::Relaxed);
            }
            None => tracing::warn!(metric = name, "unknown metric name (ignored)"),
        }
    }

    /// Current value of a metric, if known.
    pub fn get(&self, name: &str) -> Option<u64> {
        self.find(name).map(|m| m.value.load(Ordering::Relaxed))
    }

    /// All metric names and values — used by the WebSocket snapshot.
    pub fn values(&self) -> Vec<(&'static str, u64)> {
        self.metrics
            .iter()
            .map(|m| (m.name, m.value.load(Ordering::Relaxed)))
            .collect()
    }

    /// Renders the Prometheus text exposition format (version 0.0.4).
    pub fn render(&self) -> String {
        let mut out = String::with_capacity(METRICS.len() * 96);
        for metric in &self.metrics {
            out.push_str("# HELP ");
            out.push_str(metric.name);
            out.push(' ');
            out.push_str(metric.help);
            out.push_str("\n# TYPE ");
            out.push_str(metric.name);
            out.push(' ');
            out.push_str(metric.kind.as_str());
            out.push('\n');
            out.push_str(metric.name);
            out.push(' ');
            out.push_str(&metric.value.load(Ordering::Relaxed).to_string());
            out.push('\n');
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn counters_accumulate_and_gauges_hold_last_value() {
        let registry = Registry::new();
        registry.inc("todd_whip_ingests_total");
        registry.inc("todd_whip_ingests_total");
        assert_eq!(registry.get("todd_whip_ingests_total"), Some(2));

        registry.set("todd_sessions_active", 7);
        registry.set("todd_sessions_active", 3);
        assert_eq!(registry.get("todd_sessions_active"), Some(3));
    }

    #[test]
    fn unknown_metrics_are_ignored_without_panicking() {
        let registry = Registry::new();
        registry.inc("todd_does_not_exist_total");
        registry.set("nope", 42);
        assert_eq!(registry.get("nope"), None);
    }

    #[test]
    fn render_is_valid_prometheus_text() {
        let registry = Registry::new();
        registry.inc("todd_whip_ingests_total");
        let text = registry.render();
        assert!(text.contains("# HELP todd_whip_ingests_total"));
        assert!(text.contains("# TYPE todd_whip_ingests_total counter"));
        assert!(text.contains("todd_whip_ingests_total 1"));
    }
}
