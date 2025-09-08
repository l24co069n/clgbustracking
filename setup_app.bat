@echo off
echo Setting up upashtit2 Flutter app...
echo.

echo Step 1: Getting Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Step 2: Generating app icons...
flutter pub run flutter_launcher_icons
if errorlevel 1 (
    echo ERROR: Failed to generate app icons
    pause
    exit /b 1
)

echo.
echo Step 3: Cleaning and rebuilding...
flutter clean
flutter pub get

echo.
echo ✅ Setup completed successfully!
echo.
echo The app is now configured with:
echo - App name: upashtit2
echo - Google Maps API key configured
echo - App icon set to upasthit_logo.jpg
echo - Firebase connection with debug logging
echo - Fixed counter app issue
echo.
echo You can now run: flutter run
pause
