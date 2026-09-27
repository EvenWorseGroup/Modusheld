# Infraestructura actual de ModuShield

## Topología

`docker-compose.yml` crea:

- `front-network`: gateway y contenedor auxiliar `client-tests`.
- `back-network`: gateway y `demo-api`; está marcada como `internal`.
- `gateway`: publica `8080:8080` y conecta ambas redes.
- `demo-api`: declara `expose: 8081`, pero no publica un puerto del host.
- `client-tests`: servicio auxiliar bajo el perfil `tools`, utilizado para
  comprobar que la red frontal no puede acceder al backend.

No agregues `ports:` a `demo-api`: rompería E11 y el modelo de aislamiento.

## Configuración requerida

Compose recibe un `.env` local mediante `--env-file .env`.

Variables obligatorias sin valor seguro por defecto:

- `MODUSHIELD_API_KEY`
- `JWT_SECRET` de al menos 32 bytes aleatorios
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`

Variables con valores operativos predeterminados:

- `JWT_EXPIRATION_SECONDS=3600`
- `MAX_REQUEST_SIZE_BYTES=8192`
- `RATE_LIMIT_CAPACITY=5`
- `RATE_LIMIT_WINDOW_SECONDS=10`
- `SERVER_PORT=8080`
- `DEMO_API_URL=http://demo-api:8081`

Copia `.env.example`, reemplaza todos los placeholders y nunca confirmes `.env`.
Consulta el README raíz para generación segura en macOS/Linux y Windows 11.

## Dockerfiles

`gateway.Dockerfile` y `demo-api.Dockerfile` son builds multietapa:

1. Compilan desde un árbol limpio con Eclipse Temurin JDK 17 y Maven Wrapper.
2. Ejecutan `clean package` dentro de la etapa de build.
3. Copian únicamente el JAR a una imagen Temurin JRE 17.
4. Ejecutan con usuarios sin privilegios (`10001` y `10002`).

No dependen de artefactos locales bajo `target/`.

## Comandos locales

Construir e iniciar:

```bash
docker compose -f infra/docker-compose.yml --env-file .env up -d --build
```

Estado y logs:

```bash
docker compose -f infra/docker-compose.yml --env-file .env ps
docker compose -f infra/docker-compose.yml --env-file .env logs --no-color
```

Salud:

```bash
curl http://localhost:8080/health
```

`http://localhost:8081` debe permanecer inaccesible.

La respuesta de salud también debe incluir:

```http
X-Content-Type-Options: nosniff
```

## Uso de OWASP ZAP

ZAP no forma parte de `docker-compose.yml`. La evaluación entregada se ejecutó
desde un contenedor o aplicación ZAP separado contra
`http://host.docker.internal:8080/health`, con el stack local ya iniciado. Los
reportes versionados corresponden a análisis pasivos; no deben describirse como
escaneos activos ni como cobertura completa de las rutas autenticadas.

Consulta resultados, alcance y limitaciones en
[`entrega-final-equipo-modushield/reportes/seguridad-zap/`](../entrega-final-equipo-modushield/reportes/seguridad-zap/README.md).

Limpieza completa:

```bash
docker compose -f infra/docker-compose.yml --env-file .env down --volumes --remove-orphans
```

Los comandos `docker compose` son iguales en PowerShell. Para ejecutar E01–E12:

```bash
python3 client-tests/run_demo.py
```

o en Windows con el launcher de Python:

```powershell
py -3 client-tests/run_demo.py
```

## Entorno de CI

GitHub Actions genera credenciales aleatorias en el runner y las exporta a
`GITHUB_ENV`; no usa un `.env` confirmado. Define un `COMPOSE_PROJECT_NAME`
único por run, construye imágenes, ejecuta `compose up -d --no-build`, espera
`/health`, corre E01–E12, carga evidencia y finalmente ejecuta:

```bash
docker compose -f infra/docker-compose.yml down --volumes --remove-orphans
```

El teardown usa `if: always()` cuando el despliegue llegó a ejecutarse, por lo
que también limpia después de fallos de E2E.
