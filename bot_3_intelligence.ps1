# === BOT 3: THE INTELLIGENCE ===
# Purpose: Scans platform feed and trends to identify hot assets.

. "$PSScriptRoot\config.ps1"

function Invoke-IntelScan {
    Write-Host "[$(Get-Date)] Scanning global intelligence..." -ForegroundColor Cyan
    $headers = @{ Authorization = "Bearer $global:TOKEN" }
    
    try {
        $feed = Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/feed?limit=50" -Method Get -Headers $headers
        $trends = $feed.signals | Group-Object symbol | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object {
            @{ symbol=$_.Name; market=$_.Group[0].market; confidence=0.8; reason="Market Consensus" }
        }
        
        $trends | ConvertTo-Json | Out-File -FilePath $global:PATH_DATA_INTEL -Encoding utf8
        Write-Host "  > Intelligence Data Updated." -ForegroundColor Green
    } catch { Write-Host "[ERROR] Intelligence scan failed." -ForegroundColor Red }
}

Write-Host "Bot 3 (Intelligence) ONLINE" -ForegroundColor Cyan
while ($true) { Invoke-IntelScan; Start-Sleep -Seconds (Get-Random -Min 60 -Max 120) }
