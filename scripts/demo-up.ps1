$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

try {
    Push-Location -LiteralPath $repoRoot

    & docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not responding. Start Docker Desktop and try again."
    }

    & docker compose --env-file .env -f infra/docker-compose.yml config --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Docker Compose configuration validation failed."
    }

    & docker compose --env-file .env -f infra/docker-compose.yml up --build -d --wait
    if ($LASTEXITCODE -ne 0) {
        throw "The ModuShield services did not start successfully."
    }

    & docker compose --env-file .env -f infra/docker-compose.yml ps
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the final Compose status."
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
