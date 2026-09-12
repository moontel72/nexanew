#!/usr/bin/env node
// ============================================================================
// validate-json-config.mjs — pre-commit safety net.
//
// KYUN: agar `.zed/settings.json` jaise config file ka JSON toot jaye to
// tooling chup chaap usay ignore kar deti hai (misal: Zed apni saari
// exclusions bhool jata hai) — ghalti pakri nahi jati, sirf silent damage
// hota hai. Ye script commit se pehle JSON/JSONC config files ko parse karta
// hai aur broken syntax par commit BLOCK kar deta hai.
//
// USAGE
//   node .githooks/validate-json-config.mjs                 # curated configs + staged *.json
//   node .githooks/validate-json-config.mjs a.json b.jsonc  # sirf ye files
//   node .githooks/validate-json-config.mjs --install       # core.hooksPath=.githooks set karein
//   node .githooks/validate-json-config.mjs --help
//
// EXIT: 0 = sab valid | 1 = kuch broken
//
// JSONC support: full-line `//` comments aur trailing commas handle hote hain
// (Zed / VS Code / tsconfig style), magar strict JSON bhi validate hota hai.
// Sirf FULL-LINE comments strip hote hain — is liye string ke andar likha
// `"https://example.com"` jaisa `//` safe rehta hai.
// ============================================================================

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const ROOT = (() => {
  try {
    return execFileSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" }).trim();
  } catch {
    return process.cwd();
  }
})();

// Hand-maintained config files jinka tootna tooling ko chup chaap disable karta hai.
const CURATED = [
  ".zed/settings.json",
  ".vscode/settings.json",
  "backend/composer.json",
  "backend/package.json",
  "media-engine/ui/todd-studio-gui/package.json",
  "media-engine/ui/todd-studio-gui/tsconfig.json",
  "media-engine/ui/todd-studio-gui/src-tauri/tauri.conf.json",
];

// Bade generated lockfiles — inhe pre-commit par parse karna bekaar hai.
const SKIP_STAGED = /(^|\/)(package-lock\.json|composer\.lock|yarn\.lock|pnpm-lock\.yaml)$/;
const MAX_BYTES = 5 * 1024 * 1024;

// ─────────────────────────────────────────────────────────────────────────────
// Validation
// ─────────────────────────────────────────────────────────────────────────────

/** Sirf woh lines hataao jo `//` se shuru hoti hain (string-safe). */
function stripFullLineComments(text) {
  return text
    .split(/\r?\n/)
    .filter((line) => !line.trimStart().startsWith("//"))
    .join("\n");
}

/** JSONC trailing comma (`[1,2,]`) ko strict JSON banao. */
function normalizeTrailingCommas(text) {
  return text.replace(/,\s*([\]}])/g, "$1");
}

/** Absolute character position -> { line, column } (1-based). */
function locate(text, pos) {
  const upto = text.slice(0, Math.max(0, Math.min(pos, text.length)));
  return {
    line: upto.split("\n").length,
    column: pos - upto.lastIndexOf("\n"),
  };
}

function validateFile(absPath) {
  const raw = fs.readFileSync(absPath, "utf8");
  const cleaned = stripFullLineComments(raw);

  try {
    JSON.parse(cleaned);
    return { ok: true, mode: "json" };
  } catch (strictError) {
    const lenient = normalizeTrailingCommas(cleaned);
    if (lenient !== cleaned) {
      try {
        JSON.parse(lenient);
        return { ok: true, mode: "jsonc (trailing commas)" };
      } catch {
        // fall through — report the original (strict) error
      }
    }
    const message = String(strictError?.message ?? strictError);
    const match = /position (\d+)/.exec(message);
    return { ok: false, message, ...(match ? locate(cleaned, Number(match[1])) : {}) };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Git helpers
// ─────────────────────────────────────────────────────────────────────────────

function stagedJsonFiles() {
  try {
    const out = execFileSync(
      "git",
      ["diff", "--cached", "--name-only", "--diff-filter=ACM"],
      { cwd: ROOT, encoding: "utf8" },
    );
    return out
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean)
      .filter((p) => /\.jsonc?$/i.test(p))
      .filter((p) => !SKIP_STAGED.test(p));
  } catch {
    return [];
  }
}

const rel = (abs) => path.relative(ROOT, abs).split(path.sep).join("/");

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

function printHelp() {
  console.log(
    [
      "Usage: node .githooks/validate-json-config.mjs [options] [file ...]",
      "",
      "  (no args)     curated config files + staged *.json files",
      "  <file ...>    sirf ye files validate karo",
      "  --install     git config core.hooksPath=.githooks (pre-commit hook on)",
      "  --help        ye help",
      "",
      "Exit 0 = sab valid, 1 = koi file broken.",
    ].join("\n"),
  );
}

function main() {
  const args = process.argv.slice(2);

  if (args.includes("--help") || args.includes("-h")) {
    printHelp();
    return 0;
  }

  if (args.includes("--install")) {
    execFileSync("git", ["config", "core.hooksPath", ".githooks"], {
      cwd: ROOT,
      stdio: "inherit",
    });
    console.log("✅ core.hooksPath = .githooks — pre-commit safety net active.");
    return 0;
  }

  const explicit = args.filter((a) => !a.startsWith("-"));
  const targets = explicit.length
    ? explicit.map((p) => path.resolve(ROOT, p))
    : [
        ...CURATED.map((p) => path.join(ROOT, p)),
        ...stagedJsonFiles().map((p) => path.join(ROOT, p)),
      ];

  const unique = [...new Set(targets)];
  const failures = [];
  let checked = 0;
  let skipped = 0;

  for (const abs of unique) {
    if (!fs.existsSync(abs) || !fs.statSync(abs).isFile()) {
      if (explicit.length) failures.push({ rel: rel(abs), message: "file mojood nahi hai" });
      else skipped++;
      continue;
    }

    if (fs.statSync(abs).size > MAX_BYTES) {
      skipped++;
      continue;
    }

    const res = validateFile(abs);
    if (res.ok) checked++;
    else failures.push({ rel: rel(abs), ...res });
  }

  if (failures.length === 0) {
    console.log(
      `✅ JSON config valid (${checked} file${checked === 1 ? "" : "s"} checked` +
        `${skipped ? `, ${skipped} skipped (missing/large)` : ""})`,
    );
    return 0;
  }

  console.error("");
  console.error("✗ JSON config validation FAILED — commit blocked:");
  for (const f of failures) {
    console.error("");
    console.error(`  ${f.rel}`);
    console.error(`    ${f.message}`);
    if (f.line !== undefined) {
      const lines = fs.readFileSync(path.join(ROOT, f.rel), "utf8").split(/\r?\n/);
      const from = Math.max(1, f.line - 1);
      const to = Math.min(lines.length, f.line + 1);
      for (let i = from; i <= to; i++) {
        const marker = i === f.line ? ">" : " ";
        console.error(`    ${marker} ${String(i).padStart(5)} | ${lines[i - 1] ?? ""}`);
      }
      console.error(`    ^ line ${f.line}, column ${f.column}`);
    }
  }
  console.error("");
  console.error("Pehle JSON theek karein, phir commit dobara karein.");
  console.error("(Emergency bypass: git commit --no-verify)");
  console.error("");
  return 1;
}

process.exit(main());
