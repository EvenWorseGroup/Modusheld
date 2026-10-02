param([switch]$Segmented)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredServices = @("client-tests", "gateway", "demo-api")

try {
    Push-Location -LiteralPath $repoRoot

    $runningServices = @(
        & docker compose --env-file .env -f infra/docker-compose.yml ps --services --status running
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect the Compose services."
    }

    $missingServices = @($requiredServices | Where-Object { $_ -notin $runningServices })
    if ($missingServices.Count -gt 0) {
        throw "Required services are not running: $($missingServices -join ', ')."
    }

    $testArgs = @("--http-only")
    if ($Segmented) { $testArgs += "--segmented" }
    & docker compose --env-file .env -f infra/docker-compose.yml exec -T client-tests /app/client-tests/e2e.sh @testArgs
    if ($LASTEXITCODE -ne 0) {
        throw "The HTTP demonstration suite failed."
    }

    Write-Host "Demo tests succeeded: E01-E09 passed; E10-E12 were intentionally skipped in HTTP-only mode."
    Write-Host "Evidence was retained in docs/evidence/."
}
catch {
    Write-Error $_
    exit 1
}
finally {
    Pop-Location
}

exit 0
