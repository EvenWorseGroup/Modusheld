$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

try {
    Push-Location -LiteralPath $repoRoot

    $recentLogs = @(
        & docker compose --env-file .env -f infra/docker-compose.yml logs --no-color --tail 200 gateway 2>&1
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read gateway logs."
    }

    $auditLogs = @(
        $recentLogs | Select-String -Pattern "AUDIT|X-Request-Id|requestId=|decision=|status="
    )
    if ($auditLogs.Count -eq 0) {
        Write-Host "No audit or request-correlation entries were found in the latest 200 gateway log lines."
    }
    else {
        $auditLogs | ForEach-Object { $_.Line }
    }
}
catch {
    Write-Error $_
    exit 1
}
finally {
    Pop-Location
}

exit 0
