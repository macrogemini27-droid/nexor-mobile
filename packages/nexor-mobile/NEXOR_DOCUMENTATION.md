# 📱 Nexor - وثائق المشروع الشاملة

## 📋 جدول المحتويات

1. [نظرة عامة على المشروع](#نظرة-عامة-على-المشروع)
2. [الرؤية والأهداف](#الرؤية-والأهداف)
3. [المعماري التقني](#المعماري-التقني)
4. [نظام التصميم](#نظام-التصميم)
5. [هيكل المشروع](#هيكل-المشروع)
6. [المكتبات والتبعيات](#المكتبات-والتبعيات)
7. [الميزات التفصيلية](#الميزات-التفصيلية)
8. [تكامل API](#تكامل-api)
9. [إدارة الحالة](#إدارة-الحالة)
10. [الأمان والحماية](#الأمان-والحماية)
11. [الأداء والتحسين](#الأداء-والتحسين)
12. [الاختبارات](#الاختبارات)
13. [خطة التنفيذ](#خطة-التنفيذ)
14. [النشر والإطلاق](#النشر-والإطلاق)

---

## 🎯 نظرة عامة على المشروع

### ما هو Nexor؟

**Nexor** هو تطبيق موبايل متقدم مبني بتقنية Flutter يتيح للمطورين استخدام OpenCode (AI Coding Agent) من هواتفهم الذكية بشكل كامل. التطبيق يوفر تجربة مستخدم عصرية وسلسة مع تصميم داكن مستوحى من Apple، مما يمكن المطورين من:

- إدارة خوادم VPS متعددة
- تصفح وإدارة ملفات المشاريع
- التفاعل مع AI لكتابة وتعديل الكود
- متابعة المحادثات والتغييرات في الوقت الفعلي
- العمل على المشاريع من أي مكان

### المشكلة التي يحلها

المطورون يحتاجون أحيانًا للعمل على مشاريعهم أثناء التنقل، لكن:
- OpenCode الحالي يعمل فقط على Terminal/Desktop
- لا يوجد طريقة سهلة للوصول للكود من الموبايل
- التطبيقات الموجودة لا توفر تجربة AI coding كاملة

**Nexor يحل هذه المشكلة** بتوفير واجهة موبايل كاملة تتصل بـ OpenCode server على VPS الخاص بك.

### الجمهور المستهدف

- **المطورون المحترفون**: الذين يعملون على مشاريع متعددة
- **Freelancers**: الذين يحتاجون للمرونة في العمل
- **DevOps Engineers**: لإدارة السيرفرات والمشاريع
- **الطلاب والمتعلمون**: الذين يريدون التعلم أثناء التنقل

---

## 🎯 الرؤية والأهداف

### الرؤية
أن يصبح Nexor الأداة الأولى للمطورين للعمل على مشاريعهم من الموبايل، مع تجربة مستخدم لا تقل عن تجربة Desktop.

### الأهداف الرئيسية

#### 1. تجربة مستخدم استثنائية
- تصميم عصري وأنيق بثيم داكن
- انتقالات سلسة وحركات طبيعية
- استجابة فورية للتفاعلات
- واجهة بديهية لا تحتاج تعليمات

#### 2. أداء عالي
- تحميل سريع (< 2 ثانية)
- استهلاك منخفض للبطارية
- استخدام فعال للذاكرة
- عمل سلس حتى على الأجهزة المتوسطة

#### 3. موثوقية وأمان
- حماية كاملة للبيانات الحساسة
- اتصال آمن بالسيرفرات
- عدم فقدان البيانات
- معدل crash أقل من 1%

#### 4. مرونة وقابلية التوسع
- دعم خوادم متعددة
- دعم مشاريع متعددة
- إمكانية العمل offline
- سهولة إضافة ميزات جديدة

---

## 🏗️ المعماري التقني

### نظرة عامة على المعماري

```
┌─────────────────────────────────────────────────────────┐
│                    Nexor Mobile App                      │
│                     (Flutter)                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Presentation │  │   Domain     │  │     Data     │ │
│  │    Layer     │  │    Layer     │  │    Layer     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                  │                  │         │
│         └──────────────────┴──────────────────┘         │
│                          │                               │
└──────────────────────────┼───────────────────────────────┘
                           │
                           │ HTTPS/WebSocket/SSH
                           │
┌──────────────────────────▼───────────────────────────────┐
│                   VPS Server                             │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         OpenCode Server (Port 4096)                │ │
│  │                                                    │ │
│  │  • REST API                                       │ │
│  │  • WebSocket (Real-time)                         │ │
│  │  • File System Access                            │ │
│  │  • Git Operations                                │ │
│  │  • AI Model Integration                          │ │
│  └────────────────────────────────────────────────────┘ │
│                          │                               │
│                          ▼                               │
│              ┌─────────────────────┐                    │
│              │   Project Files     │                    │
│              │   Git Repository    │                    │
│              └─────────────────────┘                    │
└──────────────────────────────────────────────────────────┘
```

### Clean Architecture Pattern

نستخدم **Clean Architecture** لضمان:
- فصل واضح بين الطبقات
- سهولة الاختبار
- قابلية الصيانة
- إمكانية تبديل التقنيات

#### الطبقات الثلاث:

**1. Presentation Layer (طبقة العرض)**
```
المسؤولية: عرض البيانات والتفاعل مع المستخدم
المكونات:
  - Screens (الشاشات)
  - Widgets (المكونات)
  - State Management (Riverpod Providers)
  - Navigation (GoRouter)
```

**2. Domain Layer (طبقة المنطق)**
```
المسؤولية: منطق العمل الأساسي
المكونات:
  - Entities (الكيانات)
  - Use Cases (حالات الاستخدام)
  - Repository Interfaces (واجهات المستودعات)
```

**3. Data Layer (طبقة البيانات)**
```
المسؤولية: جلب وحفظ البيانات
المكونات:
  - Models (النماذج)
  - Repositories (المستودعات)
  - Data Sources (مصادر البيانات)
    • Remote (API)
    • Local (Database)
```

### تدفق البيانات

```
User Action
    ↓
Widget (Presentation)
    ↓
Provider (State Management)
    ↓
Use Case (Domain)
    ↓
Repository (Data)
    ↓
Data Source (Remote/Local)
    ↓
API/Database
    ↓
← Response ←
    ↓
Model → Entity
    ↓
Provider Updates State
    ↓
Widget Rebuilds
    ↓
UI Updates
```

---

## 🎨 نظام التصميم

### فلسفة التصميم

**"Simplicity meets Power"**

التصميم يجمع بين البساطة والقوة، مستوحى من:
- **Apple Design**: نظيف، أنيق، بديهي
- **Material Design 3**: مكونات حديثة ومرنة
- **Glassmorphism**: عمق وشفافية
- **Neumorphism**: تفاصيل دقيقة

### نظام الألوان

#### الألوان الأساسية (Dark Theme)

```dart
// Background Colors
static const background = Color(0xFF000000);      // Pure Black
static const backgroundElevated = Color(0xFF0A0A0A);
static const surface = Color(0xFF1C1C1E);
static const surfaceElevated = Color(0xFF2C2C2E);
static const surfaceHighlight = Color(0xFF3A3A3C);

// Accent Colors
static const primary = Color(0xFF0A84FF);         // iOS Blue
static const primaryDark = Color(0xFF0066CC);
static const primaryLight = Color(0xFF409CFF);

// Semantic Colors
static const success = Color(0xFF30D158);         // Green
static const warning = Color(0xFF FF9F0A);        // Orange
static const error = Color(0xFFFF453A);           // Red
static const info = Color(0xFF64D2FF);            // Light Blue

// Text Colors
static const textPrimary = Color(0xFFFFFFFF);
static const textSecondary = Color(0xFFAAAAAA);
static const textTertiary = Color(0xFF666666);
static const textDisabled = Color(0xFF444444);

// Border & Divider
static const border = Color(0xFF2C2C2E);
static const divider = Color(0xFF1C1C1E);

// Code Syntax Colors (VS Code Dark+)
static const codeKeyword = Color(0xFFC586C0);
static const codeString = Color(0xFFCE9178);
static const codeNumber = Color(0xFFB5CEA8);
static const codeComment = Color(0xFF6A9955);
static const codeFunction = Color(0xFFDCDCAA);
static const codeVariable = Color(0xFF9CDCFE);
```

#### الألوان الثانوية

```dart
// Status Colors
static const online = Color(0xFF30D158);
static const offline = Color(0xFF666666);
static const connecting = Color(0xFFFF9F0A);

// Git Status Colors
static const gitModified = Color(0xFFFF9F0A);
static const gitAdded = Color(0xFF30D158);
static const gitDeleted = Color(0xFFFF453A);
static const gitUntracked = Color(0xFF64D2FF);
```

### نظام الطباعة (Typography)

```dart
// Font Families
static const primaryFont = 'SF Pro Display';      // iOS style
static const fallbackFont = 'Inter';              // Web safe
static const codeFont = 'JetBrains Mono';         // Code blocks

// Font Sizes
static const h1 = 34.0;      // Large Title
static const h2 = 28.0;      // Title 1
static const h3 = 22.0;      // Title 2
static const h4 = 20.0;      // Title 3
static const body1 = 17.0;   // Body
static const body2 = 15.0;   // Callout
static const caption = 13.0; // Caption
static const small = 11.0;   // Small

// Font Weights
static const thin = FontWeight.w100;
static const light = FontWeight.w300;
static const regular = FontWeight.w400;
static const medium = FontWeight.w500;
static const semibold = FontWeight.w600;
static const bold = FontWeight.w700;
static const heavy = FontWeight.w900;

// Line Heights
static const lineHeightTight = 1.2;
static const lineHeightNormal = 1.5;
static const lineHeightRelaxed = 1.8;
```

### نظام المسافات (Spacing)

```dart
// Spacing Scale (8pt grid system)
static const space4 = 4.0;
static const space8 = 8.0;
static const space12 = 12.0;
static const space16 = 16.0;
static const space20 = 20.0;
static const space24 = 24.0;
static const space32 = 32.0;
static const space48 = 48.0;
static const space64 = 64.0;

// Semantic Spacing
static const paddingSmall = space8;
static const paddingMedium = space16;
static const paddingLarge = space24;
static const paddingXLarge = space32;

static const marginSmall = space8;
static const marginMedium = space16;
static const marginLarge = space24;
static const marginXLarge = space32;

// Component Spacing
static const cardPadding = space16;
static const listItemPadding = space12;
static const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
static const inputPadding = EdgeInsets.all(16);
```

### نظام الحواف (Border Radius)

```dart
static const radiusSmall = 8.0;
static const radiusMedium = 12.0;
static const radiusLarge = 16.0;
static const radiusXLarge = 20.0;
static const radiusFull = 9999.0;

// Component Radius
static const cardRadius = radiusMedium;
static const buttonRadius = radiusMedium;
static const inputRadius = radiusMedium;
static const modalRadius = radiusLarge;
static const chipRadius = radiusFull;
```

### نظام الظلال (Shadows)

```dart
// Elevation Shadows
static final shadow1 = BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 2),
);

static final shadow2 = BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 8,
  offset: Offset(0, 4),
);

static final shadow3 = BoxShadow(
  color: Colors.black.withOpacity(0.12),
  blurRadius: 16,
  offset: Offset(0, 8),
);

static final shadow4 = BoxShadow(
  color: Colors.black.withOpacity(0.16),
  blurRadius: 24,
  offset: Offset(0, 12),
);

// Glow Effects
static final glowPrimary = BoxShadow(
  color: primary.withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 2,
);

static final glowSuccess = BoxShadow(
  color: success.withOpacity(0.3),
  blurRadius: 20,
  spreadRadius: 2,
);
```

### نظام الحركة (Animation)

```dart
// Duration
static const durationFast = Duration(milliseconds: 150);
static const durationNormal = Duration(milliseconds: 250);
static const durationSlow = Duration(milliseconds: 400);

// Curves
static const curveDefault = Curves.easeInOut;
static const curveEmphasized = Curves.easeOutCubic;
static const curveDecelerate = Curves.decelerate;
static const curveAccelerate = Curves.accelerate;

// Transitions
static const fadeTransition = FadeTransition;
static const slideTransition = SlideTransition;
static const scaleTransition = ScaleTransition;
```

### المكونات الأساسية (Core Components)

#### 1. NexorButton

```dart
// Primary Button
NexorButton(
  text: 'Connect',
  onPressed: () {},
  type: ButtonType.primary,
  size: ButtonSize.medium,
  icon: Icons.link,
  loading: false,
  disabled: false,
)

// Variants
- primary: الزر الأساسي (أزرق)
- secondary: زر ثانوي (رمادي)
- danger: زر خطر (أحمر)
- ghost: زر شفاف
- text: زر نصي فقط

// Sizes
- small: 32px height
- medium: 44px height
- large: 56px height
```

#### 2. NexorCard

```dart
// Card with glassmorphism effect
NexorCard(
  child: Widget,
  padding: EdgeInsets,
  onTap: () {},
  elevation: 2,
  blur: true,
  gradient: false,
)

// Features
- Glassmorphism effect
- Subtle shadows
- Hover states
- Press animations
- Optional gradient background
```

#### 3. NexorInput

```dart
// Text Input
NexorInput(
  label: 'Server Address',
  hint: 'Enter IP or domain',
  controller: controller,
  validator: (value) {},
  obscureText: false,
  prefixIcon: Icons.server,
  suffixIcon: Icons.clear,
  maxLines: 1,
)

// Features
- Floating label
- Error states
- Success states
- Character counter
- Clear button
- Password toggle
```

#### 4. NexorAppBar

```dart
// Custom App Bar
NexorAppBar(
  title: 'Nexor',
  leading: IconButton,
  actions: [IconButton],
  transparent: false,
  blur: true,
)

// Features
- Blur effect
- Gradient background
- Smooth scroll behavior
- Custom height
```

---

## 📁 هيكل المشروع التفصيلي

### الهيكل الكامل

```
packages/nexor-mobile/
│
├── lib/
│   ├── main.dart                          # نقطة البداية
│   ├── app.dart                           # تكوين التطبيق
│   │
│   ├── core/                              # الأساسيات المشتركة
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # Theme configuration
│   │   │   ├── colors.dart               # Color palette
│   │   │   ├── typography.dart           # Text styles
│   │   │   ├── dimensions.dart           # Spacing & sizes
│   │   │   ├── shadows.dart              # Shadow definitions
│   │   │   └── animations.dart           # Animation configs
│   │   │
│   │   ├── constants/
│   │   │   ├── api_constants.dart        # API endpoints
│   │   │   ├── app_constants.dart        # App configs
│   │   │   ├── storage_keys.dart         # Storage keys
│   │   │   └── route_names.dart          # Route paths
│   │   │
│   │   ├── utils/
│   │   │   ├── logger.dart               # Logging utility
│   │   │   ├── validators.dart           # Input validators
│   │   │   ├── formatters.dart           # Data formatters
│   │   │   ├── date_utils.dart           # Date helpers
│   │   │   └── file_utils.dart           # File helpers
│   │   │
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart   # BuildContext extensions
│   │   │   ├── string_extensions.dart    # String helpers
│   │   │   ├── datetime_extensions.dart  # DateTime helpers
│   │   │   └── list_extensions.dart      # List helpers
│   │   │
│   │   ├── errors/
│   │   │   ├── exceptions.dart           # Custom exceptions
│   │   │   ├── failures.dart             # Failure classes
│   │   │   └── error_handler.dart        # Global error handler
│   │   │
│   │   └── network/
│   │       ├── network_info.dart         # Network status
│   │       └── ssl_pinning.dart          # Certificate pinning
│   │
│   ├── data/                              # طبقة البيانات
│   │   ├── models/
│   │   │   ├── server/
│   │   │   │   ├── server_model.dart
│   │   │   │   ├── server_model.g.dart   # Generated
│   │   │   │   └── connection_info.dart
│   │   │   │
│   │   │   ├── session/
│   │   │   │   ├── session_model.dart
│   │   │   │   ├── message_model.dart
│   │   │   │   ├── part_model.dart
│   │   │   │   └── todo_model.dart
│   │   │   │
│   │   │   ├── file/
│   │   │   │   ├── file_node_model.dart
│   │   │   │   ├── file_content_model.dart
│   │   │   │   └── file_status_model.dart
│   │   │   │
│   │   │   └── common/
│   │   │       ├── response_model.dart
│   │   │       └── error_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── server_repository_impl.dart
│   │   │   ├── session_repository_impl.dart
│   │   │   ├── file_repository_impl.dart
│   │   │   └── auth_repository_impl.dart
│   │   │
│   │   └── datasources/
│   │       ├── remote/
│   │       │   ├── api_client.dart       # Dio client
│   │       │   ├── websocket_client.dart # WebSocket
│   │       │   ├── ssh_client.dart       # SSH/SFTP
│   │       │   └── interceptors/
│   │       │       ├── auth_interceptor.dart
│   │       │       ├── logging_interceptor.dart
│   │       │       └── error_interceptor.dart
│   │       │
│   │       └── local/
│   │           ├── database/
│   │           │   ├── app_database.dart # Hive setup
│   │           │   ├── boxes.dart        # Box definitions
│   │           │   └── adapters/
│   │           │       ├── server_adapter.dart
│   │           │       └── session_adapter.dart
│   │           │
│   │           └── storage/
│   │               ├── secure_storage.dart
│   │               └── preferences.dart
│   │
│   ├── domain/                            # طبقة المنطق
│   │   ├── entities/
│   │   │   ├── server.dart
│   │   │   ├── session.dart
│   │   │   ├── message.dart
│   │   │   ├── file_node.dart
│   │   │   └── conversation.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── server_repository.dart    # Interface
│   │   │   ├── session_repository.dart
│   │   │   ├── file_repository.dart
│   │   │   └── auth_repository.dart
│   │   │
│   │   └── usecases/
│   │       ├── server/
│   │       │   ├── add_server.dart
│   │       │   ├── connect_server.dart
│   │       │   ├── disconnect_server.dart
│   │       │   ├── delete_server.dart
│   │       │   └── test_connection.dart
│   │       │
│   │       ├── session/
│   │       │   ├── create_session.dart
│   │       │   ├── get_sessions.dart
│   │       │   ├── send_message.dart
│   │       │   ├── stream_response.dart
│   │       │   └── delete_session.dart
│   │       │
│   │       └── file/
│   │           ├── list_files.dart
│   │           ├── read_file.dart
│   │           ├── search_files.dart
│   │           └── get_file_status.dart
│   │
│   ├── presentation/                      # طبقة العرض
│   │   ├── app/
│   │   │   ├── app_router.dart           # GoRouter config
│   │   │   └── app_providers.dart        # Global providers
│   │   │
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   └── splash_provider.dart
│   │   │   │
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   ├── onboarding_page.dart
│   │   │   │   └── onboarding_provider.dart
│   │   │   │
│   │   │   ├── servers/
│   │   │   │   ├── servers_list_screen.dart
│   │   │   │   ├── add_server_screen.dart
│   │   │   │   ├── server_details_screen.dart
│   │   │   │   └── providers/
│   │   │   │       ├── servers_provider.dart
│   │   │   │       └── server_form_provider.dart
│   │   │   │
│   │   │   ├── files/
│   │   │   │   ├── file_browser_screen.dart
│   │   │   │   ├── file_viewer_screen.dart
│   │   │   │   ├── file_search_screen.dart
│   │   │   │   └── providers/
│   │   │   │       ├── file_browser_provider.dart
│   │   │   │       └── file_search_provider.dart
│   │   │   │
│   │   │   ├── chat/
│   │   │   │   ├── chat_screen.dart
│   │   │   │   ├── conversation_list_screen.dart
│   │   │   │   ├── new_conversation_screen.dart
│   │   │   │   └── providers/
│   │   │   │       ├── chat_provider.dart
│   │   │   │       ├── conversation_provider.dart
│   │   │   │       └── message_stream_provider.dart
│   │   │   │
│   │   │   └── settings/
│   │   │       ├── settings_screen.dart
│   │   │       ├── theme_settings_screen.dart
│   │   │       ├── server_settings_screen.dart
│   │   │       └── providers/
│   │   │           └── settings_provider.dart
│   │   │
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── nexor_button.dart
│   │       │   ├── nexor_card.dart
│   │       │   ├── nexor_input.dart
│   │       │   ├── nexor_app_bar.dart
│   │       │   ├── nexor_bottom_sheet.dart
│   │       │   ├── nexor_dialog.dart
│   │       │   ├── nexor_snackbar.dart
│   │       │   ├── loading_indicator.dart
│   │       │   ├── empty_state.dart
│   │       │   ├── error_state.dart
│   │       │   └── skeleton_loader.dart
│   │       │
│   │       ├── server/
│   │       │   ├── server_card.dart
│   │       │   ├── server_status_badge.dart
│   │       │   ├── server_info_row.dart
│   │       │   └── connection_indicator.dart
│   │       │
│   │       ├── file/
│   │       │   ├── file_item.dart
│   │       │   ├── file_icon.dart
│   │       │   ├── breadcrumb_nav.dart
│   │       │   ├── file_status_badge.dart
│   │       │   └── file_preview.dart
│   │       │
│   │       ├── chat/
│   │       │   ├── message_bubble.dart
│   │       │   ├── user_message.dart
│   │       │   ├── ai_message.dart
│   │       │   ├── code_block.dart
│   │       │   ├── file_diff_viewer.dart
│   │       │   ├── typing_indicator.dart
│   │       │   ├── message_input.dart
│   │       │   └── tool_usage_card.dart
│   │       │
│   │       └── animations/
│   │           ├── fade_in_animation.dart
│   │           ├── slide_animation.dart
│   │           ├── scale_animation.dart
│   │           └── shimmer_animation.dart
│   │
│   └── services/
│       ├── storage_service.dart           # Hive operations
│       ├── secure_storage_service.dart    # Secure credentials
│       ├── notification_service.dart      # Push notifications
│       ├── analytics_service.dart         # Usage analytics
│       ├── biometric_service.dart         # Fingerprint/Face ID
│       └── haptic_service.dart            # Vibration feedback
│
├── assets/
│   ├── fonts/
│   │   ├── SF-Pro-Display-Regular.ttf
│   │   ├── SF-Pro-Display-Medium.ttf
│   │   ├── SF-Pro-Display-Semibold.ttf
│   │   ├── SF-Pro-Display-Bold.ttf
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Medium.ttf
│   │   ├── Inter-Semibold.ttf
│   │   ├── Inter-Bold.ttf
│   │   ├── JetBrainsMono-Regular.ttf
│   │   └── JetBrainsMono-Bold.ttf
│   │
│   ├── images/
│   │   ├── logo.png
│   │   ├── logo_dark.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   ├── onboarding_3.png
│   │   ├── empty_servers.png
│   │   ├── empty_files.png
│   │   └── empty_conversations.png
│   │
│   ├── icons/
│   │   └── app_icon.png
│   │
│   └── animations/
│       ├── loading.json                   # Lottie animation
│       ├── success.json
│       ├── error.json
│       └── connecting.json
│
├── test/
│   ├── unit/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── usecases/
│   │
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── integration/
│       └── app_test.dart
│
├── android/                               # Android config
├── ios/                                   # iOS config
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Linting rules
└── README.md                              # Project README
```

---

## 📦 المكتبات والتبعيات

### Dependencies الأساسية

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1              # State management
  riverpod_annotation: ^2.3.5           # Code generation

  # Navigation
  go_router: ^14.0.0                    # Declarative routing

  # HTTP & Networking
  dio: ^5.4.0                           # HTTP client
  web_socket_channel: ^2.4.0            # WebSocket
  connectivity_plus: ^5.0.2             # Network status

  # SSH/SFTP
  dartssh2: ^2.9.0                      # SSH client

  # Local Storage
  hive: ^2.2.3                          # NoSQL database
  hive_flutter: ^1.1.0                  # Hive Flutter integration
  flutter_secure_storage: ^9.0.0        # Secure storage
  shared_preferences: ^2.2.2            # Simple key-value

  # UI Components & Animations
  flutter_animate: ^4.5.0               # Declarative animations
  shimmer: ^3.0.0                       # Shimmer effect
  lottie: ^3.0.0                        # Lottie animations
  cached_network_image: ^3.3.1          # Image caching
  flutter_svg: ^2.0.10                  # SVG support

  # Code Highlighting
  flutter_highlight: ^0.7.0             # Syntax highlighting
  flutter_syntax_view: ^4.0.0           # Code viewer
  markdown_widget: ^2.3.0               # Markdown rendering

  # Icons
  phosphor_flutter: ^2.1.0              # Modern icons
  
  # Utilities
  intl: ^0.19.0                         # Internationalization
  path: ^1.9.0                          # Path manipulation
  uuid: ^4.3.0                          # UUID generation
  timeago: ^3.6.0                       # Relative time
  url_launcher: ^6.2.4                  # Open URLs
  share_plus: ^7.2.2                    # Share content
  
  # Biometrics & Security
  local_auth: ^2.2.0                    # Biometric auth
  flutter_vibrate: ^1.3.0               # Haptic feedback
  
  # Logging & Analytics
  logger: ^2.0.2                        # Logging
  sentry_flutter: ^7.15.0               # Error tracking (optional)

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting
  flutter_lints: ^3.0.0                 # Lint rules
  very_good_analysis: ^5.1.0            # Strict linting

  # Code Generation
  build_runner: ^2.4.8                  # Build tool
  hive_generator: ^2.0.1                # Hive adapters
  riverpod_generator: ^2.4.0            # Riverpod providers
  json_serializable: ^6.7.1             # JSON serialization

  # Testing
  mocktail: ^1.0.3                      # Mocking
  integration_test:
    sdk: flutter
```

### شرح المكتبات الرئيسية

#### 1. flutter_riverpod (State Management)

**لماذا Riverpod؟**
- Type-safe وآمن
- لا يعتمد على BuildContext
- سهل الاختبار
- DevTools ممتاز
- أداء عالي

**مثال الاستخدام:**
```dart
// Provider definition
@riverpod
class ServersNotifier extends _$ServersNotifier {
  @override
  Future<List<Server>> build() async {
    return await ref.read(serverRepositoryProvider).getServers();
  }

  Future<void> addServer(Server server) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(serverRepositoryProvider).addServer(server);
      return await ref.read(serverRepositoryProvider).getServers();
    });
  }

  Future<void> deleteServer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(serverRepositoryProvider).deleteServer(id);
      return await ref.read(serverRepositoryProvider).getServers();
    });
  }
}

// Usage in widget
class ServersScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversNotifierProvider);
    
    return serversAsync.when(
      data: (servers) => ListView.builder(
        itemCount: servers.length,
        itemBuilder: (context, index) => ServerCard(server: servers[index]),
      ),
      loading: () => LoadingIndicator(),
      error: (error, stack) => ErrorState(error: error.toString()),
    );
  }
}
```

#### 2. go_router (Navigation)

**لماذا GoRouter؟**
- Declarative routing
- Deep linking support
- Type-safe navigation
- URL-based routing

**مثال الاستخدام:**
```dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: '/servers',
      builder: (context, state) => ServersListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => AddServerScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ServerDetailsScreen(serverId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/files',
      builder: (context, state) {
        final serverId = state.uri.queryParameters['server'];
        return FileBrowserScreen(serverId: serverId);
      },
    ),
    GoRoute(
      path: '/chat/:sessionId',
      builder: (context, state) {
        final sessionId = state.pathParameters['sessionId']!;
        return ChatScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);

// Navigation examples
context.go('/servers');                    // Replace current route
context.push('/servers/add');              // Push new route
context.pop();                             // Go back
context.go('/chat/session-123');           // Navigate with params
```

#### 3. dio (HTTP Client)

**لماذا Dio؟**
- Interceptors قوية
- Request/Response transformation
- File upload/download
- Timeout handling
- Retry logic
- Cancel requests

**مثال الاستخدام:**
```dart
class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      options: options,
    );
  }

  // Stream request (for SSE)
  Stream<String> stream(String path) async* {
    final response = await _dio.get<ResponseBody>(
      path,
      options: Options(responseType: ResponseType.stream),
    );
    
    await for (final chunk in response.data!.stream) {
      yield utf8.decode(chunk);
    }
  }
}

// Auth Interceptor
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getStoredToken();
    if (token != null) {
      options.headers['Authorization'] = 'Basic $token';
    }
    handler.next(options);
  }
}

// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  final logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('REQUEST[${options.method}] => ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
    handler.next(err);
  }
}
```

#### 4. hive (Local Database)

**لماذا Hive؟**
- سريع جدًا (أسرع من SQLite)
- لا يحتاج native dependencies
- Type-safe مع code generation
- Encryption support
- Cross-platform

**مثال الاستخدام:**
```dart
// 1. Define Model
@HiveType(typeId: 0)
class Server extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String host;
  
  @HiveField(3)
  final int port;
  
  @HiveField(4)
  final String? username;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final DateTime? lastUsedAt;
  
  @HiveField(7)
  final bool autoConnect;

  Server({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    this.username,
    required this.createdAt,
    this.lastUsedAt,
    this.autoConnect = false,
  });
}

