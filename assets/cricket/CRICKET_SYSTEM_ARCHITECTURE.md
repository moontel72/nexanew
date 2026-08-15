# ═══════════════════════════════════════════════════════════════
# NEXATRACE CRICKET — MASTER SYSTEM ARCHITECTURE & HANDOVER
# ═══════════════════════════════════════════════════════════════
# Tournament: SVSB CUP 2026
# Subdomain:  cricket.traceodd.com
# Server:     135.181.46.27 (Hetzner Ubuntu 24.04)
# Stack:      Flutter BLoC → Laravel API → PostgreSQL + Redis
# ═══════════════════════════════════════════════════════════════

---

## TABLE OF CONTENTS

1. [System Roles & Permissions Hierarchy](#1-system-roles--permissions-hierarchy)
2. [Complete File Inventory](#2-complete-file-inventory)
3. [Database Schema](#3-database-schema)
4. [Backend Architecture](#4-backend-architecture)
5. [Frontend Architecture](#5-frontend-architecture)
6. [Infrastructure Architecture](#6-infrastructure-architecture)
7. [Completed Work Summary](#7-completed-work-summary)
8. [Remaining Tasks & Future Roadmap](#8-remaining-tasks--future-roadmap)
9. [Non-Destructive Isolation Rules](#9-non-destructive-isolation-rules)
10. [Quick Reference Card](#10-quick-reference-card)

---

## 1. SYSTEM ROLES & PERMISSIONS HIERARCHY

```
┌────────────────────────────────────────────────────────────┐
│                    SUPER ADMIN                              │
│  System owner. Full control across all 5 ecosystem          │
│  verticals. Provisions Sub-Admins.                          │
│  Access: http://135.181.46.27/login                        │
└────────────────────────┬───────────────────────────────────┘
                         │ provisions
        ┌────────────────┼────────────────┬────────────────┐
        ▼                ▼                ▼                ▼
   Bus Transit    Goods Logistics   Marketplace    Financial Auditor
   (bus_transit)  (goods_logistics) (commercial..) (financial_auditor)
                                 │
                                 ▼
                    ┌────────────────────────────────────────┐
                    │   CRICKET SUB-ADMIN (cricket_ops)       │
                    │   SOLE ROLE: Provision, activate,       │
                    │   suspend Cricket Operations Managers.  │
                    │   ❌ NO match operations.               │
                    │   ❌ NO bus/goods/marketplace access.   │
                    │   Sidebar: Dashboard, Cricket Managers  │
                    │   Dashboard: Add Manager + View All     │
                    └────────────────┬───────────────────────┘
                                     │ provisions managers
                                     ▼
                    ┌────────────────────────────────────────┐
                    │ CRICKET OPERATIONS MANAGER              │
                    │ (Multi-tenant accounts. Each has:       │
                    │  email, password, permissions for       │
                    │  scores/streams/sponsors)               │
                    │ Login: /cricket-manager/login           │
                    │ Dashboard: tournament setup, live       │
                    │  scoring, camera streams, voice-to-     │
                    │  score, sponsor management.             │
                    └────────────────┬───────────────────────┘
                                     │ provides RTMP keys to
                                     ▼
                    ┌────────────────────────────────────────┐
                    │  FIELD CAMERA CREW (5 operators)        │
                    │  Smartphones with Larix Broadcaster     │
                    │  OR DSLRs via HDMI capture → OBS        │
                    │  Push RTMP to SRS on Hetzner :1935      │
                    │  Stream keys per camera per match.      │
                    └────────────────────────────────────────┘
```

### 1.1 Role Details

| Role | Auth Method | Scope | Panel URL |
|------|------------|-------|-----------|
| **Super Admin** | Sanctum token (Laravel) | All 5 verticals | `/login` |
| **Cricket Sub-Admin** | Sanctum token (Laravel) | cricket_ops vertical only | `/sub-admin/login` → `/sub-admin/dashboard` |
| **Cricket Manager** | Bearer token (SHA256, custom) | Tournament + match operations | `/cricket-manager/login` → manager dashboard |
| **Field Camera Crew** | RTMP stream key | Per-camera ingest only | OBS/Larix → `rtmp://135.181.46.27:1935/live/{key}` |

### 1.2 Cricket Manager Permissions (Granular)

Each Cricket Manager has three toggleable permissions set by the Sub-Admin:

| Permission | Key | Controls |
|-----------|-----|----------|
| Can manage scores | `can_manage_scores` | Ball-by-ball updates, undo, commentary |
| Can manage streams | `can_manage_streams` | Activate/deactivate camera feeds |
| Can manage sponsors | `can_manage_sponsors` | Assign sponsor banners to matches |

### 1.3 Cricket Manager Session & Failover

- Up to **5 managers** can be assigned per match (primary + backups)
- **`takeOver` endpoint**: Any assigned manager can take over active match management if the primary's device fails
- Session heartbeat tracked via `cricket_match_managers.is_active_session` and `last_heartbeat_at`

---

## 2. COMPLETE FILE INVENTORY

### 2.1 Backend — PHP (30 files in `backend/app/`)

#### Models (`app/Models/Cricket/`) — 15 files

| File | Table | Purpose |
|------|-------|---------|
| `Tournament.php` | `cricket_tournaments` | Tournament lifecycle + `is_active` sleep toggle |
| `CricketManager.php` | `cricket_managers` | Bearer token auth, password hashing, permissions |
| `Team.php` | `cricket_teams` | Team profiles per tournament |
| `Player.php` | `cricket_players` | Player profiles with roles |
| `MatchOfficial.php` | `cricket_match_officials` | Umpires, referees, scorers |
| `MatchModel.php` | `cricket_matches` | Match schedule, toss, status, result |
| `MatchManager.php` | `cricket_match_managers` | Manager-to-match assignment with HA/failover |
| `Innings.php` | `cricket_innings` | JSONB deliveries + aggregate stats |
| `LiveScore.php` | `cricket_live_scores` | Denormalized current score snapshot |
| `Commentary.php` | `cricket_commentary` | Ball-by-ball auto-generated commentary |
| `StreamEndpoint.php` | `cricket_streams` | Multi-camera RTMP/HLS config (5 max per match) |
| `Sponsor.php` | `cricket_sponsors` | Sponsor profiles with tier/banner |
| `MatchSponsor.php` | `cricket_match_sponsors` | Per-match sponsor allocation (10 max) |
| `VoiceScoreLog.php` | `cricket_voice_score_logs` | DeepSeek V4 Pro voice-to-score audit trail |
| `ManagerSessionLog.php` | `cricket_manager_session_logs` | Manager action audit log |

#### Controllers (`app/Http/Controllers/Cricket/`) — 11 files

| File | Auth | Key Methods |
|------|------|-------------|
| `CricketManagerAuthController.php` | None (login) / Bearer (me, logout) | `login`, `logout`, `me` |
| `CricketManagerController.php` | Sanctum + sub.admin | `index`, `store`, `show`, `update`, `suspend`, `activate`, `destroy` |
| `TournamentController.php` | Sanctum + sub.admin | CRUD for tournaments |
| `TeamController.php` | Sanctum + sub.admin | CRUD for teams |
| `PlayerController.php` | Sanctum + sub.admin | CRUD for players |
| `MatchController.php` | Sanctum + sub.admin | CRUD + `updateToss`, `startMatch`, `assignManager`, `removeManager`, `takeOver` |
| `LiveScoreController.php` | Public (show) / Bearer (update, undo) | `show`, `fullScorecard`, `update`, `undoLastBall` |
| `StreamController.php` | Bearer | `index`, `store`, `update`, `activate`, `deactivate`, `destroy` |
| `SponsorController.php` | Sanctum / Bearer | Sponsor CRUD + match assignment |
| `VoiceScoreController.php` | Bearer | `process`, `apply`, `reject`, `history` |
| `PublicMatchController.php` | None | `activeTournament`, `liveMatches`, `allMatches`, `score`, `streamUrl`, `teams`, `matchSponsors` |

#### Middleware (`app/Http/Middleware/Cricket/`) — 1 file

| File | Purpose |
|------|---------|
| `CricketManagerAuth.php` | Bearer token validation against `cricket_managers.auth_token` (SHA256). Stores manager in `$request->attributes`. Exposes `CricketManagerAuth::manager($request)` static helper. |

#### Services (`app/Services/Cricket/`) — 1 file

| File | Purpose |
|------|---------|
| `LiveScoreService.php` | Core scoring engine: `processBall()`, `undoLastBall()`. Updates innings stats, live score snapshot, auto-generates commentary, syncs Redis cache (`cricket:score:{id}`), broadcasts via Reverb WebSocket. |

#### Events (`app/Events/Cricket/`) — 1 file

| File | Channel | Purpose |
|------|---------|---------|
| `CricketScoreUpdated.php` | `cricket.match.{id}` | `ShouldBroadcastNow` — immediate WebSocket fan-out on score update |

### 2.2 Database — 2 files

| File | Purpose |
|------|---------|
| `database/migrations/2026_08_09_000001_create_cricket_module_tables.php` | Creates all 15 `cricket_*` tables with UUID PKs, JSONB columns, indexes |
| `database/seeders/CricketFeatureRegistrySeeder.php` | Seeds `cricket_ops` vertical + 12 feature codes in `feature_registry` and `sub_admin_verticals` |

### 2.3 Routes — 1 file

| File | Groups |
|------|--------|
| `routes/panels/cricket.php` | 3 route groups: `api/v1/cricket/public` (no auth), `api/v1/cricket/manager` (Bearer), `api/v1/cricket/admin` (Sanctum + sub.admin) |

### 2.4 Flutter — Dart (19 files in `lib/features/cricket/`)

#### Data Layer — 2 files

| File | Purpose |
|------|---------|
| `data/models/cricket_models.dart` | 12 model classes: `TournamentModel`, `TeamModel`, `MatchModel`, `LiveScoreSnapshot`, `RecentBall`, `StreamModel`, `SponsorModel`, `CricketManagerModel`, `CommentaryModel`, `PlayerStats`, `BowlerStats` |
| `data/repositories/cricket_repository.dart` | Independent HTTP client with `cricket_manager_token` key. No dependency on shared `ApiClient` singleton. All REST endpoints + WebSocket via `WebSocketHub`. |

#### BLoCs — 7 files

| BLoC | Purpose |
|------|---------|
| `match_list_bloc` | Tournament + match list loading |
| `live_score_bloc` | WebSocket-driven realtime score with REST fallback |
| `stream_player_bloc` | HLS ABR player + camera switching |
| `cricket_auth_bloc` | Manager Bearer token login/logout |
| `camera_switcher_bloc` | Multi-camera toggle + failover |
| `voice_score_bloc` | Transcript → DeepSeek V4 → parsed score → apply/reject |
| `sponsor_bloc` | Match sponsor listing |

#### Pages — 7 files

| File | Type | Route/Access |
|------|------|-------------|
| `public/tournament_home_page.dart` | Public | `/cricket` route (in-app) |
| `public/live_match_page.dart` | Public | Match detail: stream + score + ball-by-ball |
| `manager/manager_login_page.dart` | Manager | `/cricket-manager/login` |
| `manager/manager_score_page.dart` | Manager | Ball-by-ball input: runs/wicket/extras buttons |
| `manager/camera_switcher_page.dart` | Manager | Multi-camera toggle switches |
| `manager/voice_score_page.dart` | Manager | Text-to-score input with parsed preview |
| `manager/sponsor_manage_page.dart` | Manager | Sponsor list for a match |

#### Widgets — 5 files

| File | Purpose |
|------|---------|
| `match_card.dart` | Compact match card for list |
| `scoreboard_header.dart` | Gradient scoreboard with CRR/RRR/target |
| `ball_by_ball_ticker.dart` | Colored ball indicators for recent overs |
| `video_player_widget.dart` | HLS player placeholder (production: `better_player`) |
| `sponsor_banner.dart` | Horizontal scrolling sponsor carousel |

#### Sub-Admin Panel Pages — 2 files

| File | Route | Purpose |
|------|-------|---------|
| `nexa_admin/.../cricket/cricket_manager_list_page.dart` | `/sub-admin/cricket/managers` | List all provisioned managers with active/suspended toggle |
| `nexa_admin/.../cricket/cricket_manager_add_page.dart` | `/sub-admin/cricket/managers/add` | Registration form: name, email, phone, password, permissions |

### 2.5 Infrastructure — 6 files

| File | Purpose |
|------|---------|
| `.nginx/cricket.conf` | Nginx server block for `cricket.traceodd.com` |
| `.nginx/srs-cricket.conf` | SRS config: RTMP on :1935, HLS ABR (720p/480p/360p), FFmpeg transcode |
| `.nginx/cricket-srs.service` | systemd unit for SRS with CPU/memory limits |
| `.scripts/cricket-sleep.sh` | 5-step sleep: stop SRS, deactivate DB, clear Redis, disable Nginx |
| `.scripts/cricket-wake.sh` | 6-step wake: reactivate DB, enable Nginx, start SRS, verify |
| `.scripts/CDN-CONFIG.md` | BunnyCDN Pull Zone + Cloudflare Stream setup guide |

### 2.6 Documentation — 4 files

| File | Purpose |
|------|---------|
| `assets/cricket/DEPLOY.md` | Frontend build + deploy instructions |
| `assets/cricket/HARDWARE_SETUP.md` | 3-mode camera production guide (DSLR + mobile) |
| `assets/cricket/manifest.json` | PWA manifest for cricket portal |
| `assets/cricket/CRICKET_SYSTEM_ARCHITECTURE.md` | This file |

### 2.7 Modified Shared Files (14 files — additive changes only)

| File | Change |
|------|--------|
| `backend/app/Providers/PanelRouteServiceProvider.php` | Added `'cricket'` to `$panels` array |
| `backend/bootstrap/app.php` | Registered `'cricket.manager'` middleware alias |
| `backend/routes/channels.php` | Added public `cricket.match.{id}` channel |
| `backend/config/services.php` | Added `deepseek.api_key` config |
| `backend/database/seeders/DatabaseSeeder.php` | Added `CricketFeatureRegistrySeeder` |
| `backend/app/Http/Controllers/Auth/GlobalAuthController.php` | Added `sub_admin_vertical` to login response + `resolveSubAdminVertical()` helper |
| `backend/app/Http/Controllers/Admin/SubAdminController.php` | Added `cricket_ops` to vertical validation `in:` rules (store + update) |
| `lib/routes/app_router.dart` | Added cricket manager routes, cricket sub-admin routes, imports, redirect bypasses |
| `lib/features/nexa_admin/.../sub_admin_dashboard.dart` | Vertical-aware sidebar + `_cricketDashboard` builder |
| `lib/features/nexa_admin/.../add_sub_admin_screen.dart` | Added `cricket_ops` vertical option + icon + color |
| `lib/features/nexa_admin/.../sub_admin_list_screen.dart` | Added `cricket_ops` to vertical maps |
| `.github/workflows/deploy.yml` | Added Cricket SRS/Nginx/lifecycle deployment steps + seeder call |
| `.github/workflows/frontend-deploy.yml` | Added cricket web build step (later removed as cricket integrated into shared app) |
| `pubspec.yaml` | Added `web_socket_channel` dependency |

---

## 3. DATABASE SCHEMA

### 3.1 Table Map (15 tables, all prefixed `cricket_*`)

```
cricket_tournaments
cricket_managers
cricket_teams
cricket_players
cricket_match_officials
cricket_matches
cricket_match_managers     ← Pivot: match ↔ manager (HA/failover)
cricket_match_squads       ← Phase 0: playing XI / batting order per team
cricket_innings           ← JSONB deliveries + aggregate stats
cricket_live_scores       ← Denormalized snapshot (1 row per match)
cricket_commentary        ← Ball-by-ball text
cricket_streams           ← Multi-camera RTMP/HLS endpoints
cricket_sponsors
cricket_match_sponsors    ← Pivot: match ↔ sponsor (max 10)
cricket_voice_score_logs  ← DeepSeek V4 audit trail
cricket_manager_session_logs ← Manager action audit
```

### 3.2 Key Design Decisions

- **UUID PKs** on all tables via `gen_random_uuid()` default
- **JSONB columns** for flexible data: `cricket_innings.deliveries`, `cricket_live_scores.full_snapshot`, `cricket_tournaments.match_result`
- **Soft deletes** on major entities (`deleted_at`)
- **Partial unique indexes** on pivot tables (`WHERE revoked_at IS NULL` pattern)
- **Zero foreign keys** to existing ecosystem tables — complete isolation

### 3.3 Redis Cache Keys

| Key Pattern | TTL | Purpose |
|-------------|-----|---------|
| `cricket:score:{match_id}` | 5s | Current score JSON for REST fallback |
| `cricket:match:live_list` | 5s | Active match IDs |
| `cricket:commentary:{match_id}:latest` | 60s | Latest 50 commentary entries |
| `cricket:tournament:active` | 300s | Active tournament config |
| `cricket:module:active` | 60s | Module sleep mode flag |

---

## 4. BACKEND ARCHITECTURE

### 4.1 Auth Flow — Cricket Manager Login

```
1. Manager → POST /api/v1/cricket/manager/login {email, password}
2. CricketManagerAuthController::login()
   → Lookup CricketManager by email
   → verifyPassword() using Hash::check (bcrypt)
   → generateAuthToken() → 64-char random → SHA256 hash stored in DB
   → Return plaintext token + manager profile
3. Flutter stores token under 'cricket_manager_token' in SharedPreferences
4. All subsequent requests → Authorization: Bearer {plaintext_token}
5. CricketManagerAuth middleware:
   → SHA256 hash of Bearer token
   → Lookup in cricket_managers.auth_token
   → Check expiration, extend on activity
   → Store manager in $request->attributes
```

### 4.2 Score Update Flow (WebSocket + Redis)

```
1. Manager → POST /api/v1/cricket/manager/matches/{id}/score
2. LiveScoreService::processBall()
   → DB transaction:
     a. Append delivery to cricket_innings.deliveries (JSONB)
     b. Update aggregate stats (runs, wickets, overs, extras)
     c. Update cricket_live_scores (denormalized snapshot)
     d. Generate cricket_commentary row
   → Redis SETEX cricket:score:{id} <json> EX 5
   → CricketScoreUpdated event → Reverb broadcast on cricket.match.{id}
3. Public viewers:
   → WebSocket: Subscribe to cricket.match.{id} → receive push
   → REST fallback: GET /api/v1/cricket/public/matches/{id}/score → reads Redis cache
```

### 4.3 Voice-to-Score Flow (DeepSeek V4 Pro)

```
1. Manager speaks/type → POST /api/v1/cricket/manager/voice-score/process
2. VoiceScoreController::process()
   → Store cricket_voice_score_logs row (status: processing)
   → Call DeepSeek V4 Pro API with cricket scoring system prompt
   → Parse structured JSON: {runs, is_wicket, wicket_type, extras_type, commentary_hint}
   → Update log (status: parsed)
3. Manager reviews parsed result → Apply or Reject
4. If Apply → Manager manually enters the score via score update endpoint
   (voice input is advisory; score is always human-confirmed)
5. If DeepSeek API unavailable → localFallbackParsing() using regex patterns
```

### 4.4 Sub-Admin Vertical Integration

The `cricket_ops` vertical is the 5th entry in `sub_admin_verticals`:

| Vertical Code | Display Name |
|--------------|-------------|
| `bus_transit` | Sub-Admin 1 — Bus Transit |
| `goods_logistics` | Sub-Admin 2 — Goods & Logistics |
| `commercial_marketplace` | Sub-Admin 3 — Commercial Marketplace |
| `financial_auditor` | Sub-Admin 4 — Financial & Subscription Auditor |
| `cricket_ops` | Sub-Admin 5 — Cricket Tournament Operations |

- `SubAdminMiddleware` dynamically queries `sub_admin_assignments` + `sub_admin_verticals` — no code change needed
- `GlobalAuthController::login` returns `sub_admin_vertical` dynamically via `resolveSubAdminVertical()`
- `SubAdminController` validation rules include `cricket_ops` in `in:` list

### 4.5 WebSocket Channels

| Channel | Subscribers | Event |
|---------|------------|-------|
| `cricket.match.{id}` | Public viewers, Manager panel | `score.updated` |
| Existing fleet channels | Bus/Goods modules | Unchanged |

---

## 5. FRONTEND ARCHITECTURE

### 5.1 Component Tree

```
lib/features/cricket/
├── data/
│   ├── models/cricket_models.dart         (12 model classes)
│   └── repositories/cricket_repository.dart (REST + WS, independent HTTP client)
└── presentation/
    ├── blocs/                              (7 BLoCs with sealed states/events)
    │   ├── match_list/
    │   ├── live_score/
    │   ├── stream_player/
    │   ├── cricket_auth/
    │   ├── camera_switcher/
    │   ├── voice_score/
    │   └── sponsor/
    ├── pages/
    │   ├── public/                         (tournament_home, live_match)
    │   └── manager/                        (login, score, camera, voice, sponsor)
    └── widgets/                            (match_card, scoreboard, ball_ticker, video, banner)

lib/features/nexa_admin/.../sub_admin/
├── cricket/
│   ├── cricket_manager_list_page.dart      (Sub-Admin → View All Managers)
│   └── cricket_manager_add_page.dart       (Sub-Admin → Add Manager form)
├── sub_admin_dashboard.dart               (Modified: vertical-aware)
├── add_sub_admin_screen.dart              (Modified: cricket_ops opt)
└── sub_admin_list_screen.dart             (Modified: cricket_ops opt)

lib/routes/app_router.dart                 (Modified: cricket routes)
```

### 5.2 Key Design Decisions

- **Independent HTTP client**: `CricketRepository` uses its own `http.Client` and stores token under `cricket_manager_token` key — NO conflict with shared `ApiClient` singleton
- **Sealed class BLoC pattern**: All 7 BLoCs use Dart 3 `sealed class` for states and events with exhaustive switch
- **WebSocket via shared `WebSocketHub`**: Subscribe via `WebSocketHub.instance.subscribe('cricket.match.{id}', callback)`
- **No separate entry point**: Cricket is integrated into the shared Flutter app via `go_router` routes — `main_cricket.dart` was deleted

### 5.3 Route Map

| Route | Page | Auth |
|-------|------|------|
| `/cricket-manager/login` | `ManagerLoginPage` | None |
| `/cricket-manager/dashboard` | `ManagerDashboardPage` | Bearer (via BlocProvider) |
| `/sub-admin/login` | `SubAdminLoginScreen` | None |
| `/sub-admin/dashboard` | `SubAdminDashboardScreen` | Sanctum (sub-admin) |
| `/sub-admin/cricket/managers` | `CricketManagerListPage` | Sanctum (sub-admin) |
| `/sub-admin/cricket/managers/add` | `CricketManagerAddPage` | Sanctum (sub-admin) |

---

## 6. INFRASTRUCTURE ARCHITECTURE

### 6.1 Signal Flow

```
┌──────────┐  RTMP :1935  ┌─────────────┐  HLS pull  ┌──────────────┐
│ OBS /    │ ──────────── │ SRS on      │ ────────── │ BunnyCDN     │
│ Larix    │              │ Hetzner     │            │ Edge Nodes   │
│ Phones   │              │ (transcode) │            │ (20K viewers)│
└──────────┘              └──────┬──────┘            └──────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │ Nginx (cricket.conf)    │
                    │ /api/ → PHP-FPM         │
                    │ /app/ → Reverb :8080    │
                    │ /hls/ → static segments │
                    │ /     → Flutter web     │
                    └─────────────────────────┘
```

### 6.2 Server Processes

| Service | Port | Unit |
|---------|------|------|
| Nginx | 80 | `nginx` |
| PHP-FPM | unix socket | `php8.3-fpm` |
| Laravel Reverb | 8080 | `nexatrace-reverb` |
| SRS Media Server | 1935, 1985, 8088 | `cricket-srs` |
| Redis | 6379 | `redis-server` |
| PostgreSQL | 5432 | `postgresql` |

### 6.3 Lifecycle Management

| Script | Purpose | Command |
|--------|---------|---------|
| `cricket-wake.sh` | Activate tournament: enable Nginx, start SRS, seed DB | `sudo /usr/local/bin/cricket-wake.sh` |
| `cricket-sleep.sh` | Deactivate tournament: stop SRS, disable Nginx, clear Redis, free resources | `sudo /usr/local/bin/cricket-sleep.sh` |

Sleep mode guarantees: 0% CPU, 0% RAM, 0 DB connections consumed by cricket module. All cricket data preserved in PostgreSQL.

---

## 7. COMPLETED WORK SUMMARY

### Phase 1 — Database & Backend
- [x] 15 `cricket_*` tables with UUID PKs, JSONB, soft deletes
- [x] 15 Laravel models in `App\Models\Cricket\`
- [x] 11 Laravel controllers in `App\Http\Controllers\Cricket\`
- [x] 1 custom middleware: `CricketManagerAuth`
- [x] 1 service: `LiveScoreService` (scoring engine)
- [x] 1 event: `CricketScoreUpdated` (Reverb broadcast)
- [x] 1 route file: `routes/panels/cricket.php` (3 groups, 40+ routes)
- [x] 5th vertical integration: `cricket_ops` in `sub_admin_verticals` + 12 feature codes
- [x] Dynamic sub-admin vertical resolution in `GlobalAuthController::login`
- [x] Backend validation for `cricket_ops` in `SubAdminController`

### Phase 2 — Infrastructure
- [x] Nginx server block: `cricket.traceodd.com`
- [x] SRS media server: RTMP ingest + HLS ABR transcoding (3 renditions)
- [x] SRS systemd service with resource limits
- [x] Sleep/wake lifecycle scripts
- [x] BunnyCDN/Cloudflare configuration guide
- [x] CI/CD pipeline updates (deploy.yml, frontend-deploy.yml)

### Phase 3 — Flutter + PWA
- [x] Clean Architecture + BLoC: 7 BLoCs with sealed states
- [x] Independent `CricketRepository` with own HTTP client + token storage
- [x] Cricket Manager login → dashboard flow with `BlocProvider.value`
- [x] Sub-Admin list/add manager pages with routes
- [x] Dynamic sidebar (cricket_ops vs bus/goods)
- [x] Strict dashboard separation (Sub-Admin vs Manager)
- [x] DeepSeek V4 voice-to-score pipeline
- [x] PWA manifest + deployment guide

### UI Refactoring
- [x] Sub-Admin sidebar: vertical-aware filtering
- [x] Cricket Sub-Admin dashboard: only 2 buttons (Add Manager, View All)
- [x] Cricket Manager Panel: separate `/cricket-manager/*` routes
- [x] "SVSB CUP 2026" branding on login page

### Isolated Auth
- [x] Cricket Manager Bearer tokens stored under `cricket_manager_token` key
- [x] No conflict with shared `ApiClient` singleton or sanctum tokens
- [x] Middleware uses Laravel-standard `$request->attributes` (not `setUserResolver`)

### Phase 0 — Scoring Foundation (2026-08-15)
- [x] `cricket_match_squads` table (playing XI, batting order, bench, partial unique indexes)
- [x] `cricket_innings` current striker / non-striker / bowler columns
- [x] `cricket_live_scores` striker_id / non_striker_id / bowler_id columns
- [x] Session-log enum extended with `update_squad` audit action
- [x] `LiveScoreService` rebuilt: unique `ball_id` per delivery, over/ball
      sequence numbers, batter/bowler attribution, strike rotation replay,
      per-batter & per-bowler scorecards (previously dormant columns),
      partnership tracking, bowler over-limit + no-consecutive-over rules
- [x] Full aggregate rebuild from the delivery log on every write — append,
      undo, and future edit/delete share one source of truth
- [x] `SquadController` + routes: GET / PUT `matches/{id}/squads[/{teamId}]`
- [x] Rust: `trace_odd_rust cricket --recompute` pure scoring-math module
      (mirrors the PHP engine rule-for-rule) with unit tests — the Phase 2
      correction/recompute engine
- [x] Flutter: `LiveScoreSnapshot` extended with `batters`, `bowlers`,
      `current` players, `max_overs_per_bowler`; squad models + repository
      methods (`getMatchSquads`, `saveMatchSquad`)
- [x] Backward compatible: legacy balls without player attribution keep
      scoring unchanged; new features activate as attribution arrives

### Phase 2 — Ball-by-Ball Correction Interface (2026-08-15)
- [x] Tappable delivery history on the scoring console (unique `ball_id`
      per delivery, newest first, `GET matches/{id}/deliveries`)
- [x] Edit flow: `PUT matches/{id}/deliveries/{ballId}` — runs, extras,
      wicket info, batter/bowler overrides; the engine recomputes every
      aggregate forward from the delivery log (totals, scorecards, FOW,
      current players, partnership) and regenerates all commentary rows
- [x] Delete flow: `DELETE matches/{id}/deliveries/{ballId}` — same
      forward recomputation from the remaining log
- [x] Rust cross-check: after every correction the engine pipes the
      delivery log through `trace_odd_rust cricket --recompute` and logs
      any PHP/Rust aggregate drift (config: `config/cricket.php`,
      env `CRICKET_RUST_BINARY`)
- [x] Audit trail: corrections logged in `cricket_manager_session_logs`
      (`edit_ball` / `delete_ball` metadata) + per-ball `edited_at` /
      `edited_by_cricket_manager_id` stamps
- [x] Flutter: `CorrectionBloc` (history + BLoC-driven edit form),
      `DeliveryHistoryCard` + `CorrectionSheet`, shared `BallBadge`
      extracted for reuse by the ticker and the history list
- [x] Guardrails: current innings only, match must be in progress,
      server-side validation mirrors the scoring endpoint

### Phase 3 — Public Fan Portal 3-Partition Layout (2026-08-15)
- [x] `MatchThreeColumnLayout` widget replaces the old vertical stack
      below the video player
- [x] LEFT — Bowlers column: the two most recent bowlers with overs,
      runs conceded, wickets, economy + live `NOW` highlight on the
      active bowler
- [x] CENTER — Batters column: striker & non-striker with runs, balls,
      fours, sixes, strike rate — auto-increments on every realtime
      snapshot push (plus OUT badge when dismissed)
- [x] RIGHT — Match summary: shared `CricketScoreboard` (score, wickets,
      overs, CRR/RRR, partnership) + shared `BallByBallTicker` timeline
- [x] Responsive: side-by-side at >= 900px, stacked summary-first on
      narrow/mobile screens; zero new BLoCs — the existing LiveScoreBloc
      snapshot drives all three columns (pure functions of state)

---

## 8. REMAINING TASKS & FUTURE ROADMAP

### 8.1 Pre-Tournament Testing

| Task | Priority | Detail |
|------|----------|--------|
| Live camera field test | HIGH | Deploy 1 DSLR + 2 smartphones with Larix Broadcaster. Push RTMP to SRS. Verify HLS playback on CDN. Measure latency. |
| Multi-camera failover | HIGH | Kill primary camera stream → verify auto-switch to backup on CDN. Measure cutover time. |
| Load test: 20K WebSocket | MEDIUM | Simulate 20,000 concurrent Reverb connections subscribing to `cricket.match.{id}`. Verify Redis Pub/Sub throughput. |
| Load test: 20K HLS | MEDIUM | Simulate CDN edge traffic. Verify origin only serves HLS segments, not viewer requests. |
| Score update stress test | MEDIUM | Rapid ball-by-ball updates (1/second). Verify no DB deadlocks, Redis cache consistency. |
| Voice-to-score E2E | LOW | Test DeepSeek V4 API with real cricket commentary. Measure parsing accuracy + latency. |

### 8.2 Production Go-Live

| Task | Priority | Detail |
|------|----------|--------|
| DNS propagation | HIGH | Add A record: `cricket.traceodd.com → 135.181.46.27` |
| SSL certificate | HIGH | `certbot --nginx -d cricket.traceodd.com` |
| CDN activation | HIGH | Create BunnyCDN Pull Zone pointing to origin. Test with `curl -I`. |
| Tournament data seeding | MEDIUM | Create tournament, 10 teams, players, match schedule via Sub-Admin panel |
| Manager provisioning | MEDIUM | Create 2+ Cricket Manager accounts, assign to matches |
| WAF/rate limiting | LOW | Add Cloudflare WAF rules for API endpoints if using Cloudflare |
| Backup schedule | LOW | `pg_dump -t cricket_*` cron job |

### 8.3 Known Limitations

- **HLS latency**: ~10-15 seconds glass-to-glass with CDN. Acceptable for cricket, not real-time.
- **FFmpeg CPU**: SRS transcoding uses 2-3 CPU cores. During 2 simultaneous matches, monitor CPU.
- **Single SRS instance**: No horizontal scaling for RTMP ingest. OK for 5-camera setup, not 50.
- **Voice score is advisory**: DeepSeek output must be human-confirmed — not auto-applied.

---

## 9. NON-DESTRUCTIVE ISOLATION RULES

### ⚠️ CRITICAL — READ BEFORE ANY CODE CHANGE

These rules MUST be followed by any AI agent or developer working on this system:

1. **DO NOT modify any file outside these scopes:**
   - `lib/features/cricket/**`
   - `backend/app/Models/Cricket/**`
   - `backend/app/Http/Controllers/Cricket/**`
   - `backend/app/Http/Middleware/Cricket/**`
   - `backend/app/Services/Cricket/**`
   - `backend/app/Events/Cricket/**`
   - `backend/routes/panels/cricket.php`
   - `backend/database/migrations/*cricket*`
   - `backend/database/seeders/*Cricket*`
   - `assets/cricket/**`
   - `.nginx/cricket*`
   - `.nginx/srs-cricket*`
   - `.scripts/cricket*`

2. **Shared files that have been modified (additive only):**
   - `lib/routes/app_router.dart` — Only cricket route additions
   - `lib/features/nexa_admin/.../sub_admin_dashboard.dart` — Only `_cricketDashboard` + sidebar filter
   - `lib/features/nexa_admin/.../add_sub_admin_screen.dart` — Only cricket_ops entry in `_verticals`
   - `lib/features/nexa_admin/.../sub_admin_list_screen.dart` — Only cricket_ops entry in maps
   - `backend/app/Providers/PanelRouteServiceProvider.php` — Only `'cricket'` in array
   - `backend/bootstrap/app.php` — Only `'cricket.manager'` alias
   - `backend/routes/channels.php` — Only cricket channel
   - `backend/config/services.php` — Only `deepseek` config
   - `backend/app/Http/Controllers/Auth/GlobalAuthController.php` — Only `sub_admin_vertical` + helper
   - `backend/app/Http/Controllers/Admin/SubAdminController.php` — Only `cricket_ops` in validation
   - `.github/workflows/deploy.yml` — Only cricket SRS/Nginx/seeder steps
   - `pubspec.yaml` — Only `web_socket_channel` dependency
   - **Any future changes to these files must be purely additive.**

3. **DO NOT touch the 17 core modules:**
   - Bus Transit (Modules 13-15)
   - Goods Logistics (Modules 9-11)
   - Commercial Marketplace (Modules 6, 7, 12)
   - Financial & Subscription Auditor
   - Factory Enterprise (Modules 3-5, 8)
   - Customer App
   - Reseller/Shopkeeper modules

4. **Database isolation:**
   - All cricket tables are prefixed `cricket_*`
   - NO foreign keys to non-cricket tables
   - NO queries that JOIN cricket tables with core ecosystem tables

5. **Auth isolation:**
   - Cricket Manager tokens stored under `cricket_manager_token` key
   - Never overwrite `AppConstants.authTokenKey` or `sub_admin_token`
   - Cricket auth middleware is completely independent from Sanctum

---

## 10. QUICK REFERENCE CARD

### URLs

| Purpose | URL |
|---------|-----|
| Super Admin Login | `http://135.181.46.27/login` |
| Sub-Admin Login | `http://135.181.46.27/sub-admin/login` |
| Sub-Admin Dashboard | `http://135.181.46.27/sub-admin/dashboard` |
| Cricket Manager Login | `http://135.181.46.27/cricket-manager/login` |
| Add Manager (Sub-Admin) | `http://135.181.46.27/sub-admin/cricket/managers/add` |
| View Managers (Sub-Admin) | `http://135.181.46.27/sub-admin/cricket/managers` |
| RTMP Ingest | `rtmp://135.181.46.27:1935/live/{stream_key}` |
| HLS Playlist | `https://cricket.traceodd.com/hls/live/{stream_key}.m3u8` |
| SRS HTTP API | `http://135.181.46.27:1985/api/v1/` |

### Server Commands

```bash
# SSH
ssh root@135.181.46.27

# Cricket lifecycle
sudo /usr/local/bin/cricket-wake.sh
sudo /usr/local/bin/cricket-sleep.sh

# SRS control
systemctl status cricket-srs
systemctl start cricket-srs
systemctl stop cricket-srs
journalctl -u cricket-srs -f

# Laravel
cd /var/www/traceodd/admin-panel
php artisan route:list | grep cricket
php artisan optimize:clear && php artisan optimize
php artisan db:seed --class=CricketFeatureRegistrySeeder --force

# Nginx
nginx -t && systemctl reload nginx

# Logs
tail -100 /var/log/srs-cricket.log
tail -100 /var/www/traceodd/admin-panel/storage/logs/laravel.log
```

---

> **Document Version:** 1.0  
> **Last Updated:** 2026-08-10  
> **Maintained By:** NexaTrace Engineering Team  
> **Total Files:** 30 PHP + 19 Dart + 6 Infrastructure + 4 Docs = 59 files
