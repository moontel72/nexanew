# Translation resources

Locale files for user-facing strings.

```
en.json   English
ur.json   Urdu
```

## Rules

1. **Keep the keys identical between files.** `en.json` and `ur.json` must always have the same
   shape — the same keys at the same paths. A key present in one and missing in the other is a bug.
2. **UTF-8, no BOM.** Urdu must be written as real UTF-8 text, not HTML entities or escaped code
   points.
3. Values are plain strings only — no comment keys, no metadata objects. Explanations belong in this
   README, not in the JSON, so that any i18n loader can read the files without special handling.

## ⚠️ Editing Urdu in Zed

Zed does not render right-to-left (bidi) text correctly. Urdu in `ur.json` appears disconnected and
in the wrong order **in the editor** — but the file content itself is correct. This is a display
limitation, not a data problem.

- **Do not "fix" the Urdu by retyping it in Zed** — that will actually corrupt it.
- To edit Urdu, use a bidi-capable editor (VS Code, or any editor with RTL support).
- Verify with a tool, not by eye, if in doubt:
  `node -e "console.log(require('./assets/translations/ur.json').banknote.result.suspicious)"`

## ⚠️ Legal review required

The `banknote.*` strings are **user-facing legal disclaimers** for the banknote-authentication panel
(see `docs/handoff/PILLAR-A-BANKNOTE-AUTHENTICATION.md`). They must be **verified by the owner
against the source wording** before any public release. A disclaimer that is silently paraphrased is
worse than none.

## Status

**Nothing loads these files yet.** The `assets/translations/` directory is declared in `pubspec.yaml`
and was empty until now. Wiring the strings into the app is part of Pillar A (§3.6 there), not part
of this scaffold.