// 2. Initialize Hive
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ServerAdapter());
    Hive.registerAdapter(SessionAdapter());
    
    // Open boxes
    await Hive.openBox<Server>('servers');
    await Hive.openBox<Session>('sessions');
    await Hive.openBox('settings');
  }
}

// 3. Repository Implementation
class ServerRepositoryImpl implements ServerRepository {
  final Box<Server> _box = Hive.box<Server>('servers');

  @override
  Future<List<Server>> getServers() async {
    return _box.values.toList()
      ..sort((a, b) => b.lastUsedAt?.compareTo(a.lastUsedAt ?? DateTime(0)) ?? 0);
  }

  @override
  Future<Server?> getServer(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> addServer(Server server) async {
    await _box.put(server.id, server);
  }

  @override
  Future<void> updateServer(Server server) async {
    await _box.put(server.id, server);
  }

  @override
  Future<void> deleteServer(String id) async {
    await _box.delete(id);
  }

  @override
  Stream<List<Server>> watchServers() {
    return _box.watch().map((_) => getServers()).asyncMap((future) => future);
  }
}
```

#### 5. dartssh2 (SSH/SFTP Client)

**الاستخدام:**
```dart
class SSHService {
  SSHClient? _client;
  SftpClient? _sftp;

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    String? privateKey,
  }) async {
    final socket = await SSHSocket.connect(host, port);
    
    _client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: password != null ? () => password : null,
      identities: privateKey != null 
        ? [SSHKeyPair.fromPem(privateKey)]
        : null,
    );
    
    _sftp = await _client!.sftp();
  }

  Future<List<FileNode>> listFiles(String path) async {
    if (_sftp == null) throw Exception('Not connected');
    
    final items = await _sftp!.listdir(path);
    return items.map((item) {
      return FileNode(
        name: item.filename,
        path: '$path/${item.filename}',
        isDirectory: item.attr.isDirectory,
        size: item.attr.size ?? 0,
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(
          (item.attr.modifyTime ?? 0) * 1000,
        ),
      );
    }).toList();
  }

  Future<String> readFile(String path) async {
    if (_sftp == null) throw Exception('Not connected');
    
    final file = await _sftp!.open(path);
    final content = await file.readBytes();
    return utf8.decode(content);
  }

  Future<void> writeFile(String path, String content) async {
    if (_sftp == null) throw Exception('Not connected');
    
    final file = await _sftp!.open(
      path,
      mode: SftpFileOpenMode.write | SftpFileOpenMode.create,
    );
    await file.writeBytes(utf8.encode(content));
    await file.close();
  }

  Future<void> disconnect() async {
    _client?.close();
    _client = null;
    _sftp = null;
  }
}
```

#### 6. web_socket_channel (WebSocket)

**الاستخدام:**
```dart
class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  void connect(String url, {
    required Function(dynamic) onMessage,
    required Function(dynamic) onError,
    required Function() onDone,
  }) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    _subscription = _channel!.stream.listen(
      onMessage,
      onError: onError,
      onDone: onDone,
      cancelOnError: false,
    );
  }

  void send(dynamic message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _subscription = null;
  }
}

