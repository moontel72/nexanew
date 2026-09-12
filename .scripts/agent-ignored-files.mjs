#!/usr/bin/env node
// ============================================================================
// agent-ignored-files.mjs — escape hatch for `.zedignore` /
// `.zed/settings.json` `file_scan_exclusions`.
//
// Kyun zaroori hai:
//   Zed ignored paths ko file scan, search aur DIRECT READ se hata deta hai
//   ("Cannot read file because its path matches the worktree
//   `file_scan_exclusions` setting"). Yani jab kisi error ko theek karne ya
//   deploy ke liye koi ignored file chahiye ho, to agent usay na search kar
//   sakta hai na parh sakta hai.
//
// Ye script wo pul (bridge) hai:
//   find / explain / list  -> hidden file discover karo + wajah maloom karo
//   allow <path> --yes      -> us path ko TEMPORARILY scan/read ke qabil banao
//   revoke                  -> wapas strict (token-bachao) mode par le aao
//
// Permission rule: agent ko pehle USER se ijaazat leni hai, phir `allow`
// chalana hai (iske liye `--yes` flag lazmi hai — ek speed bump).
//
// Sirf Node built-ins; koi dependency nahi.
// ============================================================================

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const ROOT = process.cwd();
const SETTINGS = path.join(ROOT, ".zed", "settings.json");
const ZED_IGNORE = path.join(ROOT, ".zedignore");
const STATE = path.join(ROOT, ".zed", "agent-scan-overrides.json");
const WALK_SKIP = new Set([".git"]);
const WALK_BUDGET = 400_000;

// ─────────────────────────────────────────────────────────────────────────────
// glob → RegExp (repo-relative POSIX paths ke against)
// ─────────────────────────────────────────────────────────────────────────────
function globToRegExp(glob) {
  let re = "";
  for (let i = 0; i < glob.length; i++) {
    const c = glob[i];
    if (c === "*") {
      if (glob[i + 1] === "*") {
        // `**/` => koi bhi directory chain (ya kuch nahi)
        if (glob[i + 2] === "/") {
          re += "(?:.*/)?";
          i += 2;
        } else {
          re += ".*";
          i += 1;
        }
      } else {
        re += "[^/]*";
      }
    } else if (c === "?") {
      re += "[^/]";
    } else if ("\\^$.|+()[]{}".includes(c)) {
      re += "\\" + c;
    } else {
      re += c;
    }
  }
  return new RegExp(`^${re}$`);
}

function toPosix(p) {
  return p.split(path.sep).join("/");
}

// ─────────────────────────────────────────────────────────────────────────────
// settings.json parsing (comment-preserving line edits ke liye offsets)
// ─────────────────────────────────────────────────────────────────────────────
function parseArray(text, key) {
  const keyIdx = text.indexOf(`"${key}"`);
  if (keyIdx < 0) return null;
  const open = text.indexOf("[", keyIdx);
  if (open < 0) return null;

  let i = open + 1;
  let depth = 1;
  let inStr = false;
  let esc = false;
  for (; i < text.length && depth > 0; i++) {
    const c = text[i];
    if (inStr) {
      if (esc) esc = false;
      else if (c === "\\") esc = true;
      else if (c === '"') inStr = false;
    } else if (c === '"') inStr = true;
    else if (c === "[") depth++;
    else if (c === "]") depth--;
  }
  const close = i - 1;

  const inner = text.slice(open + 1, close);
  const elements = [];
  const re = /"((?:[^"\\]|\\.)*)"/g;
  let m;
  while ((m = re.exec(inner))) {
    const absStart = open + 1 + m.index;
    elements.push({
      value: JSON.parse(`"${m[1]}"`),
      lineStart: text.lastIndexOf("\n", absStart - 1) + 1,
      lineEnd: (() => {
        const nl = text.indexOf("\n", absStart + m[0].length);
        return nl < 0 ? text.length : nl + 1;
      })(),
    });
  }
  return { open, close, elements };
}

