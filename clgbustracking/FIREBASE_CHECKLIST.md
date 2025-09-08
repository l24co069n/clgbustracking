# ✅ Firebase Setup Checklist

## Pre-Setup
- [ ] Firebase project created
- [ ] Android app added to Firebase project
- [ ] iOS app added to Firebase project

## Configuration Files
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] `GoogleService-Info.plist` downloaded and placed in `ios/Runner/`
- [ ] `firebase_options.dart` updated with actual project values

## Authentication
- [ ] Email/Password authentication enabled
- [ ] Test user registration works
- [ ] Test user login works

## Database
- [ ] Firestore database created
- [ ] Security rules configured (test mode for development)
- [ ] Collections created: `users`, `buses`, `routes`, `locations`

## Testing
- [ ] App runs without Firebase errors
- [ ] Debug console shows "Firebase initialized successfully"
- [ ] User can register and login
- [ ] Data can be written to Firestore

## Production (Before Release)
- [ ] Security rules updated for production
- [ ] Test all user roles and permissions
- [ ] Verify data validation
- [ ] Set up monitoring and alerts

## Quick Test Commands
```bash
# Test the app
flutter run

# Check for errors
flutter doctor

# Clean and rebuild if needed
flutter clean && flutter pub get
```

## Debug Console Messages to Look For
- ✅ "Firebase initialized successfully"
- ✅ "Authentication state checked successfully"
- ❌ Any error messages with Firebase
- ❌ Permission denied errors