// Usage in Chat Provider
@riverpod
class ChatStreamNotifier extends _$ChatStreamNotifier {
  WebSocketService? _ws;

  @override
  Stream<Message> build(String sessionId) async* {
    final server = ref.read(currentServerProvider);
    final wsUrl = 'ws://${server.host}:${server.port}/session/$sessionId/stream';
    
    final controller = StreamController<Message>();
    
    _ws = WebSocketService();
    _ws!.connect(
      wsUrl,
      onMessage: (data) {
        final message = Message.fromJson(jsonDecode(data));
        controller.add(message);
      },
      onError: (error) {
        controller.addError(error);
      },
      onDone: () {
        controller.close();
      },
    );
    
    yield* controller.stream;
  }

  void sendMessage(String content) {
    _ws?.send(jsonEncode({
      'type': 'user',
      'content': content,
    }));
  }

  @override
  void dispose() {
    _ws?.disconnect();
    super.dispose();
  }
}
```

---

## 🎯 الميزات التفصيلية - Phase by Phase

### Phase 1: إدارة الخوادم (Server Management)

#### 1.1 شاشة قائمة الخوادم (Servers List Screen)

**المسار:** `lib/presentation/screens/servers/servers_list_screen.dart`

**الوظائف الأساسية:**
1. عرض جميع الخوادم المحفوظة في cards
2. عرض حالة الاتصال (Online/Offline/Connecting)
3. آخر وقت استخدام لكل خادم
4. إمكانية البحث عن خادم
5. Pull to refresh لتحديث الحالات
6. Swipe actions (Edit/Delete)
7. FAB لإضافة خادم جديد
8. Empty state عند عدم وجود خوادم

**UI Structure:**
```dart
class ServersListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(serversNotifierProvider);
    
    return Scaffold(
      appBar: NexorAppBar(
        title: 'Servers',
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.magnifyingGlass),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: Icon(PhosphorIcons.gear),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: serversAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyState(
              icon: PhosphorIcons.server,
              title: 'No Servers',
              message: 'Add your first server to get started',
              action: NexorButton(
                text: 'Add Server',
                onPressed: () => context.push('/servers/add'),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(serversNotifierProvider.future),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                return ServerCard(
                  server: servers[index],
                  onTap: () => _connectToServer(context, ref, servers[index]),
                  onEdit: () => _editServer(context, servers[index]),
                  onDelete: () => _deleteServer(context, ref, servers[index]),
                  onTest: () => _testConnection(context, ref, servers[index]),
                );
              },
            ),
          );
        },
        loading: () => Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(serversNotifierProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/servers/add'),
        icon: Icon(PhosphorIcons.plus),
        label: Text('Add Server'),
      ),
    );
  }

  Future<void> _connectToServer(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: 'Connecting...'),
    );
    
    try {
      await ref.read(connectionServiceProvider).connect(server);
      
      // Update last used time
      await ref.read(serversNotifierProvider.notifier).updateLastUsed(server.id);
      
      // Navigate to file browser
      if (context.mounted) {
        context.pop(); // Close loading
        context.go('/files?server=${server.id}');
      }
    } catch (e) {
      if (context.mounted) {
        context.pop(); // Close loading
        showErrorDialog(context, 'Connection failed: $e');
      }
    }
  }

  Future<void> _testConnection(
    BuildContext context,
    WidgetRef ref,
    Server server,
  ) async {
    final result = await ref.read(connectionServiceProvider).testConnection(server);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => NexorDialog(
          title: result.success ? 'Connection Successful' : 'Connection Failed',
          content: Text(result.message),
          icon: result.success 
            ? Icon(PhosphorIcons.checkCircle, color: AppColors.success)
            : Icon(PhosphorIcons.xCircle, color: AppColors.error),
          actions: [
            NexorButton(
              text: 'OK',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      );
    }
  }
}
```

**ServerCard Widget:**
```dart
class ServerCard extends StatelessWidget {
  final Server server;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(server.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Icon(PhosphorIcons.pencil, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Icon(PhosphorIcons.trash, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          return await showConfirmDialog(
            context,
            title: 'Delete Server',
            message: 'Are you sure you want to delete ${server.name}?',
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: NexorCard(
        onTap: onTap,
        margin: EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.server,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: AppTypography.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      ServerStatusBadge(server: server),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.caretRight,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ServerInfoRow(
                    icon: PhosphorIcons.globe,
                    label: '${server.host}:${server.port}',
                  ),
                ),
              ],
            ),
            if (server.lastUsedAt != null) ...[
              SizedBox(height: 8),
              ServerInfoRow(
                icon: PhosphorIcons.clock,
                label: 'Last used ${timeago.format(server.lastUsedAt!)}',
              ),
            ],
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NexorButton(
                    text: 'Test',
                    type: ButtonType.secondary,
                    size: ButtonSize.small,
                    onPressed: onTest,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: NexorButton(
                    text: 'Connect',
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                    icon: PhosphorIcons.arrowRight,
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**ServerStatusBadge Widget:**
```dart
class ServerStatusBadge extends ConsumerWidget {
  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(serverStatusProvider(server.id));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            _getStatusText(status),
            style: AppTypography.caption.copyWith(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ServerStatus status) {
    switch (status) {
      case ServerStatus.online:
        return AppColors.success;
      case ServerStatus.offline:
        return AppColors.textTertiary;
      case ServerStatus.connecting:
        return AppColors.warning;
      case ServerStatus.error:
        return AppColors.error;
    }
  }

  String _getStatusText(ServerStatus status) {
    switch (status) {
      case ServerStatus.online:
        return 'Online';
      case ServerStatus.offline:
        return 'Offline';
      case ServerStatus.connecting:
        return 'Connecting';
      case ServerStatus.error:
        return 'Error';
    }
  }
}
```

#### 1.2 شاشة إضافة خادم (Add Server Screen)

**المسار:** `lib/presentation/screens/servers/add_server_screen.dart`

**Form Fields:**
```dart
class AddServerScreen extends ConsumerStatefulWidget {
  final Server? server; // For editing existing server

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '4096');
  final _usernameController = TextEditingController(text: 'opencode');
  final _passwordController = TextEditingController();
  
  bool _autoConnect = false;
  bool _useSSHKey = false;
  String? _sshKeyPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _loadServerData(widget.server!);
    }
  }

  void _loadServerData(Server server) {
    _nameController.text = server.name;
    _hostController.text = server.host;
    _portController.text = server.port.toString();
    _usernameController.text = server.username ?? 'opencode';
    _autoConnect = server.autoConnect;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NexorAppBar(
        title: widget.server == null ? 'Add Server' : 'Edit Server',
        leading: IconButton(
          icon: Icon(PhosphorIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Server Name
            NexorInput(
              label: 'Server Name',
              hint: 'e.g., Production Server',
              controller: _nameController,
              prefixIcon: PhosphorIcons.textT,
              validator: ServerValidator.validateName,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),

            // Host
            NexorInput(
              label: 'Host',
              hint: 'IP address or domain',
              controller: _hostController,
              prefixIcon: PhosphorIcons.globe,
              validator: ServerValidator.validateHost,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),

            // Port
            NexorInput(
              label: 'Port',
              hint: '4096',
              controller: _portController,
              prefixIcon: PhosphorIcons.plugs,
              validator: ServerValidator.validatePort,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 24),

            // Authentication Section
            Text(
              'Authentication',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),

            // Username
            NexorInput(
              label: 'Username (Optional)',
              hint: 'opencode',
              controller: _usernameController,
              prefixIcon: PhosphorIcons.user,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),

            // Auth Method Toggle
            NexorCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use SSH Key',
                      style: AppTypography.body1,
                    ),
                  ),
                  Switch(
                    value: _useSSHKey,
                    onChanged: (value) {
                      setState(() => _useSSHKey = value);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Password or SSH Key
            if (!_useSSHKey) ...[
              NexorInput(
                label: 'Password (Optional)',
                hint: 'Enter password',
                controller: _passwordController,
                prefixIcon: PhosphorIcons.lock,
                obscureText: true,
                textInputAction: TextInputAction.done,
              ),
            ] else ...[
              NexorCard(
                onTap: _pickSSHKey,
                child: Row(
                  children: [
                    Icon(PhosphorIcons.key, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SSH Key',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _sshKeyPath ?? 'Select SSH key file',
                            style: AppTypography.body1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      PhosphorIcons.caretRight,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24),

            // Options Section
            Text(
              'Options',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),

            // Auto Connect
            NexorCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Connect',
                          style: AppTypography.body1,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connect automatically on app start',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoConnect,
                    onChanged: (value) {
                      setState(() => _autoConnect = value);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Test Connection Button
            NexorButton(
              text: 'Test Connection',
              type: ButtonType.secondary,
              icon: PhosphorIcons.plugsConnected,
              onPressed: _testConnection,
              loading: _isLoading,
            ),
            SizedBox(height: 12),

            // Save Button
            NexorButton(
              text: widget.server == null ? 'Add Server' : 'Save Changes',
              type: ButtonType.primary,
              icon: PhosphorIcons.check,
              onPressed: _saveServer,
              loading: _isLoading,
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSSHKey() async {
    // TODO: Implement file picker for SSH key
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pem', 'key', 'pub'],
    );
    
    if (result != null) {
      setState(() {
        _sshKeyPath = result.files.single.path;
      });
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final server = _buildServer();
      final result = await ref.read(connectionServiceProvider).testConnection(server);
      
      if (mounted) {
        HapticService.success();
        showDialog(
          context: context,
          builder: (context) => NexorDialog(
            title: result.success ? 'Success' : 'Failed',
            content: Text(result.message),
            icon: result.success
              ? Icon(PhosphorIcons.checkCircle, color: AppColors.success, size: 48)
              : Icon(PhosphorIcons.xCircle, color: AppColors.error, size: 48),
            actions: [
              NexorButton(
                text: 'OK',
                onPressed: () => context.pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticService.error();
        showErrorSnackbar(context, 'Test failed: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final server = _buildServer();
      
      if (widget.server == null) {
        await ref.read(serversNotifierProvider.notifier).addServer(server);
      } else {
        await ref.read(serversNotifierProvider.notifier).updateServer(server);
      }

      // Save password securely if provided
      if (_passwordController.text.isNotEmpty) {
        await ref.read(secureStorageServiceProvider).savePassword(
          server.id,
          _passwordController.text,
        );
      }

      if (mounted) {
        HapticService.success();
        showSuccessSnackbar(
          context,
          widget.server == null ? 'Server added' : 'Server updated',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        HapticService.error();
        showErrorSnackbar(context, 'Failed to save: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Server _buildServer() {
    return Server(
      id: widget.server?.id ?? Uuid().v4(),
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.parse(_portController.text.trim()),
      username: _usernameController.text.trim().isEmpty 
        ? null 
        : _usernameController.text.trim(),
      createdAt: widget.server?.createdAt ?? DateTime.now(),
      autoConnect: _autoConnect,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**Validation Logic:**
```dart
class ServerValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? validateHost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host is required';
    }
    
    final host = value.trim();
    
    // IP address validation
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    
    // Domain validation
    final domainRegex = RegExp(
      r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    );
    
    // Localhost
    if (host == 'localhost') return null;
    
    if (!ipRegex.hasMatch(host) && !domainRegex.hasMatch(host)) {
      return 'Invalid IP address or domain';
    }
    
    return null;
  }

  static String? validatePort(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value.trim());
    if (port == null) {
      return 'Port must be a number';
    }
    
    if (port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    
    return null;
  }
}
```

**Connection Service:**
```dart
class ConnectionService {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  ConnectionService(this._dio, this._secureStorage);

  Future<ConnectionTestResult> testConnection(Server server) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Get password if exists
      final password = await _secureStorage.getPassword(server.id);
      
      // Build auth header
      String? authHeader;
      if (server.username != null && password != null) {
        final credentials = base64Encode(
          utf8.encode('${server.username}:$password'),
        );
        authHeader = 'Basic $credentials';
      }
      
      // Test connection
      final response = await _dio.get(
        'http://${server.host}:${server.port}/path',
        options: Options(
          headers: authHeader != null ? {'Authorization': authHeader} : null,
          sendTimeout: Duration(seconds: 5),
          receiveTimeout: Duration(seconds: 5),
        ),
      );
      
      stopwatch.stop();
      
      return ConnectionTestResult(
        success: true,
        message: 'Connection successful',
        latency: stopwatch.elapsedMilliseconds,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return ConnectionTestResult(
          success: false,
          message: 'Connection timeout',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return ConnectionTestResult(
          success: false,
          message: 'Receive timeout',
        );
      } else if (e.response?.statusCode == 401) {
        return ConnectionTestResult(
          success: false,
          message: 'Authentication failed',
        );
      } else {
        return ConnectionTestResult(
          success: false,
          message: 'Connection failed: ${e.message}',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return ConnectionTestResult(
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  Future<void> connect(Server server) async {
    // Similar to testConnection but stores the connection
    final result = await testConnection(server);
    if (!result.success) {
      throw Exception(result.message);
    }
    
    // Store active connection
    // TODO: Implement connection pooling
  }
}

class ConnectionTestResult {
  final bool success;
  final String message;
  final int? latency;

  ConnectionTestResult({
    required this.success,
    required this.message,
    this.latency,
  });
}
```

---

### Phase 2: نظام الملفات (File System)

#### 2.1 شاشة متصفح الملفات (File Browser Screen)

**المسار:** `lib/presentation/screens/files/file_browser_screen.dart`

**الوظائف الأساسية:**
1. عرض الملفات والمجلدات
2. التنقل بين المجلدات (Breadcrumb navigation)
3. أيقونات مخصصة حسب نوع الملف
4. Git status badges
5. فرز الملفات (Name, Date, Size)
6. فلترة الملفات (Files only, Folders only, All)
7. البحث في الملفات
8. Pull to refresh
9. زر "Open Nexor" للانتقال للشات

**UI Structure:**
```dart
class FileBrowserScreen extends ConsumerStatefulWidget {
  final String serverId;
  final String? initialPath;

  @override
  ConsumerState<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends ConsumerState<FileBrowserScreen> {
  late String _currentPath;
  SortType _sortType = SortType.name;
  FilterType _filterType = FilterType.all;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initialPath ?? '/';
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider(_currentPath));
    
    return Scaffold(
      appBar: NexorAppBar(
        title: 'Files',
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.magnifyingGlass),
            onPressed: () => _showSearch(),
          ),
          IconButton(
            icon: Icon(PhosphorIcons.funnelSimple),
            onPressed: () => _showFilterOptions(),
          ),
        ],
        bottom: BreadcrumbNav(
          path: _currentPath,
          onNavigate: (path) {
            setState(() => _currentPath = path);
          },
        ),
      ),
      body: filesAsync.when(
        data: (files) {
          final filteredFiles = _filterFiles(files);
          final sortedFiles = _sortFiles(filteredFiles);
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(filesProvider(_currentPath).future),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: sortedFiles.length,
              itemBuilder: (context, index) {
                return FileItem(
                  file: sortedFiles[index],
                  onTap: () => _handleFileTap(sortedFiles[index]),
                );
              },
            ),
          );
        },
        loading: () => Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(filesProvider(_currentPath)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNexor,
        icon: Icon(PhosphorIcons.chatCircle),
        label: Text('Open Nexor'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  List<FileNode> _filterFiles(List<FileNode> files) {
    switch (_filterType) {
      case FilterType.filesOnly:
        return files.where((f) => !f.isDirectory).toList();
      case FilterType.foldersOnly:
        return files.where((f) => f.isDirectory).toList();
      case FilterType.all:
        return files;
    }
  }

  List<FileNode> _sortFiles(List<FileNode> files) {
    final sorted = List<FileNode>.from(files);
    
    switch (_sortType) {
      case SortType.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.date:
        sorted.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
        break;
      case SortType.size:
        sorted.sort((a, b) => b.size.compareTo(a.size));
        break;
    }
    
    // Folders first
    sorted.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return 0;
    });
    
    return sorted;
  }

  void _handleFileTap(FileNode file) {
    if (file.isDirectory) {
      setState(() => _currentPath = file.path);
    } else {
      context.push('/files/viewer?path=${Uri.encodeComponent(file.path)}');
    }
  }

  void _openNexor() {
    // Create new session or resume existing
    context.push('/chat/new?directory=${Uri.encodeComponent(_currentPath)}');
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FileSearchSheet(
        currentPath: _currentPath,
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterOptionsSheet(
        currentSort: _sortType,
        currentFilter: _filterType,
        onSortChanged: (sort) {
          setState(() => _sortType = sort);
          context.pop();
        },
        onFilterChanged: (filter) {
          setState(() => _filterType = filter);
          context.pop();
        },
      ),
    );
  }
}
```

**FileItem Widget:**
```dart
class FileItem extends StatelessWidget {
  final FileNode file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NexorCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          FileIcon(file: file),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        file.name,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (file.gitStatus != null)
                      FileStatusBadge(status: file.gitStatus!),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    if (!file.isDirectory) ...[
                      Text(
                        _formatFileSize(file.size),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(' • ', style: TextStyle(color: AppColors.textTertiary)),
                    ],
                    Text(
                      timeago.format(file.modifiedAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            file.isDirectory ? PhosphorIcons.caretRight : PhosphorIcons.file,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
```

**BreadcrumbNav Widget:**
```dart
class BreadcrumbNav extends StatelessWidget implements PreferredSizeWidget {
  final String path;
  final Function(String) onNavigate;

  @override
  Size get preferredSize => Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length + 1,
        separatorBuilder: (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            PhosphorIcons.caretRight,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _BreadcrumbItem(
              label: 'Root',
              isLast: parts.isEmpty,
              onTap: () => onNavigate('/'),
            );
          }
          
          final part = parts[index - 1];
          final isLast = index == parts.length;
          final pathUpToHere = '/' + parts.sublist(0, index).join('/');
          
          return _BreadcrumbItem(
            label: part,
            isLast: isLast,
            onTap: () => onNavigate(pathUpToHere),
          );
        },
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLast ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLast ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTypography.body2.copyWith(
            color: isLast ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
```

#### 2.2 شاشة عرض الملف (File Viewer Screen)

**المسار:** `lib/presentation/screens/files/file_viewer_screen.dart`

**الوظائف:**
1. عرض محتوى الملف
2. Syntax highlighting للكود
3. أرقام الأسطر
4. Zoom in/out
5. Line wrapping toggle
6. نسخ المحتوى
7. مشاركة الملف
8. فتح في Nexor

**UI Structure:**
```dart
class FileViewerScreen extends ConsumerStatefulWidget {
  final String filePath;

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  double _fontSize = 14.0;
  bool _showLineNumbers = true;
  bool _wrapLines = false;
  String _selectedTheme = 'vs-dark';

  @override
  Widget build(BuildContext context) {
    final fileContentAsync = ref.watch(fileContentProvider(widget.filePath));
    
    return Scaffold(
      appBar: NexorAppBar(
        title: _getFileName(widget.filePath),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.textAa),
            onPressed: _showFontOptions,
          ),
          IconButton(
            icon: Icon(PhosphorIcons.shareNetwork),
            onPressed: () => _shareFile(fileContentAsync.value),
          ),
          PopupMenuButton(
            icon: Icon(PhosphorIcons.dotsThreeVertical),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(PhosphorIcons.copy),
                    SizedBox(width: 8),
                    Text('Copy Content'),
                  ],
                ),
                onTap: () => _copyContent(fileContentAsync.value),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(PhosphorIcons.chatCircle),
                    SizedBox(width: 8),
                    Text('Open in Nexor'),
                  ],
                ),
                onTap: _openInNexor,
              ),
            ],
          ),
        ],
      ),
      body: fileContentAsync.when(
        data: (content) {
          return Column(
            children: [
              // File Info Bar
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.file,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${content.lines} lines • ${_formatFileSize(content.size)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      content.language.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Code View
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: CodeBlock(
                      code: content.content,
                      language: content.language,
                      fontSize: _fontSize,
                      showLineNumbers: _showLineNumbers,
                      wrapLines: _wrapLines,
                      theme: _selectedTheme,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(fileContentProvider(widget.filePath)),
        ),
      ),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  void _showFontOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Options',
              style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 24),
            
            // Font Size
            Text('Font Size', style: AppTypography.body1),
            SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(PhosphorIcons.minus),
                  onPressed: () {
                    setState(() {
                      _fontSize = (_fontSize - 2).clamp(10.0, 24.0);
                    });
                  },
                ),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 10,
                    max: 24,
                    divisions: 7,
                    label: _fontSize.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() => _fontSize = value);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.plus),
                  onPressed: () {
                    setState(() {
                      _fontSize = (_fontSize + 2).clamp(10.0, 24.0);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Line Numbers
            SwitchListTile(
              title: Text('Show Line Numbers'),
              value: _showLineNumbers,
              onChanged: (value) {
                setState(() => _showLineNumbers = value);
              },
            ),
            
            // Wrap Lines
            SwitchListTile(
              title: Text('Wrap Lines'),
              value: _wrapLines,
              onChanged: (value) {
                setState(() => _wrapLines = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyContent(FileContent? content) {
    if (content != null) {
      Clipboard.setData(ClipboardData(text: content.content));
      showSuccessSnackbar(context, 'Content copied to clipboard');
    }
  }

  void _shareFile(FileContent? content) {
    if (content != null) {
      Share.share(content.content, subject: _getFileName(widget.filePath));
    }
  }

  void _openInNexor() {
    context.push('/chat/new?file=${Uri.encodeComponent(widget.filePath)}');
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

**CodeBlock Widget:**
```dart
class CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final double fontSize;
  final bool showLineNumbers;
  final bool wrapLines;
  final String theme;

  @override
  Widget build(BuildContext context) {
    return HighlightView(
      code,
      language: language,
      theme: _getTheme(theme),
      padding: EdgeInsets.all(16),
      textStyle: TextStyle(
        fontFamily: AppTypography.codeFont,
        fontSize: fontSize,
        height: 1.5,
      ),
    );
  }

  Map<String, TextStyle> _getTheme(String themeName) {
    // VS Code Dark+ theme
    return {
      'root': TextStyle(
        backgroundColor: AppColors.background,
        color: AppColors.textPrimary,
      ),
      'keyword': TextStyle(color: AppColors.codeKeyword),
      'string': TextStyle(color: AppColors.codeString),
      'number': TextStyle(color: AppColors.codeNumber),
      'comment': TextStyle(color: AppColors.codeComment),
      'function': TextStyle(color: AppColors.codeFunction),
      'variable': TextStyle(color: AppColors.codeVariable),
    };
  }
}
```

---

### Phase 3: واجهة المحادثة (Chat Interface)

#### 3.1 شاشة قائمة المحادثات (Conversation List Screen)

**المسار:** `lib/presentation/screens/chat/conversation_list_screen.dart`

**الوظائف:**
1. عرض جميع المحادثات
2. آخر رسالة في كل محادثة
3. الوقت النسبي
4. حالة المحادثة (Active/Completed)
5. البحث في المحادثات
6. Swipe to delete/archive
7. فلترة حسب المشروع
8. Pull to refresh

**UI Structure:**
```dart
class ConversationListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends ConsumerState<ConversationListScreen> {
  String _searchQuery = '';
  String? _selectedProject;

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      project: _selectedProject,
    ));
    
    return Scaffold(
      appBar: NexorAppBar(
        title: 'Conversations',
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.magnifyingGlass),
            onPressed: _showSearch,
          ),
          IconButton(
            icon: Icon(PhosphorIcons.funnel),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return EmptyState(
              icon: PhosphorIcons.chatCircle,
              title: 'No Conversations',
              message: 'Start a new conversation with Nexor',
              action: NexorButton(
                text: 'New Conversation',
                onPressed: () => context.push('/chat/new'),
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(conversationsProvider().future),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return ConversationCard(
                  conversation: conversations[index],
                  onTap: () => context.push('/chat/${conversations[index].id}'),
                  onDelete: () => _deleteConversation(conversations[index]),
                  onArchive: () => _archiveConversation(conversations[index]),
                );
              },
            ),
          );
        },
        loading: () => Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(conversationsProvider()),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat/new'),
        icon: Icon(PhosphorIcons.plus),
        label: Text('New Chat'),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: ConversationSearchDelegate(ref),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ProjectFilterSheet(
        selectedProject: _selectedProject,
        onProjectSelected: (project) {
          setState(() => _selectedProject = project);
          context.pop();
        },
      ),
    );
  }

  Future<void> _deleteConversation(Conversation conversation) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Conversation',
      message: 'Are you sure you want to delete this conversation?',
    );
    
    if (confirmed) {
      await ref.read(conversationsProvider.notifier).delete(conversation.id);
      showSuccessSnackbar(context, 'Conversation deleted');
    }
  }

  Future<void> _archiveConversation(Conversation conversation) async {
    await ref.read(conversationsProvider.notifier).archive(conversation.id);
    showSuccessSnackbar(context, 'Conversation archived');
  }
}
```

**ConversationCard Widget:**
```dart
class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Icon(PhosphorIcons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Icon(PhosphorIcons.trash, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onArchive();
          return false;
        } else {
          return await showConfirmDialog(
            context,
            title: 'Delete Conversation',
            message: 'This action cannot be undone.',
          );
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: NexorCard(
        onTap: onTap,
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                PhosphorIcons.chatCircle,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.title ?? 'New Conversation',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(conversation.updatedAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (conversation.lastMessage != null)
                    Text(
                      conversation.lastMessage!,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (conversation.projectPath != null) ...[
                        Icon(
                          PhosphorIcons.folder,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _getProjectName(conversation.projectPath!),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                      Spacer(),
                      if (conversation.messageCount > 0)
                        Text(
                          '${conversation.messageCount} messages',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProjectName(String path) {
    return path.split('/').last;
  }
}
```

#### 3.2 شاشة المحادثة (Chat Screen)

**المسار:** `lib/presentation/screens/chat/chat_screen.dart`

**الوظائف الأساسية:**
1. عرض الرسائل (User + AI)
2. Streaming responses في الوقت الفعلي
3. Code blocks مع syntax highlighting
4. File diffs viewer
5. Tool usage indicators
6. Typing indicator
7. إرسال رسائل نصية
8. إرفاق ملفات
9. Scroll to bottom
10. Copy messages/code
11. Regenerate responses

**UI Structure:**
```dart
class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final isAtBottom = _scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent - 100;
    
    if (isAtBottom != _isAtBottom) {
      setState(() => _isAtBottom = isAtBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider(widget.sessionId));
    final messagesAsync = ref.watch(messagesProvider(widget.sessionId));
    final isStreaming = ref.watch(streamingStateProvider(widget.sessionId));
    
    return Scaffold(
      appBar: NexorAppBar(
        title: sessionAsync.value?.title ?? 'Chat',
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isStreaming)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ),
          PopupMenuButton(
            icon: Icon(PhosphorIcons.dotsThreeVertical),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(PhosphorIcons.export),
                    SizedBox(width: 8),
                    Text('Export Chat'),
                  ],
                ),
                onTap: () => _exportChat(),
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(PhosphorIcons.trash),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
                onTap: () => _clearHistory(),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIcons.chatCircle,
                    title: 'Start Conversation',
                    message: 'Ask Nexor anything about your code',
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    
                    return message.role == 'user'
                      ? UserMessage(message: message)
                      : AIMessage(
                          message: message,
                          isStreaming: isStreaming && index == messages.length - 1,
                        );
                  },
                );
              },
              loading: () => Center(child: LoadingIndicator()),
              error: (error, stack) => ErrorState(
                error: error.toString(),
                onRetry: () => ref.invalidate(messagesProvider(widget.sessionId)),
              ),
            ),
          ),
          
          // Scroll to Bottom FAB
          if (!_isAtBottom)
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                child: Icon(PhosphorIcons.arrowDown),
              ),
            ),
          
          // Input Area
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttach: _attachFile,
            enabled: !isStreaming,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    // Clear input
    _messageController.clear();
    
    // Send message
    await ref.read(chatProvider(widget.sessionId).notifier).sendMessage(text);
    
    // Scroll to bottom
    Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
    
    // Haptic feedback
    HapticService.light();
  }

  Future<void> _attachFile() async {
    // TODO: Implement file picker
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      // Send file reference to AI
      await ref.read(chatProvider(widget.sessionId).notifier).sendFile(file.path!);
    }
  }

  Future<void> _exportChat() async {
    final messages = await ref.read(messagesProvider(widget.sessionId).future);
    final markdown = _convertToMarkdown(messages);
    
    await Share.share(markdown, subject: 'Nexor Chat Export');
  }

  Future<void> _clearHistory() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear History',
      message: 'This will delete all messages in this conversation.',
    );
    
    if (confirmed) {
      await ref.read(chatProvider(widget.sessionId).notifier).clearHistory();
    }
  }

  String _convertToMarkdown(List<Message> messages) {
    final buffer = StringBuffer();
    buffer.writeln('# Nexor Chat Export\n');
    
    for (final message in messages) {
      buffer.writeln('## ${message.role == 'user' ? 'You' : 'Nexor'}\n');
      buffer.writeln(message.content);
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

**UserMessage Widget:**
```dart
class UserMessage extends StatelessWidget {
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [AppShadows.shadow2],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    timeago.format(message.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(
              PhosphorIcons.user,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
```

**AIMessage Widget:**
```dart
class AIMessage extends StatelessWidget {
  final Message message;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.success.withOpacity(0.2),
            child: Icon(
              PhosphorIcons.robot,
              size: 16,
              color: AppColors.success,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [AppShadows.shadow1],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parse and render message content
                  _buildMessageContent(context, message),
                  
                  // Streaming indicator
                  if (isStreaming) ...[
                    SizedBox(height: 8),
                    TypingIndicator(),
                  ],
                  
                  // Timestamp and actions
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        timeago.format(message.createdAt),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(PhosphorIcons.copy, size: 16),
                        onPressed: () => _copyMessage(context, message),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(PhosphorIcons.arrowClockwise, size: 16),
                        onPressed: () => _regenerateResponse(context, message),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, Message message) {
    // Parse message parts (text, code, diffs, tool usage)
    final parts = _parseMessageParts(message.content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part is TextPart) {
          return MarkdownWidget(data: part.text);
        } else if (part is CodePart) {
          return CodeBlock(
            code: part.code,
            language: part.language,
            fileName: part.fileName,
          );
        } else if (part is DiffPart) {
          return FileDiffViewer(diff: part.diff);
        } else if (part is ToolUsagePart) {
          return ToolUsageCard(tool: part.tool);
        }
        return SizedBox.shrink();
      }).toList(),
    );
  }

  List<MessagePart> _parseMessageParts(String content) {
    // TODO: Implement proper parsing
    // For now, return simple text
    return [TextPart(content)];
  }

  void _copyMessage(BuildContext context, Message message) {
    Clipboard.setData(ClipboardData(text: message.content));
    showSuccessSnackbar(context, 'Message copied');
    HapticService.light();
  }

  void _regenerateResponse(BuildContext context, Message message) {
    // TODO: Implement regenerate
    showInfoSnackbar(context, 'Regenerating response...');
  }
}
```

**MessageInput Widget:**
```dart
class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool enabled;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attach button
            IconButton(
              icon: Icon(PhosphorIcons.paperclip),
              onPressed: widget.enabled ? widget.onAttach : null,
              color: AppColors.textSecondary,
            ),
            
            // Text input
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Message Nexor...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundElevated,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTypography.body1,
                ),
              ),
            ),
            
            SizedBox(width: 8),
            
            // Send button
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(
                  _hasText ? PhosphorIcons.paperPlaneTilt : PhosphorIcons.microphone,
                ),
                onPressed: widget.enabled && _hasText ? widget.onSend : null,
                color: _hasText ? AppColors.primary : AppColors.textSecondary,
                style: IconButton.styleFrom(
                  backgroundColor: _hasText 
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
}
```

**CodeBlock Widget (Enhanced):**
```dart
class CodeBlock extends StatelessWidget {
  final String code;
  final String language;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                if (fileName != null) ...[
                  Icon(
                    PhosphorIcons.file,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    fileName!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Spacer(),
                ],
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    language.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(PhosphorIcons.copy, size: 16),
                  onPressed: () => _copyCode(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              code,
              language: language,
              theme: _getCodeTheme(),
              padding: EdgeInsets.all(16),
              textStyle: TextStyle(
                fontFamily: AppTypography.codeFont,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    showSuccessSnackbar(context, 'Code copied');
    HapticService.light();
  }

  Map<String, TextStyle> _getCodeTheme() {
    return {
      'root': TextStyle(
        backgroundColor: AppColors.backgroundElevated,
        color: AppColors.textPrimary,
      ),
      'keyword': TextStyle(color: AppColors.codeKeyword),
      'string': TextStyle(color: AppColors.codeString),
      'number': TextStyle(color: AppColors.codeNumber),
      'comment': TextStyle(color: AppColors.codeComment, fontStyle: FontStyle.italic),
      'function': TextStyle(color: AppColors.codeFunction),
      'variable': TextStyle(color: AppColors.codeVariable),
    };
  }
}
```

**TypingIndicator Widget:**
```dart
class TypingIndicator extends StatefulWidget {
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (math.sin(value * math.pi) * 0.5 + 0.5);
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**FileDiffViewer Widget:**
```dart
class FileDiffViewer extends StatelessWidget {
  final FileDiff diff;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.gitDiff,
                  size: 16,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    diff.fileName,
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${diff.additions}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${diff.deletions}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Diff content
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: diff.lines.length,
            itemBuilder: (context, index) {
              final line = diff.lines[index];
              return _DiffLine(line: line);
            },
          ),
        ],
      ),
    );
  }
}

class _DiffLine extends StatelessWidget {
  final DiffLine line;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? textColor;
    
    switch (line.type) {
      case DiffLineType.addition:
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case DiffLineType.deletion:
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case DiffLineType.context:
        backgroundColor = null;
        textColor = AppColors.textSecondary;
        break;
    }
    
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${line.lineNumber ?? ""}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontFamily: AppTypography.codeFont,
              ),
            ),
          ),
          Expanded(
            child: Text(
              line.content,
              style: AppTypography.body2.copyWith(
                color: textColor,
                fontFamily: AppTypography.codeFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**ToolUsageCard Widget:**
```dart
class ToolUsageCard extends StatelessWidget {
  final ToolUsage tool;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getToolIcon(tool.name),
              size: 20,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getToolDisplayName(tool.name),
                  style: AppTypography.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                if (tool.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    tool.description!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tool.status == ToolStatus.running)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.info),
              ),
            )
          else if (tool.status == ToolStatus.completed)
            Icon(
              PhosphorIcons.checkCircle,
              size: 16,
              color: AppColors.success,
            )
          else if (tool.status == ToolStatus.failed)
            Icon(
              PhosphorIcons.xCircle,
              size: 16,
              color: AppColors.error,
            ),
        ],
      ),
    );
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'read':
        return PhosphorIcons.fileText;
      case 'write':
        return PhosphorIcons.pencil;
      case 'bash':
        return PhosphorIcons.terminal;
      case 'grep':
        return PhosphorIcons.magnifyingGlass;
      default:
        return PhosphorIcons.wrench;
    }
  }

  String _getToolDisplayName(String toolName) {
    switch (toolName) {
      case 'read':
        return 'Reading file';
      case 'write':
        return 'Writing file';
      case 'bash':
        return 'Running command';
      case 'grep':
        return 'Searching';
      default:
        return toolName;
    }
  }
}
```

---

## 🔌 تكامل API (API Integration)

### نظرة عامة على OpenCode API

OpenCode يوفر REST API كامل للتفاعل مع النظام. جميع الـ endpoints موثقة في `/doc`.

**Base URL Structure:**
```
http://{server.host}:{server.port}
```

**Authentication:**
```
Basic Auth: username:password (base64 encoded)
Header: Authorization: Basic {credentials}
```

### API Endpoints المستخدمة

#### 1. Server Management

```dart
// Test Connection
GET /path
Response: 200 OK

// Get Server Info
GET /path
Response: {
  "home": "/home/user",
  "state": "/home/user/.opencode",
  "config": "/home/user/.config/opencode",
  "worktree": "/projects/myapp",
  "directory": "/projects/myapp"
}
```

#### 2. Session Management

```dart
// List Sessions
GET /session?directory={path}&roots=true&limit=50
Response: [
  {
    "id": "session-123",
    "title": "Add dark mode",
    "directory": "/projects/myapp",
    "createdAt": 1234567890,
    "updatedAt": 1234567890,
    "messageCount": 15
  }
]

// Get Session
GET /session/{sessionId}
Response: {
  "id": "session-123",
  "title": "Add dark mode",
  "directory": "/projects/myapp",
  "agent": "build",
  "messages": [...]
}

// Create Session
POST /session
Body: {
  "directory": "/projects/myapp",
  "agent": "build",
  "title": "New conversation"
}
Response: {
  "id": "session-456",
  ...
}

// Delete Session
DELETE /session/{sessionId}
Response: true

// Update Session
PATCH /session/{sessionId}
Body: {
  "title": "Updated title"
}
Response: {...}
```

#### 3. Messaging

```dart
// Send Message (Streaming)
POST /session/{sessionId}/message
Body: {
  "content": "Add a dark mode toggle",
  "parts": []
}
Response: Stream of JSON objects
{
  "info": {
    "id": "msg-123",
    "sessionID": "session-123",
    "role": "assistant",
    "content": "I'll help you add...",
    "createdAt": 1234567890
  },
  "parts": [
    {
      "id": "part-1",
      "type": "text",
      "content": "..."
    },
    {
      "id": "part-2",
      "type": "tool_use",
      "tool": "read",
      "input": {...}
    }
  ]
}

// Send Message (Async)
POST /session/{sessionId}/prompt_async
Body: {
  "content": "Fix the bug in auth.ts"
}
Response: 204 No Content

// Get Messages
GET /session/{sessionId}/message
Response: [
  {
    "id": "msg-1",
    "role": "user",
    "content": "Hello",
    "createdAt": 1234567890
  },
  {
    "id": "msg-2",
    "role": "assistant",
    "content": "Hi! How can I help?",
    "createdAt": 1234567891
  }
]
```

#### 4. File Operations

```dart
// List Files
GET /file?path=/projects/myapp
Response: [
  {
    "name": "src",
    "path": "/projects/myapp/src",
    "type": "directory",
    "size": 0,
    "modifiedAt": 1234567890
  },
  {
    "name": "package.json",
    "path": "/projects/myapp/package.json",
    "type": "file",
    "size": 1234,
    "modifiedAt": 1234567890
  }
]

// Read File
GET /file/content?path=/projects/myapp/src/index.ts
Response: {
  "content": "import ...",
  "size": 1234,
  "lines": 45,
  "language": "typescript"
}

// Search Files
GET /find/file?query=auth&limit=10
Response: [
  "/projects/myapp/src/auth.ts",
  "/projects/myapp/src/auth.test.ts"
]

// Search Content
GET /find?pattern=function.*auth
Response: [
  {
    "path": "/projects/myapp/src/auth.ts",
    "line": 15,
    "content": "function authenticate(user) {",
    "column": 0
  }
]

// Get File Status (Git)
GET /file/status
Response: [
  {
    "path": "src/auth.ts",
    "status": "modified"
  },
  {
    "path": "src/new-feature.ts",
    "status": "added"
  }
]
```

### API Client Implementation

```dart
class OpenCodeApiClient {
  final Dio _dio;
  final Server server;

