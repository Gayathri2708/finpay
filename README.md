# FinPay

A full-stack fintech wallet application with a Flutter mobile client and Node.js backend, following Clean Architecture principles.

## Tech Stack

### Mobile (Flutter)
- **Flutter** 3.38.6 / **Dart** 3.10.7
- **State Management:** BLoC (flutter_bloc)
- **Navigation:** GoRouter with auth-aware redirects and session guards
- **Dependency Injection:** GetIt
- **Networking:** Dio with JWT interceptor, SSL pinning, token refresh
- **Security:** flutter_secure_storage, biometric auth (local_auth), PIN lock
- **Push Notifications:** Firebase Messaging + flutter_local_notifications
- **Deep Links:** app_links (finpay:// scheme)
- **Architecture:** Clean Architecture (Domain → Data → Presentation)

### Backend (Node.js)
- **Runtime:** Node.js with TypeScript (strict mode)
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Auth:** JWT (access + refresh tokens), bcrypt password hashing
- **Security:** Helmet, CORS, rate limiting (express-rate-limit)

## Project Structure

```
finpay/
├── lib/                          # Flutter mobile app
│   ├── core/
│   │   ├── constants/            # API endpoints, colors, app config
│   │   ├── deep_link/            # Deep link handling (app_links)
│   │   ├── di/                   # GetIt dependency injection
│   │   ├── errors/               # Failure and exception classes
│   │   ├── network/              # Dio client with SSL pinning
│   │   ├── notifications/        # FCM push notification service
│   │   ├── router/               # GoRouter with auth/session guards
│   │   ├── security/             # Biometric + PIN lock services
│   │   ├── theme/                # Material 3 theme
│   │   └── utils/                # Responsive helpers
│   ├── features/
│   │   ├── auth/                 # Login, Register, Lock Screen
│   │   ├── home/                 # Bottom nav shell (mobile + tablet)
│   │   ├── wallet/               # Balance card, quick actions, shimmer
│   │   ├── transactions/         # History, detail page, pagination
│   │   └── send_money/           # Send money flow with confirmation
│   └── main.dart
│
└── finpay-backend/               # Node.js API server
    └── src/
        ├── config/               # Database connection, env variables
        ├── middleware/            # Auth, validation, rate limiting
        ├── modules/
        │   ├── auth/             # Register, Login, Refresh, Logout
        │   ├── wallet/           # Balance, Send Money (atomic)
        │   ├── transactions/     # Paginated history, detail
        │   └── users/            # Profile, FCM token
        ├── utils/                # JWT helpers, response formatter
        └── app.ts                # Express entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38.6+
- Node.js 18+
- MongoDB (local or Atlas)

### Backend Setup

```bash
cd finpay-backend
cp .env.example .env        # Edit with your MongoDB URI and JWT secrets
npm install
npm run dev                  # Starts on http://localhost:3000
```

### Flutter App Setup

```bash
cd finpay
flutter pub get
flutter run
```

> The Flutter app connects to `http://localhost:3000/api/v1` by default. For a physical device, update `baseUrl` in `lib/core/constants/api_constants.dart` to your machine's local IP.

## API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/register` | No | Create account (₹10,000 starting balance) |
| POST | `/api/v1/auth/login` | No | Authenticate, returns JWT tokens |
| POST | `/api/v1/auth/refresh` | Refresh | Issue new access token |
| POST | `/api/v1/auth/logout` | Yes | Invalidate refresh token |
| GET | `/api/v1/wallet` | Yes | Get wallet balance |
| POST | `/api/v1/wallet/send` | Yes | Transfer money (atomic) |
| GET | `/api/v1/transactions` | Yes | Paginated transaction history |
| GET | `/api/v1/transactions/:id` | Yes | Single transaction detail |
| GET | `/api/v1/users/me` | Yes | User profile |
| PUT | `/api/v1/users/fcm-token` | Yes | Update push notification token |

## Features

### Phase 1 — Auth & Foundation
- User authentication (Login / Register) with form validation
- Secure token storage with automatic refresh
- Auth-guarded navigation via GoRouter
- Clean Architecture with full separation of concerns

### Phase 2 — Wallet Core
- Wallet dashboard with gradient balance card (show/hide toggle)
- Send money flow with confirmation bottom sheet
- Paginated transaction history with infinite scroll
- Offline-first data layer with local caching
- Shimmer loading states and offline banner
- Bottom navigation (Home, History, Profile)

### Phase 3 — Security & Polish
- Biometric authentication (fingerprint / Face ID)
- 6-digit PIN lock screen with 30s lockout after 3 failures
- Session timeout (2 min inactivity → lock screen)
- SSL certificate pinning (release builds)
- FCM push notifications with payload-based navigation
- Deep links (finpay://transaction/, finpay://send/, finpay://home)
- Transaction detail page with share receipt
- Adaptive layout (NavigationRail on tablet, bottom nav on phone)

### Backend
- Express.js REST API with TypeScript
- MongoDB with Mongoose ODM
- JWT authentication (15m access + 7d refresh tokens)
- bcrypt password hashing (12 rounds)
- Atomic money transfers using MongoDB sessions
- Rate limiting (10 req/15m auth, 100 req/15m API)
- Standardized JSON responses
- Input validation with express-validator

## License

This project is proprietary and confidential.
