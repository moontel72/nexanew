#!/usr/bin/env bash
# One-command test room: mints an admin token, creates a room, and prints
# every URL + token needed to test WHIP publish / WHEP watch.
#
# Usage:
#   ./scripts/test-room.sh                      # cameras: cam-1,cam-2, port 8080
#   CAMERAS="main,angle2" ./scripts/test-room.sh
#   STUDIO_PORT=18080 ./scripts/test-room.sh
#
# Requires: cargo, curl, python3 (for JSON parsing).

set -euo pipefail
cd "$(dirname "$0")/.."

# 1. JWT secret: .env wins over current environment
if [ -f .env ]; then
  while IFS= read -r line; do
    case "$line" in
      JWT_SECRET=*) JWT_SECRET="${line#JWT_SECRET=}" ;;
    esac
  done < .env
fi
: "${JWT_SECRET:?JWT_SECRET not found in .env or environment}"

BASE="http://127.0.0.1:${STUDIO_PORT:-8080}"
CAMERAS="${CAMERAS:-cam-1,cam-2}"

# 2. Mint the admin token with the bundled dev CLI
echo "Minting admin token..."
TOKEN=$(cargo run -q -p todd-common --example mint_token -- admin | tail -n 1)

# 3. Create the room
echo "Creating room at $BASE ..."
PAYLOAD=$(python3 - "$CAMERAS" <<'EOF'
import json, sys
cams = [c for c in sys.argv[1].split(",") if c.strip()]
print(json.dumps({"name": "test-room", "camera_ids": cams, "ttl_secs": 3600}))
EOF
)
RESP=$(curl -fsS -X POST "$BASE/api/v1/room/create" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

ROOM_ID=$(echo "$RESP" | python3 -c 'import json,sys; print(json.load(sys.stdin)["room"]["id"])')
VIEWER_TOKEN=$(echo "$RESP" | python3 -c 'import json,sys; print(json.load(sys.stdin)["viewer_token"])')

# 4. Print the cheat sheet
echo ""
echo "===== T-ODD TEST ROOM ====="
echo "ROOM ID : $ROOM_ID"
echo ""
IFS=',' read -ra CAMS <<< "$CAMERAS"
for cam in "${CAMS[@]}"; do
  cam=$(echo "$cam" | xargs)
  [ -z "$cam" ] && continue
  TOK=$(echo "$RESP" | python3 -c "import json,sys; print(json.load(sys.stdin)['ingest_tokens']['$cam'])")
  echo "WHIP publish URL ($cam):"
  echo "  $BASE/api/v1/whip/ingest/$ROOM_ID/$cam"
  echo "  ingest token: $TOK"
done
echo ""
echo "WHEP watch URL (${CAMS[0]}):"
echo "  $BASE/api/v1/whep/watch/$ROOM_ID/${CAMS[0]}"
echo "VIEWER TOKEN: $VIEWER_TOKEN"
echo ""
echo "Browser test page (start Studio with DEV_TEST_PAGE=1):"
echo "  $BASE/whiptest"
echo "============================="
