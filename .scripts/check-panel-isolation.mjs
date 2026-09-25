#!/usr/bin/env node
/**
 * Panel isolation guard.
 *
 * Enforces the layering model of docs/handoff/PANEL-SEPARATION-PLAN.md §5b.1 and its
 * hard rules 3, 4 and 5:
 *
 *     core  <-  shared  <-  features/<panel>   <-  main_<panel>.dart
 *
 * Three violations are detected:
 *
 *   1. lib/shared/**       imports lib/features/**
 *   2. lib/features/<A>/** imports lib/features/<B>/**   (A !== B)
 *   3. lib/core/**         imports lib/shared/** or lib/features/**
 *
 * This is the "CI boundary enforcement" mechanism (§5c #1) — the single check that stops
 * cross-panel coupling from growing back.
 *
 * Granularity: the baseline records individual **import statements** (file -> file), not
 * folder pairs. A folder-pair baseline is too coarse — it silently permits a brand-new
 * file to start crossing that same boundary. Statement-level means "not one new
 * cross-panel import may be added", which is the actual intent.
 *
 * Usage:
 *   node .scripts/check-panel-isolation.mjs                  # fail on NEW violations
 *   node .scripts/check-panel-isolation.mjs --report         # print the whole coupling map
 *   node .scripts/check-panel-isolation.mjs --write-baseline # record the current state
 *
 * Exit codes: 0 = clean, 1 = new violation(s), 2 = usage/IO error.
 */

import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const ROOT = process.cwd();
const LIB = path.join(ROOT, 'lib');
const BASELINE_PATH = path.join(ROOT, '.scripts', 'panel-isolation-baseline.json');

const args = new Set(process.argv.slice(2));
const REPORT = args.has('--report');
const WRITE_BASELINE = args.has('--write-baseline');

// ─────────────────────────────────────────────────────────────────────────────
// Layering model
// ─────────────────────────────────────────────────────────────────────────────

/** Classify a project-relative path ("lib/...") into a layer. */
function layerOf(rel) {
  const parts = rel.split('/');
  if (parts[0] !== 'lib') return 'other';
  if (parts[1] === 'core') return 'core';
  if (parts[1] === 'shared') return 'shared';
  if (parts[1] === 'features' && parts[2]) return `features/${parts[2]}`;
  return 'other'; // lib/main_*.dart, lib/routes/**, lib/rust_module/**
}

/** Allowed import direction? Returns a reason string when forbidden. */
function violationReason(fromLayer, toLayer) {
  if (fromLayer === 'other') return null; // entry points & routes may import anything
  if (fromLayer === toLayer) return null;

  if (fromLayer === 'core') return 'core must not depend on shared/ or features/';
  if (fromLayer === 'shared') {
    return toLayer.startsWith('features/')
      ? 'shared must never import features/ (hard rule 3)'
      : null;
  }
  if (fromLayer.startsWith('features/') && toLayer.startsWith('features/')) {
    return 'one department must never import another (hard rule 4)';
  }
  return null; // features -> core/shared is the allowed direction
}

// ─────────────────────────────────────────────────────────────────────────────
// Discovery
// ─────────────────────────────────────────────────────────────────────────────

function walk(dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(p, out);
    else if (entry.isFile() && entry.name.endsWith('.dart')) out.push(p);
  }
  return out;
}

const IMPORT_RE = /^[ \t]*(?:import|export)[ \t]+['"]([^'"]+)['"]/gm;

/** Resolve a Dart import URI to a project-relative path, or null if outside lib/. */
function resolveUri(fromAbs, uri) {
  if (uri.startsWith('dart:') || uri.startsWith('/')) return null;
  if (uri.startsWith('package:')) {
    const m = uri.match(/^package:trace_odd\/(.+)$/);
    return m ? `lib/${m[1]}` : null; // third-party packages are outside our tree
  }
  const abs = path.resolve(path.dirname(fromAbs), uri);
  const rel = path.relative(ROOT, abs).split(path.sep).join('/');
  return rel.startsWith('lib/') ? rel : null;
}

