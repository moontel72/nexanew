#!/usr/bin/env node
// Desktop build launcher for Todd Studio.
//
// Bakes the committed `.env.desktop` template into the packaged app:
// every VITE_* value is injected into the process environment before
// `tauri build` runs, so the inner `vite build` (production mode)
// freezes those values into `import.meta.env`. Shell-provided variables
// of the same name always win — override per build:
//
//   PowerShell:  $env:VITE_API_BASE_URL="http://10.0.0.5:8080"; npm run build:desktop
//   bash:        VITE_API_BASE_URL=http://10.0.0.5:8080 npm run build:desktop
//
// Extra CLI args are forwarded to the tauri CLI, e.g.:
//   npm run build:desktop -- --bundles nsis
//
// `--dry-run` prints the resolved environment and exits without building.

import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { loadEnv } from "vite";

const guiRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const passthrough = args.filter((arg) => arg !== "--dry-run");

// 1. Desktop defaults from the committed template.
const desktopEnv = loadEnv("desktop", guiRoot, "VITE_");

// 2. Pre-set shell variables win over the template.
for (const [key, value] of Object.entries(desktopEnv)) {
  if (process.env[key] === undefined) {
    process.env[key] = value;
  }
}

console.log("[build-desktop] resolved environment:");
for (const key of Object.keys(desktopEnv).sort()) {
  console.log(`  ${key}=${process.env[key] ?? ""}`);
}

if (dryRun) {
  console.log("[build-desktop] dry run — skipping `tauri build`");
  process.exit(0);
}

// 3. Run the Tauri CLI (NSIS + MSI installers on Windows via
//    `bundle.targets: "all"` in tauri.conf.json). `shell: true` on
//    Windows so spawnSync resolves `npm` through the shell (npm.cmd).
const npm = process.platform === "win32" ? "npm" : "npm";
const result = spawnSync(npm, ["run", "tauri", "--", "build", ...passthrough], {
  cwd: guiRoot,
  stdio: "inherit",
  env: process.env,
  shell: process.platform === "win32",
});
if (result.error) {
  console.error(`[build-desktop] failed to launch ${npm}: ${result.error.message}`);
  process.exit(1);
}
if (result.status !== 0) {
  console.error(
    `[build-desktop] tauri build exited with ${result.status}` +
      (result.signal ? ` (signal ${result.signal})` : ""),
  );
}
process.exit(result.status ?? 1);
