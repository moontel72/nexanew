// Dev-only syntax sanity check for the PHP files touched by the cricket
// cleanup work. Not a parser — just verifies that braces/parens/brackets
// balance outside of strings and comments, which catches the class of
// truncated/duplicated-file mistakes that a missing PHP runtime would hide.
import fs from "node:fs";
import path from "node:path";

const files = [
  "app/Services/Cricket/CricketDataCleanupService.php",
  "app/Services/Cricket/ActiveMatchContextService.php",
  "app/Services/Cricket/LiveScoreService.php",
  "app/Events/Cricket/CricketMatchContextCleared.php",
  "app/Http/Controllers/Cricket/MatchController.php",
  "app/Http/Controllers/Cricket/TeamController.php",
  "app/Http/Controllers/Cricket/TournamentSetupController.php",
  "app/Http/Controllers/Cricket/MatchContextController.php",
];

let failures = 0;

for (const rel of files) {
  const src = fs.readFileSync(path.join(process.cwd(), rel), "utf8");
  const stack = [];
  let i = 0;
  let line = 1;
  let err = null;

  const pairs = { "}": "{", ")": "(", "]": "[" };

  while (i < src.length) {
    const c = src[i];
    const n = src[i + 1];

    if (c === "\n") { line++; i++; continue; }
    if (c === "/" && n === "/") { while (i < src.length && src[i] !== "\n") i++; continue; }
    if (c === "#") { while (i < src.length && src[i] !== "\n") i++; continue; }
    if (c === "/" && n === "*") {
      i += 2;
      while (i < src.length && !(src[i] === "*" && src[i + 1] === "/")) {
        if (src[i] === "\n") line++;
        i++;
      }
      i += 2;
      continue;
    }
    if (c === "'" || c === '"') {
      const q = c;
      i++;
      while (i < src.length && src[i] !== q) {
        if (src[i] === "\\") i++;
        if (src[i] === "\n") line++;
        i++;
      }
      i++;
      continue;
    }
    if (c === "{" || c === "(" || c === "[") { stack.push({ c, line }); i++; continue; }
    if (c === "}" || c === ")" || c === "]") {
      const top = stack.pop();
      if (!top || top.c !== pairs[c]) {
        err = `line ${line}: unmatched '${c}'` +
          (top ? ` (opened '${top.c}' at line ${top.line})` : " (nothing open)");
        break;
      }
      i++;
      continue;
    }
    i++;
  }

  if (!err && stack.length) {
    const top = stack[stack.length - 1];
    err = `${stack.length} unclosed '${top.c}' (first at line ${top.line})`;
  }

  const dup = (src.match(/^class\s+\w+/gm) || []).length;
  if (!err && dup > 1) err = `${dup} class declarations (duplicated file?)`;

  if (err) { failures++; console.log(`FAIL ${rel}\n     ${err}`); }
  else console.log(`OK   ${rel}  (${src.split("\n").length} lines)`);
}

process.exit(failures ? 1 : 0);
