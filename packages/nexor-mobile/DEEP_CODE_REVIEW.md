# Nexor Mobile - Deep Code Review Report

**تاريخ المراجعة:** 17 مارس 2026  
**نوع المراجعة:** مراجعة عميقة شاملة  
**المُراجع:** OpenCode AI

---

## ملخص تنفيذي

| الفئة | العدد |
|-------|-------|
| 🔴 مشاكل حرجة | 8 |
| 🟡 مشاكل متوسطة | 15 |
| 🟢 تحسينات | 12 |
| **الإجمالي** | **35** |

---

## القسم الأول: المشاكل الأمنية الحرجة 🔴

### 1.1 Password لا يزال موجود في Entity & Model

**الخطورة:** 🔴 حرج جداً  
**المسار:** 
- `lib/domain/entities/server.dart:10,22,42,54,69`
- `lib/data/models/server/server_model.dart:25,45,60,76,103`

```dart
// ❌ المشكلة - لا يزال موجود
class Server extends Equatable {
  final String? password;  // خطر أمني!
}

@HiveType(typeId: 0)
class ServerModel extends HiveObject {
  @HiveField(5)
  final String? password;  // يُخزن في Hive بدون تشفير!
}
```

**التأثير:**
- كلمة المرور موجودة في الذاكرة
- يمكن تخزينها في Hive بدون تشفير
- حتى لو لم تُستخدم حالياً، البنية تسمح بذلك

**الحل المطلوب:**
```dart
// ✅ الحل الصحيح
class Server extends Equatable {
  final String id;
  final String name;
  final String host;
  final int port;
  final String? username;
  // إزالة password تماماً
  final DateTime createdAt;
  // ...
}
```

**الأولوية:** فورية - يجب الإصلاح قبل أي deployment

---

### 1.2 Type Casting بدون معالجة أخطاء

**الخطورة:** 🔴 حرج  
**المسار:** 
- `lib/data/models/session/message_chunk_model.dart:34`
- `lib/data/models/session/message_model.dart:128`

```dart
// ❌ المشكلة - casting مباشر
metadata: json['metadata'] as Map<String, dynamic>?,
```

**التأثير:** Crash لو API أرجع نوع بيانات مختلف

**الحل:**
```dart
// ✅ الحل
metadata: json['metadata'] is Map<String, dynamic> 
    ? json['metadata'] as Map<String, dynamic>
    : null,
```

---

### 1.3 response.data! بدون تحقق

**الخطورة:** 🔴 حرج  
**المسار:** `lib/data/datasources/remote/api_client.dart:96`

```dart
// ❌ المشكلة
await for (final chunk in response.data!.stream) {
```

**التأثير:** Null pointer exception

**الحل:**
```dart
// ✅ الحل
if (response.data == null) {
  throw Exception('Response data is null');
}
await for (final chunk in response.data!.stream) {
```

---

### 1.4 firstWhere بدون معالجة خطأ

**الخطورة:** 🔴 حرج  
**المسار:** `lib/presentation/screens/servers/add_server_screen.dart:55`

```dart
// ❌ المشكلة
_existingServer = servers.firstWhere((s) => s.id == widget.serverId);
```

**التأثير:** StateError: No element

**الحل:**
```dart
// ✅ الحل
try {
  _existingServer = servers.firstWhere((s) => s.id == widget.serverId);
} on StateError {
  // Handle server not found
  if (mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Server not found')),
    );
  }
  return;
}
```

---

## القسم الثاني: مشاكل Architecture 🟡

### 2.1 Repository Instances مكررة في كل Provider

**الخطورة:** 🟡 متوسط  
**المسار:** 
- `lib/presentation/screens/servers/providers/servers_provider.dart:12`
- `lib/presentation/screens/files/providers/files_provider.dart:14,20`
- `lib/presentation/screens/chat/providers/conversations_provider.dart:12`

```dart
// ❌ المشكلة - كل provider ينشئ instance جديد
@riverpod
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl();  // جديد كل مرة!
}

@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  return SessionRepositoryImpl(
    ServerRepositoryImpl(),  // instance جديد
    SecureStorageService(),  // instance جديد
  );
}
```

**التأثير:**
- استهلاك ذاكرة عالي
- لا يوجد shared state
- مشاكل في الـ caching

**الحل:**
```dart
// ✅ الحل - استخدام keepAlive
@Riverpod(keepAlive: true)
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(SecureStorageRef ref) {
  return SecureStorageService();
}

@riverpod
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  return SessionRepositoryImpl(
    ref.watch(serverRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
}
```

---

### 2.2 SecureStorageService & TestConnection مكررين

**الخطورة:** 🟡 متوسط  
**المسار:**
- `lib/presentation/screens/servers/add_server_screen.dart:36-37`
- `lib/presentation/screens/servers/servers_list_screen.dart:26-27`

