@echo off
REM Pet Support App - Quick Setup Script for Windows
REM This script helps you set up the development environment quickly

echo.
echo ==================================
echo Pet Support App - Quick Setup
echo ==================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [WARNING] Running as administrator. Some commands may not work properly.
    echo.
)

REM Function to check if command exists
where node >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js v18 or higher.
    echo Download from: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [SUCCESS] Node.js installed: %NODE_VERSION%
)

where npm >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] npm is not installed.
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [SUCCESS] npm installed: %NPM_VERSION%
)

where flutter >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Flutter is not installed. Please install Flutter SDK.
    echo Download from: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
) else (
    echo [SUCCESS] Flutter is installed.
)

where git >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Git is not installed.
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VERSION=%%i
    echo [SUCCESS] Git installed: %GIT_VERSION%
)

echo.
echo [INFO] Checking prerequisites completed.
echo.

REM Check if backend directory exists
if not exist "backend" (
    echo [ERROR] Backend directory not found. Please run this script from the project root.
    pause
    exit /b 1
)

REM Check if mobile directory exists
if not exist "mobile" (
    echo [ERROR] Mobile directory not found. Please run this script from the project root.
    pause
    exit /b 1
)

echo [INFO] This script will set up the Pet Support App development environment.
echo [INFO] Please make sure you have Node.js, Flutter, and PostgreSQL installed.
echo.

set /p continue="Do you want to continue? (y/n): "
if /i not "%continue%"=="y" (
    echo [INFO] Setup cancelled.
    pause
    exit /b 0
)

echo.
echo [INFO] Setting up backend...
cd backend

REM Install Node.js dependencies
echo [INFO] Installing Node.js dependencies...
call npm install
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install Node.js dependencies.
    pause
    exit /b 1
)

REM Copy environment file
if not exist ".env" (
    echo [INFO] Creating environment file...
    copy .env.example .env
    echo [WARNING] Please edit backend\.env file with your API keys and database configuration.
) else (
    echo [SUCCESS] Environment file already exists.
)

REM Install global dependencies
echo [INFO] Installing global dependencies...
call npm install -g nodemon
call npm install -g artillery
if %errorLevel% neq 0 (
    echo [WARNING] Some global dependencies may have failed to install.
)

cd ..
echo [SUCCESS] Backend setup completed.

echo.
echo [INFO] Setting up mobile app...
cd mobile

REM Install Flutter dependencies
echo [INFO] Installing Flutter dependencies...
call flutter pub get
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install Flutter dependencies.
    pause
    exit /b 1
)

REM Create local.properties for Android
if not exist "android\local.properties" (
    echo [INFO] Creating Android local.properties file...
    echo flutter.sdk=%FLUTTER_PATH% > android\local.properties
    echo [WARNING] Please update android\local.properties with your Flutter SDK path.
) else (
    echo [SUCCESS] Android local.properties already exists.
)

cd ..
echo [SUCCESS] Mobile app setup completed.

echo.
echo [INFO] Creating development scripts...

REM Create start-backend script
echo @echo off > start-backend.bat
echo cd backend >> start-backend.bat
echo npm run dev >> start-backend.bat
echo pause >> start-backend.bat

REM Create start-mobile script
echo @echo off > start-mobile.bat
echo cd mobile >> start-mobile.bat
echo flutter run >> start-mobile.bat
echo pause >> start-mobile.bat

REM Create test-backend script
echo @echo off > test-backend.bat
echo cd backend >> test-backend.bat
echo npm test >> test-backend.bat
echo pause >> test-backend.bat

REM Create test-mobile script
echo @echo off > test-mobile.bat
echo cd mobile >> test-mobile.bat
echo flutter test >> test-mobile.bat
echo pause >> test-mobile.bat

echo [SUCCESS] Development scripts created.

echo.
echo [INFO] Setup completed! Here's what to do next:
echo.
echo 1. Configure API Keys:
echo    - Edit backend\.env with your API keys
echo    - Required: OpenAI, Google Maps, Cloudinary, Firebase, SendGrid
echo.
echo 2. Start Development:
echo    - Backend: start-backend.bat
echo    - Mobile: start-mobile.bat
echo.
echo 3. Testing:
echo    - Backend: test-backend.bat
echo    - Mobile: test-mobile.bat
echo.
echo 4. For detailed testing instructions, see TESTING_GUIDE.md
echo.
echo 5. When ready for deployment:
echo    - Backend: npm run build
echo    - Mobile: flutter build apk (Android) or flutter build ios (iOS)
echo.
echo [INFO] Happy coding! 🎉
echo.
pause