  OpenCodeApiClient({
    required this.server,
    String? password,
  }) {
    final baseUrl = 'http://${server.host}:${server.port}';
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    if (server.username != null && password != null) {
      final credentials = base64Encode(
        utf8.encode('${server.username}:$password'),
      );
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Basic $credentials';
            return handler.next(options);
          },
        ),
      );
    }

    // Add logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Sessions
  Future<List<Session>> getSessions({
    String? directory,
    bool? roots,
    int? limit,
  }) async {
    final response = await _dio.get('/session', queryParameters: {
      if (directory != null) 'directory': directory,
      if (roots != null) 'roots': roots,
      if (limit != null) 'limit': limit,
    });
    
    return (response.data as List)
      .map((json) => Session.fromJson(json))
      .toList();
  }

  Future<Session> getSession(String sessionId) async {
    final response = await _dio.get('/session/$sessionId');
    return Session.fromJson(response.data);
  }

  Future<Session> createSession({
    required String directory,
    String? agent,
    String? title,
  }) async {
    final response = await _dio.post('/session', data: {
      'directory': directory,
      if (agent != null) 'agent': agent,
      if (title != null) 'title': title,
    });
    
    return Session.fromJson(response.data);
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete('/session/$sessionId');
  }

  Future<Session> updateSession(
    String sessionId, {
    String? title,
  }) async {
    final response = await _dio.patch('/session/$sessionId', data: {
      if (title != null) 'title': title,
    });
    
    return Session.fromJson(response.data);
  }

  // Messages
  Future<List<Message>> getMessages(String sessionId) async {
    final response = await _dio.get('/session/$sessionId/message');
    return (response.data as List)
      .map((json) => Message.fromJson(json))
      .toList();
  }

  Stream<MessageChunk> sendMessage(
    String sessionId,
    String content,
  ) async* {
    final response = await _dio.post<ResponseBody>(
      '/session/$sessionId/message',
      data: {'content': content},
      options: Options(responseType: ResponseType.stream),
    );

    await for (final chunk in response.data!.stream) {
      final text = utf8.decode(chunk);
      // Parse JSON chunks
      for (final line in text.split('\n')) {
        if (line.trim().isNotEmpty) {
          try {
            final json = jsonDecode(line);
            yield MessageChunk.fromJson(json);
          } catch (e) {
            // Skip invalid JSON
          }
        }
      }
    }
  }

  Future<void> sendMessageAsync(
    String sessionId,
    String content,
  ) async {
    await _dio.post('/session/$sessionId/prompt_async', data: {
      'content': content,
    });
  }

  // Files
  Future<List<FileNode>> listFiles(String path) async {
    final response = await _dio.get('/file', queryParameters: {
      'path': path,
    });
    
    return (response.data as List)
      .map((json) => FileNode.fromJson(json))
      .toList();
  }

  Future<FileContent> readFile(String path) async {
    final response = await _dio.get('/file/content', queryParameters: {
      'path': path,
    });
    
    return FileContent.fromJson(response.data);
  }

  Future<List<String>> searchFiles(String query, {int? limit}) async {
    final response = await _dio.get('/find/file', queryParameters: {
      'query': query,
      if (limit != null) 'limit': limit,
    });
    
    return List<String>.from(response.data);
  }

  Future<List<SearchMatch>> searchContent(String pattern) async {
    final response = await _dio.get('/find', queryParameters: {
      'pattern': pattern,
    });
    
    return (response.data as List)
      .map((json) => SearchMatch.fromJson(json))
      .toList();
  }

  Future<List<FileStatus>> getFileStatus() async {
    final response = await _dio.get('/file/status');
    return (response.data as List)
      .map((json) => FileStatus.fromJson(json))
      .toList();
  }
}
```

### WebSocket Integration

```dart
class OpenCodeWebSocketClient {
  final Server server;
  WebSocketChannel? _channel;
  StreamController<dynamic>? _controller;

