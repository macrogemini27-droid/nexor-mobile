# Nexor Mobile - تقرير المشاكل التقنية الشامل

**تاريخ التقرير:** 17 مارس 2026  
**عدد المشاكل المكتشفة:** 38+ مشكلة  
**مستوى الخطورة:** 🔴 حرج (11) | 🟡 متوسط (17) | 🟢 تحسين (10)

---

## القسم الأول: المشاكل الأمنية 🔴

### 1.1 تخزين كلمة المرور بشكل غير آمن

**الخطورة:** 🔴 حرج  
**المسار:** `lib/domain/entities/server.dart:10,21,40,51,65`

```dart
// المشكلة: كيان Server يحمل password في الذاكرة
class Server extends Equatable {
  final String? password;  // ← خطأ! يجب عدم تخزينه هنا
}
```

**التأثير:** كلمة المرور تبقى في الذاكرة طوال دورة حياة التطبيق.

**الحل المقترح:**  
- إزالة `password` من كيان `Server`
- جلب كلمة المرور من `SecureStorageService` عند الحاجة فقط

---

### 1.2 تخزين كلمة المرور في Hive (غير مشفر)

**الخطورة:** 🔴 حرج  
**المسار:** `lib/data/models/server/server_model.dart:25,42,56,71,85,96`

```dart
@HiveType(typeId: 0)
class ServerModel extends HiveObject {
  @HiveField(5)
  final String? password;  // ← خطأ! Hive لا يشفر تلقائياً
}
```

**التأثير:** كلمات المرور تُخزن في ملف قابل للقراءة.

**الحل المقترح:**  
- إزالة `password` من `ServerModel`
- استخدام `SecureStorageService` فقط

---

### 1.3 استخدام ApiClient بدون password في Session

**الخطورة:** 🔴 حرج  
**المسار:** `lib/data/repositories/session_repository_impl.dart:28`

```dart
return ApiClient(
  baseUrl: baseUrl,
  username: server.username,
  password: null,  // ← خطأ! دائماً null
);
```

**التأثير:** لا يمكن المصادقة على السيرفرات المحمية بكلمة مرور.

**الحل المقترح:**  
- جلب كلمة المرور من `SecureStorageService` باستخدام `server.id`

---

### 1.4 استخدام http دائماً بدلاً من https

**الخطورة:** 🔴 حرج  
**المسار:** `lib/data/repositories/session_repository_impl.dart:24`

```dart
final baseUrl = 'http://${server.host}:${server.port}';
// ↑ خطأ! يتجاهل server.useHttps تماماً!
```

**التأثير:** حتى لو فعّل المستخدم HTTPS من UI، الطلب سيرسل على HTTP!

**الحل المقترح:**
```dart
final baseUrl = '${server.useHttps ? 'https' : 'http'}://${server.host}:${server.port}';
```

---

### 1.5 SecureStorageService instance يُنشأ في كل Screen

**الخطورة:** 🟡 متوسط  
**المسار:** 
- `lib/presentation/screens/servers/add_server_screen.dart:37`
- `lib/presentation/screens/servers/servers_list_screen.dart:27`

```dart
// المشكلة: كل screen ينشئ instance جديد
final _secureStorage = SecureStorageService();
```

**التأثير:** استخدام ذاكرة أكثر، ولا يوجد shared state.

**الحل المقترح:** استخدام Riverpod provider لـ SecureStorageService

---

### 1.6 TestConnection instance يُنشأ في كل Screen

**الخطورة:** 🟢 تحسين  
**المسار:** 
- `lib/presentation/screens/servers/add_server_screen.dart:36`
- `lib/presentation/screens/servers/servers_list_screen.dart:26`

```dart
// المشكلة: كل screen ينشئ instance جديد
final _testConnection = TestConnection();
```

**التأثير:** كود مكرر، صعوبة في الصيانة.

**الحل المقترح:** استخدام Riverpod provider لـ TestConnection

---

## القسم الثاني: مشاكل Null Safety & Runtime Crashes 🟡

