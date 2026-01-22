@echo off
echo ========================================
echo ThunderCut - Installation Script
echo ========================================
echo.

echo [1/4] Installing Backend Dependencies...
cd backend
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Backend installation failed!
    pause
    exit /b 1
)
echo ✓ Backend dependencies installed
echo.

echo [2/4] Creating Environment File...
if not exist .env (
    copy .env.example .env
    echo ✓ .env file created
) else (
    echo ✓ .env file already exists
)
echo.

echo [3/4] Installing Flutter Dependencies...
cd ..\flutter-app
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter installation failed!
    pause
    exit /b 1
)
echo ✓ Flutter dependencies installed
echo.

echo [4/4] Creating Directories...
cd ..
if not exist backend\uploads mkdir backend\uploads
if not exist backend\logs mkdir backend\logs
echo ✓ Directories created
echo.

echo ========================================
echo ✓ Installation Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Start Backend:  cd backend ^&^& npm run dev
echo 2. Start Flutter:  cd flutter-app ^&^& flutter run -d windows
echo.
echo For more info, see docs/QUICK_START.md
echo.
pause
