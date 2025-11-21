# Pet Support App - Testing Guide

## 🚀 Quick Start Testing Guide

This guide will help you test the Pet Support App locally before deploying to Google Play Store or iOS App Store.

## 📋 Prerequisites

### Required Software
1. **Node.js** (v18 or higher)
2. **PostgreSQL** (v15 or higher)
3. **Flutter SDK** (v3.16.0 or higher)
4. **Android Studio** (for Android development)
5. **Xcode** (for iOS development, macOS only)
6. **Git** for version control

### Required Accounts/API Keys
1. **OpenAI API Key** - For AI chat functionality
2. **Google Maps API Key** - For location services
3. **Cloudinary Account** - For image storage
4. **Firebase Project** - For push notifications
5. **SendGrid Account** - For email services

## 🛠️ Backend Setup & Testing

### 1. Database Setup

```bash
# Install PostgreSQL
# On Ubuntu/Debian:
sudo apt update
sudo apt install postgresql postgresql-contrib

# On macOS (with Homebrew):
brew install postgresql
brew services start postgresql

# Create database
sudo -u postgres createdb pet_support_app
sudo -u postgres createuser pet_support_user
sudo -u postgres psql
ALTER USER pet_support_user PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE pet_support_app TO pet_support_user;
\q
```

### 2. Backend Configuration

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment template
cp .env.example .env

# Edit .env file with your configuration
nano .env
```

**Required .env variables:**
```env
# Database
DATABASE_URL=postgresql://pet_support_user:your_password@localhost:5432/pet_support_app

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=7d

# OpenAI
OPENAI_API_KEY=your-openai-api-key-here

# Google Maps
GOOGLE_MAPS_API_KEY=your-google-maps-api-key-here

# Cloudinary
CLOUDINARY_CLOUD_NAME=your-cloudinary-cloud-name
CLOUDINARY_API_KEY=your-cloudinary-api-key
CLOUDINARY_API_SECRET=your-cloudinary-api-secret

# Firebase
FCM_SERVER_KEY=your-firebase-server-key

# Email (SendGrid)
SENDGRID_API_KEY=your-sendgrid-api-key
EMAIL_FROM=noreply@petsupport.app

# App Configuration
NODE_ENV=development
PORT=3000
FRONTEND_URL=http://localhost:3000
```

### 3. Run Database Migrations

```bash
# Run migrations
npm run migrate

# Seed database with sample data
npm run seed
```

### 4. Start Backend Server

```bash
# Development mode
npm run dev

# Production mode
npm start
```

### 5. Test Backend Endpoints

**Using curl:**
```bash
# Test health endpoint
curl http://localhost:3000/health

# Test registration
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!",
    "firstName": "Test",
    "lastName": "User"
  }'

# Test login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123!"
  }'
```

**Using Postman/Insomnia:**
1. Import the API collection from `docs/api-collection.json`
2. Set base URL to `http://localhost:3000`
3. Test each endpoint with the provided examples

## 📱 Mobile App Setup & Testing

### 1. Flutter Environment Setup

```bash
# Check Flutter installation
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses

# Install dependencies
cd mobile
flutter pub get
```

### 2. Android Setup

```bash
# Navigate to mobile directory
cd mobile

# Create local.properties file
echo "flutter.sdk=/path/to/flutter/sdk" > android/local.properties

# Create debug keystore
keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000

# Update android/app/build.gradle with keystore info
```

### 3. iOS Setup (macOS only)

```bash
# Navigate to iOS directory
cd mobile/ios

# Install CocoaPods
sudo gem install cocoapods
pod install

# Open in Xcode
open Runner.xcworkspace
```

### 4. Configure Mobile App

Create `mobile/lib/core/config/app_config.dart`:
```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String openAIKey = 'your-openai-api-key-here';
  static const String googleMapsApiKey = 'your-google-maps-api-key-here';
  static const bool enableLogging = true;
}
```

### 5. Run Mobile App

**Android:**
```bash
# Connect Android device or start emulator
flutter devices

# Run app
flutter run -d android
```