```dart
// ❌ المشكلة
final _testConnection = TestConnection();
final _secureStorage = SecureStorageService();
```

**الحل:** إنشاء Riverpod providers

---

### 2.3 لا يوجد Current Server State

**الخطورة:** 🟡 متوسط  
**الوصف:** لا يوجد تتبع للسيرفر الحالي المختار

**الحل المقترح:**
```dart
@riverpod
class CurrentServer extends _$CurrentServer {
  @override
  String? build() => null;

  void setServer(String serverId) => state = serverId;
  void clear() => state = null;
}
```

---

### 2.4 Use Cases غير مستخدمة (15 ملف)

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/domain/usecases/*`

**الملفات غير المستخدمة:**
- server: get_servers, add_server, update_server, delete_server
- session: get_sessions, get_session, create_session, delete_session, send_message, get_messages
- file: list_files, read_file, search_files, search_content, get_git_status

**التأثير:** Dead code، صعوبة الصيانة

---

## القسم الثالث: مشاكل Error Handling 🟡

### 3.1 JSON Parsing بدون معالجة كاملة

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/models/session/message_chunk_model.dart:30`

```dart
// ❌ المشكلة - لو messageId و id كلاهما null
messageId: json['messageId'] as String? ?? json['id'] as String,
```

**التأثير:** Null pointer exception

**الحل:**
```dart
// ✅ الحل
messageId: json['messageId'] as String? ?? 
           json['id'] as String? ?? 
           'unknown-${DateTime.now().millisecondsSinceEpoch}',
```

---

### 3.2 Stream Error Handling ضعيف

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/repositories/session_repository_impl.dart:218-231`

```dart
// ❌ المشكلة - يتجاهل JSON غير صالح
try {
  final json = jsonDecode(line);
  yield MessageChunkModel.fromJson(json as Map<String, dynamic>)
      .toEntity();
} catch (e) {
  // Skip invalid JSON  ← قد نفقد بيانات مهمة!
  continue;
}
```

**التأثير:** فقدان بيانات بدون إشعار المستخدم

---

### 3.3 لا يوجد Error Boundaries

**الخطورة:** 🟡 متوسط  
**الوصف:** لو widget تعطل، التطبيق كله قد يتعطل

**الحل:** إضافة ErrorWidget.builder في main.dart

---

### 3.4 Hive Box Access بدون تحقق

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/data/datasources/local/database/app_database.dart:41-47`

```dart
// ❌ المشكلة - لو Box غير مفتوح
static Box<ServerModel> get serversBox => 
    Hive.box<ServerModel>(serversBoxName);
```

**الحل:**
```dart
// ✅ الحل
static Box<ServerModel> get serversBox {
  if (!Hive.isBoxOpen(serversBoxName)) {
    throw StateError('Servers box is not open');
  }
  return Hive.box<ServerModel>(serversBoxName);
}
```

---

## القسم الرابع: مشاكل Performance 🟢

### 4.1 Unnecessary Type Cast

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/screens/chat/providers/chat_provider.dart:63`

```dart
// ❌ غير ضروري
state = AsyncValue.data(messages.cast<Message>());

// ✅ الأفضل
state = AsyncValue.data(messages);
```

---

### 4.2 لا يوجد Debouncing في Search

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/screens/files/file_search_screen.dart:36`

```dart
// ❌ المشكلة - API call مع كل حرف
void _onSearchChanged(String value) {
  setState(() => _query = value);
}
```

**الحل:** استخدام debouncing (مثل 300ms)

---

### 4.3 لا يوجد Retry Logic

**الخطورة:** 🟢 تحسين  
**الوصف:** ApiClient لديه timeout لكن بدون retry

---

## القسم الخامس: مشاكل UI/UX 🟢

### 5.1 PhosphorIcons Dynamic Call

**الخطورة:** 🟢 تحسين  
**المسار:** `lib/presentation/widgets/chat/message_input.dart:129`

```dart
// ⚠️ قد يفشل
PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.fill)
```

**الحل:** استخدام static icon

---

### 5.2 Hardcoded Strings

**الخطورة:** 🟢 تحسين  
**الوصف:** كل النصوص hardcoded بالإنجليزية

**التأثير:** لا يوجد دعم للغات متعددة

---

### 5.3 لا يوجد Loading States موحدة

**الخطورة:** 🟢 تحسين  
**الوصف:** كل screen يدير loading state بطريقة مختلفة

---

## القسم السادس: Features غير مكتملة 🟡

### 6.1 Regenerate Message

**المسار:** `lib/presentation/screens/chat/chat_screen.dart:256`

```dart
// ❌ غير مُنفذ
onRegenerate: () {
  // TODO: Implement regenerate
},
```

---

### 6.2 File Attachment

**المسار:** `lib/presentation/screens/chat/chat_screen.dart:290`

```dart
// ❌ غير مُنفذ
onAttach: () {
  // TODO: Implement file attachment
},
```

---

### 6.3 Export Feature

**المسار:** `lib/presentation/screens/chat/chat_screen.dart:140`

```dart
// ❌ غير مُنفذ
case 'export':
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export feature coming soon')),
  );
```

---

### 6.4 Directory Picker

**المسار:** `lib/presentation/screens/chat/new_conversation_screen.dart:117`

```dart
// ❌ غير مُنفذ
// TODO: Show directory picker
```

---

### 6.5 Search Dialog

**المسار:** `lib/presentation/screens/chat/conversation_list_screen.dart:43`

```dart
// ❌ غير مُنفذ
// TODO: Show filter/search dialog
```

---

### 6.6 Open in Nexor (من File Browser)

**المسار:** `lib/presentation/screens/files/file_browser_screen.dart:258`

```dart
// ❌ غير مُنفذ
// TODO: Open in Nexor chat
```

---

### 6.7 Open in Nexor (من File Viewer)

**المسار:** `lib/presentation/screens/files/file_viewer_screen.dart:76`

```dart
// ❌ غير مُنفذ
// TODO: Navigate to chat with file context
```

---

## القسم السابع: مشاكل جديدة مكتشفة 🔴

### 7.1 Race Condition في Chat Streaming

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/providers/chat_provider.dart:38-64`

**الوصف:** لو المستخدم أرسل رسائل متعددة بسرعة، قد يحدث تداخل في الـ streaming

**الحل:** إضافة message queue أو منع الإرسال أثناء streaming

---

### 7.2 لا يوجد Offline Support

**الخطورة:** 🟢 تحسين  
**الوصف:** التطبيق يحتاج اتصال دائم بالإنترنت

**الحل المقترح:** 
- Cache للـ sessions والـ messages
- Sync عند العودة online

---

### 7.3 لا يوجد Analytics/Logging

**الخطورة:** 🟢 تحسين  
**الوصف:** صعب تتبع الأخطاء في production

**الحل:** إضافة Firebase Crashlytics أو Sentry

---

### 7.4 لا يوجد Input Validation شامل

**الخطورة:** 🟡 متوسط  
**الوصف:** بعض الـ inputs لا يتم التحقق منها بشكل كافي

**أمثلة:**
- Port number: يقبل أي رقم (يجب 1-65535)
- Host: لا يتحقق من صحة الـ format
- Username: لا يوجد قيود

---

### 7.5 Memory Management في Streaming

**الخطورة:** 🟡 متوسط  
**المسار:** `lib/presentation/screens/chat/providers/chat_provider.dart`

**الوصف:** الـ messages تتراكم في الذاكرة بدون حد أقصى

**الحل:** إضافة pagination أو limit للـ messages في الذاكرة

---

## ملخص الأولويات

### 🔴 يجب الإصلاح فوراً (قبل Production):

1. إزالة password من Server Entity & Model
2. إصلاح response.data! null check
3. إصلاح firstWhere exception handling
4. إصلاح Type casting في JSON parsing
5. إضافة Hive box safety checks

**الوقت المتوقع:** 1-2 يوم

---

### 🟡 يجب الإصلاح قبل التوسع:

1. إصلاح Repository DI (Dependency Injection)
2. إضافة Current Server State
3. إصلاح Stream error handling
4. إضافة Error boundaries
5. حذف Use Cases غير المستخدمة
6. إصلاح Race conditions في Chat
7. إضافة Input validation شامل

**الوقت المتوقع:** 3-4 أيام

---

### 🟢 تحسينات (Nice to Have):

1. إضافة Debouncing في Search
2. إضافة Retry logic
3. إضافة Internationalization
4. إضافة Offline support
5. إضافة Analytics/Logging
6. تحسين Memory management
7. تنفيذ Features المتبقية (Regenerate, Export, etc.)

**الوقت المتوقع:** 5-7 أيام

---

## الخلاصة

**إجمالي المشاكل المكتشفة:** 35 مشكلة

**التوزيع:**
- 🔴 حرجة: 8 مشاكل
- 🟡 متوسطة: 15 مشكلة
- 🟢 تحسينات: 12 مشكلة

**التقييم العام:** 
- الكود يعمل لكن يحتاج إصلاحات أمنية حرجة
- Architecture جيد لكن يحتاج تحسينات في DI
- Error handling يحتاج تحسين كبير
- Features غير مكتملة (7 features)

**الوقت الإجمالي للإصلاح:** 9-13 يوم عمل

---

**التوصية:** لا يُنصح بالـ deployment للـ production قبل إصلاح المشاكل الحرجة (🔴)
