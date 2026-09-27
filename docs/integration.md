# Estado actual de integración

## Componentes integrados

El proyecto actual integra en el reactor Maven:

- Java 17, Spring Boot 3.4.5 y Spring Cloud 2024.0.1.
- Gateway reactivo con routing `/api/**` hacia `demo-api`.
- Request ID, JSON uniforme de errores y manejo 500/502.
- Encabezado global `X-Content-Type-Options: nosniff` en respuestas del gateway.
- Registro, login, BCrypt, JWT y roles `USER`/`ADMIN`.
- API key heredada para órdenes.
- Allowlist de rutas y métodos.
- Límite de 8192 bytes y rate limit 5/10 s.
- Auditoría reactiva sanitizada.
- CRUD de productos y órdenes simuladas.
- Dockerfiles multietapa y Compose con aislamiento de red.
- JUnit 5 y JaCoCo con mínimo 80% por módulo.
- Runner E2E E01–E12 y evidencia JSON.
- GitHub Actions con prueba, construcción, despliegue temporal, E2E, artefactos
  y limpieza incondicional.

## Módulos canónicos

```text
gateway-service/src/main/java/com/modushield/gateway/
gateway-service/src/test/java/com/modushield/gateway/
demo-api/src/main/java/com/modushield/demo/
demo-api/src/test/java/com/modushield/demo/
```

La carpeta `C/` es material histórico de staging. No es un módulo del reactor,
no se empaqueta y no debe usarse como fuente del comportamiento actual.

## Decisiones de integración vigentes

- `DEMO_API_URL` sustituye cualquier URL fija de localhost entre servicios.
- No se usa `StripPrefix`; `demo-api` recibe rutas `/api/**` completas.
- `JsonErrorResponseWriter` implementa el contrato compartido de errores.
- La autenticación se concentra en el gateway; el backend privado no la duplica.
- Productos migraron de API key a JWT; únicamente órdenes conservan API key.
- `/api/admin/status` devuelve 200 dentro de la red privada, pero 403 desde el
  gateway.
- La auditoría es un `GlobalFilter`, no un filtro servlet.
- `SecurityHeadersWebFilter` usa `beforeCommit` y reemplaza cualquier valor
  previo de `X-Content-Type-Options` por `nosniff`.
- `demo-api` no publica el puerto 8081 al host.
- Los usuarios y productos son en memoria; el objetivo es una demostración
  reproducible, no persistencia productiva.

## Calidad y cobertura

El `pom.xml` raíz configura `jacoco-maven-plugin` 0.8.13. Cada módulo ejecuta:

1. `prepare-agent` antes de las pruebas.
2. `report` en la fase `test`.
3. `check` con `LINE/COVEREDRATIO >= 0.80` sobre el bundle de ese módulo.

Así, un módulo no puede compensar la baja cobertura del otro. Los reportes se
generan bajo `gateway-service/target/site/jacoco/` y
`demo-api/target/site/jacoco/`.

Comando canónico:

```bash
./mvnw --batch-mode --no-transfer-progress clean test
```

En Windows PowerShell:

```powershell
.\mvnw.cmd --batch-mode --no-transfer-progress clean test
```

Debe utilizarse JDK 17, igual que CI.

## Seguridad dinámica verificada

OWASP ZAP 2.17.0 se ejecutó como analizador pasivo contra `GET /health` en un
entorno Docker local. El reporte inicial registró una alerta baja por
`X-Content-Type-Options Header Missing`. Tras incorporar el filtro global y sus
pruebas de integración, el reporte final no registró alertas dentro de los
parámetros seleccionados.

Los reportes inicial y final se conservan en
[`entrega-final-equipo-modushield/reportes/seguridad-zap/`](../entrega-final-equipo-modushield/reportes/seguridad-zap/README.md).
El alcance fue pasivo y limitado a `/health`; las rutas autenticadas y los
ataques activos siguen fuera de esta verificación. La versión que contiene el
filtro también aprobó el workflow completo de GitHub Actions en el run
[36311708560](https://github.com/EvenWorseGroup/Modusheld/actions/runs/36311708560).

## Estado de Docker y E2E

La topología usa `front-network` y `back-network`; la segunda es interna. Solo
el gateway publica `8080:8080`.

La matriz actual se ejecuta con:

```bash
python3 client-tests/run_demo.py
```

o en Windows cuando Python se expone mediante el launcher:

```powershell
py -3 client-tests/run_demo.py
```

El criterio de aprobación completo es `12 passed, 0 failed, 0 skipped`. Cada
corrida escribe `docs/evidence/e2e-<fecha UTC>.json` sin secretos.

## Estado de CI/CD

`.github/workflows/ci.yml` se activa en pull requests, pushes a `main` y
manualmente. Su único job secuencial:

1. Ejecuta JUnit 5 y el gate JaCoCo.
2. Publica porcentajes en el resumen.
3. Empaqueta con Maven.
4. Carga reportes JaCoCo.
5. Genera credenciales efímeras aleatorias.
6. Construye imágenes Docker.
7. Despliega Compose en el runner aislado.
8. Espera `/health`.
9. Ejecuta E01–E12.
10. Carga evidencia/logs.
11. Siempre desmonta el entorno si llegó a iniciarse.

El despliegue es intencionalmente efímero y no produce una URL pública
permanente.

## Disciplina para cambios futuros

1. Leer contrato, implementación y pruebas antes de modificar una política.
2. No cambiar códigos HTTP/`error` sin actualizar runner y documentación.
3. Ejecutar `clean test` con Java 17.
4. Ejecutar E01–E12 sobre Docker cuando cambie comportamiento de integración.
5. Buscar `.env`, secretos, logs, binarios y `target/` antes de confirmar.
6. No debilitar el gate de 80% ni excluir código sustancial para aprobarlo.
