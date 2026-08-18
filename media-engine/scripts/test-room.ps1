<#
.SYNOPSIS
  One-command test room: mints an admin token, creates a room, and prints
  every URL + token needed to test WHIP publish / WHEP watch.

.DESCRIPTION
  Reads JWT_SECRET from .env (or the environment), mints an admin JWT with
  the bundled dev CLI, creates a room via the Studio API, and prints:

    - WHIP ingest URLs + per-camera ingest tokens  (publish from browser/OBS)
    - WHEP watch URL + viewer token                (watch in a browser)
    - the browser test page URL                    (start Studio with DEV_TEST_PAGE=1)

.EXAMPLE
  .\scripts\test-room.ps1                 # cameras: cam-1,cam-2, port 8080
  .\scripts\test-room.ps1 -Cameras "main,angle2"
  $env:STUDIO_PORT = "18080"; .\scripts\test-room.ps1
#>
param(
    [string]$Cameras = "cam-1,cam-2"
)
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    # 1. JWT secret: .env wins over current environment
    if (Test-Path ".env") {
        foreach ($line in Get-Content ".env") {
            if ($line -match '^JWT_SECRET=(.+)$') { $env:JWT_SECRET = $Matches[1].Trim(); break }
        }
    }
    if (-not $env:JWT_SECRET) { throw "JWT_SECRET not found in .env or environment" }

    # 2. Mint the admin token with the bundled dev CLI
    Write-Host "Minting admin token..." -ForegroundColor DarkGray
    $token = (& cargo run -q -p todd-common --example mint_token -- admin | Select-Object -Last 1).Trim()
    if (-not $token) { throw "failed to mint admin token" }

    # 3. Create the room
    $base = "http://127.0.0.1:$($env:STUDIO_PORT ?? '8080')"
    $cams = $Cameras -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    $body = @{
        name       = "test-room-$(Get-Random -Minimum 1000 -Maximum 9999)"
        camera_ids = $cams
        ttl_secs   = 3600
    } | ConvertTo-Json

    Write-Host "Creating room at $base ..." -ForegroundColor DarkGray
    $room = Invoke-RestMethod -Method Post -Uri "$base/api/v1/room/create" `
        -Headers @{ Authorization = "Bearer $token" } `
        -ContentType "application/json" -Body $body

    # 4. Print the cheat sheet
    Write-Host ""
    Write-Host "===== T-ODD TEST ROOM =====" -ForegroundColor Cyan
    Write-Host "ROOM ID : $($room.room.id)"
    Write-Host ""
    foreach ($cam in $cams) {
        Write-Host "WHIP publish URL ($cam):" -ForegroundColor Green
        Write-Host "  $base/api/v1/whip/ingest/$($room.room.id)/$cam"
        Write-Host "  ingest token: $($room.ingest_tokens.$cam)" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "WHEP watch URL ($($cams[0])):" -ForegroundColor Green
    Write-Host "  $base/api/v1/whep/watch/$($room.room.id)/$($cams[0])"
    Write-Host "VIEWER TOKEN: $($room.viewer_token)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "Browser test page (start Studio with DEV_TEST_PAGE=1):" -ForegroundColor Green
    Write-Host "  $base/whiptest"
    Write-Host "=============================" -ForegroundColor Cyan
} finally {
    Pop-Location
}
