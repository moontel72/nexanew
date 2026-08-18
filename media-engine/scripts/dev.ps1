<#
.SYNOPSIS
  Dev helper for the T-Odd media engine on Windows.

.DESCRIPTION
  GStreamer forwarding is a non-default cargo feature, so plain
  check/build/test/run already bypasses every system C library (no
  GStreamer, no MSVC Build Tools needed). This script only adds the one
  environment fix the GNU toolchain needs on Windows: MSYS2's gcc on PATH
  (the `ring` crate inside webrtc-rs compiles a small amount of C/asm).
  With the MSVC toolchain active, no injection happens at all.

.EXAMPLE
  .\scripts\dev.ps1              # cargo check --workspace (fast API dev)
  .\scripts\dev.ps1 build        # cargo build --workspace
  #  .\scripts\dev.ps1 run          # cargo run -p todd-signaling
  .\scripts\dev.ps1 test         # cargo test --workspace
  .\scripts\dev.ps1 clippy       # cargo clippy --workspace --all-targets
  .\scripts\dev.ps1 fmt          # cargo fmt --all

.NOTES
  To enable GStreamer pipelines on Windows you additionally need Visual
  Studio Build Tools + the official GStreamer 1.24 MSVC runtime/dev
  installers (see docs/05-local-dev-windows.md). For quick API dev, leave
  the feature off — WHIP ingestion and routing work without it.
#>
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$action = if ($args.Count -ge 1) { $args[0] } else { "check" }
$rest = @()
if ($args.Count -ge 2) { $rest = $args[1..($args.Count - 1)] }

# GNU toolchain: make sure MSYS2's gcc is reachable for ring's build script.
$tc = & rustup show active-toolchain 2>$null
if ($LASTEXITCODE -eq 0 -and $tc -match "gnu") {
    $mingw = "C:\msys64\mingw64\bin"
    $already = $env:PATH -split ";" | Where-Object { $_ -eq $mingw }
    if ((Test-Path $mingw) -and (-not $already)) {
        $env:PATH = "$mingw;$env:PATH"
        Write-Host "[dev] injected $mingw into PATH" -ForegroundColor DarkGray
    }
}

Push-Location $root
try {
    switch ($action) {
        "run"    { & cargo run -p todd-signaling @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        "check"  { & cargo check --workspace @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        "build"  { & cargo build --workspace @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        "test"   { & cargo test --workspace @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        "clippy" { & cargo clippy --workspace --all-targets @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        "fmt"    { & cargo fmt --all @rest; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }
        default {
            Write-Host "usage: dev.ps1 [check|build|run|test|clippy|fmt] [cargo args...]"
            exit 2
        }
    }
} finally {
    Pop-Location
}
