# Análisis de seguridad con OWASP ZAP

## ModuShield API Gateway

**Fecha de ejecución:** 27 de septiembre de 2026  
**Herramienta:** OWASP ZAP 2.17.0  
**Tipo de evaluación:** análisis pasivo comparativo antes y después de la corrección  
**Objetivo evaluado:** `GET /health` del API Gateway  
**Dirección utilizada desde ZAP:** `http://host.docker.internal:8080/health`

**Implementación verificada en CI:** commit `7abe7c0`, run
[36311708560](https://github.com/EvenWorseGroup/Modusheld/actions/runs/36311708560)

## 1. Objetivo

El propósito de esta evaluación fue observar el tráfico HTTP generado por el API Gateway de ModuShield, identificar una configuración de seguridad mejorable, aplicar una corrección verificable y comparar los resultados obtenidos antes y después del cambio.

La evaluación se realizó en un entorno local controlado mediante Docker. OWASP ZAP se utilizó como proxy y analizador pasivo; por tanto, no se enviaron cargas maliciosas ni se ejecutaron ataques activos contra sistemas externos.

## 2. Alcance

El análisis cubrió la respuesta del endpoint público de salud:

```http
GET http://host.docker.internal:8080/health
```

Se comprobó principalmente la presencia del encabezado HTTP `X-Content-Type-Options`. Los flujos autenticados, las rutas protegidas mediante JWT o API key y el resto de los endpoints no formaron parte de este ejercicio específico.

## 3. Resultado inicial

El primer análisis produjo una alerta:

| Elemento | Resultado |
|---|---|
| Hallazgo | `X-Content-Type-Options Header Missing` |
| Riesgo | Bajo |
| Confianza | Media |
| Endpoint | `GET /health` |
| Clasificación | OWASP A05:2021 - Security Misconfiguration |
| CWE | CWE-693 - Protection Mechanism Failure |
| Cantidad | 1 alerta |

La respuesta declaraba un tipo de contenido, pero no incluía el encabezado `X-Content-Type-Options: nosniff`. Sin este control, determinados navegadores pueden intentar deducir el tipo real del contenido mediante *MIME sniffing*. En escenarios donde una respuesta pudiera contener datos controlados por un atacante, ese comportamiento incrementaría el riesgo de que el navegador interpretara el contenido de una manera diferente a la declarada por el servidor.

Aunque ZAP clasificó el hallazgo con riesgo bajo, la corrección era razonable porque podía implementarse globalmente, tenía un costo reducido y fortalecía todas las respuestas emitidas por el gateway.

## 4. Corrección aplicada

Se incorporó `SecurityHeadersWebFilter`, un filtro global de Spring WebFlux que agrega el siguiente encabezado antes de confirmar cada respuesta:

```http
X-Content-Type-Options: nosniff
```

El filtro utiliza `beforeCommit` para modificar los encabezados antes de que la respuesta sea enviada. También utiliza la operación `set`, de modo que sustituye cualquier valor previo incorrecto en lugar de duplicarlo. Su prioridad es `Ordered.HIGHEST_PRECEDENCE`, por lo que el control se aplica tempranamente y no depende de una ruta individual.

Archivos relacionados:

- [`SecurityHeadersWebFilter.java`](../../../gateway-service/src/main/java/com/modushield/gateway/filter/SecurityHeadersWebFilter.java)
- [`SecurityHeadersIntegrationTest.java`](../../../gateway-service/src/test/java/com/modushield/gateway/filter/SecurityHeadersIntegrationTest.java)

No se modificaron las reglas de autenticación, autorización, JWT, API key, limitación de solicitudes ni enrutamiento del gateway.

## 5. Verificación técnica

La corrección se verificó mediante tres niveles de evidencia:

### 5.1 Pruebas automatizadas

Las pruebas de integración comprueban que:

- `GET /health` responde con `X-Content-Type-Options: nosniff`.
- Una solicitud `POST /api/orders` atraviesa una ruta real del gateway y conserva el encabezado de seguridad.
- Si el servicio de destino intenta enviar un valor incorrecto para el encabezado, el gateway lo reemplaza por `nosniff`.

La ejecución registrada completó 82 pruebas del gateway y 10 pruebas de la API de demostración, para un total de 92 pruebas sin fallos. La reconstrucción posterior del contenedor también finalizó correctamente.

La versión final que contiene el filtro, las pruebas y estos reportes también
completó exitosamente el pipeline de Java 17, JaCoCo, Docker y E01-E12 en
GitHub Actions.

### 5.2 Comprobación directa

Después de reconstruir y recrear el contenedor del gateway, se consultó el endpoint desde el host. La respuesta confirmó:

```http
X-Content-Type-Options: nosniff
```

### 5.3 Segundo análisis con ZAP

Se inició una sesión nueva de OWASP ZAP para evitar que la alerta almacenada en la sesión inicial contaminara el resultado. Se repitió la solicitud a `/health` y el analizador pasivo no generó alertas dentro de los parámetros seleccionados.

## 6. Comparación de resultados

| Indicador | Análisis inicial | Análisis final |
|---|---:|---:|
| Respuesta HTTP | `200 OK` | `200 OK` |
| Encabezado `X-Content-Type-Options` | Ausente | `nosniff` |
| Alertas altas | 0 | 0 |
| Alertas medias | 0 | 0 |
| Alertas bajas | 1 | 0 |
| Total de alertas | **1** | **0** |

El resultado demuestra la eliminación del hallazgo concreto detectado en el análisis inicial sin alterar la disponibilidad del endpoint.

## 7. Evidencias

- [Reporte inicial de OWASP ZAP](<./Modushield -Analisis inicial OWASP ZAP.pdf>)
- [Reporte final de OWASP ZAP](<./ModuShield - Análisis final OWASP ZAP.pdf>)

El reporte inicial documenta la alerta de riesgo bajo y el reporte final declara que no se encontraron alertas dentro de los parámetros evaluados.

## 8. Limitaciones

Este resultado no significa que ModuShield esté libre de vulnerabilidades. La evaluación tuvo las siguientes limitaciones:

- Se realizó un análisis pasivo, no un escaneo activo.
- Se evaluó únicamente el endpoint `/health`.
- No se probaron sesiones autenticadas, permisos por rol ni tokens JWT.
- No se evaluaron ataques de inyección, abuso de lógica, evasión de límites o disponibilidad.
- Cero alertas en este alcance significa únicamente que ZAP no detectó problemas en el tráfico observado bajo la configuración utilizada.

Como trabajo posterior se recomienda ampliar gradualmente el análisis hacia las rutas autenticadas, ejecutar las pruebas únicamente en un entorno autorizado e incorporar un escaneo base de ZAP al proceso de integración continua.

## 9. Conclusión

La evaluación permitió detectar una configuración incompleta, interpretar su impacto, implementar una corrección global y verificarla mediante pruebas automatizadas, una consulta HTTP directa y un segundo análisis independiente con OWASP ZAP. La comparación de una alerta inicial frente a cero alertas finales aporta evidencia reproducible de que el encabezado `X-Content-Type-Options: nosniff` fue incorporado correctamente.

La actividad también demuestra que una herramienta de análisis estático o dinámico no sustituye las pruebas ni la revisión técnica: ZAP señaló el síntoma, el equipo determinó una corrección compatible con la arquitectura del gateway y posteriormente reunió evidencias para comprobar que el cambio funcionó sin afectar el comportamiento esperado.
