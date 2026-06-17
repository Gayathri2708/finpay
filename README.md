# FinPay

A fintech wallet application built with Flutter, following Clean Architecture principles.

## Tech Stack

- **Flutter** 3.38.6 / **Dart** 3.10.7
- **State Management:** BLoC (flutter_bloc)
- **Navigation:** GoRouter with auth-aware redirects
- **Dependency Injection:** GetIt
- **Networking:** Dio with interceptors for auth token management
- **Security:** flutter_secure_storage for token persistence
- **Architecture:** Clean Architecture (Domain → Data → Presentation)

## Project Structure

```
lib/
├── core/
│   ├── constants/       # API endpoints, app constants, colors
│   ├── di/              # Dependency injection setup
│   ├── errors/          # Failure and exception classes
│   ├── network/         # Dio API client with auth interceptor
│   ├── router/          # GoRouter configuration
│   └── theme/           # App theme with Material 3
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/   # Remote & local data sources
│   │   │   ├── models/        # Data models (JSON serialization)
│   │   │   └── repositories/  # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/      # Business entities
│   │   │   ├── repositories/  # Repository contracts
│   │   │   └── usecases/      # Login, Register, Logout, CheckAuth
│   │   └── presentation/
│   │       ├── bloc/          # AuthBloc, events, states
│   │       ├── pages/         # Login & Register pages
│   │       └── widgets/       # Reusable auth widgets
│   └── home/
│       └── presentation/
│           └── pages/         # Home page with wallet UI
└── main.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38.6+
- Dart SDK 3.10.7+

### Installation

```bash
git clone https://github.com/<your-username>/finpay.git
cd finpay
flutter pub get
flutter run
```

## Features (Phase 1)

- User authentication (Login / Register) with form validation
- Secure token storage with automatic refresh
- Auth-guarded navigation
- Home screen with balance card and quick actions
- Clean Architecture with separation of concerns
- Reusable UI components

## Roadmap

- [ ] Backend API integration
- [ ] Transaction history
- [ ] Send / Receive money
- [ ] Profile management
- [ ] Biometric authentication
- [ ] Push notifications

## License

This project is proprietary and confidential.
