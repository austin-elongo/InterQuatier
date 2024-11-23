# InterQuatier

InterQuatier is an Android application built with Jetpack Compose and Firebase, designed to connect people within neighborhoods and facilitate local community interactions.

## Features

- User Authentication
  - Email/Password Registration
  - Secure Login System
  - Password Recovery
- Profile Management
  - User Profile Creation
  - Profile Editing
  - Age Verification
- Modern UI
  - Material Design 3
  - Dark Theme Support
  - Responsive Layout
  - Gradient Components

## Technologies Used

### Frontend
- Kotlin
- Jetpack Compose
- Material Design 3
- Navigation Compose
- Coil for Image Loading

### Backend & Services
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Firebase Cloud Messaging

### Architecture & Patterns
- MVVM Architecture
- Repository Pattern
- Dependency Injection
- Coroutines for Async Operations
- StateFlow for State Management

## Setup

1. Clone the repository
2. Add Firebase Configuration
   - Create a new project in Firebase Console
   - Add an Android app to your Firebase project
   - Download `google-services.json` and place it in the app directory
   - Enable Authentication and Firestore in Firebase Console

3. Open the project in Android Studio
4. Sync project with Gradle files
5. Run the app on an emulator or physical device

## Requirements

- Android Studio Hedgehog or newer
- JDK 17
- Android SDK 34
- Gradle 8.6
- Minimum Android API Level 24 (Android 7.0)

## Project Structure

```
app/
├── src/
│   ├── main/
│   │   ├── java/com/example/interquatier/
│   │   │   ├── model/
│   │   │   ├── repository/
│   │   │   ├── ui/
│   │   │   │   ├── components/
│   │   │   │   ├── screens/
│   │   │   │   └── theme/
│   │   │   ├── viewmodel/
│   │   │   └── navigation/
│   │   └── res/
│   └── test/
└── build.gradle.kts
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

[Choose a license and add it here] 