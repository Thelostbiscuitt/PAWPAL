# Project Structure

## Overall Project Organization

```
pet-support-app/
├── backend/                 # Node.js/Express API server
├── mobile/                  # Flutter mobile application
├── shared/                  # Shared utilities and types
├── docs/                    # Documentation
├── scripts/                 # Development and deployment scripts
├── docker-compose.yml       # Local development environment
├── README.md               # Project overview and setup instructions
└── .gitignore              # Git ignore file
```

## Backend Structure (Node.js/Express)

```
backend/
├── src/
│   ├── controllers/         # Route handlers
│   │   ├── auth.controller.js
│   │   ├── pet.controller.js
│   │   ├── health.controller.js
│   │   ├── ai.controller.js
│   │   ├── carePlan.controller.js
│   │   ├── resource.controller.js
│   │   └── reminder.controller.js
│   ├── middleware/          # Custom middleware
│   │   ├── auth.middleware.js
│   │   ├── validation.middleware.js
│   │   ├── error.middleware.js
│   │   └── rateLimit.middleware.js
│   ├── models/             # Database models
│   │   ├── User.js
│   │   ├── Pet.js
│   │   ├── HealthRecord.js
│   │   ├── CarePlan.js
│   │   ├── Reminder.js
│   │   └── LocalResource.js
│   ├── routes/             # API route definitions
│   │   ├── auth.routes.js
│   │   ├── pet.routes.js
│   │   ├── health.routes.js
│   │   ├── ai.routes.js
│   │   ├── carePlan.routes.js
│   │   ├── resource.routes.js
│   │   └── reminder.routes.js
│   ├── services/           # Business logic
│   │   ├── ai.service.js
│   │   ├── imageAnalysis.service.js
│   │   ├── carePlan.service.js
│   │   ├── emergencyTriage.service.js
│   │   ├── resourceFinder.service.js
│   │   └── notification.service.js
│   ├── utils/              # Utility functions
│   │   ├── database.js
│   │   ├── logger.js
│   │   ├── validators.js
│   │   └── helpers.js
│   ├── config/             # Configuration files
│   │   ├── database.js
│   │   ├── cloudinary.js
│   │   ├── openai.js
│   │   └── firebase.js
│   └── app.js              # Express app setup
├── tests/                  # Test files
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── migrations/             # Database migrations
├── seeds/                  # Database seed data
├── package.json
├── .env.example
├── Dockerfile
└── README.md
```

## Mobile App Structure (Flutter)

```
mobile/
├── lib/
│   ├── main.dart           # App entry point
│   ├── app/                # App-level configuration
│   │   ├── config/
│   │   │   ├── routes.dart
│   │   │   ├── theme.dart
│   │   │   └── constants.dart
│   │   └── widgets/        # Reusable widgets
│   │       ├── custom_button.dart
│   │       ├── custom_input.dart
│   │       ├── loading_indicator.dart
│   │       └── image_picker.dart
│   ├── core/               # Core functionality
│   │   ├── services/       # API and external services
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── storage_service.dart
│   │   │   └── notification_service.dart
│   │   ├── utils/          # Utility functions
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   └── helpers.dart
│   │   └── constants/      # App constants
│   │       ├── api_endpoints.dart
│   │       ├── colors.dart
│   │       └── strings.dart
│   ├── features/           # Feature modules
│   │   ├── authentication/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── login_form.dart
│   │   │   │   └── register_form.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   ├── pets/
│   │   │   ├── screens/
│   │   │   │   ├── pet_list_screen.dart
│   │   │   │   ├── add_pet_screen.dart
│   │   │   │   └── pet_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── pet_card.dart
│   │   │   │   └── pet_form.dart
│   │   │   ├── providers/
│   │   │   │   └── pet_provider.dart
│   │   │   └── models/
│   │   │       └── pet_model.dart
│   │   ├── ai_chat/
│   │   │   ├── screens/
│   │   │   │   └── chat_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── message_bubble.dart
│   │   │   │   ├── chat_input.dart
│   │   │   │   └── typing_indicator.dart
│   │   │   ├── providers/
│   │   │   │   └── chat_provider.dart
│   │   │   └── models/
│   │   │       └── message_model.dart
│   │   ├── health_tracking/
│   │   │   ├── screens/
│   │   │   │   ├── weight_tracker_screen.dart
│   │   │   │   ├── health_records_screen.dart
│   │   │   │   └── add_health_record_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── weight_chart.dart
│   │   │   │   └── health_record_form.dart
│   │   │   ├── providers/
│   │   │   │   └── health_provider.dart
│   │   │   └── models/
│   │   │       └── health_record_model.dart
│   │   ├── care_plans/
│   │   │   ├── screens/
│   │   │   │   ├── care_plans_screen.dart
│   │   │   │   ├── create_plan_screen.dart
│   │   │   │   └── plan_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── plan_card.dart
│   │   │   │   └── task_checkbox.dart
│   │   │   ├── providers/
│   │   │   │   └── care_plan_provider.dart
│   │   │   └── models/
│   │   │       └── care_plan_model.dart
│   │   ├── emergency/
│   │   │   ├── screens/
│   │   │   │   ├── emergency_triage_screen.dart
│   │   │   │   └── emergency_contacts_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── symptom_checker.dart
│   │   │   │   └── urgency_indicator.dart
│   │   │   ├── providers/
│   │   │   │   └── emergency_provider.dart
│   │   │   └── models/
│   │   │       └── emergency_model.dart
│   │   ├── resources/
│   │   │   ├── screens/
│   │   │   │   ├── resource_finder_screen.dart
│   │   │   │   └── resource_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── resource_map.dart
│   │   │   │   └── resource_card.dart
│   │   │   ├── providers/
│   │   │   │   └── resource_provider.dart
│   │   │   └── models/
│   │   │       └── resource_model.dart
│   │   └── reminders/
│   │       ├── screens/
│   │       │   ├── reminders_screen.dart
│   │       │   └── add_reminder_screen.dart
│   │       ├── widgets/
│   │       │   ├── reminder_card.dart
│   │       │   └── reminder_form.dart
│   │       ├── providers/
│   │       │   └── reminder_provider.dart
│   │       └── models/
│   │           └── reminder_model.dart
│   └── shared/             # Shared components across features
│       ├── models/
│       │   └── base_model.dart
│       ├── widgets/
│       │   ├── custom_app_bar.dart
│       │   ├── bottom_navigation.dart
│       │   └── error_widget.dart
│       └── providers/
│           └── base_provider.dart
├── assets/                 # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/                   # Test files
│   ├── unit/
│   ├── widget/
│   └── integration/
├── pubspec.yaml
├── README.md
└── analysis_options.yaml
```

