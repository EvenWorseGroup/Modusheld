# Políticas y contratos HTTP actuales

## Endpoints

| Método | Ruta | Autenticación | Autorización / resultado nominal |
|---|---|---|---|
| GET | `/health` | Ninguna | `200` |
| POST | `/auth/register` | Ninguna | `201`; crea `USER` |
| POST | `/auth/login` | Usuario y contraseña | `200`; devuelve JWT |
| GET | `/api/products` | Bearer JWT | `USER` o `ADMIN` |
| GET | `/api/products/{id}` | Bearer JWT | `USER` o `ADMIN` |
| POST | `/api/products` | Bearer JWT | Solo `ADMIN` |
| PUT | `/api/products/{id}` | Bearer JWT | Solo `ADMIN` |
| DELETE | `/api/products/{id}` | Bearer JWT | Solo `ADMIN` |
| POST | `/api/orders` | `X-API-Key` | `201` con cuerpo válido |
| GET | `/api/admin/status` | Irrelevante | El gateway siempre devuelve `403` |

## Registro y login

El username debe cumplir `[A-Za-z0-9._-]{3,64}` y la contraseña debe tener
entre 8 y 128 caracteres. Los usuarios se almacenan en memoria con hash BCrypt.

Registro exitoso:

```json
{"username":"reader","role":"USER"}
```

Login exitoso:

```json
{
  "token": "<JWT>",
  "tokenType": "Bearer",
  "username": "reader",
  "role": "USER",
  "expiresAt": "<fecha ISO-8601>"
}
```

Errores de autenticación local:

| HTTP | `error` | Caso |
|---:|---|---|
| 400 | `INVALID_REGISTRATION` | Username o contraseña inválidos |
| 409 | `USERNAME_EXISTS` | Username duplicado |
| 401 | `INVALID_CREDENTIALS` | Login incorrecto |

Estos errores pertenecen al `AuthController`; el contrato uniforme de seis
campos descrito abajo corresponde a rechazos creados por las políticas del
gateway.

## JWT y roles

Las rutas de productos exigen exactamente un header:

```http
Authorization: Bearer <JWT>
```

El gateway valida firma, estructura, identidad, rol y expiración. Un token
ausente, inválido, alterado o vencido devuelve `401 INVALID_TOKEN`. Un `USER`
que intenta `POST`, `PUT` o `DELETE` recibe
`403 INSUFFICIENT_PERMISSIONS`.

## API key heredada

`POST /api/orders` exige exactamente un `X-API-Key` igual al valor privado de
`MODUSHIELD_API_KEY`. La comparación es de tiempo constante. La clave no se
registra ni se guarda en evidencia.

Productos no aceptan la API key como sustituto del JWT.

## Rutas y métodos

La allowlist permite salud, productos CRUD y creación de órdenes. Una ruta
desconocida bajo `/api/**` devuelve `403 ROUTE_NOT_ALLOWED`. Una ruta conocida
con un método no permitido devuelve `405 METHOD_NOT_ALLOWED`. Se rechazan rutas
ambiguas con `..`, separadores dobles o codificaciones peligrosas de `.` o `/`.

## Tamaño de solicitud

El límite predeterminado es 8192 bytes. Para `POST`, `PUT` y `PATCH`:

- `Content-Length` debe existir una sola vez y ser un entero no negativo.
- Un valor mayor que 8192 devuelve `413 PAYLOAD_TOO_LARGE`.
- Cualquier `Transfer-Encoding` se rechaza porque el tamaño no puede verificarse
  antes de aceptar el cuerpo.

Los fixtures oficiales validan exactamente 8192 y 8193 bytes.

## Rate limit

La configuración predeterminada permite cinco solicitudes por identidad en una
ventana fija de diez segundos. La sexta devuelve
`429 RATE_LIMIT_EXCEEDED`. El estado vive en memoria y es adecuado para esta
demostración de una sola instancia.

## Errores uniformes del gateway

| HTTP | `error` | Regla interna |
|---:|---|---|
| 401 | `INVALID_TOKEN` | `AUTHENTICATION` |
| 403 | `INSUFFICIENT_PERMISSIONS` | `AUTHORIZATION` |
| 401 | `INVALID_API_KEY` | `API_KEY` |
| 403 | `ROUTE_NOT_ALLOWED` | `ROUTE` |
| 405 | `METHOD_NOT_ALLOWED` | `METHOD` |
| 413 | `PAYLOAD_TOO_LARGE` | `SIZE` |
| 429 | `RATE_LIMIT_EXCEEDED` | `RATE_LIMIT` |
| 502 | `UPSTREAM_UNAVAILABLE` | `UPSTREAM` |
| 500 | `INTERNAL_GATEWAY_ERROR` | `INTERNAL` |

Respuesta pública:

```json
{
  "timestamp": "2026-09-27T03:00:00Z",
  "status": 429,
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Request limit exceeded",
  "path": "/api/products",
  "requestId": "e07-demo-001"
}
```

No se exponen `rule`, claves, headers de autorización, cuerpos, excepciones ni
stack traces. Las respuestas originadas directamente por `demo-api`, por
ejemplo un `404` de producto, usan el formato estándar de Spring y no este
contrato del gateway.

## Encabezado global de seguridad

Toda respuesta confirmada por el gateway debe incluir:

```http
X-Content-Type-Options: nosniff
```

`SecurityHeadersWebFilter` aplica el encabezado a endpoints locales y a
respuestas reenviadas. Si el upstream intenta enviar otro valor, el gateway lo
reemplaza. Las pruebas de integración cubren `/health` y una ruta real
proxyficada; la evidencia OWASP ZAP documenta la alerta inicial y su eliminación
en el análisis pasivo final de `/health`.

## Configuración segura

| Variable | Propósito |
|---|---|
| `MODUSHIELD_API_KEY` | Credencial privada de órdenes heredadas |
| `JWT_SECRET` | Firma JWT; mínimo 32 bytes aleatorios |
| `JWT_EXPIRATION_SECONDS` | Vigencia del token; predeterminado 3600 |
| `ADMIN_USERNAME` | ADMIN creado al arrancar |
| `ADMIN_PASSWORD` | Contraseña privada del ADMIN |
| `DEMO_API_URL` | URL interna, normalmente `http://demo-api:8081` |
| `MAX_REQUEST_SIZE_BYTES` | Límite, normalmente 8192 |
| `RATE_LIMIT_CAPACITY` | Capacidad, normalmente 5 |
| `RATE_LIMIT_WINDOW_SECONDS` | Ventana, normalmente 10 |
| `SERVER_PORT` | Puerto del servicio |

Los secretos reales viven solamente en `.env`, variables del proceso o
secretos externos. `.env.example` contiene placeholders y `.env` está ignorado
por Git. Un secreto expuesto debe rotarse aunque se elimine posteriormente.
