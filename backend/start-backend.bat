@echo off
title WissensApp Backend
:restart
echo [Backend] Starte server.js...
node --env-file=.env server.js
echo.
echo [Backend] Server beendet (Exit-Code: %errorlevel%). Neustart in 3 Sekunden...
echo [Backend] Fenster schliessen um zu stoppen.
timeout /t 3 /nobreak >nul
goto restart
