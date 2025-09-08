# 🔥 Firebase Setup Guide for upashtit2

## Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Click "Create a project" or "Add project"

2. **Project Configuration**
   - **Project name**: `upashtit2` (or your preferred name)
   - **Google Analytics**: Enable (recommended)
   - **Analytics account**: Create new or use existing
   - Click "Create project"

3. **Wait for project creation** (1-2 minutes)

## Step 2: Add Android App to Firebase

1. **In Firebase Console**
   - Click the Android icon (🤖) or "Add app"
   - **Android package name**: `com.example.upashtit2`
   - **App nickname**: `upashtit2 Android`
   - **Debug signing certificate SHA-1**: (Optional for now)
   - Click "Register app"

2. **Download Configuration File**
   - Download `google-services.json`
   - **IMPORTANT**: Place it in `android/app/google-services.json`

## Step 3: Add iOS App to Firebase

1. **Add iOS App**
   - Click the iOS icon (🍎) or "Add app"
   - **iOS bundle ID**: `com.example.upashtit2`
   - **App nickname**: `upashtit2 iOS`
   - Click "Register app"

2. **Download Configuration File**
   - Download `GoogleService-Info.plist`
   - **IMPORTANT**: Place it in `ios/Runner/GoogleService-Info.plist`

## Step 4: Enable Authentication

1. **Navigate to Authentication**
   - In Firebase Console, click "Authentication" in left sidebar
   - Click "Get started"

2. **Enable Sign-in Methods**
   - Go to "Sign-in method" tab
   - **Enable Email/Password**:
     - Click "Email/Password"
     - Toggle "Enable" to ON
     - Click "Save"

3. **Optional: Enable Additional Methods**
   - **Google Sign-In** (if needed)
   - **Phone Authentication** (if needed)

## Step 5: Create Firestore Database

1. **Navigate to Firestore Database**
   - Click "Firestore Database" in left sidebar
   - Click "Create database"

2. **Security Rules**
   - Choose "Start in test mode" (for development)
   - **IMPORTANT**: Change to production rules later!
   - Click "Next"

3. **Location Selection**
   - Choose a location close to your users
   - Click "Done"

## Step 6: Enable Realtime Database (Optional)

1. **Navigate to Realtime Database**
   - Click "Realtime Database" in left sidebar
   - Click "Create database"

2. **Security Rules**
   - Choose "Start in test mode"
   - Click "Done"

## Step 7: Update Firebase Configuration

1. **Update firebase_options.dart**
   - Replace the placeholder values with your actual Firebase config
   - You can get these values from:
     - Project Settings → General → Your apps
     - Or from the downloaded config files

2. **Example Configuration Structure**:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-actual-android-api-key',
  appId: 'your-actual-android-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

## Step 8: Configure Firestore Security Rules

1. **Go to Firestore → Rules**
2. **Replace with these rules** (for development):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. **Click "Publish"**

## Step 9: Set Up User Roles Collection

1. **Create Collections in Firestore**:
   - Go to Firestore → Data
   - Create these collections:
     - `users` (for user profiles)
     - `buses` (for bus information)
     - `routes` (for route information)
     - `locations` (for real-time tracking)

2. **Sample User Document Structure**:
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "role": "student", // admin, coordinator, driver, teacher, student
  "collegeName": "College Name",
  "approvalStatus": "approved", // pending, approved, rejected
  "createdAt": "timestamp",
  "lastLogin": "timestamp"
}
```

## Step 10: Test Firebase Connection

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Check Debug Console** for:
   - ✅ "Firebase initialized successfully"
   - ✅ Authentication state messages
   - ❌ Any error messages

## Step 11: Production Security Rules

**IMPORTANT**: Before going to production, update your Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bus data - coordinators and admins can manage
    match /buses/{busId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'coordinator']);
    }
    
    // Route data - coordinators and admins can manage
    match /routes/{routeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'coordinator']);
    }
    
    // Location data - drivers can write, others can read
    match /locations/{locationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['driver', 'admin']);
    }
  }
}
```

## 🔧 Troubleshooting

### Common Issues:

1. **"Firebase initialization failed"**
   - Check if `google-services.json` is in correct location
   - Verify package name matches Firebase console

2. **"Permission denied"**
   - Check Firestore security rules
   - Ensure user is authenticated

3. **"App not found"**
   - Verify app is registered in Firebase console
   - Check bundle/package name matches

### Debug Steps:
1. Check console output for Firebase messages
2. Verify config files are in correct locations
3. Test with simple read/write operations
4. Check Firebase console for error logs

## 📱 Next Steps After Setup

1. **Test Authentication**: Try registering a new user
2. **Test Database**: Create some sample data
3. **Test Roles**: Verify role-based access works
4. **Test Location**: Ensure location tracking works
5. **Deploy**: Configure for production when ready

## 🆘 Need Help?

- Check the debug console output in your IDE
- Look for Firebase error messages
- Verify all configuration files are in place
- Test with a simple Firebase operation first
