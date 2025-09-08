# upashtit2 - College Bus Tracking System

A comprehensive Flutter application with Firebase integration for tracking college buses in real-time.

## 🚀 Quick Setup

### Automated Setup
Run the provided batch script:
```bash
.\setup_app.bat
```

### Manual Setup
1. Get dependencies: `flutter pub get`
2. Generate app icons: `flutter pub run flutter_launcher_icons`
3. Run the app: `flutter run`

## ✅ Pre-configured Settings

- **App Name**: upashtit2
- **Google Maps API Key**: AIzaSyAW4daIcQZHGeusF8VeqtrsStvpM1HMKjE (already configured)
- **App Icon**: Using upasthit_logo.jpg from assets
- **Firebase**: Debug logging enabled for troubleshooting
- **Fixed Issue**: Counter app interface replaced with proper bus tracking interface

## Features

### User Roles
- **Admin**: Manage all users, approve coordinators
- **Bus Coordinators**: Create buses and routes, approve drivers/teachers
- **Drivers**: Share location, track assigned buses
- **Teachers**: View bus locations, approve students
- **Students**: Track bus locations

### Core Functionality
- Role-based authentication and registration
- Real-time location tracking
- Bus and route management
- Multi-level approval system
- Google Maps integration
- Persistent data storage

## Setup Instructions

### 1. Firebase Configuration
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password)
3. Create Firestore Database
4. Enable Realtime Database
5. Add your app to Firebase project
6. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
7. Update `lib/firebase_options.dart` with your project configuration

### 2. Google Maps Setup
1. Enable Google Maps SDK in Google Cloud Console
2. Create API key with Maps SDK enabled
3. Add API key to:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`

### 3. Dependencies
Run the following command to install dependencies:
```bash
flutter pub get
```

## 🐛 Debug Logging

The app now includes comprehensive debug logging for troubleshooting:

- 🔥 **Firebase Initialization**: Shows success/failure of Firebase setup
- 🔍 **Authentication State**: Tracks user login status and session checks  
- 👤 **User Management**: Logs user data loading and role assignments
- 🏗️ **App Navigation**: Shows which screen is being loaded
- 📱 **SharedPreferences**: Tracks local storage operations

### Console Output Examples:
```
🔥 Initializing Firebase...
✅ Firebase initialized successfully
🔍 Checking authentication state...
🔐 No user authenticated, showing login screen...
```

Check your IDE's debug console or device logs for detailed information.

### 4. Permissions
The app requires location permissions for real-time tracking. These are already configured in the manifest files.

## Usage

### First Time Setup
1. Register as Admin using any email
2. Create Bus Coordinators
3. Coordinators create buses and routes
4. Assign drivers to buses
5. Teachers and students can then track buses

### User Registration Flow
- **College Email**: Automatic verification
- **Personal Email**: Requires approval from appropriate role

### Location Sharing
- Drivers can start/stop location sharing
- Real-time updates visible to teachers and students
- Map shows current bus location and route

## Architecture

The app follows clean architecture principles with:
- **Models**: Data structures for users, buses, routes, locations
- **Services**: Firebase integration, location services
- **Providers**: State management using Provider pattern
- **Screens**: UI components organized by functionality
- **Widgets**: Reusable UI components

## Security Features
- Role-based access control
- Email verification system
- Multi-level approval workflow
- Secure Firebase rules (to be configured)

## Future Enhancements
- Push notifications for bus arrivals
- Estimated arrival times
- Route optimization
- Offline support
- Analytics dashboard