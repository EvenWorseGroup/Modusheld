@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\demo-down.ps1"
exit /b %ERRORLEVEL%
