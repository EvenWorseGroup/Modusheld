# Arquitectura actual de ModuShield

## Propósito

ModuShield es un API Gateway de seguridad. Centraliza correlación, control de
rutas y métodos, autenticación, autorización, límites, encabezados de
seguridad, manejo de errores y auditoría antes de reenviar tráfico a una API
interna de demostración.

El reactor Maven contiene solamente dos módulos ejecutables:

```text
modushield
├── gateway-service
└── demo-api
```

La carpeta histórica `C/` conserva material de integración, pero no forma parte
de la lista de módulos del `pom.xml` raíz ni del runtime.

## Topología Docker

```text
Cliente / curl / run_demo.py
              |
              | HTTP localhost:8080
              v
       gateway-service
       - front-network
       - back-network
              |
              | HTTP demo-api:8081
              v
           demo-api
       - back-network interna
       - sin puerto en el host
```

`gateway-service` es el único servicio unido a ambas redes y el único que
publica un puerto. `demo-api` usa `expose: 8081` como documentación interna,
pero no tiene `ports:`. La red `back-network` está marcada como `internal`.

## Superficies HTTP

El gateway atiende directamente:

- `GET /health`: Actuator, sin autenticación.
- `POST /auth/register`: registro de usuarios en memoria con rol `USER`.
- `POST /auth/login`: validación BCrypt y emisión de JWT.

Spring Cloud Gateway reenvía `/api/**` hacia `${DEMO_API_URL}` después de
aplicar las políticas. Las rutas de negocio principales son:

- Productos: JWT Bearer; lectura para `USER` y CRUD para `ADMIN`.
- Órdenes heredadas: `X-API-Key`.
- `/api/admin/status`: existe en el backend, pero el gateway la bloquea para
  demostrar denegación previa al upstream.

## Flujo de una solicitud `/api/**`

Los `GlobalFilter` se ejecutan por orden numérico:

| Orden | Componente | Responsabilidad |
|---:|---|---|
| -100 | `RequestIdFilter` | Conserva un `X-Request-Id` seguro o crea un UUID; lo reenvía y lo devuelve. |
| -90 | `AuditFilter` | Mide la solicitud y emite un único evento sanitizado al terminar. |
| -80 | `GatewayErrorFilter` | Convierte fallos de conexión/timeout en 502 y fallos inesperados en 500. |
| 30 | `RouteMethodPolicy` | Rechaza rutas fuera de la allowlist y métodos no permitidos. |
| 40 | `JwtAuthenticationFilter` | Protege productos, valida JWT y exige `ADMIN` para escrituras. |
| 45 | `ApiKeyFilter` | Protege rutas heredadas; productos quedan exentos porque usan JWT. |
| 50 | `RequestSizePolicy` | Aplica límite de 8192 bytes y rechaza longitudes no verificables. |
| 60 | `RateLimitPolicy` | Aplica cinco solicitudes por diez segundos por identidad. |
| posterior | Spring Cloud Gateway | Reenvía la solicitud permitida a `demo-api`. |

Además de esos `GlobalFilter`, `SecurityHeadersWebFilter` es un `WebFilter`
global con `Ordered.HIGHEST_PRECEDENCE`. Antes de confirmar cualquier respuesta
establece `X-Content-Type-Options: nosniff`; la operación `set` sustituye un
valor inseguro enviado por el upstream en vez de duplicarlo.

El JWT no se reenvía al backend. Después de validarlo, el gateway elimina
`Authorization` y coloca `X-Authenticated-User` y `X-Authenticated-Role`. La
identidad del rate limit se deriva del usuario autenticado, de la API key para
rutas heredadas o de la IP; solamente se conserva su hash SHA-256.

## Autenticación y usuarios

- `UserService` crea el ADMIN configurado al arrancar.
- Los registros públicos siempre reciben `USER`.
- Las contraseñas se almacenan con BCrypt, no en texto plano.
- `JwtService` firma con `JWT_SECRET`, que debe tener al menos 32 bytes.
- El JWT contiene `sub`, `role`, `iat` y `exp`.
- Los usuarios son volátiles: recrear el gateway elimina registros hechos por
  `/auth/register`, pero vuelve a crear el ADMIN configurado.

## API interna

`demo-api` contiene:

- CRUD en memoria para `/api/products`.
- Productos iniciales `P-100` y `P-200`.
- Creación simulada de órdenes en `POST /api/orders`.
- `GET /health`.
- `GET /api/admin/status`, accesible dentro de la red privada pero bloqueado por
  el gateway.

La autorización vive en el gateway; `demo-api` no duplica la autenticación.

## Errores, correlación y auditoría

Las políticas crean `PolicyDecision`. `JsonErrorResponseWriter` es el único
serializador de rechazos del gateway y devuelve:

```json
{
  "timestamp": "2026-09-27T03:00:00Z",
  "status": 401,
  "error": "INVALID_TOKEN",
  "message": "Missing, invalid or expired bearer token",
  "path": "/api/products",
  "requestId": "ejemplo-001"
}
```

Los eventos `AUDIT` incluyen timestamp, request ID, IP, método, ruta, decisión,
regla, estado y duración. No incluyen el JWT, la API key completa ni el cuerpo.

## Encabezado de seguridad y evidencia ZAP

Un análisis pasivo inicial con OWASP ZAP 2.17.0 sobre `GET /health` detectó una
alerta baja, confianza media, por ausencia de `X-Content-Type-Options`. Después
de incorporar `SecurityHeadersWebFilter`, un análisis nuevo del mismo endpoint
reportó cero alertas dentro del alcance seleccionado.

La evidencia y sus limitaciones se documentan en
[`entrega-final-equipo-modushield/reportes/seguridad-zap/`](../entrega-final-equipo-modushield/reportes/seguridad-zap/README.md).
El resultado corresponde a un análisis pasivo de `/health`; no demuestra la
ausencia de vulnerabilidades en las rutas autenticadas ni sustituye un escaneo
activo o una revisión manual.

## Datos y límites operativos

No hay base de datos ni almacenamiento persistente. El diseño es intencional
para una demostración reproducible de una sola instancia. El rate limit también
es local y en memoria; no es un contador distribuido.

## Verificación automatizada

- JUnit 5 cubre ambos módulos.
- JaCoCo genera reportes por módulo y exige al menos 80% de líneas en cada uno.
- `client-tests/run_demo.py` valida E01–E12 sobre Docker Compose.
- GitHub Actions prueba, empaqueta, construye imágenes, despliega temporalmente
  el Compose, ejecuta E01–E12, carga evidencia y siempre limpia el entorno.