function readSettings() {
  return fs.readFileSync(SETTINGS, "utf8");
}

function writeSettings(text) {
  // Trailing comma normalize (JSONC me allowed, magar saaf rakhte hain).
  const cleaned = text.replace(/,(\s*)\]/g, "$1]").replace(/,(\s*)}/g, "$1}");
  fs.writeFileSync(SETTINGS, cleaned, "utf8");
}

/** Ek array element (string) hatao — poori line samet, comments safe. */
function removeArrayElement(text, key, value) {
  const block = parseArray(text, key);
  const el = block?.elements.find((e) => e.value === value);
  if (!el) return text;
  return text.slice(0, el.lineStart) + text.slice(el.lineEnd);
}

/**
 * Ek array element (string) add karo, agar pehle se na ho. Array mojood na ho
 * to naya array banao (aur pichhli key ke baad comma laga kar valid JSON rakho).
 */
function ensureArrayElement(text, key, value, afterKey) {
  const block = parseArray(text, key);
  if (block && block.elements.some((e) => e.value === value)) return text;

  if (!block) {
    const anchor = parseArray(text, afterKey ?? "file_scan_exclusions");
    if (!anchor) return text;
    const insertAt = text.indexOf("\n", anchor.close) + 1;
    // Pichhli property ke `]`/`}` ke baad comma lazmi hai, warna JSON toot jati hai.
    const head = text.slice(0, insertAt).replace(/([\]}\S])(\s*\n\s*)$/, "$1,$2");
    const arr = `  "${key}": [\n    "${value}"\n  ]\n`;
    return head + arr + text.slice(insertAt);
  }

  if (block.elements.length === 0) {
    return text.slice(0, block.open + 1) + `\n    "${value}"\n  ` + text.slice(block.close);
  }

  // Aakhri element se pehle insert karo (uski line intact rehti hai).
  const lastLineStart = block.elements[block.elements.length - 1].lineStart;
  return text.slice(0, lastLineStart) + `    "${value}",\n` + text.slice(lastLineStart);
}

function exclusionGlobs() {
  const block = parseArray(readSettings(), "file_scan_exclusions");
  return block ? block.elements.map((e) => e.value) : [];
}

function inclusionGlobs() {
  const block = parseArray(readSettings(), "file_scan_inclusions");
  return block ? block.elements.map((e) => e.value) : [];
}

function zedIgnoreRules() {
  if (!fs.existsSync(ZED_IGNORE)) return [];
  return fs
    .readFileSync(ZED_IGNORE, "utf8")
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith("#"));
}

/** Kya glob is path (ya iske kisi parent directory) ko match karta hai? */
function matchesPathOrAncestor(glob, relPath) {
  const parts = relPath.split("/");
  const re = globToRegExp(glob);
  for (let i = 1; i <= parts.length; i++) {
    if (re.test(parts.slice(0, i).join("/"))) return true;
  }
  return false;
}

/** In exclusion globs me se jo bhi is path ko hide karte hain (parent dirs samet). */
function hidingGlobs(relPath, globs = exclusionGlobs()) {
  return globs.filter((g) => g !== "..." && matchesPathOrAncestor(g, relPath));
}

function isGitIgnored(relPath) {
  try {
    execFileSync("git", ["check-ignore", "-q", relPath], {
      cwd: ROOT,
      stdio: "ignore",
    });
    return true;
  } catch {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FS walk (ignored dirs bhi include, taake hidden files mil sakein)
// ─────────────────────────────────────────────────────────────────────────────
function walk(dir, matcher, out, budget) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    if (budget.n <= 0) return;
    if (WALK_SKIP.has(entry.name)) continue;
    const abs = path.join(dir, entry.name);
    if (entry.isSymbolicLink()) continue;
    if (entry.isDirectory()) {
      walk(abs, matcher, out, budget);
    } else if (entry.isFile()) {
      budget.n--;
      const rel = toPosix(path.relative(ROOT, abs));
      if (matcher(rel)) out.push(rel);
    }
  }
}

