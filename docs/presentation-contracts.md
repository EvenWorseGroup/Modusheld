# Contratos actuales para la presentación

Este documento define lo que debe demostrar `client-tests/run_demo.py` en la
versión actual. El resultado de una corrida real y su JSON de evidencia son la
prueba final; este archivo no los sustituye.

## 1. Punto de entrada y credenciales

- URL pública local: `http://localhost:8080`.
- `demo-api:8081` solo existe en `back-network` y no debe responder en
  `http://localhost:8081`.
- Productos usan `Authorization: Bearer <JWT>`.
- Órdenes heredadas usan `X-API-Key`.
- El runner obtiene un JWT ADMIN mediante `/auth/login` y registra un USER
  temporal para validar el 403 de autorización.
- Ninguna credencial debe imprimirse ni guardarse en evidencia.
- `X-Request-Id` opcional debe cumplir
  `[A-Za-z0-9][A-Za-z0-9._:-]{0,127}`; de lo contrario se reemplaza por UUID.

Valores predeterminados de la matriz:

| Variable | Valor |
|---|---:|
| `MAX_REQUEST_SIZE_BYTES` | 8192 |
| `RATE_LIMIT_CAPACITY` | 5 |
| `RATE_LIMIT_WINDOW_SECONDS` | 10 |

## 2. Contratos de autenticación

Registro:

```http
POST /auth/register
Content-Type: application/json

{"username":"reader","password":"<8-128 caracteres>"}
```

Resultado: `201` con rol `USER`.

Login:

```http
POST /auth/login
Content-Type: application/json

{"username":"reader","password":"<contraseña>"}
```

Resultado: `200` con JWT, tipo Bearer, username, rol y expiración. Credenciales
incorrectas devuelven `401 INVALID_CREDENTIALS`.

El JWT válido contiene identidad (`sub`), `role`, `iat` y `exp`. Tokens
ausentes, inválidos, alterados o vencidos reciben `401 INVALID_TOKEN`.

## 3. Contratos de productos

| Método y ruta | Rol permitido | Resultado nominal |
|---|---|---|
| `GET /api/products` | USER, ADMIN | `200` y arreglo |
| `GET /api/products/{id}` | USER, ADMIN | `200` o `404` |
| `POST /api/products` | ADMIN | `201` |
| `PUT /api/products/{id}` | ADMIN | `200` |
| `DELETE /api/products/{id}` | ADMIN | `204` |

Un USER que intenta cualquier escritura recibe
`403 INSUFFICIENT_PERMISSIONS`.

Productos iniciales:

```json
[
  {"id":"P-100","name":"Demo product","stock":12},
  {"id":"P-200","name":"Sample item","stock":7}
]
```

Producto válido:

```json
{"id":"P-DEMO","name":"Demo","stock":3}
```

El ID admite 1-64 caracteres `[A-Za-z0-9._-]`, el nombre no puede estar vacío
ni superar 200 caracteres y el stock no puede ser negativo. En `PUT`, el ID del
cuerpo debe coincidir con el de la ruta.

## 4. Contrato de órdenes heredadas

```http
POST /api/orders
X-API-Key: <valor configurado>
Content-Type: application/json

{"productId":"P-100","quantity":2}
```

Resultado: `201`:

```json
{
  "orderId":"ORD-a1b2c3d4",
  "productId":"P-100",
  "quantity":2,
  "status":"SIMULATED"
}
```

`orderId` es dinámico y cumple `^ORD-[0-9a-f]{8}$`. `quantity` debe estar
entre 1 y 100. API key ausente o incorrecta devuelve `401 INVALID_API_KEY`.

## 5. Reglas negativas comunes

- `/api/admin/status` siempre se bloquea externamente con
  `403 ROUTE_NOT_ALLOWED`.