**iOS:**
```bash
# Connect iOS device or start simulator
flutter devices

# Run app
flutter run -d ios
```

**Web (for testing):**
```bash
flutter run -d web-server --web-port 8080
```

## 🧪 Comprehensive Testing Checklist

### 1. Authentication Testing

#### Registration Flow
- [ ] User can register with valid email and password
- [ ] Validation works for invalid email format
- [ ] Validation works for weak password
- [ ] Duplicate email registration is prevented
- [ ] Email verification is sent
- [ ] User can verify email
- [ ] User cannot login without verification

#### Login Flow
- [ ] User can login with correct credentials
- [ ] Error shown for incorrect email
- [ ] Error shown for incorrect password
- [ ] Remember me functionality works
- [ ] Biometric login works (if available)
- [ ] Logout functionality works

#### Password Reset
- [ ] User can request password reset
- [ ] Reset email is received
- [ ] User can reset password with valid token
- [ ] Error shown for invalid token
- [ ] New password must meet requirements

### 2. Pet Management Testing

#### Pet Creation
- [ ] User can add new pet with all required fields
- [ ] Photo upload works correctly
- [ ] Validation prevents empty required fields
- [ ] Pet profile is saved correctly
- [ ] Multiple pets can be added

#### Pet Viewing & Editing
- [ ] Pet list displays all user's pets
- [ ] Pet details show correctly
- [ ] Pet information can be edited
- [ ] Pet can be deleted
- [ ] Pet photos can be updated

### 3. AI Chat Testing

#### Basic Chat
- [ ] Chat interface loads correctly
- [ ] User can send text messages
- [ ] AI responds appropriately
- [ ] Chat history is maintained
- [ ] Messages are timestamped

#### Image Analysis
- [ ] User can upload images
- [ ] Image analysis works
- [ ] Results are displayed clearly
- [ ] Error handling for invalid images

### 4. Health Tracking Testing

#### Weight Tracking
- [ ] User can add weight entries
- [ ] Weight chart displays correctly
- [ ] Historical data is preserved
- [ ] Data syncs with backend

#### Health Records
- [ ] User can add health records
- [ ] Documents can be uploaded
- [ ] Records are categorized correctly
- [ ] Search functionality works

### 5. Emergency Triage Testing

#### Symptom Assessment
- [ ] Symptom selection works
- [ ] Assessment questions are relevant
- [ ] Urgency level is calculated correctly
- [ ] Emergency contacts are displayed

#### Emergency Features
- [ ] Emergency call button works
- [ ] First aid guidance is helpful
- [ ] Location-based emergency services show

### 6. Resource Finder Testing

#### Location Services
- [ ] App requests location permission
- [ ] Current location is detected
- [ ] Manual location entry works
- [ ] Location privacy is respected

#### Resource Discovery
- [ ] Resources load correctly
- [ ] Search functionality works
- [ ] Filters work properly
- [ ] Map integration works
- [ ] Reviews and ratings display

### 7. Data Synchronization Testing

#### Offline Functionality
- [ ] App works without internet
- [ ] Data is saved locally
- [ ] Sync occurs when connection restored
- [ ] Conflict resolution works

#### Backend Sync
- [ ] Data syncs to backend
- [ ] Changes reflect across devices
- [ ] Sync status is indicated
- [ ] Manual sync works

### 8. Notifications Testing

#### Push Notifications
- [ ] Permission request works
- [ ] Notifications are received
- [ ] Notification content is correct
- [ ] Deep linking from notifications works

#### In-App Notifications
- [ ] Reminders are scheduled
- [ ] Reminders trigger correctly
- [ ] Notification settings work
- [ ] Quiet hours are respected

## 🔧 Debugging Tools

### Backend Debugging

```bash
# Enable debug logging
DEBUG=* npm run dev

# Check database connection
npm run db:test

# Run specific tests
npm test -- --grep "authentication"

# Check API documentation
http://localhost:3000/api-docs
```

### Mobile Debugging

