#!/usr/bin/env node
// Generates the Tauri updater manifest (desktop-update.json) from the
// artifacts produced by `tauri build` with `createUpdaterArtifacts`.
//
// Usage:
//   node scripts/make-update-manifest.mjs \
//     --version 0.2.0 \
//     --notes "Release notes" \
//     --bundle-dir src-tauri/target/release/bundle \
//     --base-url https://traceodd.com/download/windows \
//     --out /tmp/desktop-update.json

import fs from "node:fs";
import path from "node:path";

function arg(name, fallback = undefined) {
  const index = process.argv.indexOf(`--${name}`);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const version = arg("version", process.env.VERSION || "");
const notes = arg("notes", "");
const baseUrl = arg("base-url", "https://traceodd.com/download/windows");
const bundleDir = arg("bundle-dir", "src-tauri/target/release/bundle");
const out = arg("out", "desktop-update.json");

if (!version) {
  console.error("missing --version");
  process.exit(1);
}

// Canonical Windows update channel: the NSIS installer + its signature.
const nsisDir = path.join(bundleDir, "nsis");
if (!fs.existsSync(nsisDir)) {
  console.error(`bundle dir not found: ${nsisDir}`);
  process.exit(1);
}
const setup = fs
  .readdirSync(nsisDir)
  .filter((name) => name.endsWith("-setup.exe") && !name.endsWith(".sig"))
  .sort()
  .pop();
if (!setup) {
  console.error(`no NSIS setup found in ${nsisDir}`);
  process.exit(1);
}
const sigFile = `${setup}.sig`;
const sigPath = path.join(nsisDir, sigFile);
if (!fs.existsSync(sigPath)) {
  console.error(
    `missing signature ${sigPath} — build with TAURI_SIGNING_PRIVATE_KEY set`,
  );
  process.exit(1);
}
const signature = fs.readFileSync(sigPath, "utf8").trim();

const manifest = {
  version,
  notes,
  pub_date: new Date().toISOString(),
  platforms: {
    "windows-x86_64": {
      signature,
      url: `${baseUrl.replace(/\/+$/, "")}/${encodeURI(setup)}`,
    },
  },
};

fs.writeFileSync(out, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(
  `manifest written: v${version} → ${manifest.platforms["windows-x86_64"].url}`,
);
