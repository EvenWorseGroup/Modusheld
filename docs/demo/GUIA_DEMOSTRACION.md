# Guía de demostración de ModuShield

## Propósito

Esta guía permite presentar ModuShield como un prototipo académico funcional y
verificable. La demostración enseña cómo un cliente accede a una API interna
solamente a través de un gateway que aplica controles de seguridad.

Tiempo total recomendado: **10 a 15 minutos**.

## Requisitos previos

- Windows con PowerShell.
- Docker Desktop instalado, iniciado y con Compose disponible.
- Repositorio descargado y ubicado en una carpeta local.
- Puerto `8080` libre.
- Archivo `.env` local preparado a partir de `.env.example`.
- Conexión a Internet durante la primera construcción de las imágenes.

No es necesario instalar Maven: las imágenes usan Maven Wrapper durante la
construcción.

## Preparación antes de la clase — 3 minutos

1. Abre PowerShell en la raíz del repositorio.
2. Confirma que Docker Desktop terminó de iniciar:

   ```powershell
   docker info
   ```

3. Si todavía no existe `.env`, créalo desde la plantilla versionada:

   ```powershell
   Copy-Item .env.example .env
   ```

4. Edita `.env` fuera de la proyección y sustituye los valores de ejemplo.
   Como mínimo, configura `MODUSHIELD_API_KEY`, `JWT_SECRET`,
   `ADMIN_USERNAME` y `ADMIN_PASSWORD`. Respeta las indicaciones de
   `.env.example` y del README.
5. Cierra el editor que contiene `.env` antes de compartir pantalla.

> **Nunca abras, imprimas ni proyectes el contenido real de `.env`.** Tampoco
> muestres API keys, contraseñas, JWT ni secretos en capturas o terminales.

## Inicio — 2 a 5 minutos

Desde la raíz ejecuta un solo comando:

```powershell
.\run-demo.cmd
```

El comando valida Compose, construye o reutiliza las imágenes, espera los
healthchecks y ejecuta E01–E09 dentro del contenedor cliente. Al terminar, los
tres contenedores permanecen activos.

Estados esperados:

| Servicio | Estado esperado | Exposición |
|---|---|---|
| `client-tests` | `Up` | Sin puerto publicado |
| `gateway` | `Up (healthy)` | `8080:8080` |
| `demo-api` | `Up (healthy)` | Solo `8081` interno |

## Orden recomendado de exposición — 5 minutos

1. **Objetivo:** explicar que el gateway es el único punto público.
2. **Arquitectura:** mostrar cliente → gateway → API interna y las dos redes.
3. **Arranque:** ejecutar `run-demo.cmd` y señalar los tres estados.
4. **Controles:** resumir E01–E09 conforme aparecen como `PASS`.
5. **Observabilidad:** consultar los eventos de auditoría sin revelar secretos.

E01–E09 representan:

| Escenario | Comprobación |
|---|---|
| E01 | El endpoint de salud del gateway responde `200`. |
| E02 | Un administrador autenticado puede consultar productos. |
| E03 | Una petición protegida sin JWT recibe `401 INVALID_TOKEN`. |
| E04 | Un JWT inválido recibe `401 INVALID_TOKEN`. |
| E05 | Una ruta no permitida recibe `403 ROUTE_NOT_ALLOWED`. |
| E06 | Un usuario sin privilegios de escritura recibe `403 INSUFFICIENT_PERMISSIONS`. |
| E07 | La sexta petición de la ventana recibe `429 RATE_LIMIT_EXCEEDED`. |
| E08 | Un payload de exactamente 8192 bytes es aceptado con `201`. |
| E09 | Un payload de 8193 bytes es rechazado con `413 PAYLOAD_TOO_LARGE`. |

La ejecución cotidiana omite deliberadamente E10–E12 porque requieren control
del entorno desde el host. En la validación completa aprobada se confirmaron:

- E10: backend detenido → `502 UPSTREAM_UNAVAILABLE` y restauración posterior.
- E11: acceso directo del cliente a Demo API bloqueado por la red.
- E12: evento `AUDIT` correlacionado, sin JWT en logs.

La validación confirmada terminó con **12 aprobadas, 0 fallidas y 0 omitidas**.
Esto demuestra el alcance probado; no significa que el prototipo sea
invulnerable o esté preparado para producción.

## Logs seguros — 1 minuto

Ejecuta:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\demo-logs.ps1
```

El script limita la salida reciente del gateway y selecciona eventos útiles
para explicar `requestId`, decisión, regla y código HTTP. No copies ni leas en
voz alta credenciales. Si una salida inesperada pareciera sensible, detén la
proyección antes de revisarla.

Las evidencias JSON quedan en `docs/evidence/`, directorio ignorado por Git.

## Cierre — 1 minuto

```powershell
.\stop-demo.cmd
```

El resultado esperado es que desaparezcan los contenedores y redes del proyecto.
Las imágenes y los archivos de `docs/evidence/` se conservan.

