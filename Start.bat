@echo off
echo Starte WissensApp...
start "WissensApp Frontend" cmd /k "cd /d C:\Users\bztyl\OneDrive\Desktop\wissens-app\frontend && npm run dev"
start "WissensApp Backend" cmd /k "cd /d C:\Users\bztyl\OneDrive\Desktop\wissens-app\backend && start-backend.bat"
timeout /t 3 /nobreak >nul
start "" "http://localhost:5173"
