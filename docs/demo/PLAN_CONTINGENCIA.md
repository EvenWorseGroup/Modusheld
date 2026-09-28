# Plan de contingencia para la demostración

Aplica estas acciones sin mostrar `.env`, credenciales, API keys, JWT ni
contraseñas. No borres volúmenes ni cambies permanentemente la política de
PowerShell.

## Docker Desktop está cerrado

- **Síntoma:** `run-demo.cmd` indica que Docker no responde.
- **Causa probable:** el motor de Docker Desktop no está iniciado.
- **Comprobación segura:** ejecuta `docker info`.
- **Solución:** abre Docker Desktop y espera hasta que indique que el motor está listo.
- **Alternativa:** explica la arquitectura y usa la evidencia previamente validada.

## El puerto 8080 está ocupado

- **Síntoma:** gateway no puede publicar `8080:8080`.
- **Causa probable:** otra aplicación o contenedor usa el puerto.
- **Comprobación segura:** ejecuta `Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue`.
- **Solución:** identifica y cierra de forma normal la aplicación que ocupa el puerto; no cambies el puerto del proyecto.
- **Alternativa:** presenta el diagrama, resultados confirmados y evidencia existente.

## Falta `.env`

- **Síntoma:** Compose informa que faltan variables requeridas o el archivo.
- **Causa probable:** no se creó la configuración local.
- **Comprobación segura:** ejecuta `Test-Path .env`; no uses `Get-Content .env` durante la proyección.
- **Solución:** ejecuta `Copy-Item .env.example .env` y completa los valores de forma privada.
- **Alternativa:** continúa con la explicación documental sin iniciar el entorno.

## Falta una variable

- **Síntoma:** `config --quiet` falla indicando el nombre de una variable.
- **Causa probable:** el campo no existe o está vacío en `.env`.
- **Comprobación segura:** revisa solamente el nombre reportado, fuera de la proyección.
- **Solución:** completa esa variable siguiendo `.env.example` y el README.
- **Alternativa:** usa la evidencia validada; no improvises valores en pantalla.

## PowerShell bloquea scripts

- **Síntoma:** aparece un error de `ExecutionPolicy` al abrir un `.ps1` directamente.
- **Causa probable:** la política local restringe scripts.
- **Comprobación segura:** confirma que estás usando el acceso `.cmd`.
- **Solución:** ejecuta `.\run-demo.cmd` o `.\stop-demo.cmd`; aplican `Bypass` solo a su proceso.
- **Alternativa:** explica que no es necesario cambiar permanentemente la política del equipo.

## La construcción tarda demasiado

- **Síntoma:** la terminal permanece varios minutos en descarga o compilación.
- **Causa probable:** primera ejecución, caché vacía o pocos recursos.
- **Comprobación segura:** observa si Docker continúa mostrando progreso, sin interrumpirlo inmediatamente.
- **Solución:** espera; para futuras presentaciones ejecuta la demostración una vez antes de clase.
- **Alternativa:** pasa a arquitectura y resultados mientras la construcción continúa.

## No hay conexión para descargar imágenes

- **Síntoma:** errores de resolución, timeout o acceso al registro de imágenes.
- **Causa probable:** red ausente y caché local incompleta.
- **Comprobación segura:** revisa el mensaje de Docker y la conectividad general.
- **Solución:** restaura la conexión o utiliza imágenes descargadas durante el ensayo previo.
- **Alternativa:** presenta las evidencias previamente validadas y aclara que el fallo es de aprovisionamiento.

## Un contenedor no queda saludable

- **Síntoma:** `run-demo.cmd` termina con error o muestra un servicio `unhealthy`.
- **Causa probable:** configuración incompleta, dependencia no disponible o recursos insuficientes.
- **Comprobación segura:** ejecuta `docker compose --env-file .env -f infra/docker-compose.yml ps` y luego el visor seguro de logs:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\demo-logs.ps1
  ```

- **Solución:** corrige únicamente la preparación local identificada y vuelve a ejecutar `run-demo.cmd`.
- **Alternativa:** muestra la arquitectura y la evidencia del ensayo aprobado.

## Falla una prueba en vivo

- **Síntoma:** aparece `FAIL` o el comando devuelve código distinto de cero.
- **Causa probable:** estado transitorio, credenciales locales distintas o entorno incompleto.
- **Comprobación segura:** conserva el mensaje, revisa el estado de los tres servicios y no muestres `.env`.
- **Solución:** cierra con `stop-demo.cmd`, verifica la preparación y repite solamente si hay tiempo.
- **Alternativa:** muestra el JSON previamente validado y explica el resultado esperado sin afirmar que la ejecución actual pasó.

## Usar evidencia previamente validada

- **Síntoma:** no es posible recuperar la ejecución durante la clase.
- **Causa probable:** problema del equipo, Docker o conectividad.
- **Comprobación segura:** abre únicamente un JSON conocido de `docs/evidence/`; confirma antes que no contiene información sensible.
- **Solución:** presenta el resumen confirmado: 82 pruebas Java, JaCoCo satisfecho, E01–E09 aprobadas y suite completa 12/12.
- **Alternativa:** recorre `ARQUITECTURA_DEMO.md` y `HOJA_RAPIDA.md`, diferenciando claramente evidencia previa de ejecución en vivo.

