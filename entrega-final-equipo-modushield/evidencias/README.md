# Inventario de evidencias

## Incluidas

### `despliegue.png`

Captura del detalle de GitHub Actions run 36291416738. Muestra:

- workflow `CI and test deployment`;
- estado `Success`;
- job exitoso en 2 min 39 s;
- JUnit 5 y JaCoCo 80%;
- construcción de imágenes Docker;
- despliegue aislado y readiness;
- E01–E12;
- carga de evidencia y teardown.

Enlace verificable:
https://github.com/EvenWorseGroup/Modusheld/actions/runs/36291416738

### `evidencia-pipeline.png`

Captura general de pipeline conservada de la preparación anterior.

### `e2e-ci-36291416738.json` y `e2e-evidence-36291416738.zip`

Evidencia original descargada del run 36291416738. El JSON fue extraído para
consulta directa y el ZIP se conserva para verificar el artefacto nativo.
Registra el commit completo `d9a45cc58337a852720f0f1c9b13dd74434ea564` y los
doce escenarios con resultado `PASS`.

### `e2e-local-12-de-12.json`

Evidencia generada por `client-tests/run_demo.py` el
`2026-09-27T03:32:33Z` sobre el commit `d9a45cc`. Contiene E01–E12 con resultado
`PASS` y no contiene tokens, contraseñas o API keys.

## Evidencia local complementaria

- `e2e-local-12-de-12.json` conserva una corrida local adicional.

## Pendiente antes del ZIP final

- Capturas/exportaciones actualizadas de OWASP ZAP.
- Confirmar que el PDF de SonarQube corresponde a la versión final.
- PDF de cierre exportado desde Google Docs.