function state() {
  if (!fs.existsSync(STATE)) return { overrides: [] };
  try {
    return JSON.parse(fs.readFileSync(STATE, "utf8"));
  } catch {
    return { overrides: [] };
  }
}

function saveState(s) {
  fs.writeFileSync(STATE, JSON.stringify(s, null, 2) + "\n", "utf8");
}

// ─────────────────────────────────────────────────────────────────────────────
// Commands
// ─────────────────────────────────────────────────────────────────────────────
function cmdList() {
  const ex = exclusionGlobs();
  const inc = inclusionGlobs();
  console.log(`\nfile_scan_exclusions (${ex.length}) — Zed inhe scan/search/read se hata deta hai:`);
  for (const g of ex) console.log(`  ${g}`);
  console.log(`\nfile_scan_inclusions (${inc.length}) — inhe gitignored hone par bhi scan karta hai:`);
  for (const g of inc) console.log(`  ${g}`);
  const rules = zedIgnoreRules();
  console.log(`\n.zedignore rules (${rules.length}) — project panel / file finder:`);
  for (const r of rules) console.log(`  ${r}`);
}

function cmdExplain(target) {
  const rel = toPosix(path.relative(ROOT, path.resolve(ROOT, target))) || target;
  const hits = hidingGlobs(rel);
  console.log(`path:        ${rel}`);
  console.log(`git-ignored: ${isGitIgnored(rel) ? "yes" : "no"}`);
  console.log(`excluded by: ${hits.length ? hits.join(", ") : "(none — Zed isay parh sakta hai)"}`);
  const rules = zedIgnoreRules().filter((r) => {
    if (r.startsWith("!")) return false;
    const pat = r.endsWith("/") ? `${r}**` : r;
    return matchesPathOrAncestor(pat, rel);
  });
  console.log(`.zedignore:  ${rules.length ? rules.join(", ") : "(none)"}`);
}

function cmdFind(needle, limit) {
  const budget = { n: WALK_BUDGET };
  const globs = exclusionGlobs();
  const out = [];
  walk(ROOT, (rel) => {
    if (!rel.toLowerCase().includes(needle.toLowerCase())) return false;
    return hidingGlobs(rel, globs).length > 0;
  }, out, budget);
  out.sort();
  if (!out.length) {
    console.log(`"${needle}" se milti koi IGNORED file nahi mili.`);
    return;
  }
  console.log(`"${needle}" se milti ignored files (${out.length}${out.length >= limit ? "+" : ""}):\n`);
  for (const rel of out.slice(0, limit)) {
    console.log(`  ${rel}`);
    console.log(`     hidden by: ${hidingGlobs(rel, globs).join(", ")}`);
  }
  if (out.length > limit) console.log(`\n… aur ${out.length - limit} (--limit barha dein)`);
  console.log(`\nKisi ek ko kholne ke liye (USER ki ijaazat ke baad):`);
  console.log(`  node .scripts/agent-ignored-files.mjs allow ${out[0]} --yes`);
}

