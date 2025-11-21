# Pet Support App Backend

Backend API server for the First-Time Pet Owner Support App built with Node.js, Express, and PostgreSQL.

## 🚀 Features

- **User Authentication** - JWT-based authentication with email verification
- **Pet Management** - CRUD operations for pet profiles
- **Health Tracking** - Weight logs, vaccination records, health history
- **AI Chat Integration** - Conversational AI support for pet care questions
- **Care Plans** - Personalized care schedules and tasks
- **Emergency Triage** - Symptom assessment and urgency classification
- **Resource Finder** - Location-based discovery of pet services
- **Reminders** - Scheduled notifications for pet care activities

## 📋 Prerequisites

- Node.js 16+ and npm
- PostgreSQL 13+
- Redis (optional, for caching)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pet-support-app/backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   
   Edit the `.env` file with your configuration:
   ```env
   # Server Configuration
   NODE_ENV=development
   PORT=3000
   ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=pet_support
   DB_USER=postgres
   DB_PASSWORD=your_password

   # JWT Configuration
   JWT_SECRET=your_super_secret_jwt_key_here
   JWT_EXPIRES_IN=7d
   JWT_REFRESH_EXPIRES_IN=30d

   # External API Keys
   OPENAI_API_KEY=your_openai_api_key
   CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
   CLOUDINARY_API_KEY=your_cloudinary_api_key
   CLOUDINARY_API_SECRET=your_cloudinary_api_secret
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. **Set up the database**
   ```bash
   # Create database
   createdb pet_support
   
   # Run migrations
   npm run migrate
   
   # Seed with sample data (optional)
   npm run seed
   ```

## 🏃‍♂️ Running the Server

### Development Mode
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` (or your configured PORT).

## 📚 API Documentation

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | User registration |
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/refresh` | Refresh access token |
| POST | `/api/auth/logout` | User logout |
| POST | `/api/auth/send-verification` | Send email verification |
| POST | `/api/auth/verify-email` | Verify email |
| POST | `/api/auth/forgot-password` | Send password reset |
| POST | `/api/auth/reset-password` | Reset password |
| POST | `/api/auth/change-password` | Change password |
| GET | `/api/auth/profile` | Get user profile |
| PUT | `/api/auth/profile` | Update user profile |

### Pet Management Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/pets` | Get user's pets |
| POST | `/api/pets` | Add new pet |
| GET | `/api/pets/:id` | Get pet details |
| PUT | `/api/pets/:id` | Update pet information |
| DELETE | `/api/pets/:id` | Delete pet |

### Health Tracking Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health/records/:petId` | Get pet's health records |
| POST | `/api/health/records/:petId` | Add health record |
| GET | `/api/health/weight/:petId` | Get weight history |
| POST | `/api/health/weight/:petId` | Log weight |

### AI Chat Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/ai/chat` | Send message to AI assistant |
| POST | `/api/ai/analyze-image` | Analyze pet photo/video |
| POST | `/api/ai/emergency-triage` | Get emergency assessment |
| GET | `/api/ai/conversations` | Get user's conversations |
| POST | `/api/ai/conversations` | Create new conversation |
| GET | `/api/ai/conversations/:id/messages` | Get conversation messages |

### Care Plans Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/care-plans/pet/:petId` | Get pet's care plans |
| POST | `/api/care-plans/pet/:petId` | Create care plan |
| GET | `/api/care-plans/:id` | Get care plan details |
| PUT | `/api/care-plans/:id` | Update care plan |
| DELETE | `/api/care-plans/:id` | Delete care plan |
| POST | `/api/care-plans/:id/tasks` | Add task to care plan |
| PUT | `/api/care-plans/tasks/:taskId` | Complete task |

### Resource Finder Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/resources/nearby` | Find nearby resources |
| GET | `/api/resources/search` | Search resources |
| GET | `/api/resources/:id` | Get resource details |
| POST | `/api/resources/:id/reviews` | Add review |
| GET | `/api/resources/:id/reviews` | Get resource reviews |

### Reminders Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reminders` | Get user reminders |
| POST | `/api/reminders` | Create reminder |
| GET | `/api/reminders/:id` | Get reminder details |
| PUT | `/api/reminders/:id` | Update reminder |
| DELETE | `/api/reminders/:id` | Delete reminder |
| POST | `/api/reminders/:id/complete` | Mark reminder as completed |
| GET | `/api/reminders/upcoming` | Get upcoming reminders |

## 🔒 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## 🧪 Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch
```

## 📝 Scripts

| Command | Description |
|---------|-------------|
| `npm start` | Start production server |
| `npm run dev` | Start development server with nodemon |
| `npm test` | Run tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run migrate` | Run database migrations |
| `npm run seed` | Seed database with sample data |

## 🏗️ Project Structure

```
backend/
├── src/
│   ├── controllers/         # Route handlers
│   ├── middleware/          # Custom middleware
│   ├── models/              # Database models
│   ├── routes/              # API routes
│   ├── services/            # Business logic
│   ├── utils/               # Utility functions
│   └── app.js               # Express app setup
├── migrations/              # Database migrations
├── scripts/                 # Development scripts
├── tests/                   # Test files
├── package.json
├── .env.example
└── README.md
```

## 🔧 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `NODE_ENV` | Environment (development/production) | No |
| `PORT` | Server port | No |
| `DB_HOST` | Database host | Yes |
| `DB_PORT` | Database port | Yes |
| `DB_NAME` | Database name | Yes |
| `DB_USER` | Database user | Yes |
| `DB_PASSWORD` | Database password | Yes |
| `JWT_SECRET` | JWT signing secret | Yes |
| `OPENAI_API_KEY` | OpenAI API key | Yes |
| `CLOUDINARY_*` | Cloudinary configuration | Yes |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | Yes |

## 🚨 Error Handling

The API uses standard HTTP status codes and returns error responses in the following format:

```json
{
  "error": "Error message",
  "message": "Detailed error description",
  "timestamp": "2023-01-01T00:00:00.000Z",
  "path": "/api/endpoint"
}
```

## 📊 Database Schema

The application uses PostgreSQL with the following main tables:
- `users` - User accounts and profiles
- `pets` - Pet profiles
- `health_records` - Pet health and medical records
- `care_plans` - Personalized care schedules
- `local_resources` - Pet services and businesses
- `reminders` - Scheduled notifications
- `chat_conversations` - AI chat sessions
- `emergency_triage` - Emergency assessment records

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.