/** Every forbidden import statement in the tree. */
function collectViolations() {
  if (!fs.existsSync(LIB)) {
    console.error(`ERROR: ${LIB} not found — run this from the repository root.`);
    process.exit(2);
  }

  const violations = [];
  for (const abs of walk(LIB)) {
    const from = path.relative(ROOT, abs).split(path.sep).join('/');
    const fromLayer = layerOf(from);
    if (fromLayer === 'other') continue;

    for (const m of fs.readFileSync(abs, 'utf8').matchAll(IMPORT_RE)) {
      const to = resolveUri(abs, m[1]);
      if (!to) continue;
      const toLayer = layerOf(to);
      if (toLayer === 'other') continue;

      const reason = violationReason(fromLayer, toLayer);
      if (!reason) continue;

      violations.push({ key: `${from} -> ${to}`, from, to, fromLayer, toLayer, reason });
    }
  }
  return violations.sort((a, b) => a.key.localeCompare(b.key));
}

function loadBaseline() {
  if (!fs.existsSync(BASELINE_PATH)) return [];
  try {
    return JSON.parse(fs.readFileSync(BASELINE_PATH, 'utf8')).imports ?? [];
  } catch (e) {
    console.error(`ERROR: ${BASELINE_PATH} is not valid JSON — ${e.message}`);
    process.exit(2);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────────────────────────────────────

const violations = collectViolations();

if (WRITE_BASELINE) {
  const groups = {};
  for (const v of violations) {
    const g = `${v.fromLayer} -> ${v.toLayer}`;
    groups[g] = (groups[g] ?? 0) + 1;
  }
  fs.mkdirSync(path.dirname(BASELINE_PATH), { recursive: true });
  fs.writeFileSync(
    BASELINE_PATH,
    `${JSON.stringify(
      {
        $comment:
          'Tracked cross-panel coupling (PANEL-SEPARATION-PLAN.md §5c mechanism 1). ' +
          'These import statements exist today and are grandfathered so the guard can run ' +
          'without a red build. Statement-level on purpose: a folder-pair baseline would let ' +
          'a brand-new file cross the same boundary unnoticed. ' +
          'REMOVE an entry once that import has been extracted — never add one without an owner decision.',
        generatedAt: new Date().toISOString(),
        summary: groups,
        imports: violations.map((v) => v.key),
      },
      null,
      2,
    )}\n`,
  );
  console.log(
    `Baseline written: ${path.relative(ROOT, BASELINE_PATH)} — ${violations.length} import statement(s)`,
  );
  for (const [g, n] of Object.entries(groups)) console.log(`  ${g}: ${n}`);
  process.exit(0);
}

const baseline = loadBaseline();
const baselineSet = new Set(baseline);

if (REPORT) {
  const groups = new Map();
  for (const v of violations) {
    const g = `${v.fromLayer} -> ${v.toLayer}`;
    if (!groups.has(g)) groups.set(g, []);
    groups.get(g).push(v);
  }

  console.log('Panel isolation report');
  console.log('======================');
  console.log(`Violating import statements: ${violations.length}`);
  console.log(`Tracked in baseline:        ${baseline.length}\n`);

  for (const [g, list] of [...groups.entries()].sort()) {
    console.log(`[${g}]  ${list.length} statement(s) — ${list[0].reason}`);
    for (const v of list) console.log(`    ${v.from}  ->  ${v.to}`);
    console.log('');
  }

  const stale = baseline.filter((k) => !violations.some((v) => v.key === k));
  if (stale.length) {
    console.log(`Stale baseline entries (import no longer exists — remove from the baseline): ${stale.length}`);
    for (const k of stale) console.log(`    ${k}`);
  }
  process.exit(0);
}

const newViolations = violations.filter((v) => !baselineSet.has(v.key));
const stale = baseline.filter((k) => !violations.some((v) => v.key === k));

if (stale.length) {
  console.warn(`⚠️  ${stale.length} stale baseline entry(ies) — those imports are gone. Remove them:`);
  for (const k of stale) console.warn(`     ${k}`);
  console.warn('');
}

if (newViolations.length === 0) {
  console.log(
    `✅ Panel isolation OK — no new cross-panel imports (${baseline.length} tracked, grandfathered).`,
  );
  process.exit(0);
}

console.error('❌ NEW cross-panel coupling detected — the layering model was broken.\n');
for (const v of newViolations) {
  console.error(`  ${v.from}`);
  console.error(`    -> ${v.to}`);
  console.error(`    ${v.reason}\n`);
}
console.error(
  `Fix the import — promote the shared thing to lib/shared/, or route it through the API.\n` +
    `If it genuinely must stay, a human decides and then adds it to ` +
    `.scripts/panel-isolation-baseline.json.\n` +
    `See docs/handoff/PANEL-SEPARATION-PLAN.md §5b.1 and hard rules 3-5.`,
);
process.exit(1);
