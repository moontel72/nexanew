#!/usr/bin/env bash
# Dev helper for the T-Odd media engine (Linux / WSL / macOS).
#
# GStreamer forwarding is a non-default cargo feature, so these commands
# already bypass every system C library. To opt in on a host with
# libgstreamer >= 1.24 (Ubuntu 24.04 ships it):
#   ./scripts/dev.sh check --features gst
#
# Usage: ./scripts/dev.sh [check|build|run|test|clippy|fmt] [cargo args...]

set -euo pipefail
cd "$(dirname "$0")/.."

action="${1:-check}"
shift || true

case "$action" in
  run)    exec cargo run -p todd-signaling "$@" ;;
  check)  exec cargo check --workspace "$@" ;;
  build)  exec cargo build --workspace "$@" ;;
  test)   exec cargo test --workspace "$@" ;;
  clippy) exec cargo clippy --workspace --all-targets "$@" ;;
  fmt)    exec cargo fmt --all "$@" ;;
  *) echo "usage: $0 [check|build|run|test|clippy|fmt] [cargo args...]" >&2; exit 2 ;;
esac
