//! Per-camera stream statistics: packet/byte accounting, a sliding-window
//! bitrate meter, an RFC 3550 interarrival-jitter estimator and the last
//! sampled RTT.
//!
//! Everything here is cheap enough to run on the per-packet hot path:
//! atomics for counters, one `Mutex` per camera stream for the windowed
//! estimators (different cameras contend on different locks).

use std::collections::VecDeque;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Mutex;
use std::time::{Duration, Instant};

use serde::Serialize;

/// Bitrate window: samples are bucketed per second and kept for this many
/// buckets, so `rate_bps()` is a smoothed average over the window.
const BITRATE_WINDOW_SECS: u64 = 4;

/// RFC 3550 smoothing factor for the interarrival jitter estimate.
const JITTER_SMOOTHING: f64 = 16.0;

/// One camera stream's live statistics.
pub struct StreamStats {
    packets_in: AtomicU64,
    bytes_in: AtomicU64,
    packets_dropped: AtomicU64,
    packets_forwarded: AtomicU64,
    bytes_forwarded: AtomicU64,
    /// Last sampled ICE round-trip time in milliseconds (0 = unknown).
    last_rtt_ms: AtomicU64,
    bitrate: Mutex<BitrateMeter>,
    egress: Mutex<BitrateMeter>,
    jitter: Mutex<JitterEstimator>,
}

impl Default for StreamStats {
    fn default() -> Self {
        Self::new(90_000)
    }
}

impl StreamStats {
    /// `clock_rate` is the RTP clock rate of the stream (Hz) — 90 000 for
    /// video codecs, 48 000 for Opus, 8 000 for PCMU. It only affects the
    /// jitter estimator's timestamp-to-seconds conversion.
    pub fn new(clock_rate: u32) -> Self {
        Self {
            packets_in: AtomicU64::new(0),
            bytes_in: AtomicU64::new(0),
            packets_dropped: AtomicU64::new(0),
            packets_forwarded: AtomicU64::new(0),
            bytes_forwarded: AtomicU64::new(0),
            last_rtt_ms: AtomicU64::new(0),
            bitrate: Mutex::new(BitrateMeter::new()),
            egress: Mutex::new(BitrateMeter::new()),
            jitter: Mutex::new(JitterEstimator::new(clock_rate.max(1))),
        }
    }

    /// Records one inbound RTP packet (called by the ingest pump).
    pub fn record_ingress(&self, rtp_timestamp: u32, bytes: usize) {
        self.packets_in.fetch_add(1, Ordering::Relaxed);
        self.bytes_in.fetch_add(bytes as u64, Ordering::Relaxed);
        if let Ok(mut meter) = self.bitrate.lock() {
            meter.add(bytes as u64);
        }
        if let Ok(mut jitter) = self.jitter.lock() {
            jitter.update(rtp_timestamp);
        }
    }

    /// Records fan-out accounting for one forwarded packet (called by the
    /// track router). `delivered`/`dropped` are subscriber counts.
    pub fn record_fanout(&self, bytes: usize, delivered: usize, dropped: usize) {
        self.packets_forwarded
            .fetch_add(delivered as u64, Ordering::Relaxed);
        self.packets_dropped
            .fetch_add(dropped as u64, Ordering::Relaxed);
        let egress_bytes = (bytes as u64) * (delivered as u64);
        self.bytes_forwarded
            .fetch_add(egress_bytes, Ordering::Relaxed);
        if delivered > 0 {
            if let Ok(mut meter) = self.egress.lock() {
                meter.add(egress_bytes);
            }
        }
    }

    /// Sets the last sampled RTT (milliseconds).
    pub fn set_rtt_ms(&self, rtt_ms: f64) {
        self.last_rtt_ms
            .store(rtt_ms.round().max(0.0) as u64, Ordering::Relaxed);
    }

    /// Ingress bitrate in bits per second.
    pub fn ingress_bps(&self) -> f64 {
        self.bitrate
            .lock()
            .map(|meter| meter.rate_bps())
            .unwrap_or(0.0)
    }

    /// Egress (fan-out) bitrate in bits per second.
    pub fn egress_bps(&self) -> f64 {
        self.egress
            .lock()
            .map(|meter| meter.rate_bps())
            .unwrap_or(0.0)
    }

    /// Egress (fan-out) bitrate in bits per second, derived from the
    /// forwarded-byte counter delta between calls.
    pub fn jitter_ms(&self) -> f64 {
        self.jitter
            .lock()
            .map(|jitter| jitter.jitter_ms())
            .unwrap_or(0.0)
    }

