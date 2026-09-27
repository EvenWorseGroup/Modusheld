# Entrega final — Equipo ModuShield

Esta carpeta reúne la evidencia técnica preparada para generar el ZIP de la
entrega. No contiene `.env`, contraseñas, JWT, API keys ni otros secretos.

## Contenido actual

```text
entrega-final-equipo-modushield/
├── pipeline/
│   ├── ci.yml
│   ├── README.md
│   └── run-36291416738.json
├── reportes/
│   ├── pruebas-unitarias/
│   │   ├── RESUMEN.md
│   │   ├── gateway-service-jacoco/
│   │   ├── demo-api-jacoco/
│   │   ├── junit/
│   │   └── jacoco-reports-36291416738.zip
│   └── sonar/
│       └── Analisis&Evidencia-SonarQube.pdf
├── evidencias/
│   ├── README.md
│   ├── E2E-RESUMEN.md
│   ├── evidencia-pipeline.png
│   ├── despliegue.png
│   ├── e2e-ci-36291416738.json
│   ├── e2e-evidence-36291416738.zip
│   └── e2e-local-12-de-12.json
└── PLAN-MEJORA-CONTINUA.pdf
```

## Estado

- Pipeline CI/CD: documentado con la ejecución exitosa 36291416738.
- JUnit 5: 80 pruebas del gateway y 10 de demo-api, sin fallos.
- JaCoCo: 91.26% en gateway y 96.36% en demo-api.
- E2E del pipeline y local: E01–E12 aprobados.
- Plan de mejora continua: PDF de tres páginas con acciones específicas,
  indicadores medibles, prioridades, horizontes y propuesta de innovación.
- SonarQube: se conserva como evidencia histórica el PDF generado sobre una
  versión anterior; el plan de mejora contempla repetir el análisis sobre la
  versión final actualizada y registrar el commit exacto analizado en un futuro.
- OWASP ZAP: pendiente de repetir con autenticación JWT actual. (Ya casi lo termina Jairo)
- `informe-cierre.pdf`: se agregará después de actualizar ZAP y SonarQube.

## Antes de crear el ZIP de entrega

1. Agregar el reporte actual de ZAP.
2. Verificar que las capturas no muestren secretos ni datos personales
   innecesarios.
3. Exportar el informe de cierre desde Google Docs y agregarlo como
   `informe-cierre.pdf`. (Humberto lo hará cuando tengamos el reporte OWASP ZAP)