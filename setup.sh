#!/bin/bash

# Pet Support App - Quick Setup Script
# This script helps you set up the development environment quickly

set -e

echo "🚀 Pet Support App - Quick Setup"
echo "=================================="

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

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_status "Node.js installed: $NODE_VERSION"
    else
        print_error "Node.js is not installed. Please install Node.js v18 or higher."
        exit 1
    fi
    
    # Check npm
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_status "npm installed: $NPM_VERSION"
    else
        print_error "npm is not installed."
        exit 1
    fi
    
    # Check Flutter
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_status "Flutter installed: $FLUTTER_VERSION"
    else
        print_error "Flutter is not installed. Please install Flutter SDK."
        exit 1
    fi
    
    # Check PostgreSQL
    if command -v psql &> /dev/null; then
        POSTGRES_VERSION=$(psql --version)
        print_status "PostgreSQL installed: $POSTGRES_VERSION"
    else
        print_warning "PostgreSQL is not installed. Please install PostgreSQL v15 or higher."
        print_info "You can install it later and run this script again."
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version)
        print_status "Git installed: $GIT_VERSION"
    else
        print_error "Git is not installed."
        exit 1
    fi
}

# Setup backend
setup_backend() {
    print_info "Setting up backend..."
    
    if [ ! -d "backend" ]; then
        print_error "Backend directory not found. Please run this script from the project root."
        exit 1
    fi
    
    cd backend
    
    # Install dependencies
    print_info "Installing Node.js dependencies..."
    npm install
    
    # Copy environment file
    if [ ! -f ".env" ]; then
        print_info "Creating environment file..."
        cp .env.example .env
        print_warning "Please edit backend/.env file with your API keys and database configuration."
    else
        print_status "Environment file already exists."
    fi
    
    # Install global dependencies
    print_info "Installing global dependencies..."
    npm install -g nodemon
    npm install -g artillery
    
    cd ..
    print_status "Backend setup completed."
}

# Setup mobile app
setup_mobile() {
    print_info "Setting up mobile app..."
    
    if [ ! -d "mobile" ]; then
        print_error "Mobile directory not found. Please run this script from the project root."
        exit 1
    fi
    
    cd mobile
    
    # Install Flutter dependencies
    print_info "Installing Flutter dependencies..."
    flutter pub get
    
    # Create local.properties for Android
    if [ ! -f "android/local.properties" ]; then
        print_info "Creating Android local.properties file..."
        echo "flutter.sdk=$(flutter sdk-path)" > android/local.properties
    fi
    
    # Install CocoaPods for iOS (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v pod &> /dev/null; then
            print_info "Installing iOS dependencies..."
            cd ios
            pod install
            cd ..
        else
            print_warning "CocoaPods is not installed. Please install it for iOS development."
        fi
    fi
    
    cd ..
    print_status "Mobile app setup completed."
}

# Setup database
setup_database() {
    print_info "Setting up database..."
    
    if command -v psql &> /dev/null; then
        # Check if PostgreSQL is running
        if pg_isready -q; then
            print_info "PostgreSQL is running."
            
            # Create database and user (you may need to adjust these commands)
            print_info "Creating database and user..."
            sudo -u postgres psql -c "CREATE DATABASE pet_support_app;" 2>/dev/null || print_warning "Database may already exist."
            sudo -u postgres psql -c "CREATE USER pet_support_user WITH PASSWORD 'pet_support_password';" 2>/dev/null || print_warning "User may already exist."
            sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE pet_support_app TO pet_support_user;" 2>/dev/null
            
            # Run migrations
            cd backend
            print_info "Running database migrations..."
            npm run migrate
            
            # Seed database
            print_info "Seeding database with sample data..."
            npm run seed
            cd ..
            
            print_status "Database setup completed."
        else
            print_error "PostgreSQL is not running. Please start PostgreSQL service."
            print_info "On Ubuntu: sudo systemctl start postgresql"
            print_info "On macOS: brew services start postgresql"
        fi
    else
        print_warning "PostgreSQL is not installed. Skipping database setup."
    fi
}

# Create development scripts
create_dev_scripts() {
    print_info "Creating development scripts..."
    
    # Create start-backend script
    cat > start-backend.sh << 'EOF'
#!/bin/bash
cd backend
npm run dev
EOF
    chmod +x start-backend.sh
    
    # Create start-mobile script
    cat > start-mobile.sh << 'EOF'
#!/bin/bash
cd mobile
flutter run
EOF
    chmod +x start-mobile.sh
    
    # Create test-backend script
    cat > test-backend.sh << 'EOF'
#!/bin/bash
cd backend
npm test
EOF
    chmod +x test-backend.sh
    
    # Create test-mobile script
    cat > test-mobile.sh << 'EOF'
#!/bin/bash
cd mobile
flutter test
EOF
    chmod +x test-mobile.sh
    
    print_status "Development scripts created."
}

# Display next steps
show_next_steps() {
    print_info "Setup completed! Here's what to do next:"
    echo ""
    echo "1. Configure API Keys:"
    echo "   - Edit backend/.env with your API keys"
    echo "   - Required: OpenAI, Google Maps, Cloudinary, Firebase, SendGrid"
    echo ""
    echo "2. Start Development:"
    echo "   - Backend: ./start-backend.sh"
    echo "   - Mobile: ./start-mobile.sh"
    echo ""
    echo "3. Testing:"
    echo "   - Backend: ./test-backend.sh"
    echo "   - Mobile: ./test-mobile.sh"
    echo ""
    echo "4. For detailed testing instructions, see TESTING_GUIDE.md"
    echo ""
    echo "5. When ready for deployment:"
    echo "   - Backend: npm run build"
    echo "   - Mobile: flutter build apk (Android) or flutter build ios (iOS)"
    echo ""
    print_info "Happy coding! 🎉"
}

# Main execution
main() {
    echo ""
    print_info "This script will set up the Pet Support App development environment."
    print_info "Please make sure you have Node.js, Flutter, and PostgreSQL installed."
    echo ""
    
    read -p "Do you want to continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled."
        exit 0
    fi
    
    check_prerequisites
    setup_backend
    setup_mobile
    setup_database
    create_dev_scripts
    show_next_steps
}

# Run main function
main "$@"