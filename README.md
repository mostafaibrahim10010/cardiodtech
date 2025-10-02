# CardioDTech - Advanced Cardiovascular Health Monitoring App

<div align="center">
  <img src="assets/Images/main_logo.png" alt="CardioDTech Logo" width="200" height="200">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue.svg)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
  [![Health Connect](https://img.shields.io/badge/Health%20Connect-Integrated-green.svg)](https://developer.android.com/health-and-fitness/guides/health-connect)
  [![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)
</div>

## 🏥 Overview

CardioDTech is a comprehensive Flutter-based mobile application designed for cardiovascular health monitoring and patient management. The app integrates with Android Health Connect to provide real-time health data visualization, patient profile management, and AI-powered health insights for medical professionals.

## ✨ Key Features

### 🔐 Authentication & Security
- **Firebase Authentication** with email/password and Google Sign-In
- **Secure user management** with role-based access control
- **Robust error handling** for authentication flows

### 📊 Health Data Integration
- **Android Health Connect integration** for real-time health monitoring
- **Comprehensive health metrics** including:
  - Heart rate monitoring with live updates
  - Blood oxygen saturation (SpO2)
  - Daily calorie burn tracking
  - Sleep pattern analysis
  - Step counting and distance tracking
  - Workout data integration

### 👥 Patient Management
- **Patient profile requests** with approval workflow
- **Accepted patients dashboard** with search functionality
- **Detailed patient profiles** with health data visualization
- **Real-time health status monitoring**

### 🤖 AI-Powered Insights
- **Intelligent health analysis** based on collected data
- **Health status predictions** with visual indicators
- **Automated health trend analysis**

### 📱 Modern UI/UX
- **Material Design 3** with custom theming
- **Responsive layouts** for various screen sizes
- **Real-time data visualization** with charts and graphs
- **Intuitive navigation** with bottom tab bar
- **Pull-to-refresh** functionality for data updates

## 🛠️ Technical Stack

### Core Technologies
- **Flutter 3.9.0** - Cross-platform mobile development
- **Dart** - Programming language
- **Firebase** - Backend services and authentication
- **Android Health Connect** - Health data integration

### Key Dependencies
```yaml
# UI & Styling
google_fonts: ^6.3.2
hexcolor: ^3.0.1
fl_chart: ^1.1.1
percent_indicator: ^4.2.5

# State Management
bloc: ^8.1.4
flutter_bloc: ^8.1.6

# Health & Permissions
health: ^13.2.0
permission_handler: ^11.3.1

# Firebase
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
google_sign_in: ^6.2.1

# Local Storage
sqflite: ^2.4.2
shared_preferences: ^2.2.2

# Notifications
flutter_local_notifications: ^17.2.2

# AI Integration
google_generative_ai: ^0.4.4
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Android Studio or VS Code with Flutter extensions
- Android device with Health Connect installed (for health data)
- Firebase project configured

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/cardiodtech.git
   cd cardiodtech
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication and configure sign-in methods

4. **Configure Health Connect**
   - Ensure Health Connect is installed on your Android device
   - Grant necessary permissions for health data access

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 App Architecture

### Project Structure
```
lib/
├── core/
│   └── di/                    # Dependency injection
├── Screens/
│   ├── Auth/                  # Authentication screens
│   ├── Settings/              # Settings and configuration
│   ├── home.dart              # Main dashboard
│   ├── patient_requests_screen.dart
│   ├── accepted_patients_screen.dart
│   └── patient_detail_screen.dart
├── UI/
│   └── Components/            # Reusable UI components
├── Utils/
│   ├── auth_wrapper.dart      # Authentication state management
│   ├── firebase_auth_service.dart
│   ├── google_auth_service.dart
│   ├── health_service.dart    # Health Connect integration
│   └── main_variables.dart    # App constants and themes
└── main.dart                  # App entry point
```

### Key Services

#### HealthService
- Manages Android Health Connect integration
- Handles permission requests and data retrieval
- Provides real-time health data processing
- Includes comprehensive error handling and diagnostics

#### FirebaseAuthService
- Manages user authentication
- Handles email/password and Google Sign-In
- Provides user profile management
- Includes robust error handling

#### GoogleAuthService
- Unified Google Sign-In implementation
- Handles authentication state management
- Provides Firebase credential integration

## 🔧 Configuration

### Environment Setup
1. **Android Configuration**
   - Minimum SDK: 21 (Android 5.0)
   - Target SDK: 34 (Android 14)
   - Health Connect permissions configured

2. **Firebase Configuration**
   - Authentication enabled
   - Google Sign-In configured
   - Security rules implemented

3. **Health Connect Setup**
   - Required permissions declared
   - Data types configured
   - Privacy policy implemented

## 📊 Health Data Features

### Supported Health Metrics
- **Heart Rate**: Real-time BPM monitoring with live status indicators
- **Blood Oxygen**: SpO2 percentage with circular progress indicators
- **Calories**: Daily calorie burn tracking with progress visualization
- **Sleep**: Sleep duration tracking with health insights
- **Activity**: Steps and distance monitoring
- **Workouts**: Exercise session tracking

### Data Visualization
- **Real-time charts** using FL Chart library
- **Circular progress indicators** for health metrics
- **Live status indicators** showing data freshness
- **Time-based data formatting** for user-friendly timestamps

## 🔒 Privacy & Security

### Data Protection
- **Local data encryption** using SQLite
- **Secure API communication** with Firebase
- **Health data privacy** compliance with Android Health Connect
- **User consent** for health data access

### Permission Management
- **Runtime permission requests** for health data
- **Granular permission control** for different data types
- **User-friendly permission explanations**
- **Fallback handling** for denied permissions

## 🧪 Testing

### Running Tests
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Test Coverage
- Unit tests for service classes
- Widget tests for UI components
- Integration tests for health data flow
- Authentication flow testing

## 🚀 Deployment

### Android Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### Build Configuration
- **ProGuard** rules for code obfuscation
- **Signing configuration** for release builds
- **App icons** and splash screens configured
- **Version management** with semantic versioning

## 🤝 Contributing

### Development Guidelines
1. Follow Flutter/Dart style guidelines
2. Write comprehensive tests for new features
3. Update documentation for API changes
4. Use conventional commit messages
5. Ensure all health data features are properly tested

### Code Style
- Use `flutter analyze` to check code quality
- Follow the existing project structure
- Implement proper error handling
- Add comprehensive logging for debugging

## 📄 License

This project is proprietary and confidential. All rights reserved.

## 🆘 Support

### Common Issues
1. **Health Connect not available**: Ensure Health Connect is installed from Google Play Store
2. **Permission denied**: Check device settings for health permissions
3. **Firebase authentication failed**: Verify google-services.json configuration
4. **No health data**: Ensure fitness tracker is connected and syncing

### Getting Help
- Check the [Issues](https://github.com/your-username/cardiodtech/issues) page
- Review the [Wiki](https://github.com/your-username/cardiodtech/wiki) for detailed documentation
- Contact the development team for technical support

## 🔮 Roadmap

### Upcoming Features
- [ ] iOS HealthKit integration
- [ ] Advanced AI health predictions
- [ ] Telemedicine video calls
- [ ] Medication reminder system
- [ ] Health report generation
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Offline data synchronization

### Version History
- **v1.0.0** - Initial release with core health monitoring features
- **v1.1.0** - Enhanced patient management and UI improvements
- **v1.2.0** - AI-powered health insights and predictions

---

<div align="center">
  <p>Built with ❤️ for better cardiovascular health monitoring</p>
  <p>© 2025 CardioDTech. All rights reserved.</p>
</div>
