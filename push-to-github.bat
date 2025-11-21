@echo off
REM Pet Support App - Quick GitHub Push Script for Windows
REM This script helps you push your project to GitHub quickly

echo.
echo ========================================
echo Pet Support App - GitHub Push Script
echo ========================================
echo.

REM Check if Git is installed
where git >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Git is not installed. Please install Git first.
    echo Download from: https://git-scm.com/
    pause
    exit /b 1
) else (
    echo [SUCCESS] Git is installed
)

REM Check if GitHub CLI is installed
where gh >nul 2>&1
if %errorLevel% neq 0 (
    set GITHUB_CLI_AVAILABLE=false
    echo [WARNING] GitHub CLI not found. Will use manual setup.
) else (
    set GITHUB_CLI_AVAILABLE=true
    echo [SUCCESS] GitHub CLI is available
)

echo.
echo [INFO] Please provide your GitHub information:
set /p github_username="GitHub Username: "
set /p github_email="GitHub Email: "
set /p repo_name="Repository Name (pet-support-app): "
if "%repo_name%"=="" set repo_name=pet-support-app

set /p repo_visibility="Public or Private repository? (public/private): "
if "%repo_visibility%"=="" set repo_visibility=public

REM Configure Git
echo.
echo [INFO] Configuring Git...
git config --global user.name "%github_username%"
git config --global user.email "%github_email%"
echo [SUCCESS] Git configured for %github_email%

REM Navigate to project directory
set PROJECT_DIR=c:\Users\m-oguntimehin\Desktop\New folder\cc
if exist "%PROJECT_DIR%" (
    cd /d "%PROJECT_DIR%"
    echo [SUCCESS] Changed to project directory: %PROJECT_DIR%
) else (
    echo [ERROR] Project directory not found: %PROJECT_DIR%
    pause
    exit /b 1
)

REM Initialize Git repository
if not exist ".git" (
    echo [INFO] Initializing Git repository...
    git init
    echo [SUCCESS] Git repository initialized
) else (
    echo [SUCCESS] Git repository already exists
)

REM Create .gitignore if it doesn't exist
if not exist ".gitignore" (
    echo [INFO] Creating .gitignore file...
    (
        echo # Dependencies
        echo node_modules/
        echo mobile/.dart_tool/
        echo mobile/build/
        echo mobile/.flutter-plugins
        echo mobile/.flutter-plugins-dependencies
        echo mobile/.packages
        echo mobile/pub-cache/
        echo.
        echo # Environment variables
        echo .env
        echo .env.local
        echo .env.development.local
        echo .env.test.local
        echo .env.production.local
        echo.
        echo # IDE files
        echo .vscode/
        echo .idea/
        echo *.swp
        echo *.swo
        echo *~
        echo.
        echo # OS generated files
        echo .DS_Store
        echo .DS_Store?
        echo ._*
        echo .Spotlight-V100
        echo .Trashes
        echo ehthumbs.db
        echo Thumbs.db
        echo.
        echo # Logs
        echo *.log
        echo logs/
        echo.
        echo # Flutter specific
        echo mobile/ios/Flutter/Flutter.framework
        echo mobile/ios/Flutter/Flutter.podspec
        echo mobile/ios/Pods/
        echo mobile/ios/.symlinks/
        echo mobile/ios/Flutter/Generated.xcconfig
        echo mobile/ios/Flutter/ephemeral/
        echo mobile/ios/.packages/
        echo mobile/ios/.dart-tool/
        echo.
        echo # Android specific
        echo mobile/android/.gradle/
        echo mobile/android/app/build/
        echo mobile/android/local.properties
        echo mobile/android/key.properties
        echo.
        echo # Keystore files
        echo *.jks
        echo *.p8
        echo *.p12
        echo *.key
        echo *.mobileprovision
        echo *.orig.*
        echo.
        echo # Database
        echo *.sqlite
        echo *.sqlite3
        echo *.db
        echo.
        echo # API Keys and secrets
        echo secrets/
        echo *.pem
        echo *.key
        echo *.crt
    ) > .gitignore
    echo [SUCCESS] .gitignore file created
) else (
    echo [SUCCESS] .gitignore file already exists
)

REM Add files to Git
echo [INFO] Adding files to Git...
git add .
echo [SUCCESS] Files added to staging area

REM Create commit
echo [INFO] Creating initial commit...
git commit -m "Initial commit: Complete Pet Support App implementation

Features implemented:
- Backend API with Node.js/Express and PostgreSQL
- Flutter mobile app with comprehensive UI
- AI-powered chat with OpenAI integration
- Health tracking and emergency triage
- Local resource finder with geolocation
- Data synchronization and offline support
- Admin dashboard for content management
- Comprehensive testing suite
- CI/CD pipeline for deployment
- App store deployment configuration
- User documentation and onboarding

Tech stack:
- Backend: Node.js, Express, PostgreSQL, JWT
- Frontend: Flutter, Provider, Go Router
- Services: OpenAI, Firebase, Cloudinary, Google Maps
- Testing: Jest, Flutter Test, Artillery
- Deployment: Docker, GitHub Actions"

echo [SUCCESS] Initial commit created

REM Create GitHub repository and push
if "%GITHUB_CLI_AVAILABLE%"=="true" (
    echo [INFO] Using GitHub CLI to create repository...
    
    REM Check if logged in to GitHub
    gh auth status >nul 2>&1
    if %errorLevel% neq 0 (
        echo [INFO] Please login to GitHub...
        gh auth login
    )
    
    REM Create repository and push
    echo [INFO] Creating GitHub repository: %repo_name%
    gh repo create "%repo_name%" --%repo_visibility% --source=. --remote=origin --push
    echo [SUCCESS] Repository created and pushed to GitHub
    
    set REPO_URL=https://github.com/%github_username%/%repo_name%
) else (
    REM Manual setup
    echo [INFO] Manual GitHub setup required...
    
    REM Create remote
    set REPO_URL=https://github.com/%github_username%/%repo_name%.git
    echo [INFO] Adding remote origin: %REPO_URL%
    git remote add origin "%REPO_URL%"
    
    REM Push to GitHub
    echo [INFO] Pushing to GitHub...
    git branch -M main
    git push -u origin main
    echo [SUCCESS] Code pushed to GitHub
    
    set REPO_URL=https://github.com/%github_username%/%repo_name%
)

REM Success message
echo.
echo 🎉 SUCCESS! Your Pet Support App is now on GitHub!
echo.
echo Repository URL: %REPO_URL%
echo.
echo Next steps:
echo 1. Visit your repository: %REPO_URL%
echo 2. Set up GitHub Actions secrets in repository settings
echo 3. Enable GitHub Actions for CI/CD pipeline
echo 4. Configure branch protection rules
echo 5. Add collaborators if needed
echo.
echo Required secrets for CI/CD:
echo - DATABASE_URL
echo - JWT_SECRET
echo - OPENAI_API_KEY
echo - GOOGLE_MAPS_API_KEY
echo - CLOUDINARY_CLOUD_NAME
echo - CLOUDINARY_API_KEY
echo - CLOUDINARY_API_SECRET
echo - FCM_SERVER_KEY
echo - SENDGRID_API_KEY
echo.
echo [INFO] Happy coding! 🚀
echo.
pause