# === UNIVERSAL FLEET STARTUP ===
# Launch all bots in sequence.

Write-Host "--- INITIALIZING ROBIN TRADER FLEET ---" -ForegroundColor Cyan

# 1. Clean up
Get-WmiObject Win32_Process -Filter "CommandLine LIKE '%bot_%' OR CommandLine LIKE '%config.ps1%'" | ForEach-Object { try { taskkill /F /PID $_.ProcessId } catch {} }

# 2. Init Config
. "$PSScriptRoot\config.ps1"

# 3. Startup Sequence
$bots = @(
    @{ name="Guardian";     file="bot_4_guardian.ps1" },
    @{ name="Intelligence"; file="bot_3_intelligence.ps1" },
    @{ name="Analyst";      file="bot_2_analyst.ps1" },
    @{ name="Heartbeat";    file="bot_5_heartbeat.ps1" },
    @{ name="Strategist";   file="bot_6_strategist.ps1" },
    @{ name="Executor";     file="bot_1_executor.ps1" }
)

foreach ($bot in $bots) {
    Write-Host ">> Starting $($bot.name)..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSScriptRoot\$($bot.file)`""
    Start-Sleep -Seconds 7
}

Write-Host "`nFLEET ONLINE! 🚀💎" -ForegroundColor Green
