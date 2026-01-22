@echo off
echo ========================================
echo ThunderCut - Starting Application
echo ========================================
echo.

echo Starting Backend Server...
start "ThunderCut Backend" cmd /k "cd backend && npm run dev"
timeout /t 3 /nobreak > nul
echo ✓ Backend server started
echo.

echo Starting Flutter App...
start "ThunderCut Flutter" cmd /k "cd flutter-app && flutter run -d windows"
echo ✓ Flutter app starting...
echo.

echo ========================================
echo ✓ ThunderCut is starting!
echo ========================================
echo.
echo Backend: http://localhost:3000
echo Flutter: Check the new window
echo.
echo Press any key to close this window...
pause > nul
