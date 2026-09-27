# Evidencia del pipeline CI/CD

## Workflow entregado

El archivo `ci.yml` es una copia verificable del workflow vigente en
`.github/workflows/ci.yml`.

Se activa en:

- cada pull request;
- cada push a `main`;
- ejecución manual mediante `workflow_dispatch`.

## Ejecución exitosa seleccionada

| Campo | Valor |
|---|---|
| Workflow | `CI and test deployment` |
| Run | `36291416738` / número 9 |
| Evento | `push` a `main` |
| Commit | `d9a45cc58337a852720f0f1c9b13dd74434ea564` |
| Mensaje | `Updated README.md to correctly configure locally and added Powershell commands.` |
| Inicio UTC | `2026-09-27T03:26:38Z` |
| Fin UTC | `2026-09-27T03:29:31Z` |
| Estado | `completed` |
| Conclusión | `success` |
| Duración del job mostrada por GitHub | 2 min 39 s |
| Enlace | https://github.com/EvenWorseGroup/Modusheld/actions/runs/36291416738 |

## Etapas verificadas

El job `Test, build, and deploy isolated environment` terminó exitosamente. La
API pública de GitHub reporta estos pasos:

| Orden | Paso | Resultado |
|---:|---|---|
| 1 | Check out repository | success |
| 2 | Set up Java 17 with Maven cache | success |
| 3 | Run JUnit 5 tests and JaCoCo 80% quality gate | success |
| 4 | Publish coverage summary | success |
| 5 | Package application | success |
| 6 | Upload JaCoCo reports | success |
| 7 | Generate ephemeral CI credentials | success |
| 8 | Build Docker images | success |
| 9 | Deploy to isolated CI test environment | success |
| 10 | Wait for gateway readiness | success |
| 11 | Run E01-E12 | success |
| 12 | Record successful test deployment | success |
| 13 | Upload E2E evidence | success |
| 14 | Tear down isolated environment | success |

`Capture Docker logs after failure` se omitió correctamente porque no hubo
fallos.

## Artefactos de la ejecución

| Artefacto | Tamaño | Digest SHA-256 | Expiración reportada |
|---|---:|---|---|
| `jacoco-reports-36291416738` | 402699 bytes | `b1ddefc91af65ea4626094f5be35db451def0f800ddfb5ca1f2fef94c982db47` | 2026-12-26 |
| `e2e-evidence-36291416738` | 1086 bytes | `48cc5eaf024e9a293b1a38f7c856fd718341ca8befc475ad256dffae416ffc75` | 2026-12-26 |

La captura `../evidencias/despliegue.png` muestra todos los pasos del job en
verde: pruebas, JaCoCo, empaquetado, imágenes, despliegue, readiness, E01–E12,
artefactos y teardown. `../evidencias/evidencia-pipeline.png` conserva la
captura general aportada previamente.

## Verificación posterior del encabezado de seguridad

Después de incorporar `SecurityHeadersWebFilter`, sus pruebas de integración y
los reportes OWASP ZAP, el commit `7abe7c0` volvió a ejecutar el mismo workflow.
El run [36311708560](https://github.com/EvenWorseGroup/Modusheld/actions/runs/36311708560)
terminó en `success`: aprobó Java 17, JUnit 5, el gate JaCoCo, empaquetado,
imágenes Docker, despliegue efímero, E01-E12, artefactos y teardown.

Los archivos descargados que se conservan en esta carpeta siguen perteneciendo
al run 36291416738; esta distinción evita atribuir un artefacto antiguo al
commit nuevo.

## Interpretación

Esta ejecución demuestra el orden exigido por la rúbrica: pruebas y cobertura,
empaquetado, imágenes Docker, despliegue Compose aislado, readiness, E01–E12,
evidencia y teardown. Las credenciales fueron aleatorias y efímeras; no se
confirmó ningún secreto en el workflow.
