# دليل بناء تطبيق Nexor Mobile - التوثيق الكامل

## نظرة عامة
هذا الدليل يوثق عملية بناء تطبيق Nexor Mobile (Flutter) وحل جميع المشاكل التي واجهتنا، ورفع ملف APK النهائي.

---

## المتطلبات الأساسية

### البيئة المستخدمة
- **النظام:** Linux (Codespace/Ubuntu)
- **Docker:** متوفر ومثبت
- **المساحة المطلوبة:** 8-10 GB على الأقل

### الأدوات
- Docker (لتشغيل Flutter container)
- curl (لرفع الملفات)

---

## المشاكل والحلول

### 1. مشكلة: Flutter غير مثبت على النظام
**الخطأ:**
```
flutter: command not found
```

**الحل:**
استخدام Docker image يحتوي على Flutter بدلاً من تثبيته محلياً:
```bash
docker run --rm -v "$(pwd):/project" -w /project ghcr.io/cirruslabs/flutter:3.19.0 sh -c "flutter build apk --release"
```

**السبب:** Flutter 3.19.0 يحتوي على Dart 3.3 المتوافق مع المشروع (SDK >=3.2.0)

---

### 2. مشكلة: عدم توافق إصدارات Dart/Flutter
**الخطأ:**
```
Error: Type 'UnmodifiableUint8ListView' not found
Error: Type 'CardThemeData' not found
```

**الحل:**
- استخدام Flutter 3.19.0 بدلاً من latest (3.41.4)
- تعديل `CardThemeData` إلى `CardTheme` في ملف `lib/core/theme/app_theme.dart`

**الكود المصحح:**
```dart
cardTheme: CardTheme(  // كان CardThemeData
  color: AppColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
  ),
),
```

---

### 3. مشكلة: مشاكل في Gradle versions
**الخطأ:**
```
Build failed with an exception.
'void com.android.build.api.variant.AndroidComponentsExtension.onVariants...'
```

**الحل:**
تحديث إصدارات Gradle و Kotlin في ملفات Android:

**ملف `android/build.gradle`:**
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}
```

**ملف `android/settings.gradle`:**
```gradle
plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.1.0" apply false
    id "org.jetbrains.kotlin.android" version "1.9.0" apply false
}
```

**ملف `android/app/build.gradle`:**
```gradle
android {
    compileSdk 34
    targetSdk 34
}
```

---

### 4. مشكلة: ملفات Android Resources ناقصة
**الخطأ:**
```
error: resource mipmap/ic_launcher not found
error: resource style/LaunchTheme not found
error: resource style/NormalTheme not found
```

**الحل:**
إنشاء الملفات المطلوبة يدوياً:

**1. ملف `android/app/src/main/res/values/styles.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
```

**2. ملف `android/app/src/main/res/drawable/launch_background.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
</layer-list>
```

**3. ملف `android/app/src/main/res/drawable-v21/launch_background.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />
</layer-list>
```

**4. أيقونات التطبيق** في المجلدات:
- `mipmap-hdpi/ic_launcher.xml`
- `mipmap-mdpi/ic_launcher.xml`
- `mipmap-xhdpi/ic_launcher.xml`
- `mipmap-xxhdpi/ic_launcher.xml`
- `mipmap-xxxhdpi/ic_launcher.xml`

محتوى كل ملف:
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#2196F3" />
    <corners android:radius="8dp" />
</shape>
```

---

### 5. مشكلة: نفاد المساحة على الديسك
**الخطأ:**
```
no space left on device
```

**الحل:**
تنظيف Docker بشكل دوري:
```bash
docker system prune -af
docker volume prune -f
```

**النتيجة:** استرجاع 4-5 GB من المساحة

---

### 6. مشكلة: التطبيق لا يستطيع الاتصال بالسيرفر (HTTP Cleartext Traffic)
**الخطأ:**
```
Connection failed / Connection timeout
Test connection failed
```

**السبب:**
أندرويد 9+ يمنع اتصالات HTTP غير المشفرة (cleartext traffic) افتراضياً لأسباب أمنية.

**الحل:**
إضافة إعدادات السماح باتصالات HTTP:

**1. تحديث `android/app/src/main/AndroidManifest.xml`:**
```xml
<application
    android:label="Nexor"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config">
```

**2. إنشاء ملف `android/app/src/main/res/xml/network_security_config.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

**3. إضافة دعم HTTPS في `lib/domain/entities/server.dart`:**
```dart
class Server extends Equatable {
  final bool useHttps;
  
  const Server({
    // ... other fields
    this.useHttps = false,
  });
  
  String get url => '${useHttps ? 'https' : 'http'}://$host:$port';
}
```

**4. تحديث `lib/data/models/server/server_model.dart`:**
```dart
@HiveField(9)
final bool useHttps;
```

**5. تحديث Hive adapter في `lib/data/models/server/server_model.g.dart`:**
```dart
// في read method:
useHttps: fields[9] as bool? ?? false,

