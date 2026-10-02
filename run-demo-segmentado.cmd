@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run-demo.ps1" -Segmented
exit /b %ERRORLEVEL%
