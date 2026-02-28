# ═══════════════════════════════════════════════════════════════
# vidyasetu - Local Development Startup Script (PowerShell)
# Starts backend (Express) and frontend (Vite) servers
# ═══════════════════════════════════════════════════════════════

$ErrorActionPreference = "Continue"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $RootDir "backend"
$FrontendDir = Join-Path $RootDir "frontend"

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "       vidyasetu - Starting Up           " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# ── Install dependencies if needed ──
if (-not (Test-Path (Join-Path $BackendDir "node_modules"))) {
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    Push-Location $BackendDir
    npm install
    Pop-Location
    Write-Host "Backend dependencies installed" -ForegroundColor Green
}

if (-not (Test-Path (Join-Path $FrontendDir "node_modules"))) {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    Push-Location $FrontendDir
    npm install
    Pop-Location
    Write-Host "Frontend dependencies installed" -ForegroundColor Green
}

# ── Start Backend ──
Write-Host "Starting backend server (port 5001)..." -ForegroundColor Cyan
$backendJob = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/c cd /d `"$BackendDir`" && npm run dev" `
    -PassThru -WindowStyle Normal

Start-Sleep -Seconds 4

# Verify backend is running
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5001/" -Method GET -TimeoutSec 5
    Write-Host "Backend is running on http://localhost:5001" -ForegroundColor Green
} catch {
    Write-Host "Backend is starting up (may take a few seconds)..." -ForegroundColor Yellow
}

# ── Start Frontend ──
Write-Host "Starting frontend dev server (port 5173)..." -ForegroundColor Cyan
$frontendJob = Start-Process -FilePath "cmd.exe" `
    -ArgumentList "/c cd /d `"$FrontendDir`" && npm run dev" `
    -PassThru -WindowStyle Normal

Start-Sleep -Seconds 4

Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "       vidyasetu is running!             " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend:  http://localhost:5173" -ForegroundColor Cyan
Write-Host "  Backend:   http://localhost:5001" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to stop all servers..." -ForegroundColor Yellow
Read-Host

# ── Cleanup ──
Write-Host "Shutting down vidyasetu..." -ForegroundColor Yellow

if ($backendJob -and -not $backendJob.HasExited) {
    Stop-Process -Id $backendJob.Id -Force -ErrorAction SilentlyContinue
    # Also kill any child node processes on port 5001
    Get-NetTCPConnection -LocalPort 5001 -ErrorAction SilentlyContinue |
        ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
    Write-Host "Backend stopped" -ForegroundColor Red
}

if ($frontendJob -and -not $frontendJob.HasExited) {
    Stop-Process -Id $frontendJob.Id -Force -ErrorAction SilentlyContinue
    # Also kill any child node processes on port 5173
    Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue |
        ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
    Write-Host "Frontend stopped" -ForegroundColor Red
}

Write-Host "vidyasetu shut down." -ForegroundColor Green
