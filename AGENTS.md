# AGENTS.md — NexaTrace System

Project-wide rules for AI coding agents working in this repo.

## ⚠️ Ignored files — "file nahi mili" kehne se pehle ye parhein

Is repo me generated, vendored, cached aur bhaari files Zed ke file scan se
hide hain:

- `.zedignore` — project panel / file finder
- `.zed/settings.json` → `file_scan_exclusions` — **file scan + search +
  DIRECT READ**

Yani Zed aisi files ko na sirf search me dikhata hai, na hi parhne deta hai.
Error message aisa aata hai:

```
Cannot read file because its path matches the worktree
`file_scan_exclusions` setting: <path>
```

Is liye: agar koi file logically mojood honi chahiye magar search/read me
nahi aa rahi, to usay **"missing" na samjhein** — pehle neeche wala escape
hatch use karein. (Ye files waqai mojood hoti hain; sirf scan se hatai gayi
hain.)

### Escape hatch — laazmi tarteeb

1. **Discovery** — hidden file dhoondein:

   ```sh
   node .scripts/agent-ignored-files.mjs find <naam-ka-hissa>
   ```

2. **Wajah** — kaunsi rule ise chhupa rahi hai:

   ```sh
   node .scripts/agent-ignored-files.mjs explain <path>
   ```

3. **Permission** — USER se saaf ijaazat maangein. Apne message me likhein:
   - kaunsi file chahiye aur **kyun** (error fix / deploy / verification),
   - ye warning ke is category ke doosre files bhi temporarily scan me aa
     sakte hain (extra tokens).

   `allow` bina `--yes` chalta hi nahi — ye jaan-boojh kar lagaya gaya speed
   bump hai taake ijaazat ke baghair na ho.

4. **Access** — ijaazat milne par:

   ```sh
   node .scripts/agent-ignored-files.mjs allow <path> --yes
   ```

   Ab `read_file` / `edit_file` us path par normal kaam karega.
   (Settings hot-reload hoti hain; zaroorat par `workspace: reload`.)

5. **Cleanup (SKIP NA KAREIN)** — kaam khatam hote hi strict mode wapas:

   ```sh
   node .scripts/agent-ignored-files.mjs revoke
   node .scripts/agent-ignored-files.mjs status   # confirm: 0 overrides
   ```

### Rules

- `allow` sirf user ki ijaazat ke baad chalayein.
- Kaam ke baad **hamesha** `revoke` — warna tokens zaya hote rahenge.
- `allow` poori category expose kar sakta hai; is liye sab se specific
  path chunein.
- `.zedignore` / `.zed/settings.json` ki ignore entries ko "fix" karne ke
  liye hataayein na — sirf temporary `allow`/`revoke` use karein.
- Generated / vendored files ya secrets ko sirf parhne ke liye repo me
  commit na karein.

## Deploy ke waqt ignored files

CI aur deploy scripts kuch generated / locked files par depend karte hain
(jaise `composer.lock`, `pubspec.lock`, `package-lock.json`,
`backend/vendor/**`, `media-engine/ui/todd-studio-gui/package-lock.json`).
Agar deploy debug karte waqt in me se koi file parhni ya compare karni ho,
to upar wala hi protocol use karein — file ko repo me "wapas" laane ki
zaroorat nahi.

## Doosri ahem baatein

- Deploy GitHub Actions se hota hai (`.github/workflows/`), push par
  `main` **aur** `mainnew` dono branches se trigger hota hai. Server par
  manually `git pull` / `npm run build` / `cargo build` ki zaroorat nahi.
- Media engine gst feature ke saath Docker image me build hota hai
  (`media-engine-build.yml`) — manually `--features gst` chalane ki
  zaroorat nahi.