## Shared Structure

```
shared/
├── types/                  # TypeScript type definitions
│   ├── user.types.ts
│   ├── pet.types.ts
│   ├── health.types.ts
│   └── api.types.ts
├── constants/              # Shared constants
│   ├── api_endpoints.ts
│   ├── error_codes.ts
│   └── validation_rules.ts
├── utils/                  # Shared utility functions
│   ├── validators.ts
│   ├── formatters.ts
│   └── helpers.ts
└── package.json
```

## Documentation Structure

```
docs/
├── api/                    # API documentation
│   ├── authentication.md
│   ├── pets.md
│   ├── health.md
│   ├── ai.md
│   └── resources.md
├── deployment/             # Deployment guides
│   ├── backend.md
│   ├── mobile.md
│   └── ci-cd.md
├── development/            # Development guides
│   ├── setup.md
│   ├── testing.md
│   └── contributing.md
└── user/                   # User documentation
    ├── getting-started.md
    ├── features.md
    └── troubleshooting.md
```

## Scripts Structure

```
scripts/
├── setup/                  # Setup scripts
│   ├── install-dependencies.sh
│   ├── setup-database.sh
│   └── configure-env.sh
├── development/            # Development scripts
│   ├── start-dev.sh
│   ├── run-tests.sh
│   └── lint.sh
├── deployment/            # Deployment scripts
│   ├── build-backend.sh
│   ├── build-mobile.sh
│   └── deploy.sh
└── maintenance/           # Maintenance scripts
    ├── backup-database.sh
    ├── clean-logs.sh
    └── update-dependencies.sh
```

## Key Design Principles

### 1. Modular Architecture
- Each feature is self-contained with its own screens, widgets, providers, and models
- Clear separation of concerns between UI, business logic, and data layers
- Reusable components in the shared directory

### 2. State Management
- Provider pattern for state management in Flutter
- Consistent state structure across all features
- Reactive UI updates based on state changes

### 3. API Design
- RESTful API design with consistent naming conventions
- Proper HTTP status codes and error handling
- Comprehensive API documentation with Swagger

### 4. Code Organization
- Feature-first approach for better scalability
- Consistent naming conventions across the project
- Clear file and folder structure for easy navigation

### 5. Testing Strategy
- Unit tests for business logic and utilities
- Widget tests for UI components
- Integration tests for complete user flows

### 6. Configuration Management
- Environment-specific configurations
- Secure handling of sensitive information
- Centralized configuration management

This structure provides a solid foundation for building a scalable, maintainable, and feature-rich pet support application.