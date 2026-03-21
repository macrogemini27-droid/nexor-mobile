# Nexor Mobile - GitHub Actions CI/CD

## 📋 Overview

This workflow automatically builds Nexor Mobile for Android and iOS whenever changes are pushed to the repository.

## 🚀 Workflow Jobs

### 1. **build-android**

Builds Android APK and App Bundle:

- **Debug APK** (split per ABI: arm64-v8a, armeabi-v7a, x86_64)
- **Release APK** (split per ABI)
- **App Bundle** (.aab for Google Play)

**Artifacts:**

- `nexor-mobile-debug-apk` (30 days retention)
- `nexor-mobile-release-apk` (90 days retention)
- `nexor-mobile-app-bundle` (90 days retention)

### 2. **build-ios**

Builds iOS IPA (unsigned):

- **Release IPA** (no codesign for CI)

**Artifacts:**

- `nexor-mobile-ios-ipa` (90 days retention)

### 3. **lint**

Runs code quality checks:

- Flutter analyze
- Dart format check

### 4. **release**

Creates GitHub release with all artifacts (only on main/dev branch push)

## 🔧 Configuration

### Flutter Version

- **Version:** 3.19.0 (stable)
- **Dart:** 3.3.x (included with Flutter)

### Android Configuration

- **Java:** 17 (Zulu distribution)
- **Gradle:** 8.1.0
- **Kotlin:** 1.9.0
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 34 (Android 14)
- **Compile SDK:** 36

### iOS Configuration

- **Deployment Target:** 12.0
- **Build:** Release (no codesign)

## 📦 Triggers

The workflow runs on:

1. **Push** to `dev` or `main` branches (when nexor-mobile files change)
2. **Pull Request** (when nexor-mobile files change)
3. **Manual trigger** (workflow_dispatch)

## 🎯 Usage

### Download Build Artifacts

After the workflow completes, you can download the artifacts:

1. Go to **Actions** tab in GitHub
2. Click on the latest workflow run
3. Scroll down to **Artifacts** section
4. Download the desired artifact:
   - `nexor-mobile-debug-apk` - Debug APKs for testing
   - `nexor-mobile-release-apk` - Release APKs for distribution
   - `nexor-mobile-app-bundle` - App Bundle for Google Play
   - `nexor-mobile-ios-ipa` - iOS IPA (unsigned)

### Install APK on Android Device

```bash
# Extract the downloaded artifact
unzip nexor-mobile-release-apk.zip

# Install on device (via ADB)
adb install app-arm64-v8a-release.apk
```

### Manual Trigger

You can manually trigger the workflow:

1. Go to **Actions** tab
2. Select **Nexor Mobile Build** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 📝 Release Process

When code is pushed to `main` or `dev` branch:

1. Workflow builds all artifacts
2. Creates a GitHub release with tag `nexor-mobile-vX.Y.Z`
3. Uploads all APKs, AAB, and IPA to the release
4. Generates release notes automatically

## 🔍 Troubleshooting

### Build Fails on Android

Check:

- Gradle version compatibility
- Java version (must be 17)
- Android SDK versions in `android/app/build.gradle`

### Build Fails on iOS

Check:

- Xcode version on macOS runner
- iOS deployment target in `ios/Podfile`
- CocoaPods dependencies

### Tests Fail

Tests are set to `continue-on-error: true`, so they won't block the build. However, you should fix failing tests.

## 🛠️ Local Testing

To test the build locally before pushing:

```bash
cd packages/nexor-mobile

# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build Android
flutter build apk --release --split-per-abi

# Build iOS (macOS only)
flutter build ios --release --no-codesign
```

## 📊 Build Times

Approximate build times:

- **Android:** 8-12 minutes
- **iOS:** 10-15 minutes
- **Lint:** 2-3 minutes

Total workflow time: ~15-20 minutes

## 🔐 Secrets Required

No secrets required for basic builds. For signed releases, you'll need:

- `ANDROID_KEYSTORE` - Android signing keystore
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password
- iOS signing certificates (for App Store)

## 📚 References

- [Flutter CI/CD Documentation](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