- Ruta no permitida: `403 ROUTE_NOT_ALLOWED`.
- Método no permitido: `405 METHOD_NOT_ALLOWED`.
- Body no medible o mayor al máximo: `413 PAYLOAD_TOO_LARGE`.
- Exactamente 8192 bytes se permiten; 8193 se rechazan.
- Primeras cinco solicitudes por identidad/ventana se permiten; la sexta recibe
  `429 RATE_LIMIT_EXCEEDED`.
- Backend detenido o inaccesible: `502 UPSTREAM_UNAVAILABLE`.

Para aislar la ventana de tasa, el runner espera 11 segundos antes de E07 y
otros 11 segundos antes de E08.

## 6. Contrato uniforme de rechazo del gateway

```json
{
  "timestamp":"2026-09-27T03:00:00Z",
  "status":401,
  "error":"INVALID_TOKEN",
  "message":"Missing, invalid or expired bearer token",
  "path":"/api/products",
  "requestId":"e03-demo-001"
}
```

Asersiones relevantes:

1. `status` coincide con HTTP.
2. `error` coincide con la matriz.
3. `message` no expone detalles internos.
4. `path` coincide con la ruta.
5. `requestId` no está vacío y coincide con `X-Request-Id`.
6. No aparecen secretos, cuerpos, excepciones o stack traces.

| HTTP | `error` |
|---:|---|
| 401 | `INVALID_TOKEN` |
| 403 | `INSUFFICIENT_PERMISSIONS` |
| 401 | `INVALID_API_KEY` |
| 403 | `ROUTE_NOT_ALLOWED` |
| 405 | `METHOD_NOT_ALLOWED` |
| 413 | `PAYLOAD_TOO_LARGE` |
| 429 | `RATE_LIMIT_EXCEEDED` |
| 502 | `UPSTREAM_UNAVAILABLE` |
| 500 | `INTERNAL_GATEWAY_ERROR` |

## 7. Matriz E01–E12 actual

| ID | Entrada / preparación | Salida que aprueba |
|---|---|---|
| E01 | `GET /health` | `200` |
| E02 | Login ADMIN y `GET /api/products` con su JWT | `200` |
| E03 | `GET /api/products` sin JWT | `401 INVALID_TOKEN` |
| E04 | `GET /api/products` con JWT inválido | `401 INVALID_TOKEN` |
| E05 | `GET /api/admin/status` con API key configurada | `403 ROUTE_NOT_ALLOWED` |
| E06 | Registrar/login USER e intentar `POST /api/products` | `403 INSUFFICIENT_PERMISSIONS` |
| E07 | Tras 11 s, seis GET autenticados con el mismo ADMIN | `[200,200,200,200,200,429]` y `RATE_LIMIT_EXCEEDED` |
| E08 | Tras otros 11 s, orden con fixture de 8192 bytes y API key | `201` |
| E09 | Orden con fixture de 8193 bytes | `413 PAYLOAD_TOO_LARGE` |
| E10 | Detener `demo-api`, consultar productos con ADMIN y reiniciar en `finally` | `502 UPSTREAM_UNAVAILABLE` |
| E11 | Intentar host `:8081` y `demo-api:8081` desde `front-network` | Ambos fallan |
| E12 | GET autenticado con request ID único e inspección de logs | `200`, ID presente, JWT ausente |

E10 y E11 son disruptivos y solo deben ejecutarse contra el stack local/efímero.
E10 debe reiniciar `demo-api` incluso si la aserción falla.

## 8. Ejecución y evidencia

macOS/Linux/Git Bash/WSL:

```bash
python3 client-tests/run_demo.py
```

Windows PowerShell, cuando Python usa el launcher:

```powershell
py -3 client-tests/run_demo.py
```

Debe terminar con código 0, `12 passed, 0 failed, 0 skipped` y crear
`docs/evidence/e2e-<fecha UTC>.json`. La evidencia incluye revisión, comandos
descriptivos y resultados, nunca tokens, API keys o contraseñas.

`--http-only` ejecuta E01–E09 y marca E10–E12 como `SKIP`; no constituye una
aprobación completa.
