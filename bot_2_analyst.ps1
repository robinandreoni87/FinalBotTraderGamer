# === BOT 2: THE ANALYST ===
# Purpose: Scans top leaders and filters them for the Executor.

. "$PSScriptRoot\config.ps1"

function Invoke-MarketScan {
    Write-Host "`n[ANALYSIS] Scanning Leaders... ($(Get-Date))" -ForegroundColor Cyan
    $headers = @{ Authorization = "Bearer $global:TOKEN" }
    
    $trends = if (Test-Path $global:PATH_DATA_INTEL) { (Get-Content $global:PATH_DATA_INTEL -Raw | ConvertFrom-Json).symbol } else { @() }
    $bans   = if (Test-Path $global:PATH_DATA_BANS) { (Get-Content $global:PATH_DATA_BANS -Raw | ConvertFrom-Json).agent_id } else { @() }

    try {
        $res = Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/grouped?limit=30" -Method Get -Headers $headers
        $insights = foreach ($agent in $res.agents) {
            if ($bans -contains $agent.agent_id) { continue }
            
            $isTrending = $null -ne $agent.positions -and ($agent.positions.symbol | Where-Object { $trends -contains $_ })
            if ($agent.position_pnl -gt 0 -or $isTrending) {
                Write-Host "  > Leader Found: $($agent.agent_name) (PnL: $($agent.position_pnl))"
                @{
                    agent_id   = $agent.agent_id
                    name       = $agent.agent_name
                    pnl        = $agent.position_pnl
                    top_assets = $agent.positions | Select-Object -First 3 | ForEach-Object { @{ symbol=$_.symbol; market=$_.market } }
                }
            }
        }
        $insights | ConvertTo-Json -Depth 5 | Out-File -FilePath $global:PATH_DATA_MARKET -Encoding utf8
        Write-Host "[SUCCESS] Market Insights Updated." -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq "Unauthorized") { $global:TOKEN = Update-Session }
        Write-Host "[ERROR] Scan failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Bot 2 (Analyst) ONLINE" -ForegroundColor Yellow
while ($true) { Invoke-MarketScan; Start-Sleep -Seconds 60 }
