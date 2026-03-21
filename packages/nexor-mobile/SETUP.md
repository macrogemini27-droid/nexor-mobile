# Nexor Mobile - Setup Instructions

## Prerequisites

- Flutter SDK (3.2.0 or higher)
- Dart SDK (3.2.0 or higher)
- Android Studio / Xcode (for mobile development)
- A device or emulator

## Installation Steps

### 1. Install Flutter

If you haven't installed Flutter yet:

```bash
# Visit https://flutter.dev/docs/get-started/install
# Follow the instructions for your operating system
```

Verify installation:
```bash
flutter doctor
```

### 2. Navigate to Project Directory

```bash
cd /workspaces/ServMo/work/open/opencode/packages/nexor-mobile
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Code (Optional)

The generated files are already included, but if you need to regenerate:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Add Font Files (Optional)

The app uses Inter font family. Download from:
https://fonts.google.com/specimen/Inter

Place the following files in `assets/fonts/`:
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

If you skip this step, the app will use the system default font.

### 6. Run the App

For Android:
```bash
flutter run
```

For iOS:
```bash
flutter run
```

For a specific device:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## Testing

Run unit tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Building

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Issue: "flutter: command not found"
- Make sure Flutter is installed and added to your PATH
- Run `flutter doctor` to verify installation

### Issue: Build errors
- Run `flutter clean` then `flutter pub get`
- Delete `build/` folder and rebuild

### Issue: Missing fonts
- Either add the Inter font files to `assets/fonts/`
- Or remove the font configuration from `pubspec.yaml` to use system fonts

### Issue: Gradle errors (Android)
- Make sure you have Java 11 or higher installed
- Update Android SDK tools in Android Studio

## Project Structure

```
nexor-mobile/
├── lib/
│   ├── core/              # Core utilities and theme
│   ├── data/              # Data layer (models, repositories)
│   ├── domain/            # Domain layer (entities, use cases)
│   ├── presentation/      # UI layer (screens, widgets)
│   ├── services/          # External services
│   ├── app.dart          # App widget
│   └── main.dart         # Entry point
├── test/                  # Unit tests
├── android/              # Android configuration
├── ios/                  # iOS configuration
├── assets/               # Assets (fonts, images)
└── pubspec.yaml          # Dependencies
```

## Features

- ✅ Add/Edit/Delete servers
- ✅ Test server connection
- ✅ Secure password storage
- ✅ Local data persistence
- ✅ Dark theme with glassmorphism
- ✅ Pull to refresh
- ✅ Form validation

## Next Steps

After setup, you can:
1. Add your first OpenCode server
2. Test the connection
3. Explore the server management features

For Phase 2 features (file browser, code editor, AI chat), stay tuned!
