# Never inspect generated, build, or heavy files without permission

**Rule type:** Always Apply (project-wide)
**Owner:** NexaTrace System

## Intent

This repository hides auto-generated code, build artifacts, caches, lockfiles
and heavy logs so agents stay focused on hand-written source. **Never read,
search, open or pull the files listed below into context unless the user has
explicitly given permission.**

## Do NOT inspect (without explicit permission)

- **Auto-generated code**
  - `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `*.gr.dart`, `*.gen.dart`
  - `**/generated_plugin_registrant.*`, `**/generated_plugins.cmake`
  - `**/lib/generated/**`
- **Build output / caches / vendored deps**
  - `build/`, `**/build/`, `.dart_tool/`, `**/dist/`
  - `**/target/`, `**/target_check/`, `backend/vendor/`, `**/node_modules/`
  - `**/.gradle/`, `linux/flutter/ephemeral/`, `windows/flutter/ephemeral/`
- **Lockfiles** (very large, no signal for source work)
  - `pubspec.lock`, `composer.lock`, `Cargo.lock`, `package-lock.json`,
    `yarn.lock`, `pnpm-lock.yaml`, `Gemfile.lock`
- **Logs / runtime data**
  - `*.log`, `**/logs/`, `backend/storage/`
- **Binaries, archives, media**
  - `*.tar.gz`, `*.zip`, `*.7z`, `*.apk`, `*.aab`, `*.ipa`, `*.exe`, `*.msi`,
    `*.dmg`, `*.deb`, `*.rpm`, `*.so`, `*.dll`, `*.dylib`, `*.rlib`
  - `*.mp4`, `*.mkv`, `*.mov`, `*.webm`, `*.m3u8`
- **Secrets / credentials** (never print or copy values)
  - `.env`, `.env.*`, `*.p12`, `*.jks`, `*.keystore`, `service-account*.json`

## If such a file is genuinely needed (error fix or deploy)

1. **Ask the user first.** State clearly *which file* and *why* it is needed.
2. After approval, open **only that file** — do not walk the whole directory.
3. Do not run repository-wide searches that would drag these paths into the
   results.
4. Do not keep generated content in context after the task is done.

## Why

Token/context spent on generated output is wasted and it buries the real source.
Errors inside generated files are fixed in their source, never in the generated
file itself (`*.freezed.dart` → its `*.dart` source, `*.g.dart` → the model).

## Project notes

- The same policy is enforced for the Zed agent via `.zedignore` +
  `.zed/settings.json` (`file_scan_exclusions`), with a permission-based
  `allow` / `revoke` escape hatch documented in `AGENTS.md`.
- This file is a Qoder project rule. Qoder also auto-reads the repository root
  `AGENTS.md`; on conflict, rules in `.qoder/rules/` take precedence.
- Prefer the smallest specific path when asking for access; never blanket-open
  a whole ignored category.