  OpenCodeWebSocketClient({required this.server});

  Stream<dynamic> connect(String sessionId) {
    final wsUrl = 'ws://${server.host}:${server.port}/session/$sessionId/stream';
    
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _controller = StreamController<dynamic>.broadcast();
    
    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data);
          _controller!.add(json);
        } catch (e) {
          _controller!.addError(e);
        }
      },
      onError: (error) => _controller!.addError(error),
      onDone: () => _controller!.close(),
    );
    
    return _controller!.stream;
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
    _channel = null;
    _controller = null;
  }
}
```

---

## 🔄 إدارة الحالة (State Management)

### Riverpod Providers Structure

#### Server Providers

```dart
// Server Repository Provider
@riverpod
ServerRepository serverRepository(ServerRepositoryRef ref) {
  return ServerRepositoryImpl(
    box: Hive.box<Server>('servers'),
  );
}

// Servers List Provider
@riverpod
class ServersNotifier extends _$ServersNotifier {
  @override
  Future<List<Server>> build() async {
    return await ref.read(serverRepositoryProvider).getServers();
  }

  Future<void> addServer(Server server) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(serverRepositoryProvider).addServer(server);
      return await ref.read(serverRepositoryProvider).getServers();
    });
  }

  Future<void> updateServer(Server server) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(serverRepositoryProvider).updateServer(server);
      return await ref.read(serverRepositoryProvider).getServers();
    });
  }

  Future<void> deleteServer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(serverRepositoryProvider).deleteServer(id);
      return await ref.read(serverRepositoryProvider).getServers();
    });
  }

  Future<void> updateLastUsed(String id) async {
    final server = state.value?.firstWhere((s) => s.id == id);
    if (server != null) {
      final updated = server.copyWith(lastUsedAt: DateTime.now());
      await updateServer(updated);
    }
  }
}

