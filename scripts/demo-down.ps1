$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

try {
    Push-Location -LiteralPath $repoRoot

    & docker compose --env-file .env -f infra/docker-compose.yml down --remove-orphans
    if ($LASTEXITCODE -ne 0) {
        throw "Could not stop the ModuShield services."
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
