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
  mv "$DIR/main.dart.js" "$DIR/main.dart.$STAMP.js"
  sed -i "s|mainJsPath\":\"main.dart.js\"|mainJsPath\":\"main.dart.$STAMP.js\"|" "$DIR/flutter_bootstrap.js"
  echo "✅ Versioned bundle: main.dart.$STAMP.js"
else
  echo "⚠ No main.dart.js found in $DIR — skipping versioning."
fi

exit 0
