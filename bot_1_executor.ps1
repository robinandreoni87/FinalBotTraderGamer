# === BOT 1: THE EXECUTOR ===
# Purpose: Manages open positions, implements trailing stops, and executes trades.

. "$PSScriptRoot\config.ps1"

# Parameters
$TARGET_MIN   = 0.02
$TARGET_MAX   = 0.05
$TRAIL_BUFFER = 0.005
$RESERVE      = 1000
$BUY_AMOUNT   = 5000

# State
$script:peakPnl = @{}

function Write-Log {
    param([string]$msg, [string]$color = "White")
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] $msg"
    Write-Host $line -ForegroundColor $color
    $logPath = if ($global:PATH_LOG_MONITOR) { $global:PATH_LOG_MONITOR } else { "$PSScriptRoot\log_monitor.txt" }
    try { $line | Out-File -FilePath $logPath -Append -Encoding utf8 } catch { }
}

function Get-Positions {
    $headers = @{ Authorization = "Bearer $global:TOKEN" }
    try { return Invoke-RestMethod -Uri "$($global:BASE_URL)/positions" -Method Get -Headers $headers }
    catch { if ($_.Exception.Response.StatusCode -eq "Unauthorized") { $global:TOKEN = Update-Session }; return $null }
}

# === MAIN LOOP ===
Write-Log -msg "Bot 1 (Executor) ONLINE" -color "Yellow"
while ($true) {
    try {
        $data = Get-Positions
        if ($data -and ($data.cash -gt ($RESERVE + $BUY_AMOUNT))) {
            $target = $null
            if (Test-Path $global:PATH_DATA_STRATEGY) {
                $strats = Get-Content $global:PATH_DATA_STRATEGY -Raw | ConvertFrom-Json
                if ($strats[0].confidence -ge 0.75) { $target = $strats[0] }
            }
            if ($null -eq $target -and (Test-Path $global:PATH_DATA_INTEL)) {
                $intel = Get-Content $global:PATH_DATA_INTEL -Raw | ConvertFrom-Json
                if ($intel[0].confidence -ge 0.8) { $target = $intel[0] }
            }

            if ($target -and $target.symbol) {
                if (-not ($data.positions | Where-Object { $_.symbol -eq $target.symbol })) {
                    $s = $target.symbol
                    $m = if ($target.market) { $target.market } else { "crypto" }
                    
                    $price = 0
                    # 1. Try Realtime
                    try {
                        $resP = Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/realtime?symbol=$s" -Method Get -Headers @{ Authorization="Bearer $global:TOKEN" }
                        $price = $resP.price
                    } catch {
                        # 2. Try Feed Fallback (with STRICT symbol check)
                        try {
                            $feed = Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/feed?limit=20"
                            $match = $feed.signals | Where-Object { $_.symbol -eq $s } | Select-Object -First 1
                            if ($match.entry_price) { $price = $match.entry_price }
                            elseif ($match.current_price) { $price = $match.current_price }
                        } catch { }
                    }

                    # 3. Execution
                    if ($price -gt 0) {
                        $qty = if ($m -match "stock") { [Math]::Floor($BUY_AMOUNT / $price) } else { [Math]::Round($BUY_AMOUNT / $price, 2) }
                        if ($qty -gt 0) {
                            # We send price = $null to let the server execute at Market Price (safer)
                            $body = @{ market=$m; action="buy"; symbol=$s; price=$null; quantity=$qty; executed_at="now" } | ConvertTo-Json
                            Write-Log -msg "EXECUTION: Buying $qty $s (Ref Price: $price)" -color "Green"
                            try {
                                Invoke-RestMethod -Uri "$($global:BASE_URL)/signals/realtime" -Method Post -Body $body -Headers @{ Authorization="Bearer $global:TOKEN" } -ContentType "application/json"
                                Write-Log -msg "SUCCESS: Order placed for $s" -color "Green"
                            } catch { Write-Log -msg "TRADE ERROR: $($_.Exception.Message)" -color "Red" }
                        }
                    } else {
                        Write-Log -msg "SKIPPED: No reliable price for $s. Waiting for next sync." -color "Gray"
                    }
                }
            }
        }
    } catch { Write-Log -msg "Loop Warning: $($_.Exception.Message)" -color "Red" }
    Start-Sleep -Seconds 15
}
