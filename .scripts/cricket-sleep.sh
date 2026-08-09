#!/bin/bash
# =============================================================================
# NEXATRACE CRICKET — SLEEP MODE SCRIPT
# =============================================================================
# Path: /usr/local/bin/cricket-sleep.sh
#
# Puts the cricket module into dormant "sleep" mode after tournament concludes.
# Frees 100% of CPU, RAM, and DB connections for the core 17 modules.
#
# ACTIONS:
#   1. Stop SRS media server (kills RTMP ingest + FFmpeg transcoding)
#   2. Set tournament is_active = false in database
#   3. Clear Redis cricket cache keys
#   4. Optionally disable Nginx server block (serve dormant page instead)
#   5. Log all actions
#
# USAGE:
#   sudo /usr/local/bin/cricket-sleep.sh
# =============================================================================

set -e

LOG_FILE="/var/log/cricket-lifecycle.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "══════════════════════════════════════════════"
log "CRICKET MODULE — ENTERING SLEEP MODE"
log "══════════════════════════════════════════════"

# ─── 1. Stop SRS Media Server ──────────────────────────
log "Step 1/5: Stopping SRS media server..."
if systemctl is-active --quiet cricket-srs 2>/dev/null; then
    systemctl stop cricket-srs
    log "  ✓ SRS stopped successfully."
else
    log "  → SRS was not running. Skipped."
fi

# ─── 2. Deactivate Tournament in Database ──────────────
log "Step 2/5: Deactivating tournament in PostgreSQL..."
DB_RESULT=$(sudo -u www-data php /var/www/traceodd/admin-panel/artisan tinker --execute="
    \$updated = DB::table('cricket_tournaments')->where('status', 'active')->update(['is_active' => false, 'status' => 'completed']);
    echo \$updated . ' tournament(s) deactivated.';
" 2>&1)
log "  $DB_RESULT"

# ─── 3. Clear Redis Cricket Cache ──────────────────────
log "Step 3/5: Clearing Redis cricket cache keys..."
REDIS_RESULT=$(sudo -u www-data php /var/www/traceodd/admin-panel/artisan tinker --execute="
    try {
        \$keys = Redis::keys('cricket:*');
        \$count = count(\$keys);
        if (\$count > 0) {
            Redis::del(\$keys);
        }
        echo \"Cleared {\$count} cricket Redis keys.\";
    } catch (\\Exception \$e) {
        echo 'Redis unavailable: ' . \$e->getMessage();
    }
" 2>&1)
log "  $REDIS_RESULT"

# ─── 4. Optional: Disable Nginx Server Block ────────────
log "Step 4/5: Disabling Nginx cricket server block..."
if [ -f /etc/nginx/sites-enabled/cricket ]; then
    mv /etc/nginx/sites-enabled/cricket /etc/nginx/sites-available/cricket.disabled
    nginx -t && systemctl reload nginx
    log "  ✓ Cricket Nginx block disabled. Visitors see main domain."
else
    log "  → Cricket Nginx block already disabled. Skipped."
fi

# ─── 5. Verify Clean Shutdown ─────────────────────────
log "Step 5/5: Verifying clean shutdown..."
# Check no cricket processes remain
SRS_PROCS=$(ps aux | grep -E 'srs.*cricket' | grep -v grep | wc -l)
FFMPEG_PROCS=$(ps aux | grep -E 'ffmpeg.*cricket.*hls' | grep -v grep | wc -l)

if [ "$SRS_PROCS" -eq 0 ] && [ "$FFMPEG_PROCS" -eq 0 ]; then
    log "  ✓ All cricket processes terminated."
else
    log "  ⚠ Warning: $SRS_PROCS SRS and $FFMPEG_PROCS FFmpeg processes still running."
    log "    Run: pkill -f 'srs.*cricket' && pkill -f 'ffmpeg.*cricket'"
fi

# Memory check
FREE_MEM=$(free -m | awk '/^Mem:/{print $4}')
log "  ℹ Free memory: ${FREE_MEM} MB"

log "══════════════════════════════════════════════"
log "CRICKET MODULE SLEEP MODE ACTIVATED"
log "All resources returned to core 17 modules."
log "To wake: sudo /usr/local/bin/cricket-wake.sh"
log "══════════════════════════════════════════════"

exit 0