// Current Server Provider
@riverpod
class CurrentServer extends _$CurrentServer {
  @override
  Server? build() {
    return null;
  }

  void setServer(Server server) {
    state = server;
  }

  void clearServer() {
    state = null;
  }
}

// Server Status Provider
@riverpod
class ServerStatus extends _$ServerStatus {
  Timer? _timer;

  @override
  ServerConnectionStatus build(String serverId) {
    // Start periodic status check
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      _checkStatus();
    });
    
    // Initial check
    _checkStatus();
    
    return ServerConnectionStatus.offline;
  }

  Future<void> _checkStatus() async {
    try {
      final server = await ref.read(serverRepositoryProvider).getServer(serverId);
      if (server == null) return;
      
      final result = await ref.read(connectionServiceProvider).testConnection(server);
      state = result.success 
        ? ServerConnectionStatus.online 
        : ServerConnectionStatus.offline;
    } catch (e) {
      state = ServerConnectionStatus.error;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

#### Session/Chat Providers

```dart
// API Client Provider
@riverpod
OpenCodeApiClient apiClient(ApiClientRef ref) {
  final server = ref.watch(currentServerProvider);
  if (server == null) {
    throw Exception('No server selected');
  }
  
  final password = ref.watch(secureStorageServiceProvider).getPassword(server.id);
  
  return OpenCodeApiClient(
    server: server,
    password: password,
  );
}

// Sessions List Provider
@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<Session>> build({String? search, String? project}) async {
    final client = ref.read(apiClientProvider);
    return await client.getSessions(
      directory: project,
      roots: true,
      limit: 100,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      return await client.getSessions(roots: true, limit: 100);
    });
  }

  Future<void> delete(String sessionId) async {
    final client = ref.read(apiClientProvider);
    await client.deleteSession(sessionId);
    await refresh();
  }

  Future<void> archive(String sessionId) async {
    // TODO: Implement archive
    await refresh();
  }
}

// Single Session Provider
@riverpod
Future<Session> session(SessionRef ref, String sessionId) async {
  final client = ref.read(apiClientProvider);
  return await client.getSession(sessionId);
}

// Messages Provider
@riverpod
Future<List<Message>> messages(MessagesRef ref, String sessionId) async {
  final client = ref.read(apiClientProvider);
  return await client.getMessages(sessionId);
}

// Chat Provider (with streaming)
@riverpod
class Chat extends _$Chat {
  @override
  FutureOr<List<Message>> build(String sessionId) async {
    final client = ref.read(apiClientProvider);
    return await client.getMessages(sessionId);
  }

  Future<void> sendMessage(String content) async {
    // Add user message immediately
    final userMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    
    state = AsyncValue.data([...state.value ?? [], userMessage]);
    
    // Start streaming
    ref.read(streamingStateProvider(sessionId).notifier).setStreaming(true);
    
    try {
      final client = ref.read(apiClientProvider);
      final stream = client.sendMessage(sessionId, content);
      
      String aiMessageContent = '';
      
      await for (final chunk in stream) {
        aiMessageContent += chunk.content;
        
        // Update AI message
        final aiMessage = Message(
          id: chunk.messageId,
          sessionId: sessionId,
          role: 'assistant',
          content: aiMessageContent,
          createdAt: DateTime.now(),
        );
        
        final messages = [...state.value ?? []];
        final existingIndex = messages.indexWhere((m) => m.id == chunk.messageId);
        
        if (existingIndex >= 0) {
          messages[existingIndex] = aiMessage;
        } else {
          messages.add(aiMessage);
        }
        
        state = AsyncValue.data(messages);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      ref.read(streamingStateProvider(sessionId).notifier).setStreaming(false);
    }
  }

  Future<void> sendFile(String filePath) async {
    await sendMessage('Can you help me with this file: $filePath');
  }

  Future<void> clearHistory() async {
    state = const AsyncValue.data([]);
  }
}

// Streaming State Provider
@riverpod
class StreamingState extends _$StreamingState {
  @override
  bool build(String sessionId) {
    return false;
  }

  void setStreaming(bool value) {
    state = value;
  }
}
```

#### File Providers

```dart
// Files Provider
@riverpod
Future<List<FileNode>> files(FilesRef ref, String path) async {
  final client = ref.read(apiClientProvider);
  return await client.listFiles(path);
}

// File Content Provider
@riverpod
Future<FileContent> fileContent(FileContentRef ref, String path) async {
  final client = ref.read(apiClientProvider);
  return await client.readFile(path);
}

// File Search Provider
@riverpod
class FileSearch extends _$FileSearch {
  @override
  Future<List<String>> build(String query) async {
    if (query.isEmpty) return [];
    
    final client = ref.read(apiClientProvider);
    return await client.searchFiles(query, limit: 50);
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      return await client.searchFiles(query, limit: 50);
    });
  }
}
```

---

## 🔐 الأمان والحماية (Security)

### 1. تخزين البيانات الحساسة

**استخدام flutter_secure_storage:**
```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Save password
  Future<void> savePassword(String serverId, String password) async {
    await _storage.write(
      key: 'server_password_$serverId',
      value: password,
    );
  }

  // Get password
  Future<String?> getPassword(String serverId) async {
    return await _storage.read(key: 'server_password_$serverId');
  }

  // Delete password
  Future<void> deletePassword(String serverId) async {
    await _storage.delete(key: 'server_password_$serverId');
  }

  // Save SSH key
  Future<void> saveSSHKey(String serverId, String key) async {
    await _storage.write(
      key: 'server_ssh_key_$serverId',
      value: key,
    );
  }

  // Get SSH key
  Future<String?> getSSHKey(String serverId) async {
    return await _storage.read(key: 'server_ssh_key_$serverId');
  }
}
```

### 2. Biometric Authentication

```dart
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}

// Usage in app
class AppLockScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.lockKey,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Nexor is Locked',
              style: AppTypography.h2,
            ),
            SizedBox(height: 48),
            NexorButton(
              text: 'Unlock',
              icon: PhosphorIcons.fingerprint,
              onPressed: () async {
                final authenticated = await ref.read(biometricServiceProvider).authenticate(
                  reason: 'Unlock Nexor',
                );
                
                if (authenticated) {
                  // Navigate to main screen
                  context.go('/servers');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Network Security

**SSL Pinning:**
```dart
class SSLPinningInterceptor extends Interceptor {
  final List<String> allowedSHA256Fingerprints;

  SSLPinningInterceptor({required this.allowedSHA256Fingerprints});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add certificate validation
    options.validateStatus = (status) => status! < 500;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badCertificate) {
      // Handle certificate error
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: 'SSL Certificate validation failed',
      ));
    } else {
      handler.next(err);
    }
  }
}
```

**Certificate Pinning Setup:**
```dart
class ApiClient {
  late Dio _dio;

  ApiClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
    
    // Add SSL pinning for production
    if (kReleaseMode) {
      _dio.interceptors.add(SSLPinningInterceptor(
        allowedSHA256Fingerprints: [
          'YOUR_CERTIFICATE_FINGERPRINT_HERE',
        ],
      ));
    }
  }
}
```

### 4. Data Encryption

**Encrypt Hive Database:**
```dart
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Generate encryption key
    final encryptionKey = await _getEncryptionKey();
    
    // Open encrypted boxes
    await Hive.openBox<Server>(
      'servers',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    await Hive.openBox<Session>(
      'sessions',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  static Future<List<int>> _getEncryptionKey() async {
    final secureStorage = FlutterSecureStorage();
    
    // Try to get existing key
    final existingKey = await secureStorage.read(key: 'hive_encryption_key');
    
    if (existingKey != null) {
      return base64Decode(existingKey);
    }
    
    // Generate new key
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'hive_encryption_key',
      value: base64Encode(key),
    );
    
    return key;
  }
}
```

### 5. Input Validation & Sanitization

```dart
class SecurityUtils {
  // Sanitize user input
  static String sanitizeInput(String input) {
    return input
      .trim()
      .replaceAll(RegExp(r'[<>]'), '') // Remove HTML tags
      .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ''); // Remove control characters
  }

  // Validate URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Validate file path
  static bool isValidPath(String path) {
    // Prevent path traversal
    if (path.contains('..')) return false;
    if (path.contains('~')) return false;
    return true;
  }
}
```

---

## ⚡ الأداء والتحسين (Performance Optimization)

### 1. Image Optimization

```dart
// Use cached_network_image for remote images
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => ShimmerLoader(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 400, // Resize in memory
  maxWidthDiskCache: 800, // Resize on disk
)

// Optimize local images
Image.asset(
  'assets/images/logo.png',
  cacheWidth: 200, // Resize in memory
)
```

### 2. List Performance

```dart
// Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
  // Add cache extent for smoother scrolling
  cacheExtent: 500,
)

// Use const constructors
class ItemWidget extends StatelessWidget {
  final Item item;
  
  const ItemWidget({Key? key, required this.item}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Card(...); // Use const where possible
  }
}
```

### 3. Code Splitting & Lazy Loading

```dart
// Lazy load heavy widgets
class HeavyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadHeavyData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingIndicator();
        }
        return _buildContent(snapshot.data);
      },
    );
  }
}
```

### 4. Memory Management

```dart
// Dispose controllers
@override
void dispose() {
  _controller.dispose();
  _scrollController.dispose();
  _focusNode.dispose();
  super.dispose();
}

// Cancel subscriptions
StreamSubscription? _subscription;

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}

// Clear caches when needed
void clearCaches() {
  imageCache.clear();
  imageCache.clearLiveImages();
}
```

### 5. Build Optimization

```dart
// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ExpensiveWidget(),
)

