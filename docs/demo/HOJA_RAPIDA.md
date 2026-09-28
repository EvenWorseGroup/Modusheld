# Hoja rápida de exposición

## Cinco comprobaciones previas

1. Docker Desktop está iniciado.
2. PowerShell está abierto en la raíz del repositorio.
3. El puerto `8080` está libre.
4. `.env` existe y fue preparado en privado desde `.env.example`.
5. El editor de `.env` está cerrado antes de proyectar.

## Inicio

```powershell
.\run-demo.cmd
```

Estados esperados:

- `client-tests`: `Up`.
- `gateway`: `Up (healthy)`, puerto público `8080`.
- `demo-api`: `Up (healthy)`, puerto `8081` solamente interno.

## Explicación en cinco pasos

1. El cliente solo comparte `front-network` con el gateway.
2. El gateway aplica políticas y es el único punto público.
3. Demo API solo comparte `back-network` con el gateway.
4. E01–E09 comprueban salud, acceso permitido y bloqueos de seguridad.
5. Los logs correlacionan cada decisión sin registrar el JWT.

## Resultados técnicos confirmados

- Clon limpio de Windows validado y archivos Linux en LF.
- Tres imágenes construidas correctamente.
- 82 pruebas Java aprobadas y JaCoCo satisfecho.
- E01–E09: 9 aprobadas.
- E01–E12: 12 aprobadas, 0 fallidas, 0 omitidas.
- E10: `502 UPSTREAM_UNAVAILABLE`.
- E11: aislamiento directo confirmado.
- E12: auditoría encontrada sin JWT en logs.

## Logs

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\demo-logs.ps1
```

## Cierre

```powershell
.\stop-demo.cmd
```

Después del cierre no deben quedar contenedores ni redes del proyecto; las
imágenes y evidencias permanecen.

## Si algo falla

- “El problema actual es del entorno; mostraré la evidencia del ensayo validado.”
- “El control esperado está documentado y fue confirmado en la suite completa 12/12.”
- “Continuaré con la arquitectura sin exponer credenciales ni cambiar la configuración.”

> **No abras, imprimas ni proyectes `.env`, API keys, contraseñas o JWT.**