### 2.1 استخدام queryParameters بدون تحقق

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/app/app_router.dart:34,45,56`

```dart
// المشكلة
final serverId = state.uri.queryParameters['serverId']!;
final path = state.uri.queryParameters['path']!;

// الحل المقترح
final serverId = state.uri.queryParameters['serverId'];
if (serverId == null) return const SizedBox(); // أو redirect
```

---

### 2.2 استخدام servers.first بدون تحقق

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/repositories/session_repository_impl.dart:43,75,101,130,145,172,197,231`

```dart
// المشكلة - كل العمليات تستخدم السيرفر الأول
final servers = await _serverRepository.getServers();
final client = await _getApiClient(servers.first.id);  // ← crash لو فارغ!
```

**الحل المقترح:**  
- إضافة current server state
- التحقق من وجود سيرفر قبل الاستخدام

---

### 2.3 استخدام firstWhere بدون try-catch

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/servers/add_server_screen.dart:54`

```dart
_existingServer = servers.firstWhere((s) => s.id == widget.serverId);
// ← crash لو السيرفر غير موجود!
```

**الحل المقترح:**
```dart
try {
  _existingServer = servers.firstWhere((s) => s.id == widget.serverId);
} catch (e) {
  // معالجة الخطأ
}
```

---

### 2.4 استخدام response.data بدون تحقق

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/datasources/remote/api_client.dart:96`

```dart
await for (final chunk in response.data!.stream) {  // ← null safety
```

**الحل المقترح:**
```dart
if (response.data != null) {
  await for (final chunk in response.data!.stream) {
```

---