// Use keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return ItemWidget(
      key: ValueKey(items[index].id),
      item: items[index],
    );
  },
)
```

---

## 🧪 استراتيجية الاختبار (Testing Strategy)

### نظرة عامة

نستهدف **80% code coverage** مع التركيز على:
- **60% Unit Tests** - اختبار المنطق والوظائف
- **30% Widget Tests** - اختبار الواجهات
- **10% Integration Tests** - اختبار التدفقات الكاملة

### 1. Unit Tests

**اختبار Models:**
```dart
void main() {
  group('Server Model', () {
    test('should create server from JSON', () {
      final json = {
        'id': 'server-1',
        'name': 'Test Server',
        'host': '192.168.1.100',
        'port': 4096,
      };
      
      final server = Server.fromJson(json);
      
      expect(server.id, 'server-1');
      expect(server.name, 'Test Server');
      expect(server.host, '192.168.1.100');
      expect(server.port, 4096);
    });

    test('should convert server to JSON', () {
      final server = Server(
        id: 'server-1',
        name: 'Test Server',
        host: '192.168.1.100',
        port: 4096,
        createdAt: DateTime(2024, 1, 1),
      );
      
      final json = server.toJson();
      
      expect(json['id'], 'server-1');
      expect(json['name'], 'Test Server');
    });
  });
}
```

**اختبار Repositories:**
```dart
void main() {
  late ServerRepository repository;
  late Box<Server> mockBox;

  setUp(() {
    mockBox = MockBox<Server>();
    repository = ServerRepositoryImpl(box: mockBox);
  });

  group('ServerRepository', () {
    test('should get all servers', () async {
      final servers = [
        Server(id: '1', name: 'Server 1', host: 'host1', port: 4096, createdAt: DateTime.now()),
        Server(id: '2', name: 'Server 2', host: 'host2', port: 4096, createdAt: DateTime.now()),
      ];
      
      when(() => mockBox.values).thenReturn(servers);
      
      final result = await repository.getServers();
      
      expect(result.length, 2);
      expect(result[0].name, 'Server 1');
    });

    test('should add server', () async {
      final server = Server(
        id: '1',
        name: 'New Server',
        host: 'host',
        port: 4096,
        createdAt: DateTime.now(),
      );
      
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
      
      await repository.addServer(server);
      
      verify(() => mockBox.put(server.id, server)).called(1);
    });
  });
}
```

**اختبار Use Cases:**
```dart
void main() {
  late AddServer useCase;
  late MockServerRepository mockRepository;

  setUp(() {
    mockRepository = MockServerRepository();
    useCase = AddServer(mockRepository);
  });

  test('should add server successfully', () async {
    final server = Server(
      id: '1',
      name: 'Test',
      host: 'host',
      port: 4096,
      createdAt: DateTime.now(),
    );
    
    when(() => mockRepository.addServer(server))
      .thenAnswer((_) async => {});
    
    await useCase(server);
    
    verify(() => mockRepository.addServer(server)).called(1);
  });
}
```

### 2. Widget Tests

**اختبار Widgets:**
```dart
void main() {
  testWidgets('ServerCard displays server info', (tester) async {
    final server = Server(
      id: '1',
      name: 'Test Server',
      host: '192.168.1.100',
      port: 4096,
      createdAt: DateTime.now(),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServerCard(
            server: server,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
            onTest: () {},
          ),
        ),
      ),
    );
    
    expect(find.text('Test Server'), findsOneWidget);
    expect(find.text('192.168.1.100:4096'), findsOneWidget);
  });

  testWidgets('NexorButton triggers onPressed', (tester) async {
    var pressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NexorButton(
            text: 'Click Me',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );
    
    await tester.tap(find.text('Click Me'));
    await tester.pump();
    
    expect(pressed, true);
  });
}
```

**اختبار Screens:**
```dart
void main() {
  testWidgets('ServersListScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serversNotifierProvider.overrideWith((ref) {
            return MockServersNotifier([]);
          }),
        ],
        child: MaterialApp(
          home: ServersListScreen(),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    expect(find.text('No Servers'), findsOneWidget);
    expect(find.text('Add Server'), findsOneWidget);
  });
}
```

### 3. Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('Complete flow: Add server -> Connect -> Browse files', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to add server
      await tester.tap(find.byIcon(PhosphorIcons.plus));
      await tester.pumpAndSettle();
      
      // Fill form
      await tester.enterText(find.byType(TextField).at(0), 'Test Server');
      await tester.enterText(find.byType(TextField).at(1), '192.168.1.100');
      await tester.enterText(find.byType(TextField).at(2), '4096');
      
      // Save
      await tester.tap(find.text('Add Server'));
      await tester.pumpAndSettle();
      
      // Verify server added
      expect(find.text('Test Server'), findsOneWidget);
      
      // Connect to server
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();
      
      // Verify file browser opened
      expect(find.text('Files'), findsOneWidget);
    });
  });
}
```

---

## 📅 خطة التنفيذ (Implementation Timeline)

### Week 1-2: Foundation & Setup

**Day 1-3: Project Setup**
- ✅ إنشاء Flutter project
- ✅ إعداد folder structure
- ✅ تثبيت dependencies
- ✅ إعداد Hive database
- ✅ إعداد Riverpod providers
- ✅ إعداد GoRouter

**Day 4-7: Design System**
- ✅ تطبيق theme system
- ✅ إنشاء color palette
- ✅ إنشاء typography system
- ✅ إنشاء spacing system
- ✅ إنشاء animation configs

**Day 8-10: Core Components**
- ✅ NexorButton
- ✅ NexorCard
- ✅ NexorInput
- ✅ NexorAppBar
- ✅ LoadingIndicator
- ✅ EmptyState
- ✅ ErrorState

**Day 11-14: Server Management**
- ✅ Server model & repository
- ✅ ServersListScreen
- ✅ AddServerScreen
- ✅ ServerCard widget
- ✅ Connection service
- ✅ Secure storage integration

### Week 3-4: File System

**Day 15-18: File Browser**
- ✅ File models
- ✅ FileBrowserScreen
- ✅ FileItem widget
- ✅ BreadcrumbNav
- ✅ File icons
- ✅ Git status badges

**Day 19-21: File Viewer**
- ✅ FileViewerScreen
- ✅ Syntax highlighting
- ✅ Code themes
- ✅ Zoom controls
- ✅ Copy/Share functionality

**Day 22-24: File Search**
- ✅ FileSearchScreen
- ✅ Search functionality
- ✅ Filter options
- ✅ Sort options

**Day 25-28: Polish & Testing**
- ✅ Unit tests
- ✅ Widget tests
- ✅ Bug fixes
- ✅ Performance optimization

### Week 5-6: Chat Interface

**Day 29-32: Conversation List**
- ✅ ConversationListScreen
- ✅ ConversationCard
- ✅ Search functionality
- ✅ Swipe actions

**Day 33-38: Chat Screen**
- ✅ ChatScreen
- ✅ UserMessage widget
- ✅ AIMessage widget
- ✅ MessageInput
- ✅ Streaming support
- ✅ WebSocket integration

**Day 39-42: Advanced Features**
- ✅ CodeBlock with highlighting
- ✅ FileDiffViewer
- ✅ ToolUsageCard
- ✅ TypingIndicator
- ✅ Message actions

### Week 7-8: Polish & Testing

**Day 43-49: Testing**
- ✅ Complete unit tests
- ✅ Complete widget tests
- ✅ Integration tests
- ✅ Performance testing
- ✅ Security audit

**Day 50-56: Polish**
- ✅ Animations refinement
- ✅ UI/UX improvements
- ✅ Bug fixes
- ✅ Documentation
- ✅ Code review

### Week 9-10: Beta & Release

**Day 57-63: Beta Testing**
- ✅ Internal testing
- ✅ Bug fixes
- ✅ Performance optimization
- ✅ User feedback integration

**Day 64-70: Release Preparation**
- ✅ App store assets
- ✅ Screenshots
- ✅ Description
- ✅ Privacy policy
- ✅ Terms of service
- ✅ Final testing
- ✅ Release!

---

## 🚀 النشر والإطلاق (Deployment & Release)

### 1. Build Configuration

**Android (build.gradle):**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.nexor.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
}
```

**iOS (Info.plist):**
```xml
<key>CFBundleDisplayName</key>
<string>Nexor</string>
<key>CFBundleIdentifier</key>
<string>com.nexor.app</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### 2. App Store Submission

**Google Play Store:**
- App name: Nexor - AI Code Assistant
- Short description: Code from anywhere with AI
- Full description: [Detailed description]
- Category: Developer Tools
- Content rating: Everyone
- Privacy policy: Required
- Screenshots: 8 screenshots (phone + tablet)

**Apple App Store:**
- App name: Nexor
- Subtitle: AI Code Assistant
- Description: [Detailed description]
- Category: Developer Tools
- Age rating: 4+
- Privacy policy: Required
- Screenshots: 6.5", 5.5", 12.9" iPad

### 3. Release Checklist

**Pre-Release:**
- [ ] All tests passing
- [ ] No critical bugs
- [ ] Performance benchmarks met
- [ ] Security audit completed
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] App store assets ready
- [ ] Marketing materials ready

**Release:**
- [ ] Build signed APK/IPA
- [ ] Upload to stores
- [ ] Submit for review
- [ ] Monitor review status
- [ ] Respond to reviewer questions

**Post-Release:**
- [ ] Monitor crash reports
- [ ] Monitor user reviews
- [ ] Track analytics
- [ ] Gather user feedback
- [ ] Plan next iteration

---

## 📊 مقاييس النجاح (Success Metrics)

### Performance Metrics

**App Launch:**
- Cold start: < 2 seconds ✅
- Warm start: < 1 second ✅
- Hot start: < 0.5 seconds ✅

**UI Performance:**
- Frame rate: 60 FPS (120 FPS on supported devices) ✅
- Jank-free scrolling ✅
- Smooth animations ✅

**Network:**
- API response time: < 500ms ✅
- File download speed: Optimal ✅
- WebSocket latency: < 100ms ✅

**Memory:**
- Memory usage: < 150MB average ✅
- No memory leaks ✅
- Efficient garbage collection ✅

**Battery:**
- Battery drain: < 5% per hour active use ✅
- Background battery usage: < 1% per hour ✅

### Quality Metrics

**Stability:**
- Crash-free rate: > 99% ✅
- ANR rate: < 0.1% ✅
- Error rate: < 1% ✅

**User Experience:**
- App store rating: > 4.5 stars 🎯
- User retention (Day 1): > 60% 🎯
- User retention (Day 7): > 40% 🎯
- User retention (Day 30): > 20% 🎯

**Engagement:**
- Daily active users: Track 📈
- Session duration: > 10 minutes 🎯
- Sessions per user: > 3 per day 🎯

### Business Metrics

**Downloads:**
- Month 1: 1,000+ downloads 🎯
- Month 3: 5,000+ downloads 🎯
- Month 6: 10,000+ downloads 🎯

**User Satisfaction:**
- NPS Score: > 50 🎯
- Support tickets: < 5% of users 🎯
- Feature requests: Track and prioritize 📝

---

## 🎯 الخلاصة والخطوات التالية

### ما تم إنجازه

تم إنشاء وثائق شاملة لتطبيق **Nexor** تغطي:

✅ **الرؤية والأهداف** - تطبيق موبايل متقدم للعمل مع OpenCode
✅ **المعماري التقني** - Clean Architecture مع Flutter
✅ **نظام التصميم** - Dark theme مستوحى من Apple
✅ **هيكل المشروع** - تنظيم واضح ومنطقي
✅ **المكتبات** - اختيار أفضل الأدوات (Riverpod, GoRouter, Dio, Hive)
✅ **الميزات التفصيلية** - 3 مراحل رئيسية
✅ **تكامل API** - اتصال كامل مع OpenCode
✅ **إدارة الحالة** - Riverpod providers منظمة
✅ **الأمان** - تشفير وحماية كاملة
✅ **الأداء** - تحسينات شاملة
✅ **الاختبارات** - استراتيجية واضحة
✅ **خطة التنفيذ** - 10 أسابيع مفصلة

### الخطوات التالية

**1. مراجعة الوثائق**
- قراءة كاملة للوثائق
- التأكد من فهم جميع المكونات
- طرح أي أسئلة أو استفسارات

**2. البدء في التنفيذ**
- إنشاء Flutter project
- إعداد البنية الأساسية
- تطبيق Design System
- بناء المكونات الأساسية

**3. التطوير التدريجي**
- Phase 1: Server Management (أسبوعين)
- Phase 2: File System (أسبوعين)
- Phase 3: Chat Interface (أسبوعين)
- Polish & Testing (4 أسابيع)

**4. الإطلاق**
- Beta testing
- App store submission
- Marketing & promotion
- User feedback & iteration

### الموارد المطلوبة

**فريق التطوير:**
- 1-2 Flutter developers
- 1 UI/UX designer (للمراجعة)
- 1 QA tester

**الأدوات:**
- Flutter SDK
- Android Studio / VS Code
- Figma (للتصميم)
- Firebase (للـ analytics)
- Sentry (للـ error tracking)

**الوقت:**
- 10 أسابيع للنسخة الأولى
- 2-4 أسابيع للـ beta testing
- إطلاق في الشهر الثالث

---

## 📞 الدعم والمساعدة

**للأسئلة والاستفسارات:**
- راجع هذه الوثائق أولاً
- تحقق من OpenCode docs: https://opencode.ai/docs
- افتح issue على GitHub
- انضم لـ Discord community

**للمساهمة:**
- Fork the repository
- Create feature branch
- Submit pull request
- Follow contribution guidelines

---

**تم إنشاء هذه الوثائق بواسطة OpenCode**
**آخر تحديث: 2024**

**جاهز للبدء؟ لنبني Nexor! 🚀**