// في write method:
..writeByte(10)  // تغيير من 9 إلى 10
// ... إضافة
..writeByte(9)
..write(obj.useHttps);
```

**6. تحسين اختبار الاتصال في `lib/domain/usecases/server/test_connection.dart`:**
```dart
// زيادة timeout من 10 إلى 30 ثانية
connectTimeout: const Duration(seconds: 30),
receiveTimeout: const Duration(seconds: 30),

// اختبار عدة endpoints
final endpoints = ['/health', '/', '/api'];
for (final endpoint in endpoints) {
  try {
    response = await _dio.get('${server.url}$endpoint', options: options);
    break;
  } catch (e) {
    if (endpoint == endpoints.last) rethrow;
  }
}

// قبول status codes إضافية
if (response.statusCode == 200 || 
    response.statusCode == 404 || 
    response.statusCode == 403) {
  return ConnectionTestResult(success: true, latencyMs: latency);
}
```

**7. إضافة HTTPS toggle في واجهة المستخدم `lib/presentation/screens/servers/add_server_screen.dart`:**
```dart
bool _useHttps = false;

// في build method:
SwitchListTile(
  title: const Text('Use HTTPS'),
  subtitle: const Text('Enable secure connection (SSL/TLS)'),
  value: _useHttps,
  onChanged: (value) {
    setState(() => _useHttps = value);
  },
),
```

---

### 7. مشكلة: pub cache غير متاح في Docker
**الخطأ:**
```
Error: Error when reading '/root/.pub-cache/hosted/pub.dev/...' No such file or directory
```

**الحل:**
استخدام Docker volume لحفظ pub cache:
```bash
docker run --rm \
  -v "$(pwd):/project" \
  -v flutter-pub-cache:/root/.pub-cache \
  -w /project \
  ghcr.io/cirruslabs/flutter:3.19.0 \
  sh -c "flutter pub get && flutter build apk --release"
```

---

## خطوات البناء الكاملة

### الخطوة 1: التحضير
```bash
cd /path/to/nexor-mobile
```

### الخطوة 2: التأكد من وجود المساحة الكافية
```bash
df -h
# يجب أن يكون هناك 8GB على الأقل متاحة
```

### الخطوة 3: تنظيف Docker (إذا لزم الأمر)
```bash
docker system prune -af
docker volume prune -f
```

### الخطوة 4: بناء التطبيق
```bash
docker run --rm \
  -v "$(pwd):/project" \
  -v flutter-pub-cache:/root/.pub-cache \
  -w /project \
  ghcr.io/cirruslabs/flutter:3.19.0 \
  sh -c "flutter pub get && flutter build apk --release"
```

### الخطوة 5: التحقق من نجاح البناء
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
file build/app/outputs/flutter-apk/app-release.apk
```

**النتيجة المتوقعة:**
```
-rw-rw-rw- 1 root root 26M ... app-release.apk
app-release.apk: Android package (APK)
```

---

## رفع ملف APK

### الطريقة 1: catbox.moe (موصى بها)
```bash
curl -F "reqtype=fileupload" \
  -F "fileToUpload=@build/app/outputs/flutter-apk/app-release.apk" \
  https://catbox.moe/user/api.php
```

**النتيجة:**
```
https://files.catbox.moe/xxxxx.apk
```

### الطريقة 2: tmpfiles.org
```bash
curl -F "file=@build/app/outputs/flutter-apk/app-release.apk" \
  https://tmpfiles.org/api/v1/upload
```

**ملاحظة:** قد يحول الملف إلى zip، استخدم catbox.moe بدلاً منه.

### الطريقة 3: pixeldrain.com
```bash
curl -F "file=@build/app/outputs/flutter-apk/app-release.apk" \
  https://pixeldrain.com/api/file/
```

---

## الخدمات التي لم تعمل

### ❌ transfer.sh
```
Failed to connect to transfer.sh
```

### ❌ 0x0.st
```
Network is banned: Microsoft Corporation
```

### ❌ file.io
الرفع يتقطع في المنتصف

---

## ملاحظات مهمة

### 1. إصدارات متوافقة
- **Flutter:** 3.19.0
- **Dart:** 3.3.0
- **Android Gradle Plugin:** 8.1.0
- **Kotlin:** 1.9.0
- **compileSdk:** 34
- **targetSdk:** 34

### 2. حجم الملف النهائي
- **APK Size:** ~25-26 MB

### 3. وقت البناء
- **أول مرة:** 5-7 دقائق (تحميل dependencies)
- **المرات التالية:** 3-5 دقائق (مع cache)

### 4. المساحة المطلوبة
- **Flutter Docker Image:** ~2 GB
- **Build artifacts:** ~500 MB
- **Pub cache:** ~1 GB
- **إجمالي:** ~4-5 GB

---

## استكشاف الأخطاء

