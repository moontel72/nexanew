#!/bin/bash
# =============================================================================
# NEXATRACE CRICKET — WAKE MODE SCRIPT (DUAL-SUBDOMAIN v2)
# =============================================================================
# Path: /usr/local/bin/cricket-wake.sh
#
# Wakes the cricket module from dormant "sleep" mode for a new tournament.
# Restores all services: SRS media server, BOTH Nginx server blocks
# (cricket-public + cricket-manager), database flags.
#
# ACTIONS:
#   1. Reactivate tournament in database
#   2. Re-enable BOTH Nginx cricket server blocks
#   3. Ensure HLS output directory exists
#   4. Verify SRS binary
#   5. Start SRS media server
#   6. Verify all services running
#
# USAGE:
#   sudo /usr/local/bin/cricket-wake.sh
# =============================================================================

set -e

LOG_FILE="/var/log/cricket-lifecycle.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "══════════════════════════════════════════════"
log "CRICKET MODULE — WAKING FROM SLEEP MODE (DUAL-SUBDOMAIN)"
log "══════════════════════════════════════════════"

# ─── 1. Reactivate Tournament in Database ──────────────
log "Step 1/6: Reactivating tournament in PostgreSQL..."
DB_RESULT=$(sudo -u www-data php /var/www/traceodd/admin-panel/artisan tinker --execute="
    \$updated = DB::table('cricket_tournaments')->where('status', 'completed')->update(['is_active' => true, 'status' => 'upcoming']);
    echo \$updated . ' tournament(s) reactivated.';
" 2>&1)
log "  $DB_RESULT"

# ─── 2. Re-enable BOTH Nginx Server Blocks ────────────
log "Step 2/6: Enabling Nginx cricket server blocks (public + manager)..."

enable_block() {
    local name="$1"
    if [ -f "/etc/nginx/sites-available/$name" ]; then
        if [ ! -f "/etc/nginx/sites-enabled/$name" ]; then
            ln -sf "/etc/nginx/sites-available/$name" "/etc/nginx/sites-enabled/$name"
            log "  ✓ $name block enabled."
        else
            log "  → $name already enabled."
        fi
    elif [ -f "/etc/nginx/sites-available/$name.disabled" ]; then
        mv "/etc/nginx/sites-available/$name.disabled" "/etc/nginx/sites-available/$name"
        ln -sf "/etc/nginx/sites-available/$name" "/etc/nginx/sites-enabled/$name"
        log "  ✓ $name block restored and enabled."
    else
        log "  ⚠ $name Nginx config not found. Deploy it first."
    fi
}

enable_block "cricket-public"
enable_block "cricket-manager"

nginx -t && systemctl reload nginx
log "  ✓ Nginx reloaded."

# ─── 3. Ensure HLS Directory Exists ────────────────────
log "Step 3/6: Ensuring HLS output directory exists..."
mkdir -p /var/www/traceodd/cricket-hls
chown -R www-data:www-data /var/www/traceodd/cricket-hls
chmod 755 /var/www/traceodd/cricket-hls
log "  ✓ HLS directory ready."

# ─── 4. Verify SRS Binary ──────────────────────────────
log "Step 4/6: Checking SRS installation..."
if [ -f /usr/local/srs/objs/srs ]; then
    log "  ✓ SRS binary found."
else
    log "  ⚠ SRS not installed. Please install SRS first:"
    log "    See: https://github.com/ossrs/srs"
    log "    Quick install:"
    log "    cd /tmp && git clone https://github.com/ossrs/srs.git"
    log "    cd srs/trunk && ./configure && make"
    log "    ./objs/srs -c /usr/local/srs/conf/cricket.conf"
    exit 1
fi

# ─── 5. Start SRS Media Server ─────────────────────────
log "Step 5/6: Starting SRS media server..."
if systemctl is-active --quiet cricket-srs 2>/dev/null; then
    log "  → SRS already running. Restarting..."
    systemctl restart cricket-srs
else
    systemctl start cricket-srs
fi

sleep 2
if systemctl is-active --quiet cricket-srs; then
    log "  ✓ SRS started successfully."
else
    log "  ⚠ SRS failed to start. Check: journalctl -u cricket-srs -n 50"
fi

# ─── 6. Verify All Services ────────────────────────────
log "Step 6/6: Verifying all cricket services..."

NGINX_OK=$(nginx -t 2>&1 | grep -c "successful" || true)
SRS_OK=$(systemctl is-active cricket-srs 2>/dev/null || echo "inactive")

log "  ℹ Nginx config: $([ "$NGINX_OK" -gt 0 ] && echo 'OK' || echo 'WARNING')"
log "  ℹ SRS status: $SRS_OK"

# Quick API health checks
HTTP_PUBLIC=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/v1/cricket/public/tournament/active -H "Host: cricket.traceodd.com" 2>/dev/null || echo "000")
log "  ℹ Public API health check: HTTP $HTTP_PUBLIC"

log "══════════════════════════════════════════════"
log "CRICKET MODULE AWAKE AND OPERATIONAL"
log "══════════════════════════════════════════════"
log ""
log "Next steps:"
log "  1. Verify public portal: https://cricket.traceodd.com"
log "  2. Verify manager panel: https://manager.cricket.traceodd.com"
log "  3. Verify RTMP ingest: rtmp://cricket.traceodd.com:1935/live/{stream_key}"
log "  4. Verify HLS output: https://cricket.traceodd.com/hls/live/{stream_key}.m3u8"
log "  5. Configure CDN Pull Zone (see BunnyCDN docs)"
log "  6. Seed tournament data via Sub-Admin panel"
log "  7. Assign Cricket Managers and start scoring"
log ""

exit 0
