//! Per-interface ICE candidate harvesting policy.
//!
//! Replaces the previous global IPv4-only blanket
//! (`set_network_types([Udp4, Tcp4])`) with an adaptive, per-host policy:
//!
//! - Interfaces are enumerated at startup (`local-ip-address`).
//! - `ICE_INTERFACES` allow-lists candidate interfaces by name;
//!   `ICE_INTERFACE_DENY` (prefix-matched) excludes virtual adapter
//!   families (docker/veth/vmware/hyper-v/wsl/...).
//! - Link-local, APIPA and loopback addresses are always excluded —
//!   they are never routable and only produce ICE pairs that time out.
//! - UDP6/TCP6 candidates are gathered only when the host actually has a
//!   global unicast IPv6 address on an allowed interface. IPv4-only hosts
//!   never emit IPv6 pairs again; dual-stack hosts keep full IPv6.
//! - `ICE_PUBLIC_IPS` advertises 1:1 NAT public addresses as host
//!   candidates (generalizes the old loopback-only dev hack).
//! - `ICE_UDP_PORT_MIN/MAX` pins the ephemeral UDP port range via a bound
//!   `EphemeralUDP` network (replaces ad-hoc port-pinning with the
//!   supported webrtc-ice mechanism).
//! - ICE timeouts (disconnected / failed / keep-alive) are tuned from
//!   settings for fast, deterministic `Disconnected` detection — the
//!   keep-alive STUN traffic is ICE consent freshness in action.

use std::net::IpAddr;
use std::sync::Arc;
use std::time::Duration;

use todd_common::config::Settings;
use webrtc_ice::network_type::NetworkType;

/// Interface-name filter, shared by the engine config.
pub type InterfaceFilterFn = Arc<dyn Fn(&str) -> bool + Send + Sync>;
/// IP-address filter, shared by the engine config.
pub type IpFilterFn = Arc<dyn Fn(IpAddr) -> bool + Send + Sync>;

/// The resolved network policy handed to the webrtc-rs `SettingEngine`.
#[derive(Clone)]
pub struct IceNetworkPolicy {
    pub network_types: Vec<NetworkType>,
    pub interface_filter: Option<InterfaceFilterFn>,
    pub ip_filter: Option<IpFilterFn>,
    pub nat_1to1_ips: Vec<String>,
    pub udp_port_range: Option<(u16, u16)>,
    /// `(disconnected, failed, keep_alive)` — `None` keeps webrtc-rs
    /// defaults (5s / 25s / 2s).
    pub timeouts: Option<(Duration, Duration, Duration)>,
    /// Allowed `(interface_name, ip)` pairs, for startup logging.
    pub interfaces_seen: Vec<(String, IpAddr)>,
}

/// True for addresses that can never be routable ICE candidates:
/// unspecified, loopback, multicast and link-local (APIPA 169.254.0.0/16
/// and IPv6 fe80::/10).
fn is_unroutable(ip: IpAddr) -> bool {
    match ip {
        IpAddr::V4(v4) => {
            v4.is_unspecified() || v4.is_loopback() || v4.is_multicast() || v4.is_link_local()
        }
        IpAddr::V6(v6) => {
            v6.is_unspecified()
                || v6.is_loopback()
                || v6.is_multicast()
                || v6.is_unicast_link_local()
        }
    }
}

/// Builds the ICE network policy from host interfaces + settings.
/// Failures to enumerate interfaces degrade to "no host candidates,
/// STUN/TURN only" rather than aborting startup.
pub fn build_policy(settings: &Settings) -> IceNetworkPolicy {
    let interfaces: Vec<(String, IpAddr)> =
        local_ip_address::list_afinet_netifas().unwrap_or_default();

    let allow = settings.ice_interfaces.clone();
    let deny = settings.ice_deny_interfaces.clone();

    let name_denied = |name: &str| {
        deny.iter()
            .any(|d| name == d.as_str() || name.starts_with(d.as_str()))
    };
    let name_allowed = |name: &str| allow.is_empty() || allow.iter().any(|a| name == a.as_str());

    let interfaces_seen: Vec<(String, IpAddr)> = interfaces
        .iter()
        .filter(|(name, ip)| !is_unroutable(*ip) && !name_denied(name) && name_allowed(name))
        .cloned()
        .collect();

    // Every IPv6 in `interfaces_seen` already passed the routability
    // filter (no link-local/loopback/multicast), so any IPv6 present
    // means the host can actually route v6.
    let has_global_ipv6 = interfaces_seen
        .iter()
        .any(|(_, ip)| matches!(ip, IpAddr::V6(_)));

    let network_types = if has_global_ipv6 {
        vec![
            NetworkType::Udp4,
            NetworkType::Udp6,
            NetworkType::Tcp4,
            NetworkType::Tcp6,
        ]
    } else {
        vec![NetworkType::Udp4, NetworkType::Tcp4]
    };

    // The interface filter enforces the allow/deny lists at gather time;
    // the IP filter is the always-on correctness layer.
    let interface_filter: Option<InterfaceFilterFn> =
        (!allow.is_empty() || !deny.is_empty()).then(|| {
            let allow = allow.clone();
            let deny = deny.clone();
            let filter: InterfaceFilterFn = Arc::new(move |name: &str| {
                let ok = allow.is_empty() || allow.iter().any(|a| name == a.as_str());
                let bad = deny
                    .iter()
                    .any(|d| name == d.as_str() || name.starts_with(d.as_str()));
                ok && !bad
            });
            filter
        });

    let ip_filter: Option<IpFilterFn> = {
        let filter: IpFilterFn = Arc::new(|ip: IpAddr| !is_unroutable(ip));
        Some(filter)
    };

    // 1:1 NAT public IPs; loopback is appended only in dev mode.
    let mut nat_1to1_ips = settings.ice_public_ips.clone();
    if settings.ice_loopback && !nat_1to1_ips.iter().any(|ip| ip == "127.0.0.1") {
        nat_1to1_ips.push("127.0.0.1".to_string());
    }

    let udp_port_range = match (settings.ice_udp_port_min, settings.ice_udp_port_max) {
        (Some(min), Some(max)) if min <= max => Some((min, max)),
        (Some(min), Some(max)) => {
            tracing::warn!(
                min,
                max,
                "ICE_UDP_PORT_MIN > ICE_UDP_PORT_MAX; ignoring port range"
            );
            None
        }
        _ => None,
    };

    let timeouts = Some((
        Duration::from_millis(settings.ice_disconnected_timeout_ms),
        Duration::from_millis(settings.ice_failed_timeout_ms),
        Duration::from_millis(settings.ice_keepalive_interval_ms),
    ));

    IceNetworkPolicy {
        network_types,
        interface_filter,
        ip_filter,
        nat_1to1_ips,
        udp_port_range,
        timeouts,
        interfaces_seen,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unroutable_addresses_are_filtered() {
        assert!(is_unroutable("169.254.10.20".parse().unwrap()));
        assert!(is_unroutable("127.0.0.1".parse().unwrap()));
        assert!(is_unroutable("fe80::1".parse().unwrap()));
        assert!(is_unroutable("0.0.0.0".parse().unwrap()));
        assert!(!is_unroutable("192.168.1.5".parse().unwrap()));
        assert!(!is_unroutable("10.0.0.2".parse().unwrap()));
    }
}
