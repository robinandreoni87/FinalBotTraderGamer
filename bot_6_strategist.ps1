# === BOT 6: THE STRATEGIST ===
# Purpose: Parses raw data to find asset consensus among AI sources.

. "$PSScriptRoot\config.ps1"

function Invoke-StrategyAnalysis {
    Write-Host "[$(Get-Date)] Analyzing raw reports for market consensus..." -ForegroundColor Magenta
    
    $rawPath = if ($global:PATH_RAW_REPORTS) { $global:PATH_RAW_REPORTS } else { "$PSScriptRoot\data_raw_reports.txt" }
    $stratPath = if ($global:PATH_DATA_STRATEGY) { $global:PATH_DATA_STRATEGY } else { "$PSScriptRoot\data_strategies.json" }

    if (Test-Path $rawPath) {
        $content = Get-Content $rawPath -Raw -Encoding utf8
        $symbolsFound = @{}
        
        $allMatches = [regex]::Matches($content, "\b[A-Z]{3,5}\b")
        foreach ($m in $allMatches) {
            $sym = $m.Value
            $exclude = @("THE", "AND", "FOR", "BUY", "SELL", "HOLD", "NONE", "DATE", "TIME", "EURO", "USDT", "LAST", "DAY", "SCAN", "POS", "WATCH", "SIDE")
            if ($sym -notin $exclude) {
                if (-not $symbolsFound.ContainsKey($sym)) { $symbolsFound[$sym] = @{ count = 0; market = "us-stock" } }
                $symbolsFound[$sym].count++
            }
        }

        $topPicks = $symbolsFound.GetEnumerator() | Where-Object { $_.Value.count -ge 2 } | ForEach-Object {
            @{
                symbol = $_.Key
                count = $_.Value.count
                market = if ($_.Key -match "BTC|ETH|SOL|NEAR|XRP|DOGE") { "crypto" } else { "us-stock" }
                confidence = 0.80 + ($_.Value.count * 0.02)
            }
        }

        if ($topPicks.Count -gt 0) {
            $topPicks | Sort-Object count -Descending | ConvertTo-Json | Out-File -FilePath $stratPath -Encoding utf8
            Write-Host "  > SUCCESS: Strategy Insights Updated ($($topPicks.Count) assets)." -ForegroundColor Green
        }
    }
}

Write-Host "Bot 6 (Strategist) ONLINE" -ForegroundColor Magenta
while ($true) { Invoke-StrategyAnalysis; Start-Sleep -Seconds 300 }
