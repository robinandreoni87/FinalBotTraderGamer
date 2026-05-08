# === UNIVERSAL GITHUB CONFIGURATION ===
# Handles auto-initialization, persistence, and relative paths.

$global:BASE_URL   = "https://ai4trade.ai/api"
$global:TOKEN_FILE = "$PSScriptRoot\.token"
$global:CRED_FILE  = "$PSScriptRoot\.credentials"

# Global Paths (Dynamic)
$global:PATH_LOG_MONITOR   = "$PSScriptRoot\log_monitor.txt"
$global:PATH_LOG_JOURNAL   = "$PSScriptRoot\log_journal.txt"
$global:PATH_LOG_VALIDATOR = "$PSScriptRoot\log_validator.txt"
$global:PATH_LOG_HEARTBEAT = "$PSScriptRoot\log_heartbeat.txt"
$global:PATH_DATA_STRATEGY = "$PSScriptRoot\data_strategies.json"
$global:PATH_DATA_INTEL    = "$PSScriptRoot\data_intelligence.json"
$global:PATH_DATA_MARKET   = "$PSScriptRoot\data_market.json"
$global:PATH_DATA_BANS     = "$PSScriptRoot\data_blacklist.json"
$global:PATH_RAW_REPORTS   = "$PSScriptRoot\data_raw_reports.txt"

# Realistic Identity Generator (6 letters + 2 numbers)
function Get-RealisticName {
    $letters = "abcdefghijklmnopqrstuvwxyz"
    $nums = "0123456789"
    $lStr = -join ($letters.ToCharArray() | Get-Random -Count 6)
    $nStr = -join ($nums.ToCharArray() | Get-Random -Count 2)
    return "Trader_$($lStr)$($nStr)"
}

# Self-Initialization with Persistence
function Invoke-AutoInit {
    if (Test-Path $global:TOKEN_FILE) {
        $existingToken = Get-Content $global:TOKEN_FILE -Raw
        if ($existingToken) {
            Write-Host "[AUTH] Session restored. Identity verified." -ForegroundColor Green
            return $existingToken
        }
    }

    Write-Host "[INIT] No account found. Generating new GOLD identity..." -ForegroundColor Cyan
    $name  = Get-RealisticName
    $email = "$name@ai4trade.github"
    $pass  = "Pass_$(Get-Random -Minimum 1000 -Maximum 9999)!"

    $regBody = @{ name=$name; email=$email; password=$pass } | ConvertTo-Json
    try {
        $res = Invoke-RestMethod -Uri "$global:BASE_URL/claw/agents/selfRegister" -Method Post -Body $regBody -ContentType "application/json"
        if ($res.token) {
            $res.token | Out-File -FilePath $global:TOKEN_FILE -NoNewline -Encoding utf8
            $regBody   | Out-File -FilePath $global:CRED_FILE  -Encoding utf8
            Write-Host "[SUCCESS] New Identity: $name" -ForegroundColor Green
            return $res.token
        }
    } catch {
        Write-Host "[ERROR] Registration failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
    return $null
}

# Load Global Token
$global:TOKEN = Invoke-AutoInit

# Session Refresh
function Update-Session {
    if (Test-Path $global:CRED_FILE) {
        $creds = Get-Content $global:CRED_FILE | ConvertFrom-Json
        try {
            $res = Invoke-RestMethod -Uri "$global:BASE_URL/claw/agents/login" -Method Post -Body ($creds | ConvertTo-Json) -ContentType "application/json"
            if ($res.token) {
                $res.token | Out-File -FilePath $global:TOKEN_FILE -NoNewline -Encoding utf8
                $global:TOKEN = $res.token
                return $res.token
            }
        } catch { return $null }
    }
    return $null
}

# Sound Feedback
function Invoke-Alert {
    param([int]$freq=800, [int]$dur=200)
    try { [Console]::Beep($freq, $dur) } catch {}
}
