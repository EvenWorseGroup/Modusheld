# Resumen de evidencia E2E del pipeline

Archivo fuente: `e2e-ci-36291416738.json`, conservado también dentro de
`e2e-evidence-36291416738.zip`.

| ID | Resultado observado |
|---|---|
| E01 | PASS — health 200 |
| E02 | PASS — login ADMIN y productos 200 |
| E03 | PASS — JWT ausente, 401 `INVALID_TOKEN` |
| E04 | PASS — JWT inválido, 401 `INVALID_TOKEN` |
| E05 | PASS — ruta bloqueada, 403 `ROUTE_NOT_ALLOWED` |
| E06 | PASS — escritura USER, 403 `INSUFFICIENT_PERMISSIONS` |
| E07 | PASS — cinco 200 y sexto 429 `RATE_LIMIT_EXCEEDED` |
| E08 | PASS — payload 8192 bytes, 201 |
| E09 | PASS — payload 8193 bytes, 413 `PAYLOAD_TOO_LARGE` |
| E10 | PASS — upstream detenido, 502 `UPSTREAM_UNAVAILABLE` |
| E11 | PASS — aislamiento del backend |
| E12 | PASS — request ID presente y JWT ausente de logs |

Resultado total: **12 aprobados, 0 fallidos, 0 omitidos**.

La evidencia fue generada automáticamente por GitHub Actions y no contiene
secretos. El commit registrado es
`d9a45cc58337a852720f0f1c9b13dd74434ea564`:
https://github.com/EvenWorseGroup/Modusheld/actions/runs/36291416738
