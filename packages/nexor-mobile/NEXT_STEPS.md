# Phase 2 - Next Steps للتشغيل والاختبار

## ✅ ما تم إنجازه

تم تنفيذ Phase 2 بالكامل مع:
- 30+ ملف Dart جديد
- 5 ملفات محدثة
- جميع الميزات المطلوبة
- Clean Architecture
- Riverpod State Management
- API Integration كامل

## 📋 خطوات التشغيل

### 1. تثبيت Dependencies

```bash
cd /workspaces/ServMo/work/open/opencode/packages/nexor-mobile
flutter pub get
```

### 2. تشغيل Build Runner

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

هذا سيولد الملفات التالية:
- `file_node_model.g.dart` (Hive adapter)
- `files_provider.g.dart` (Riverpod providers)
- `file_search_provider.g.dart` (Riverpod providers)

### 3. إضافة الخطوط (Fonts)

تأكد من وجود الخطوط في المجلد:
```
assets/fonts/
├── Inter-Regular.ttf
├── Inter-Medium.ttf
├── Inter-SemiBold.ttf
├── Inter-Bold.ttf
├── JetBrainsMono-Regular.ttf  ← جديد
└── JetBrainsMono-Bold.ttf      ← جديد
```

إذا لم تكن موجودة، حملها من:
- Inter: https://fonts.google.com/specimen/Inter
- JetBrains Mono: https://www.jetbrains.com/lp/mono/

### 4. تشغيل التطبيق

```bash
flutter run
```

## 🧪 اختبار الميزات

### File Browser
1. افتح التطبيق
2. اضغط على "Files" في أي server card
3. تحقق من:
   - عرض الملفات والمجلدات
   - الأيقونات الصحيحة لكل نوع ملف
   - Breadcrumb navigation
   - Git status badges
   - Sort & Filter

### File Viewer
1. اضغط على أي ملف
2. تحقق من:
   - Syntax highlighting
   - Line numbers
   - Font size controls
   - Copy to clipboard
   - Share functionality

### File Search
1. اضغط على أيقونة البحث
2. تحقق من:
   - البحث بالاسم
   - البحث في المحتوى
   - عرض النتائج

## 🐛 استكشاف الأخطاء

### إذا ظهرت أخطاء في Build Runner

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### إذا ظهرت أخطاء في Imports

تأكد من أن جميع الملفات موجودة في المسارات الصحيحة:
```
lib/
├── core/
│   ├── theme/
│   │   ├── colors.dart
│   │   └── typography.dart
│   └── utils/
│       └── file_type_detector.dart
├── data/
│   ├── models/file/
│   ├── repositories/
│   └── datasources/remote/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/file/
└── presentation/
    ├── screens/files/
    └── widgets/file/
```

### إذا لم تعمل API Calls

1. تأكد من أن OpenCode server يعمل
2. تأكد من صحة Host و Port
3. تأكد من صحة Username و Password
4. اختبر الاتصال من Server List

## 📱 سيناريوهات الاختبار

### Scenario 1: Browse Project Files
```
1. Add server (localhost:3000)
2. Click "Files" button
3. Navigate to project folder
4. Open a .dart file
5. View with syntax highlighting
```

### Scenario 2: Search for Files
```
1. Open file browser
2. Click search icon
3. Search for "main"
4. View results
5. Open a file from results
```

### Scenario 3: Sort and Filter
```
1. Open file browser
2. Click filter icon
3. Select "Files only"
4. Sort by "Size (Largest first)"
5. Verify sorting
```

### Scenario 4: Git Status
```
1. Open a git repository
2. Modify a file (outside app)
3. Refresh file browser
4. See "M" badge on modified file
```

## 🔧 تعديلات محتملة

### تخصيص الألوان
عدل `lib/core/theme/colors.dart`:
```dart
static const Color primary = Color(0xFF0A84FF); // غير اللون الأساسي
```

### إضافة لغات برمجة جديدة
عدل `lib/core/utils/file_type_detector.dart`:
```dart
case 'newext':
  return 'newlanguage';
```

### تخصيص حجم الخط الافتراضي
عدل `lib/presentation/screens/files/file_viewer_screen.dart`:
```dart
double _fontSize = 14; // غير الحجم الافتراضي
```

## 📊 إحصائيات Phase 2

- **إجمالي الملفات المنشأة**: 30+
- **أسطر الكود**: ~3000+
- **عدد الشاشات**: 3
- **عدد الـ Widgets**: 7
- **عدد الـ Providers**: 4
- **عدد الـ Use Cases**: 5
- **أنواع الملفات المدعومة**: 30+

## ✅ Checklist قبل الانتقال لـ Phase 3

- [ ] flutter pub get نجح
- [ ] build_runner نجح
- [ ] التطبيق يعمل بدون أخطاء
- [ ] File browser يعرض الملفات
- [ ] File viewer يعرض الكود مع highlighting
- [ ] Search يعمل بشكل صحيح
- [ ] Sort & Filter يعملان
- [ ] Git status يظهر بشكل صحيح
- [ ] جميع الأزرار تعمل
- [ ] لا توجد أخطاء في Console

## 🚀 Phase 3 Preview

Phase 3 سيشمل:
- Chat interface مع AI
- إرسال واستقبال الرسائل
- File context في المحادثة
- Code suggestions
- Terminal integration
- Real-time updates

## 📞 الدعم

إذا واجهت أي مشاكل:
1. تحقق من Console للأخطاء
2. تأكد من أن جميع Dependencies مثبتة
3. تأكد من أن OpenCode server يعمل
4. راجع PHASE2_COMPLETE.md للتفاصيل

---

**Phase 2 جاهز للاختبار! 🎉**
