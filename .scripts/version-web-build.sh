#!/bin/bash
# =============================================================================
# Version the Flutter web bundle so browsers NEVER serve stale JS.
# =============================================================================
# Flutter web emits an unversioned `main.dart.js` every build. Even with
# no-cache headers, browsers that previously cached it under `immutable`
# would keep serving the old bundle. This script gives each deploy a
# unique filename and patches the generated flutter_bootstrap.js
# entrypoint reference accordingly.
#
# Usage (on CI, Ubuntu):
#   bash .scripts/version-web-build.sh build/web
# =============================================================================

set -e

DIR="${1:-build/web}"
STAMP=$(date -u +%Y%m%d%H%M%S)

if [ -f "$DIR/main.dart.js" ]; then
  # CI builds several targets sequentially into the same build/web.
  # flutter build only overwrites main.dart.js, so stamped bundles from
  # earlier targets linger and leak into every rsync destination.
  # Drop stale stamps before creating the new one (bootstrap is
  # re-patched below to point at the fresh bundle).
  # The .map is stamped too, so its stale copies must go with the .js.
  rm -f "$DIR"/main.dart.20*.js "$DIR"/main.dart.20*.js.map
  mv "$DIR/main.dart.js" "$DIR/main.dart.$STAMP.js"

  # The source map MUST be renamed with the bundle. It used to be left as
  # `main.dart.js.map` while the bundle became `main.dart.<stamp>.js`, and the
  # bundle's own `//# sourceMappingURL=main.dart.js.map` no longer described the
  # file next to it — Chrome then renders every frame as
  # `main.dart.<stamp>.js:sourcemap:97028`, which names no Dart file, so a
  # production crash (e.g. the Cricket Manager's null-check) could not be
  # located at all. Rename the map and repoint the comment in one step.
  if [ -f "$DIR/main.dart.js.map" ]; then
    mv "$DIR/main.dart.js.map" "$DIR/main.dart.$STAMP.js.map"
    sed -i "s|sourceMappingURL=main.dart.js.map|sourceMappingURL=main.dart.$STAMP.js.map|" "$DIR/main.dart.$STAMP.js"
    echo "✅ Versioned source map: main.dart.$STAMP.js.map"
  else
    echo "⚠ No main.dart.js.map — build this target with --source-maps for readable stacks."
  fi

  sed -i "s|mainJsPath\":\"main.dart.js\"|mainJsPath\":\"main.dart.$STAMP.js\"|" "$DIR/flutter_bootstrap.js"
  echo "✅ Versioned bundle: main.dart.$STAMP.js"
else
  echo "⚠ No main.dart.js found in $DIR — skipping versioning."
fi

# ─────────────────────────────────────────────────────────────────────────────
# Version the BOOTSTRAP URL too.
#
# index.html points at `flutter_bootstrap.js?v=1.0.3` — a fixed version, so the URL
# never changes. The zone's Cloudflare "Browser Cache TTL" rewrites .js responses to
# `max-age=14400` (measured live on every host in this zone, 2026-09-30), so a
# returning browser can reuse an OLD bootstrap for four hours — and the bootstrap is
# what carries the versioned bundle name, so that browser keeps running the old
# build. index.html itself is served no-cache, so stamping the URL here is picked up
# immediately.
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$DIR/index.html" ]; then
  sed -i -E "s|flutter_bootstrap\.js\?v=[^\"]*|flutter_bootstrap.js?v=$STAMP|g" "$DIR/index.html"
  if grep -q "flutter_bootstrap\.js?v=$STAMP" "$DIR/index.html"; then
    echo "✅ Versioned bootstrap URL: ?v=$STAMP"
  else
    echo "⚠ No 'flutter_bootstrap.js?v=' found in $DIR/index.html — bootstrap URL not versioned."
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# No build may tell the loader to register a service worker that is not shipped.
# (MASTER-TASK-LIST.md item 10.)
#
# Every panel deletes Flutter's `flutter_service_worker.js` (the panels ship their
# own worker instead: `web/sw.js`). But a build made with the DEFAULT
# `--pwa-strategy` still bakes the file's version into `flutter_bootstrap.js`, so
# the loader registers a file that 404s as `text/html` — a MIME error and no
# worker at all. `--pwa-strategy none` is the fix; this is the regression guard.
#
# `serviceWorkerVersion: "…"` is the CONFIG marker (the loader's library code also
# mentions the name, but unquoted), so this pattern matches the config only.
# ─────────────────────────────────────────────────────────────────────────────
if [ -f "$DIR/flutter_bootstrap.js" ] && grep -qE 'serviceWorkerVersion:[[:space:]]*"' "$DIR/flutter_bootstrap.js"; then
  echo "❌ $DIR/flutter_bootstrap.js tells the loader to register flutter_service_worker.js,"
  echo "   but that file is deleted after every build — the registration would 404 as text/html."
  echo "   Build this target with --pwa-strategy none (see frontend-deploy.yml)."
  exit 1
fi

exit 0
