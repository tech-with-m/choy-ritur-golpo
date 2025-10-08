# Setup Guide for Bangla Weather App

This guide will help you set up the Bangla Weather app for development and production.

## 🔧 Prerequisites

Before starting, ensure you have:

- **Flutter SDK** (3.7.2 or later)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Firebase account** (free)
- **Android device** or **emulator** for testing

## 📋 Step-by-Step Setup

### 1. Clone and Install Dependencies

```bash
git clone https://github.com/tech-with-m/choy-ritur-golpo.git
cd choy-ritur-golpo
flutter pub get
```

### 2. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `bangla-weather` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

#### Add Android App
1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.tech_with_m.choy_ritur_golpo`
3. Enter app nickname: `Bangla Weather`
4. Click "Register app"
5. Download `google-services.json`
6. Place the file in `android/app/` directory

#### Enable Services
1. In Firebase Console, go to "Cloud Messaging"
2. Click "Get started"
3. Note down your Server Key (you'll need this for sending notifications)

### 3. App Signing Configuration (For Release Builds)

#### Create Keystore
```bash
keytool -genkey -v -keystore android/app/choy_ritur_golpo.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias choy_ritur_golpo
```

#### Create key.properties
Create `android/key.properties` with your keystore details:
```properties
storePassword=your_actual_store_password
keyPassword=your_actual_key_password
keyAlias=choy_ritur_golpo
storeFile=choy_ritur_golpo.keystore
```

### 4. Run the App

#### Debug Mode
```bash
flutter run
```

#### Release Mode
```bash
flutter run --release
```

## 🚨 Important Security Notes

### Files to NEVER Commit
- `android/app/google-services.json` (contains Firebase API keys)
- `android/key.properties` (contains keystore passwords)
- `android/app/*.keystore` (contains signing keys)

### Template Files
Use these template files as reference:
- `android/app/google-services.json.template`
- `android/key.properties.template`

## 🔍 Troubleshooting

### Common Issues

#### "Flutter command not found"
- Add Flutter to your system PATH
- Restart your terminal/IDE

#### "No connected devices"
- Start Android emulator: `flutter emulators --launch <emulator_id>`
- Or connect a physical device with USB debugging enabled

#### "Gradle build failed"
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

#### "Firebase not initialized"
- Ensure `google-services.json` is in `android/app/` directory
- Check that the package name matches in Firebase Console

#### "Signing config not found"
- Ensure `key.properties` exists in `android/` directory
- Verify keystore file exists in `android/app/` directory

### Getting Help

1. Check [Flutter Documentation](https://flutter.dev/docs)
2. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
3. Open an issue in this repository
4. Join Flutter Discord community

## 📱 Testing Push Notifications

### Using Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter title and message
4. Select target: "Topic" → "general"
5. Click "Review" → "Publish"

### Using cURL
```bash
curl -X POST -H "Authorization: key=YOUR_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "to": "/topics/general",
       "notification": {
         "title": "Test Notification",
         "body": "This is a test message"
       }
     }' \
     https://fcm.googleapis.com/fcm/send
```

## 🏗️ Building for Production

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## 📊 Project Structure

```
choy-ritur-golpo/
├── android/                 # Android-specific files
│   ├── app/
│   │   ├── google-services.json.template
│   │   └── choy_ritur_golpo.keystore (create this)
│   └── key.properties.template
├── lib/                     # Main Dart code
│   ├── app/                # Application logic
│   ├── translation/        # Localization
│   └── theme/              # App theming
├── assets/                 # Images, fonts, data
├── screenshots/            # App screenshots
└── README.md              # This file
```

## 🎯 Next Steps

After setup:
1. Run the app and test basic functionality
2. Test push notifications
3. Customize the app for your needs
4. Build and test release version
5. Deploy to Play Store (if desired)

## 📞 Support

If you encounter issues:
1. Check this setup guide first
2. Search existing GitHub issues
3. Create a new issue with detailed information
4. Include error messages and steps to reproduce

---

**Happy coding! 🚀**
