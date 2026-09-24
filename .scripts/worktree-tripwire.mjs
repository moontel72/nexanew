#!/usr/bin/env node
// Worktree tripwire.
//
// Prints what the working tree contains, and SHOUTS when a *tracked* file is
// missing from disk. That deletion signature is not hypothetical: the root
// `android/` directory (17 tracked files) once vanished from the worktree while
// an unrelated commit was being prepared, and it was only caught by reading
// `git status` by hand. A tripwire makes that a one-command check.
//
// Usage:
//
//   node .scripts/worktree-tripwire.mjs
//
// Exits 1 when tracked files have been deleted, so it can gate a session or a
// pre-commit step. Untracked and modified files are reported but never fail:
// they are the normal state of a working tree.

import { execFileSync } from "node:child_process";

function git(args) {
  return execFileSync("git", args, { encoding: "utf8" });
}

/** `git status --porcelain` is stable and script-safe. */
const lines = git(["status", "--porcelain"])
  .split("\n")
  .map((line) => line.trimEnd())
  .filter((line) => line !== "");

const groups = { deleted: [], modified: [], added: [], untracked: [], other: [] };

for (const line of lines) {
  const status = line.slice(0, 2);
  const path = line.slice(3).trim();
  if (status === "??") groups.untracked.push(path);
  else if (status.includes("D")) groups.deleted.push(path);
  else if (status.includes("A")) groups.added.push(path);
  else if (status.includes("M") || status.includes("R")) groups.modified.push(path);
  else groups.other.push(`${status} ${path}`);
}

console.log(`branch : ${git(["rev-parse", "--abbrev-ref", "HEAD"]).trim()}`);
console.log(`head   : ${git(["log", "-1", "--oneline"]).trim()}`);
console.log("");

const report = [
  ["modified", "M", groups.modified],
  ["added", "A", groups.added],
  ["untracked", "?", groups.untracked],
  ["other", "!", groups.other],
  ["DELETED", "D", groups.deleted],
];

for (const [label, marker, paths] of report) {
  console.log(`${label}: ${paths.length}`);
  for (const path of paths) {
    console.log(`  ${marker} ${path}`);
  }
}

if (groups.deleted.length > 0) {
  console.log("");
  console.log("!! TRACKED FILES ARE MISSING FROM THE WORKING TREE !!");
  console.log("   If that was not deliberate, restore them with:");
  console.log("     git restore <path>");
  process.exit(1);
}
