# === ACCOUNT STATUS CHECKER (GITHUB VERSION) ===
. "$PSScriptRoot\config.ps1"

Write-Host "--- AI-TRADER FLEET: ACCOUNT STATUS ---" -ForegroundColor Cyan

$headers = @{ Authorization = "Bearer $global:TOKEN" }
try {
    # 1. Identity Check
    if (Test-Path $global:CRED_FILE) {
        $creds = Get-Content $global:CRED_FILE | ConvertFrom-Json
        Write-Host "Agent Name : $($creds.name)" -ForegroundColor Yellow
        Write-Host "Agent Email: $($creds.email)" -ForegroundColor Yellow
    }

    # 2. Financial Check
    $res = Invoke-RestMethod -Uri "$($global:BASE_URL)/positions" -Method Get -Headers $headers
    Write-Host "Cash Balance: $($res.cash)" -ForegroundColor Green
    
    Write-Host "`n--- OPEN POSITIONS ---" -ForegroundColor Cyan
    if ($res.positions.Count -gt 0) {
        $res.positions | Select-Object symbol, quantity, entry_price, current_price, pnl | Format-Table -AutoSize
    } else {
        Write-Host "No open positions yet." -ForegroundColor Gray
    }
} catch {
    Write-Host "[ERROR] Could not fetch status. Ensure the fleet is started and you have internet." -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = [Console]::ReadKey()
