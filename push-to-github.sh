#!/bin/bash

# Pet Support App - Quick GitHub Push Script
# This script helps you push your project to GitHub quickly

set -e

echo "🚀 Pet Support App - GitHub Push Script"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

# Check if Git is installed
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    print_info "Download from: https://git-scm.com/"
    exit 1
fi

# Check if GitHub CLI is installed
if command -v gh &> /dev/null; then
    GITHUB_CLI_AVAILABLE=true
    print_status "GitHub CLI is available"
else
    GITHUB_CLI_AVAILABLE=false
    print_warning "GitHub CLI not found. Will use manual setup."
fi

# Get user information
echo ""
print_info "Please provide your GitHub information:"
read -p "GitHub Username: " github_username
read -p "GitHub Email: " github_email
read -p "Repository Name (pet-support-app): " repo_name
repo_name=${repo_name:-pet-support-app}

read -p "Public or Private repository? (public/private): " repo_visibility
repo_visibility=${repo_visibility:-public}

# Configure Git
print_info "Configuring Git..."
git config --global user.name "$github_username"
git config --global user.email "$github_email"
print_status "Git configured for $github_email"

# Navigate to project directory
PROJECT_DIR="c:/Users/m-oguntimehin/Desktop/New folder/cc"
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR"
    print_status "Changed to project directory: $PROJECT_DIR"
else
    print_error "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Initialize Git repository
if [ ! -d ".git" ]; then
    print_info "Initializing Git repository..."
    git init
    print_status "Git repository initialized"
else
    print_status "Git repository already exists"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    print_info "Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
mobile/.dart_tool/
mobile/build/
mobile/.flutter-plugins
mobile/.flutter-plugins-dependencies
mobile/.packages
mobile/pub-cache/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Logs
*.log
logs/

# Flutter specific
mobile/ios/Flutter/Flutter.framework
mobile/ios/Flutter/Flutter.podspec
mobile/ios/Pods/
mobile/ios/.symlinks/
mobile/ios/Flutter/Generated.xcconfig
mobile/ios/Flutter/ephemeral/
mobile/ios/.packages/
mobile/ios/.dart-tool/

# Android specific
mobile/android/.gradle/
mobile/android/app/build/
mobile/android/local.properties
mobile/android/key.properties

# Keystore files
*.jks
*.p8
*.p12
*.key
*.mobileprovision
*.orig.*

# Database
*.sqlite
*.sqlite3
*.db

# API Keys and secrets
secrets/
*.pem
*.key
*.crt
EOF
    print_status ".gitignore file created"
else
    print_status ".gitignore file already exists"
fi

# Add files to Git
print_info "Adding files to Git..."
git add .
print_status "Files added to staging area"

# Create commit
print_info "Creating initial commit..."
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

print_status "Initial commit created"

# Create GitHub repository and push
if [ "$GITHUB_CLI_AVAILABLE" = true ]; then
    print_info "Using GitHub CLI to create repository..."
    
    # Login to GitHub if not already logged in
    if ! gh auth status &> /dev/null; then
        print_info "Please login to GitHub..."
        gh auth login
    fi
    
    # Create repository and push
    print_info "Creating GitHub repository: $repo_name"
    gh repo create "$repo_name" --$repo_visibility --source=. --remote=origin --push
    print_status "Repository created and pushed to GitHub"
    
    REPO_URL="https://github.com/$github_username/$repo_name"
else
    # Manual setup
    print_info "Manual GitHub setup required..."
    
    # Create remote
    REPO_URL="https://github.com/$github_username/$repo_name.git"
    print_info "Adding remote origin: $REPO_URL"
    git remote add origin "$REPO_URL"
    
    # Push to GitHub
    print_info "Pushing to GitHub..."
    git branch -M main
    git push -u origin main
    print_status "Code pushed to GitHub"
fi

# Success message
echo ""
echo "🎉 SUCCESS! Your Pet Support App is now on GitHub!"
echo ""
echo "Repository URL: $REPO_URL"
echo ""
echo "Next steps:"
echo "1. Visit your repository: $REPO_URL"
echo "2. Set up GitHub Actions secrets in repository settings"
echo "3. Enable GitHub Actions for CI/CD pipeline"
echo "4. Configure branch protection rules"
echo "5. Add collaborators if needed"
echo ""
echo "Required secrets for CI/CD:"
echo "- DATABASE_URL"
echo "- JWT_SECRET"
echo "- OPENAI_API_KEY"
echo "- GOOGLE_MAPS_API_KEY"
echo "- CLOUDINARY_CLOUD_NAME"
echo "- CLOUDINARY_API_KEY"
echo "- CLOUDINARY_API_SECRET"
echo "- FCM_SERVER_KEY"
echo "- SENDGRID_API_KEY"
echo ""
print_info "Happy coding! 🚀"