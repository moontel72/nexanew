# 05 — Local Dev on Windows: Toolchain & IDE Setup

Step-by-step guide for a clean Rust development environment on Windows,
plus an explanation of the "45 red errors" that appeared in Zed and how
they were resolved.

## 1. What the red errors actually were

The workspace Zed opens (`NexaTrace_System/`) contains two Rust projects:

| Project | Errors seen | Real cause |
|---|---|---|
| `rust/` (Flutter FFI crate) | 43× `frb: proc macro server is not running` | **IDE-only.** flutter_rust_bridge v1's `#[frb]` macro is self-contained (it rewrites attributes into doc comments) but rust-analyzer could not spawn its proc-macro server because the toolchain setup was broken. `cargo check` on this crate passes with zero errors. |
| `media-engine/` | 2× type-inference false positives | **IDE-only.** Stale rust-analyzer cache from before the toolchain repair; both code sites were accepted by rustc. The engine.rs closure has since been hardened anyway (explicit `-> bool` match). |

Ground truth is always the compiler, not the IDE:

```powershell
cd C:\Ecosystem\NexaTrace_System\media-engine
cargo check --workspace --all-targets   # authoritative
```

## 2. Toolchain checklist (fixed setup)

Your current state after repair:

```powershell
rustup show                 # active toolchain: stable-x86_64-pc-windows-msvc
rustc --version             # 1.97.x
rustup toolchain list       # both gnu and msvc installed
```

What was wrong and what was done:

1. **MSVC toolchain was corrupt** ("rustc.exe not applicable to the
   toolchain"). Fixed by reinstalling:
   ```powershell
   rustup toolchain uninstall stable-x86_64-pc-windows-msvc
   rustup toolchain install stable-x86_64-pc-windows-msvc --profile minimal
   ```
2. **MSYS2 gcc was invisible to the GNU toolchain.** The `ring` crate
   (DTLS inside webrtc-rs) compiles a little C on `*-gnu` builds and needs
   gcc on PATH. Fixed permanently (user scope):
   ```powershell
   [Environment]::SetEnvironmentVariable("Path",
     [Environment]::GetEnvironmentVariable("Path","User") + ";C:\msys64\mingw64\bin",
     "User")
   ```
3. **`media-engine/rust-toolchain.toml`** pins `stable` + `rustfmt` +
   `clippy` for this workspace, so cargo and rust-analyzer always agree on
   the toolchain.

> Note: the MSVC toolchain can *check* and run rust-analyzer without any
> extra installs, but **linking** MSVC binaries needs Visual Studio Build
> Tools (see §4). The GNU toolchain links fine today via MSYS2's ld.

## 3. Make the IDE errors disappear

1. **Restart rust-analyzer**: in Zed, open the command palette
   (Ctrl+Shift+P) → `rust-analyzer: Restart server`, or close and reopen
   the workspace. After the toolchain repair, the frb proc-macro errors
   and the two false positives are gone.
2. Verify: `cargo check --workspace --all-targets` in `media-engine/` and
   `cargo check --lib` in `rust/` both finish clean.
3. **Fallback** (only if `frb` errors persist): tell rust-analyzer to skip
   expanding that macro. Add to `.zed/settings.json`:
   ```json
   {
     "lsp": {
       "rust-analyzer": {
         "procMacro": {
           "ignored": { "flutter_rust_bridge": ["frb"] }
         }
       }
     }
   }
   ```
   The `#[frb]` attributes are inert at compile time (they become doc
   comments), so skipping expansion loses nothing for editing.

## 4. Optional: GStreamer pipelines on Windows

GStreamer forwarding (`--features gst`) is a non-default feature — the
API, WHIP ingestion and routing develop fine without it. If you want the
full pipelines locally:

1. **Visual Studio Build Tools** (MSVC linker, required to link MSVC
   binaries at all):
   ```powershell
   winget install Microsoft.VisualStudio.2022.BuildTools `
     --override "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100"
   ```
2. **GStreamer 1.24.x MSVC** from <https://gstreamer.freedesktop.org/download/>
   — install *both*:
   - `gstreamer-1.0-msvc-x86_64-1.24.x.msi` (runtime)
   - `gstreamer-1.0-devel-msvc-x86_64-1.24.x.msi` (development)
3. Point cargo at it (PowerShell, one time):
   ```powershell
   [Environment]::SetEnvironmentVariable("GSTREAMER_1_0_ROOT_MSVC_X86_64",
     "C:\gstreamer\1.0\msvc_x86_64", "User")
   $p = [Environment]::GetEnvironmentVariable("Path","User")
   [Environment]::SetEnvironmentVariable("Path", "$p;C:\gstreamer\1.0\msvc_x86_64\bin", "User")
   ```
4. Build with the feature:
   ```powershell
   cargo check --workspace --features gst
   ```

Alternative: skip Windows GStreamer entirely and test pipelines in Docker
(`deploy/docker/`), where Ubuntu 24.04 + GStreamer 1.24 are pre-wired.
This is the recommended path — production runs on Linux anyway.

## 5. Daily commands

| Goal | Command |
|---|---|
| Quick API dev check (no native libs) | `.\scripts\dev.ps1` |
| Build workspace | `.\scripts\dev.ps1 build` |
| Run Studio | `.\scripts\dev.ps1 run` |
| Tests | `.\scripts\dev.ps1 test` |
| Lint / format | `.\scripts\dev.ps1 clippy` / `.\scripts\dev.ps1 fmt` |
| Full check incl. examples | `cargo check --workspace --all-targets` |

The scripts are no-ops for the environment when everything is already
configured — they only inject the MSYS2 gcc PATH when the GNU toolchain is
active, and GStreamer stays off unless you pass `--features gst`.

## 6. Troubleshooting table

| Symptom | Fix |
|---|---|
| `failed to find tool "gcc.exe"` (gnu builds) | §2.2 PATH fix, or run `scripts\dev.ps1` |
| `rustc.exe ... not applicable to the toolchain` | §2.1 reinstall that toolchain |
| `frb: proc macro server error` in IDE only | §3 restart rust-analyzer; fallback config |
| `link.exe not found` on MSVC builds | §4.1 install VS Build Tools |
| `gst ... unresolved module` | feature is off by design; add `--features gst` after §4 |
