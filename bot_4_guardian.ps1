# === BOT 4: THE GUARDIAN ===
# Purpose: Monitors safety, maintains blacklist, and validates platform data.

. "$PSScriptRoot\config.ps1"

function Invoke-SecurityPatrol {
    Write-Host "[$(Get-Date)] Running security patrol..." -ForegroundColor Red
    $headers = @{ Authorization = "Bearer $global:TOKEN" }
    
    try {
        $res = Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/grouped?limit=100" -Method Get -Headers $headers
        $bans = $res.agents | Where-Object { $_.position_pnl -lt -0.05 } | ForEach-Object {
            @{ agent_id=$_.agent_id; name=$_.agent_name; banned_at=(Get-Date).ToString(); reason="Performance below threshold" }
        }
        $bans | ConvertTo-Json | Out-File -FilePath $global:PATH_DATA_BANS -Encoding utf8
        Write-Host "  > Blacklist Updated ($($bans.Count) toxic agents)." -ForegroundColor Gray
    } catch { Write-Host "[ERROR] Guardian patrol failed." -ForegroundColor Red }
}

Write-Host "Bot 4 (Guardian) ONLINE" -ForegroundColor Red
while ($true) { Invoke-SecurityPatrol; Start-Sleep -Seconds 60 }
