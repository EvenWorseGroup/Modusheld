param([switch]$Segmented)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$composeArgs = @("compose", "--env-file", ".env", "-f", "infra/docker-compose.yml")
$exitCode = 0

try {
    if ($Segmented) { Write-Host "`n========== 1. VALIDACIONES DEL ENTORNO Y ARRANQUE ==========" }
    & (Join-Path $PSScriptRoot "demo-up.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "Demo startup failed."
    }

    if ($Segmented) { Write-Host "`n========== 2. PETICIONES Y VALIDACIONES HTTP ==========" }
    & (Join-Path $PSScriptRoot "demo-test.ps1") -Segmented:$Segmented
    if ($LASTEXITCODE -ne 0) {
        throw "Demo tests failed."
    }
}
catch {
    Write-Error $_ -ErrorAction Continue
    $exitCode = 1
}
finally {
    Push-Location -LiteralPath $repoRoot
    try {
        if ($Segmented) { Write-Host "`n========== 3. ESTADO FINAL ==========" }
        Write-Host "Final service status:"
        & docker @composeArgs ps
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Could not read the final Compose status." -ErrorAction Continue
            $exitCode = 1
        }
    }
    finally {
        Pop-Location
    }
}

if ($exitCode -ne 0) {
    exit $exitCode
}

Write-Host "The containers remain active."
Write-Host "View audit logs with: .\scripts\demo-logs.ps1"
Write-Host "Stop the environment with: .\scripts\demo-down.ps1"
exit 0