```bash
# Flutter logs
flutter logs

# Debug mode
flutter run --debug

# Profile mode
flutter run --profile

# Hot reload
flutter run --hot
```

### Browser Testing (Web)

```bash
# Run web version
flutter run -d web-server

# Open Chrome DevTools
flutter run -d web-server --web-port 8080
# Then open Chrome DevTools for debugging
```

## 🐛 Common Issues & Solutions

### Backend Issues

**Database Connection Error:**
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connection
psql -h localhost -U pet_support_user -d pet_support_app
```

**API Key Errors:**
- Verify all API keys in .env file
- Check API key permissions and quotas
- Ensure network connectivity

### Mobile Issues

**Build Failures:**
```bash
# Clean Flutter
flutter clean
flutter pub get

# Clean Android
cd android
./gradlew clean
cd ..

# Clean iOS (macOS only)
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**Emulator Issues:**
```bash
# List available emulators
flutter emulators

# Start specific emulator
flutter emulators --launch <emulator_name>

# Create new emulator
flutter emulators --create
```

**Permission Issues:**
- Check AndroidManifest.xml for required permissions
- Verify Info.plist for iOS permissions
- Test permission flows manually

## 📊 Performance Testing

### Backend Performance

```bash
# Load testing with artillery
npm install -g artillery
artillery run load-test.yml

# Database query analysis
npm run db:analyze

# Memory usage monitoring
npm run monitor
```

### Mobile Performance

```bash
# Flutter performance profiling
flutter run --profile
# Then use Flutter DevTools

# Memory profiling
flutter run --profile --trace-startup
```

## 🔒 Security Testing

### Backend Security

```bash
# Run security audit
npm audit

# Check for vulnerabilities
npm audit fix

# Test authentication endpoints
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@test.com", "password": "admin"}'
```

### Mobile Security

```bash
# Check for hardcoded secrets
grep -r "password\|secret\|key" mobile/lib/

# Check network security
flutter run --debug
# Monitor network requests in DevTools
```

## 📱 Device Testing

### Required Devices for Testing

**Android:**
- [ ] Low-end device (2GB RAM, Android 8.0)
- [ ] Mid-range device (4GB RAM, Android 10.0)
- [ ] High-end device (8GB RAM, Android 12.0+)
- [ ] Tablet device

**iOS:**
- [ ] iPhone (2-3 years old)
- [ ] Current iPhone model
- [ ] iPad (if supporting tablets)

### Testing Checklist per Device

- [ ] App installs correctly
- [ ] Performance is acceptable
- [ ] UI displays correctly
- [ ] All features work
- [ ] No crashes or freezes
- [ ] Battery usage is reasonable
- [ ] Memory usage is acceptable

## 🚀 Pre-Deployment Checklist

### Backend
- [ ] All tests pass
- [ ] Security audit passed
- [ ] Performance benchmarks met
- [ ] Database is optimized
- [ ] API documentation is complete
- [ ] Error handling is comprehensive
- [ ] Logging is implemented
- [ ] Monitoring is configured

### Mobile
- [ ] All tests pass on target devices
- [ ] App store guidelines are met
- [ ] Privacy policy is included
- [ ] Terms of service are included
- [ ] App icons and screenshots are ready
- [ ] Store listing is complete
- [ ] Build is optimized for size
- [ ] Crash reporting is configured

## 📞 Support During Testing

If you encounter issues during testing:

1. **Check logs** for error messages
2. **Review documentation** for configuration details
3. **Test components individually** to isolate issues
4. **Check network connectivity** and API key validity
5. **Verify database setup** and migrations
6. **Test with different data** to identify edge cases

## 🎯 Next Steps After Testing

Once testing is complete and all issues are resolved:

1. **Finalize app store assets** (icons, screenshots, descriptions)
2. **Prepare release builds** (signed APK/IPA)
3. **Set up app store accounts** (Google Play Console, App Store Connect)
4. **Submit for review** with proper documentation
5. **Monitor post-launch performance** and user feedback

Good luck with your testing! 🚀