function cmdAllow(target, yes) {
  if (!yes) {
    console.error(
      [
        "RUKO — user ki ijaazat zaroori hai.",
        "",
        "Ye command ignored path ko TEMPORARILY scan/read ke qabil banati hai",
        "(settings.json se matching exclusion hatati hai), jis se us category",
        "ke doosre files bhi scan me aa sakte hain = extra tokens.",
        "",
        "Pehle user se poochein: 'kya main <path> ko temporarily un-ignore karun?'",
        "Phir:  node .scripts/agent-ignored-files.mjs allow <path> --yes",
      ].join("\n"),
    );
    process.exit(2);
  }

  const rel = toPosix(path.relative(ROOT, path.resolve(ROOT, target))) || target;
  const hits = hidingGlobs(rel);
  if (!hits.length && !isGitIgnored(rel)) {
    console.log(`"${rel}" pehle se hi visible hai — kuch karne ki zaroorat nahi.`);
    return;
  }

  let text = readSettings();
  // 1) Matching exclusion globs ki lines hata do (comments preserve karte hue).
  for (const glob of hits) {
    text = removeArrayElement(text, "file_scan_exclusions", glob);
  }

  // 2) Target ko inclusions me daal do (gitignored files ke liye zaroori).
  text = ensureArrayElement(text, "file_scan_inclusions", rel, "file_scan_exclusions");

  writeSettings(text);

  const s = state();
  s.overrides = s.overrides.filter((o) => o.target !== rel);
  s.overrides.push({
    target: rel,
    removedExclusions: hits,
    addedInclusions: [rel],
    at: new Date().toISOString(),
  });
  saveState(s);

  console.log(`✅ "${rel}" ab scan/read ke qabil hai.`);
  if (hits.length) console.log(`   hataye gaye exclusions: ${hits.join(", ")}`);
  console.log(`   (settings hot-reload hone chahiye — zaroorat par workspace: reload)`);
  console.log(`\n⚠️  Is category ke doosre files bhi scan me aa sakte hain (extra tokens).`);
  console.log(`   Kaam khatam hone par strict mode wapas laayein:`);
  console.log(`     node .scripts/agent-ignored-files.mjs revoke`);
}

function cmdRevoke() {
  const s = state();
  if (!s.overrides.length) {
    console.log("Koi active override nahi — strict mode bereits on hai.");
    return;
  }

  let text = readSettings();
  const removed = new Set();
  const added = new Set();
  for (const o of s.overrides) {
    (o.removedExclusions ?? []).forEach((g) => removed.add(g));
    (o.addedInclusions ?? []).forEach((g) => added.add(g));
  }

  // 1) Added inclusions hata do.
  for (const glob of added) {
    text = removeArrayElement(text, "file_scan_inclusions", glob);
  }

  // 2) Removed exclusions wapas daal do.
  for (const glob of removed) {
    text = ensureArrayElement(text, "file_scan_exclusions", glob, null);
  }

  writeSettings(text);
  if (fs.existsSync(STATE)) fs.unlinkSync(STATE);
  console.log(`✅ Strict mode wapas. Restore kiye: ${[...removed].join(", ") || "(kuch nahi)"}`);
}

function cmdStatus() {
  const s = state();
  const ex = exclusionGlobs();
  console.log(`exclusion globs active : ${ex.length}`);
  console.log(`temporary overrides    : ${s.overrides.length}`);
  for (const o of s.overrides) {
    console.log(`  • ${o.target}  (removed: ${(o.removedExclusions ?? []).join(", ") || "-"})`);
  }
  if (s.overrides.length) {
    console.log(`\nStrict mode wapas: node .scripts/agent-ignored-files.mjs revoke`);
  }
}

function usage() {
  console.log(
    [
      "Usage: node .scripts/agent-ignored-files.mjs <command>",
      "",
      "  list                          saare ignore rules dikhao",
      "  status                        active temporary overrides",
      "  explain <path>                kaunsi rule is path ko chhupa rahi hai",
      "  find <substring> [--limit N]  ignored (hidden) files dhoondo",
      "  allow <path> --yes            path ko temporarily un-ignore karo (permission ke baad)",
      "  revoke                        strict mode wapas laao",
    ].join("\n"),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
const [cmd, ...rest] = process.argv.slice(2);
const arg = rest.find((a) => !a.startsWith("--"));
const limitIdx = rest.indexOf("--limit");
const limit = limitIdx >= 0 ? Number(rest[limitIdx + 1]) || 50 : 50;

switch (cmd) {
  case "list":
    cmdList();
    break;
  case "status":
    cmdStatus();
    break;
  case "explain":
    if (!arg) usage();
    else cmdExplain(arg);
    break;
  case "find":
    if (!arg) usage();
    else cmdFind(arg, limit);
    break;
  case "allow":
    if (!arg) usage();
    else cmdAllow(arg, rest.includes("--yes"));
    break;
  case "revoke":
    cmdRevoke();
    break;
  default:
    usage();
    process.exit(cmd ? 1 : 0);
}
