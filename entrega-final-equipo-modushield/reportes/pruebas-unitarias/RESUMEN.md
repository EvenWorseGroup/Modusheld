# Resumen de pruebas unitarias y cobertura

## Resultado CI seleccionado

Los reportes HTML, CSV y XML extraídos en esta carpeta provienen del artefacto
`jacoco-reports-36291416738.zip`, generado por GitHub Actions sobre el commit
`d9a45cc58337a852720f0f1c9b13dd74434ea564`. El ZIP original también se conserva
para verificar su procedencia. Los resúmenes de Surefire corresponden a la
ejecución equivalente de la misma suite.

| Módulo | Pruebas | Fallos | Errores | Omitidas | Líneas cubiertas | Líneas totales | Cobertura |
|---|---:|---:|---:|---:|---:|---:|---:|
| `gateway-service` | 80 | 0 | 0 | 0 | 449 | 492 | 91.26% |
| `demo-api` | 10 | 0 | 0 | 0 | 53 | 55 | 96.36% |

Ambos módulos superan el mínimo obligatorio de 80% de cobertura de líneas.

## Quality gate

El `pom.xml` raíz ejecuta `jacoco:prepare-agent`, `jacoco:report` y
`jacoco:check` durante la fase `test`. La regla se aplica por módulo con:

```text
counter = LINE
value = COVEREDRATIO
minimum = 0.80
```

Por lo tanto, las pruebas aprobadas no son suficientes por sí mismas: Maven
falla si cualquiera de los dos módulos queda debajo de 80%.

Comando reproducible:

```bash
./mvnw --batch-mode --no-transfer-progress clean test
```

Windows PowerShell:

```powershell
.\mvnw.cmd --batch-mode --no-transfer-progress clean test
```

## Cómo revisar la evidencia

- Abrir `gateway-service-jacoco/index.html`.
- Abrir `demo-api-jacoco/index.html`.
- Consultar `jacoco.csv` para los contadores usados en el porcentaje.
- Consultar `jacoco.xml` para integración con otras herramientas.
- Revisar `junit/gateway-service/*.txt` y `junit/demo-api/*.txt` para los
  resultados de cada clase de prueba.

La ejecución debe hacerse con Java 17, igual que GitHub Actions.
