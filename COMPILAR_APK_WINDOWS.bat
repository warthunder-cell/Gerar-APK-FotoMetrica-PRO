@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Compilar_APK.ps1"
if errorlevel 1 (echo. & echo Falha na compilacao. Veja as mensagens acima. & pause & exit /b 1)
echo. & echo APK gerado. & pause
