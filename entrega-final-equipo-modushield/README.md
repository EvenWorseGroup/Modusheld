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
│   ├── seguridad-zap/
│   │   ├── README.md
│   │   ├── Modushield -Analisis inicial OWASP ZAP.pdf
│   │   └── ModuShield - Análisis final OWASP ZAP.pdf
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
├── PLAN-MEJORA-CONTINUA.pdf
└── informe-cierre.pdf
```

## Estado

- Pipeline CI/CD: documentado con la ejecución exitosa 36291416738.
- JUnit 5: el artefacto conservado del run 36291416738 registra 80 pruebas del
  gateway y 10 de demo-api; la versión actual añade dos pruebas de integración
  para el encabezado de seguridad y aprobó el run 36311708560.
- JaCoCo: 91.26% en gateway y 96.36% en demo-api.
- E2E del pipeline y local: E01–E12 aprobados.
- Plan de mejora continua: PDF de tres páginas con acciones específicas,
  indicadores medibles, prioridades, horizontes y propuesta de innovación.
- SonarQube: análisis completado y documentado con métricas globales, selección
  de un hallazgo de confiabilidad en `AuditFilter`, corrección aplicada y un
  segundo análisis que confirmó la eliminación del hallazgo seleccionado. El
  informe distingue la versión analizada de los cambios posteriores verificados
  mediante JUnit, JaCoCo y CI.
- OWASP ZAP 2.17.0: análisis pasivo comparativo completado sobre `GET /health`.
  El resultado pasó de una alerta baja por falta de
  `X-Content-Type-Options` a cero alertas dentro del alcance evaluado después de
  incorporar `SecurityHeadersWebFilter`.
- Informe de cierre: PDF incorporado con los resultados de los puntos 1 a 4,
  énfasis en seguridad y calidad, inventario de evidencias, limitaciones y
  conclusiones.

## Antes de crear el ZIP de entrega

1. Verificar que las capturas y reportes no muestren secretos ni datos
   personales innecesarios.
2. Si se desea evidencia CI completamente alineada con el último commit,
   descargar los artefactos del run 36311708560 y sustituir los del run
   36291416738.
