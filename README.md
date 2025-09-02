# College Bus Tracking System

A comprehensive Flutter application with Firebase integration for tracking college buses in real-time.

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