### 2.5 استخدام widget.label بدون تحقق

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/widgets/common/nexor_input.dart:78`

```dart
Text(
  widget.label!,  // ← خطأ محتمل لو null
)
```

---

## القسم الثالث: المشاكل المعمارية (ستُفسد الكود مع الوقت) 🔴

### 3.1 الـ Use Cases غير مستخدمة إطلاقاً

**الخطورة:** 🔴 حرج  
**المسار:** `lib/domain/usecases/*`

**الوصف:** تم إنشاء 16 ملف Use Case لكن لا يُستخدم أي منها!

```
lib/domain/usecases/
├── server/
│   ├── get_servers.dart      ❌ غير مستخدم
│   ├── add_server.dart       ❌ غير مستخدم
│   ├── update_server.dart    ❌ غير مستخدم
│   ├── delete_server.dart    ❌ غير مستخدم
│   └── test_connection.dart  ✅ مستخدم
├── session/
│   ├── get_sessions.dart     ❌ غير مستخدم
│   ├── get_session.dart      ❌ غير مستخدم
│   ├── create_session.dart   ❌ غير مستخدم
│   ├── delete_session.dart   ❌ غير مستخدم
│   ├── send_message.dart     ❌ غير مستخدم
│   └── get_messages.dart     ❌ غير مستخدم
└── file/
    ├── list_files.dart       ❌ غير مستخدم
    ├── read_file.dart        ❌ غير مستخدم
    ├── search_files.dart     ❌ غير مستخدم
    ├── search_content.dart   ❌ غير مستخدم
    └── get_git_status.dart   ❌ غير مستخدم
```

**التأثير:** 
- الكود مُكرر في الـ Screens والـ Repositories
- لا يوجد business logic موحد
- صعب الاختبار والصيانة

---

### 3.2 لا يوجد Current Server State

**الخطورة:** 🔴 حرج  
**المسار:** `lib/data/repositories/session_repository_impl.dart` + `lib/data/repositories/file_repository_impl.dart`

**الوصف:** كل العمليات تأخذ `serverId` كـ parameter، لكن لا يوجد跟踪 للسيرفر الحالي.

```dart
// المشكلة: كل دالة تستدعي getServers() من جديد
Future<ApiClient> _getApiClient(String serverId) async {
  final server = await _serverRepository.getServerById(serverId);
  // ...
}

// وكل العمليات تستخدم السيرفر الأول!
final servers = await _serverRepository.getServers();
final client = await _getApiClient(servers.first.id);
```

**التأثير:**
- مستخدم يختار سيرفر معين، لكن الكود يستخدم السيرفر الأول!
- البيانات تختلط بين السيرفرات
- تجربة المستخدم سيئة

**الحل المقترح:**
```dart
// إضافة Current Server Provider
@riverpod
class CurrentServer extends _$CurrentServer {
  @override
  String? build() => null;

  void setServer(String serverId) {
    state = serverId;
  }

  void clear() => state = null;
}
```

---

### 3.3 Dependency Injection مفقود

**الخطورة:** 🟡 متوسط  
**المسار:** 
- `lib/presentation/screens/servers/providers/servers_provider.dart:12`
- `lib/presentation/screens/files/providers/files_provider.dart:12-19`
- `lib/presentation/screens/chat/providers/conversations_provider.dart:10-12`

```dart
// المشكلة: كل provider ينشئ instance جديد
@riverpod
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl();  // ← instance جديد كل مرة!
}

@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  return SessionRepositoryImpl(ServerRepositoryImpl());  // ← instances متعددة
}
```

**التأثير:**
- لا يوجد shared state
- مشاكل في الـ caching
- استخدام ذاكرة أكثر

**الحل المقترح:** استخدام `ref.watch` بشكل صحيح + shared instances

---

### 3.4 الـ Repository تستدعي getServers() في كل عملية

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/repositories/session_repository_impl.dart` (كل الدوال)

```dart
// تتكرر في كل دالة
Future<ApiClient> _getApiClient(String serverId) async {
  final server = await _serverRepository.getServerById(serverId);
  // ...
}

// وكل عمليات الـ API تستدعي هذا
@override
Future<List<Session>> getSessions({String? directory}) async {
  final servers = await _serverRepository.getServers();  // ← كل مرة!
  if (servers.isEmpty) return [];
  final client = await _getApiClient(servers.first.id);
  // ...
}
```

**التأثير:**
- بطء في الأداء
- طلبات شبكة غير ضرورية
- استهلاك بطارية

---

### 3.5 الـ Providers تُنشئ Repository instances جديدة

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/files/providers/files_provider.dart:11-19`

```dart
@riverpod
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl();  // ← كل(provider) ينشئ جديد
}

@riverpod
FileRepository fileRepository(FileRepositoryRef ref) {
  final serverRepo = ref.watch(serverRepositoryProvider);
  return FileRepositoryImpl(serverRepo);  // ← instance جديد
}
```

**التأثير:** لا يوجد singleton pattern، كل شيء يُنشئ من جديد

---

## القسم الرابع: المشاكل المنطقية (Features غير مكتملة) 🟡

### 4.1 اتصال فعلي بالخادم غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/servers/servers_list_screen.dart:120`

```dart
Future<void> _connectToServer(Server server) async {
  await ref.read(serversNotifierProvider.notifier).updateLastUsed(server.id);
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to ${server.name}...'),
      ),
    );
  }
  // TODO: Implement actual connection logic  ← غير مُنفذ!
}
```

**التأثير:** لا يوجد اتصال فعلي بالخادم، فقط snackbar

---

### 4.2 فتح الملف في Nexor Chat غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/files/file_browser_screen.dart:258`

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    // TODO: Open in Nexor chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening in Nexor...'),
      ),
    );
  },
  // ...
)
```

---

### 4.3 فتح الملف في Chat من File Viewer

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/files/file_viewer_screen.dart:76`

```dart
void _openInNexor() {
  // TODO: Navigate to chat with file context
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Opening in Nexor chat...'),
    ),
  );
}
```

---

### 4.4 Regenerate Message غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/chat_screen.dart:256`

```dart
onRegenerate: () {
  // TODO: Implement regenerate
},
```

---

### 4.5 File Attachment غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/chat_screen.dart:290`

```dart
onAttach: () {
  // TODO: Implement file attachment
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('File attachment coming soon'),
    ),
  );
},
```

---

### 4.6 Directory Picker غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/new_conversation_screen.dart:117`

```dart
// TODO: Show directory picker
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Directory picker coming soon'),
  ),
);
```

---

### 4.7 Export Feature غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/chat_screen.dart:140-144`

```dart
case 'export':
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Export feature coming soon'),
    ),
  );
  break;
```

---

### 4.8 Search Dialog غير مُنفذ

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/conversation_list_screen.dart:43`

```dart
// TODO: Show filter/search dialog
```

---

## القسم الخامس: مشاكل UI/UX 🟢

### 5.1 استخدام PhosphorIcons قد يسبب أخطاء

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/widgets/chat/message_input.dart:128-132`

```dart
Icon(
  PhosphorIcons.paperPlaneTilt(
    PhosphorIconsStyle.fill,
  )
)
// قد لا يكون متوفر في كل إصدار Phosphor
```

**الحل المقترح:** التحقق من توفر الأيقونة أو استخدام بديل

---

### 5.2 Widgets تستخدم Color بشكل متكرر

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/widgets/common/*`

**الوصف:** كل widget يعرف ألوانه الخاصة بدلاً من استخدام Theme

---

## القسم السادس: مشاكل Performance 🟢

### 6.1 Box getters بدون تحقق

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/data/datasources/local/database/app_database.dart:41-47`

```dart
static Box<ServerModel> get serversBox => Hive.box<ServerModel>(serversBoxName);
// ← crash لو Box غير مفتوح
```

**الحل المقترح:** إضافة تحقق

---

### 6.2 إعادة تحميل قائمة السيرفرات في كل عملية

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/data/repositories/session_repository_impl.dart`

**الوصف:** كل عملية API تستدعي `getServers()` من جديد

---

## القسم السابع: مشاكل الكود الميت (Dead Code) 💀

### 7.1 Use Cases غير مستخدمة

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/domain/usecases/`

16 ملف Use Case غير مستخدمة

---

### 7.2 دوال في Repository غير مُستدعاة

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/domain/repositories/server_repository.dart`

```dart
Future<void> updateLastUsed(String id);
// قد تُستدعى لكن بشكل خاطئ
```

---

## ملخص المشاكل حسب الأولوية

### 🔴 يجب الإصلاح فوراً (قبل الإنتاج):

1. تخزين password بشكل غير آمن (3 مشاكل)
2. استخدام السيرفر الأول دائماً (1 مشكلة كبيرة)
3. Null Safety في Router (3 مشاكل)
4. استخدام http بدلاً من https (1 مشكلة)

### 🟡 يجب الإصلاح قبل التوسع:

4. Use Cases غير مستخدمة
5. Dependency Injection مفقود
6. Features غير مكتملة (8 مشاكل)
7. SecureStorage/TestConnection instances مكررين

### 🟢 تحسينات:

7. Performance
8. UI consistency
9. Code cleanup

---

## خطة الإصلاح المقترحة

### المرحلة 1: الأمان (يوم واحد)
- [ ] إزالة password من Server Entity و Model
- [ ] إصلاح Session Repository لجلب password من SecureStorage
- [ ] إضافة null checks في Router

### المرحلة 2: Architecture (يومان)
- [ ] إنشاء Current Server Provider
- [ ] إصلاح Repository لاستخدام serverId الممرر
- [ ] إنشاء singleton للـ Repositories

### المرحلة 3: Features (يومان)
- [ ] تنفيذ _connectToServer
- [ ] تنفيذ Open in Nexor
- [ ] تنفيذ Directory Picker
- [ ] تنفيذ File Attachment
- [ ] تنفيذ Export

### المرحلة 4: Refactoring (يوم واحد)
- [ ] حذف Use Cases غير المستخدمة
- [ ] تحسين Performance
- [ ] إضافة Tests

---

**إجمالي الوقت المتوقع:** 5-7 أيام عمل
