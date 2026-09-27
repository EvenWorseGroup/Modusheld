# Guion actualizado de demostración

Este guion usa los contratos de [presentation-contracts.md](presentation-contracts.md)
y la configuración completa del [README principal](../README.md).

## 1. Preparación previa

No muestres `.env` ni imprimas JWT, API keys o contraseñas durante la
presentación.

macOS/Linux/Git Bash/WSL:

```bash
git status --short --branch
git rev-parse --short HEAD
java -version
./mvnw -version
./mvnw --batch-mode --no-transfer-progress clean test
docker compose -f infra/docker-compose.yml --env-file .env up -d --build
docker compose -f infra/docker-compose.yml --env-file .env ps
```

Windows PowerShell:

```powershell
git status --short --branch
git rev-parse --short HEAD
java -version
.\mvnw.cmd -version
.\mvnw.cmd --batch-mode --no-transfer-progress clean test
docker compose -f infra/docker-compose.yml --env-file .env up -d --build
docker compose -f infra/docker-compose.yml --env-file .env ps
```

Confirma antes de presentar:

- Java y Maven Wrapper usan Java 17.
- Los dos módulos superan el gate JaCoCo de 80%.
- `gateway` publica 8080.
- `demo-api` muestra solamente `8081/tcp`, sin binding del host.
- `curl http://localhost:8080/health` responde 200.
- `localhost:8081` no responde.

## 2. Demostración manual de JWT y roles

El recorrido detallado y seguro está en el README. Para una presentación corta:

1. Registrar un usuario y mostrar que recibe `role=USER`.
2. Iniciar sesión sin imprimir el token.
3. Mostrar GET de productos con USER → 200.
4. Mostrar POST de producto con USER → 403
   `INSUFFICIENT_PERMISSIONS`.
5. Iniciar sesión con el ADMIN configurado sin mostrar credenciales/token.
6. Crear, consultar, actualizar y eliminar un producto → 201, 200, 200 y 204.
7. Consultar el producto eliminado → 404.
8. Mostrar productos sin JWT → 401 `INVALID_TOKEN`.

Si se recibió 429 durante ensayos, espera 11 segundos antes de repetir una
secuencia con el mismo usuario.

## 3. Demostración automatizada E01–E12

macOS/Linux/Git Bash/WSL:

```bash
python3 client-tests/run_demo.py
```

Windows PowerShell:

```powershell
py -3 client-tests/run_demo.py
```

Destaca:

- E02: login ADMIN y proxy autenticado con JWT, 200.
- E03/E04: JWT ausente o inválido, 401.
- E05: ruta bloqueada, 403.
- E06: escritura de USER, 403.
- E07: rate limit, 429 en la sexta solicitud.
- E09: 8193 bytes, 413.
- E10: backend detenido, 502 y recuperación.
- E11: aislamiento de red.
- E12: request ID auditado y JWT ausente del log.

El cierre correcto es:

```text
Summary: 12 passed, 0 failed, 0 skipped
```

Muestra el archivo nuevo de `docs/evidence/`, verificando que no contiene
secretos. Una revisión terminada en `-dirty` significa que había cambios sin
commit al ejecutar.

## 4. Evidencia de CI/CD

En GitHub Actions abre **CI and test deployment** y muestra:

1. JUnit 5 y gate JaCoCo exitosos.
2. Porcentaje ≥80% en cada módulo.
3. Empaquetado Maven e imágenes Docker exitosos.
4. Despliegue Compose y readiness exitosos.
5. E01–E12 exitosos.
6. Artefactos `jacoco-reports-<run id>` y `e2e-evidence-<run id>`.
7. Paso de teardown ejecutado.

## 5. Cierre y limpieza

```bash
docker compose -f infra/docker-compose.yml --env-file .env logs --no-color gateway
docker compose -f infra/docker-compose.yml --env-file .env down --volumes --remove-orphans
```

No presentes `--http-only` como una corrida completa: E10–E12 quedan omitidos.
Si Docker no está disponible, declara explícitamente qué no pudo verificarse.