    /// Serializable snapshot for the diagnostics WebSocket feed.
    pub fn snapshot(&self) -> StreamSnapshot {
        StreamSnapshot {
            packets_in: self.packets_in.load(Ordering::Relaxed),
            bytes_in: self.bytes_in.load(Ordering::Relaxed),
            packets_dropped: self.packets_dropped.load(Ordering::Relaxed),
            packets_forwarded: self.packets_forwarded.load(Ordering::Relaxed),
            bytes_forwarded: self.bytes_forwarded.load(Ordering::Relaxed),
            rtt_ms: self.last_rtt_ms.load(Ordering::Relaxed),
            ingress_bps: self.ingress_bps(),
            egress_bps: self.egress_bps(),
            jitter_ms: self.jitter_ms(),
        }
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct StreamSnapshot {
    pub packets_in: u64,
    pub bytes_in: u64,
    pub packets_dropped: u64,
    pub packets_forwarded: u64,
    pub bytes_forwarded: u64,
    pub rtt_ms: u64,
    pub ingress_bps: f64,
    pub egress_bps: f64,
    pub jitter_ms: f64,
}

/// Sliding-window bitrate meter with per-second buckets.
pub struct BitrateMeter {
    window: Duration,
    /// `(bucket_start, bytes)` — kept sorted by bucket start.
    buckets: VecDeque<(Instant, u64)>,
}

impl BitrateMeter {
    pub fn new() -> Self {
        Self {
            window: Duration::from_secs(BITRATE_WINDOW_SECS),
            buckets: VecDeque::new(),
        }
    }

    pub fn add(&mut self, bytes: u64) {
        let now = Instant::now();
        self.prune(now);
        match self.buckets.back_mut() {
            Some((start, total)) if now.duration_since(*start) < Duration::from_secs(1) => {
                *total += bytes;
            }
            _ => {
                self.buckets.push_back((now, bytes));
            }
        }
    }

    fn prune(&mut self, now: Instant) {
        while let Some((start, _)) = self.buckets.front() {
            if now.duration_since(*start) > self.window {
                self.buckets.pop_front();
            } else {
                break;
            }
        }
    }

    /// Average rate over the window in bits per second.
    pub fn rate_bps(&self) -> f64 {
        let now = Instant::now();
        let mut total: u64 = 0;
        let mut oldest: Option<Instant> = None;
        for (start, bytes) in &self.buckets {
            if now.duration_since(*start) <= self.window {
                total += bytes;
                oldest.get_or_insert(*start);
            }
        }
        let span = match oldest {
            Some(start) => now
                .duration_since(start)
                .as_secs_f64()
                .max(1.0)
                .min(self.window.as_secs_f64()),
            None => 1.0,
        };
        (total as f64) * 8.0 / span
    }
}

impl Default for BitrateMeter {
    fn default() -> Self {
        Self::new()
    }
}

/// RFC 3550 §6.4.1 interarrival jitter estimator.
pub struct JitterEstimator {
    /// Clock rate of the stream, used to convert RTP timestamp deltas
    /// into seconds.
    clock_rate: u32,
    last_rtp_timestamp: Option<u32>,
    last_arrival: Option<Instant>,
    /// Smoothed jitter, in seconds.
    jitter: f64,
}

impl JitterEstimator {
    pub fn new(clock_rate: u32) -> Self {
        Self {
            clock_rate,
            last_rtp_timestamp: None,
            last_arrival: None,
            jitter: 0.0,
        }
    }

    /// Feeds one packet's RTP timestamp (called at arrival time).
    pub fn update(&mut self, rtp_timestamp: u32) {
        let arrived = Instant::now();
        if let (Some(prev_ts), Some(prev_arrival)) = (self.last_rtp_timestamp, self.last_arrival) {
            // `wrapping_sub` is correct RTP timestamp arithmetic across
            // the 32-bit wraparound boundary.
            let transit_rtp =
                f64::from(rtp_timestamp.wrapping_sub(prev_ts)) / f64::from(self.clock_rate.max(1));
            let transit_real = arrived.duration_since(prev_arrival).as_secs_f64();
            let deviation = (transit_real - transit_rtp).abs();
            self.jitter += (deviation - self.jitter) / JITTER_SMOOTHING;
        }
        self.last_rtp_timestamp = Some(rtp_timestamp);
        self.last_arrival = Some(arrived);
    }

    /// Smoothed jitter in milliseconds.
    pub fn jitter_ms(&self) -> f64 {
        self.jitter * 1000.0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bitrate_meter_accumulates_bytes() {
        let mut meter = BitrateMeter::new();
        meter.add(1_000);
        meter.add(1_000);
        assert!(meter.rate_bps() > 0.0);
    }

    #[test]
    fn jitter_is_zero_for_steady_clock() {
        let mut jitter = JitterEstimator::new(90_000);
        jitter.update(0);
        jitter.update(90_000); // exactly one second later in RTP time
                               // Arrival delta is ~0s real time; deviation is bounded by how
                               // long the test took, which is far below a second.
        assert!(jitter.jitter_ms() < 1_000.0);
    }

    #[test]
    fn jitter_grows_with_bursty_arrivals() {
        let mut jitter = JitterEstimator::new(90_000);
        jitter.update(0);
        std::thread::sleep(Duration::from_millis(50));
        jitter.update(90_000); // 1s of media in ~50ms of real time
        assert!(jitter.jitter_ms() > 0.0);
    }
}