### إذا فشل البناء مع "no space left"
```bash
# نظف Docker
docker system prune -af
docker volume prune -f

# تحقق من المساحة
df -h

# احذف build folder القديم
rm -rf build/
```

### إذا فشل البناء مع أخطاء Gradle
```bash
# نظف Gradle cache
rm -rf android/.gradle
rm -rf android/app/build

# أعد البناء
docker run --rm -v "$(pwd):/project" -v flutter-pub-cache:/root/.pub-cache -w /project ghcr.io/cirruslabs/flutter:3.19.0 sh -c "flutter clean && flutter pub get && flutter build apk --release"
```

### إذا فشل الرفع
جرب خدمة أخرى من القائمة أعلاه، أو:
```bash
# رفع يدوي عبر GitHub Release
# أو استخدام Google Drive / Dropbox
```

---

## سكريبت كامل للبناء والرفع

احفظ هذا في ملف `build_and_upload.sh`:

```bash
#!/bin/bash

set -e  # توقف عند أي خطأ

echo "🚀 بدء عملية البناء..."

# 1. التحقق من المساحة
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 8 ]; then
    echo "❌ المساحة غير كافية. متاح: ${AVAILABLE_SPACE}GB، مطلوب: 8GB"
    echo "🧹 تنظيف Docker..."
    docker system prune -af
    docker volume prune -f
fi

# 2. الانتقال لمجلد المشروع
cd /path/to/nexor-mobile

# 3. البناء
echo "🔨 بناء APK..."
docker run --rm \
  -v "$(pwd):/project" \
  -v flutter-pub-cache:/root/.pub-cache \
  -w /project \
  ghcr.io/cirruslabs/flutter:3.19.0 \
  sh -c "flutter pub get && flutter build apk --release"

# 4. التحقق من نجاح البناء
if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "❌ فشل البناء!"
    exit 1
fi

echo "✅ البناء نجح!"
ls -lh build/app/outputs/flutter-apk/app-release.apk

# 5. رفع الملف
echo "📤 رفع APK..."
UPLOAD_URL=$(curl -F "reqtype=fileupload" \
  -F "fileToUpload=@build/app/outputs/flutter-apk/app-release.apk" \
  https://catbox.moe/user/api.php)

echo ""
echo "✅ تم الرفع بنجاح!"
echo "🔗 رابط التحميل: $UPLOAD_URL"
echo ""
echo "📋 انسخ الرابط وشاركه مع الفريق"
```

**الاستخدام:**
```bash
chmod +x build_and_upload.sh
./build_and_upload.sh
```

---

## الخلاصة

تم بناء التطبيق بنجاح بعد حل المشاكل التالية:
1. ✅ استخدام Flutter 3.19.0 المتوافق
2. ✅ تصحيح أخطاء الكود (CardTheme)
3. ✅ تحديث إصدارات Gradle و Kotlin
4. ✅ إنشاء ملفات Android Resources الناقصة
5. ✅ إدارة المساحة وتنظيف Docker
6. ✅ استخدام Docker volumes للـ cache
7. ✅ **إصلاح مشكلة HTTP Cleartext Traffic (أندرويد 9+)**
8. ✅ **إضافة دعم HTTPS للاتصال الآمن**
9. ✅ **تحسين اختبار الاتصال (timeout 30 ثانية، endpoints متعددة)**
10. ✅ **إضافة واجهة HTTPS toggle في شاشة إضافة السيرفر**
11. ✅ رفع الملف على catbox.moe

**الملف النهائي:** APK بحجم 25.3MB جاهز للتوزيع

### الإصلاحات الجديدة (مارس 2026)

#### مشكلة الاتصال بالسيرفر
**المشكلة:** التطبيق كان يفشل في الاتصال بالسيرفر حتى مع معلومات صحيحة.

**السبب الرئيسي:** أندرويد 9+ يمنع اتصالات HTTP غير المشفرة افتراضياً.

**الحلول المطبقة:**
1. إضافة `usesCleartextTraffic="true"` في AndroidManifest
2. إنشاء network security config للسماح بـ HTTP
3. إضافة دعم HTTPS في كود التطبيق
4. زيادة timeout من 10 إلى 30 ثانية
5. اختبار endpoints متعددة (/health, /, /api)
6. قبول status codes إضافية (200, 404, 403)
7. إضافة toggle لاختيار HTTP/HTTPS في الواجهة

**النتيجة:** التطبيق الآن يدعم:
- ✅ اتصالات HTTP (للسيرفرات المحلية)
- ✅ اتصالات HTTPS (للسيرفرات الآمنة)
- ✅ timeout أطول لشبكات بطيئة
- ✅ اختبار اتصال أكثر مرونة

---

## جهة الاتصال

إذا واجهت أي مشاكل، راجع هذا الدليل أولاً. معظم المشاكل موثقة هنا مع حلولها.

**تاريخ التوثيق:** مارس 2026
**الإصدار:** 1.0
