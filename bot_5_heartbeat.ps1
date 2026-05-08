# === BOT 5: HEARTBEAT ===
# Keeps the platform connection alive, earns points, and handles notifications.

. "$PSScriptRoot\config.ps1"

$script:pulseCount = 0

function Write-Log {
    param([string]$msg, [string]$color = "DarkCyan")
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$timestamp] [HEARTBEAT] $msg"
    Write-Host "[HEARTBEAT] $msg" -ForegroundColor $color
    
    $logPath = if ($global:PATH_LOG_HEARTBEAT) { $global:PATH_LOG_HEARTBEAT } else { "$PSScriptRoot\log_heartbeat.txt" }
    
    if ($script:pulseCount -ge 50) {
        $line | Out-File -FilePath $logPath -Encoding utf8
        $script:pulseCount = 0
    } else {
        $line | Out-File -FilePath $logPath -Append -Encoding utf8
    }
}

function Invoke-Pulse {
    $headers = @{ Authorization = "Bearer $global:TOKEN" }
    try {
        $res = Invoke-RestMethod -Uri "$($global:BASE_URL)/claw/agents/heartbeat" -Method Post -Headers $headers
        $script:pulseCount++
        Invoke-Alert -freq 200 -dur 80

        # Notifications
        if ($res.messages.Count -gt 0) {
            Invoke-Alert -freq 1000 -dur 100
            foreach ($m in $res.messages) { Write-Log -msg "ALERT [$($m.type)]: $($m.content)" -color "Green" }
        }

        # Tasks
        if ($res.tasks.Count -gt 0) {
            foreach ($t in $res.tasks) { Write-Log -msg "TASK: $($t.type)" -color "Yellow" }
        }

        $interval = if ($res.recommended_poll_interval_seconds) { $res.recommended_poll_interval_seconds } else { 30 }
        Write-Log -msg "Pulse OK. Next poll in ${interval}s" -color "Gray"
        return $interval
    } catch {
        if ($_.Exception.Response.StatusCode -eq "Unauthorized") {
            Write-Log -msg "Unauthorized. Refreshing session..." -color "Yellow"
            $global:TOKEN = Update-Session
            return 5
        }
        Write-Log -msg "Connection Warning: $($_.Exception.Message)" -color "Red"
        return 60
    }
}

# === MAIN LOOP ===
Write-Host "Bot 5 (Heartbeat) ONLINE" -ForegroundColor DarkCyan
while ($true) {
    $waitSeconds = Invoke-Pulse
    if ($null -eq $waitSeconds) { $waitSeconds = 30 }
    Start-Sleep -Seconds $waitSeconds
}
