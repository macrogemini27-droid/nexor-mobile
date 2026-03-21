# 📋 خطة تطوير Nexor Mobile - OpenCode Logic Integration

## 🎯 الهدف الرئيسي

تحويل تطبيق Nexor Mobile من **thin client** (يتصل بـ OpenCode Server) إلى **standalone app** يحتوي على كل منطق OpenCode بداخله، مع تنفيذ الأوامر والعمليات على السيرفر البعيد عبر SSH.

---

## 🏗️ المعمارية المستهدفة

### الفكرة الأساسية

```
┌─────────────────────────────────────────────────────────────┐
│                    📱 Nexor Mobile App                      │
│                    (على هاتف المستخدم)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  🧠 OpenCode Logic (مدمج في التطبيق)                      │
│  ├── AI Integration (Anthropic, OpenAI, Google)            │
│  ├── Session Management (SQLite محلي)                      │
│  ├── Tool Orchestration (تنسيق تنفيذ الأدوات)             │
│  ├── Message Processing (معالجة الرسائل والـ streaming)    │
│  ├── Permission System (نظام الصلاحيات)                   │
│  └── Agent System (أنواع الـ agents المختلفة)             │
│                                                             │
│  📡 SSH Client (للاتصال بالسيرفر)                         │
│  ├── Command Execution (تنفيذ الأوامر)                     │
│  ├── SFTP (عمليات الملفات)                                │
│  └── Session Management (إدارة الاتصال)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ SSH Connection
┌─────────────────────────────────────────────────────────────┐
│                  🖥️ Remote Server                           │
│                  (سيرفر المستخدم البعيد)                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✋ Execution Environment (بيئة التنفيذ فقط)               │
│  ├── Bash Commands (تنفيذ الأوامر)                         │
│  ├── File System (قراءة/كتابة/تعديل الملفات)              │
│  ├── Git Operations (عمليات Git)                          │
│  └── Project Files (ملفات المشروع)                        │
│                                                             │
│  ⚠️ ملاحظة: لا يوجد OpenCode Server على السيرفر!         │
│              السيرفر فقط لتنفيذ الأوامر                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 المفاهيم الأساسية

### 1. OpenCode Logic في التطبيق

**ماذا يعني هذا؟**
- كل "عقل" OpenCode (AI integration, session management, tool orchestration) موجود في تطبيق Flutter
- التطبيق يتخذ القرارات: متى يستدعي AI، أي tool يستخدم، كيف يعالج الردود
- التطبيق يدير الـ sessions والـ messages محلياً في قاعدة بيانات SQLite

**ماذا لا يعني؟**
- ❌ لا نحتاج تثبيت OpenCode على السيرفر
- ❌ لا نحتاج OpenCode Server يشتغل
- ❌ لا نحتاج Node.js أو Bun على السيرفر

### 2. الأدوات (Tools) تتنفذ على السيرفر

**كيف يعمل؟**

عندما AI يقرر استخدام أداة (مثل `bash` أو `read`):

```
1. AI يقول: "أريد تنفيذ ls -la"
   ↓
2. التطبيق يستقبل tool call
   ↓
3. التطبيق يتصل بالسيرفر عبر SSH
   ↓
4. التطبيق ينفذ الأمر: ssh.execute("ls -la")
   ↓
5. السيرفر ينفذ الأمر ويرجع النتيجة
   ↓
6. التطبيق يرسل النتيجة للـ AI
   ↓
7. AI يكمل المحادثة بناءً على النتيجة
```

**أمثلة:**

#### مثال 1: قراءة ملف
```dart
// AI يطلب قراءة ملف
Tool: read
Parameters: { filePath: "/home/user/app.js" }

// التطبيق ينفذ عبر SFTP
final content = await sftpClient.readFile("/home/user/app.js");

// التطبيق يرجع النتيجة للـ AI
return ToolResult(output: content);
```

#### مثال 2: تنفيذ أمر
```dart
// AI يطلب تنفيذ أمر
Tool: bash
Parameters: { command: "git status" }

// التطبيق ينفذ عبر SSH
final result = await sshClient.execute("git status");

// التطبيق يرجع النتيجة للـ AI
return ToolResult(output: result.stdout);
```

#### مثال 3: تعديل ملف
```dart
// AI يطلب تعديل ملف
Tool: edit
Parameters: { 
  filePath: "/home/user/app.js",
  edits: [
    { line: 10, oldText: "const x = 1", newText: "const x = 2" }
  ]
}

// التطبيق:
// 1. يقرأ الملف عبر SFTP
final content = await sftpClient.readFile("/home/user/app.js");

// 2. يطبق التعديلات محلياً
final newContent = applyEdits(content, edits);

// 3. يكتب الملف المعدل عبر SFTP
await sftpClient.writeFile("/home/user/app.js", newContent);

// 4. يرجع النتيجة للـ AI
return ToolResult(output: "File edited successfully");
```

---

## 📦 المكونات الرئيسية

### 1. AI Integration Layer

**المسؤولية:**
- الاتصال بـ AI providers (Anthropic, OpenAI, Google)
- إرسال الرسائل واستقبال الردود
- معالجة streaming responses
- استخراج tool calls من ردود AI

**التقنيات:**
- HTTP client (Dio)
- SSE (Server-Sent Events) parsing
- JSON parsing

**الملفات المتوقعة:**
```
lib/core/ai/
├── providers/
│   ├── ai_provider.dart (interface)
│   ├── anthropic_provider.dart
│   ├── openai_provider.dart
│   └── google_provider.dart
├── models/
│   ├── ai_message.dart
│   ├── ai_stream_event.dart
│   └── tool_call.dart
└── streaming/
    └── sse_parser.dart
```

---

### 2. Session Management Layer

**المسؤولية:**
- إدارة الـ sessions (المحادثات)
- حفظ واسترجاع الرسائل
- تتبع تاريخ المحادثة
- إدارة context window

**التقنيات:**
- SQLite (عبر drift package)
- Local storage

**قاعدة البيانات:**
```sql
-- Sessions table
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  title TEXT,
  server_id TEXT,
  directory TEXT,
  created_at INTEGER,
  updated_at INTEGER
);

-- Messages table
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  session_id TEXT,
  role TEXT, -- 'user' or 'assistant'
  created_at INTEGER,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- Message Parts table
CREATE TABLE message_parts (
  id TEXT PRIMARY KEY,
  message_id TEXT,
  type TEXT, -- 'text', 'tool_call', 'tool_result', 'reasoning'
  content TEXT,
  metadata TEXT, -- JSON
  FOREIGN KEY (message_id) REFERENCES messages(id)
);
```

**الملفات المتوقعة:**
```
lib/data/database/
├── app_database.dart (drift database)
├── tables/
│   ├── sessions_table.dart
│   ├── messages_table.dart
│   └── message_parts_table.dart
└── daos/
    ├── session_dao.dart
    └── message_dao.dart
```

---

### 3. Tool System Layer

**المسؤولية:**
- تعريف الأدوات المتاحة
- تنفيذ الأدوات عبر SSH/SFTP
- التحقق من الصلاحيات
- معالجة نتائج الأدوات

**الأدوات الأساسية:**

#### 3.1 bash Tool
```dart
class BashTool extends Tool {
  final SSHClient sshClient;
  
  @override
  String get id => 'bash';
  
  @override
  String get description => 'Execute bash commands on the remote server';
  
  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'command': {
        'type': 'string',
        'description': 'The bash command to execute',
      },
    },
    'required': ['command'],
  };
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final command = args['command'] as String;
    
    // Check permission
    await ctx.checkPermission('bash', patterns: [command]);
    
    // Execute via SSH
    final result = await sshClient.execute(
      command,
      workingDirectory: ctx.workingDirectory,
    );
    
    return ToolResult(
      title: 'Command: $command',
      output: result.stdout,
      exitCode: result.exitCode,
    );
  }
}
```

#### 3.2 read Tool
```dart
class ReadTool extends Tool {
  final SFTPClient sftpClient;
  
  @override
  String get id => 'read';
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final filePath = args['filePath'] as String;
    final offset = args['offset'] as int? ?? 1;
    final limit = args['limit'] as int? ?? 2000;
    
    // Check permission
    await ctx.checkPermission('read', patterns: [filePath]);
    
    // Read via SFTP
    final content = await sftpClient.readFile(filePath);
    final lines = content.split('\n');
    
    // Apply pagination
    final start = offset - 1;
    final end = start + limit;
    final selectedLines = lines.skip(start).take(limit).toList();
    
    // Format with line numbers
    final output = selectedLines.asMap().entries
      .map((e) => '${start + e.key + 1}: ${e.value}')
      .join('\n');
    
    return ToolResult(
      title: 'File: $filePath',
      output: output,
      metadata: {
        'totalLines': lines.length,
        'truncated': end < lines.length,
      },
    );
  }
}
```

#### 3.3 write Tool
```dart
class WriteTool extends Tool {
  final SFTPClient sftpClient;
  
  @override
  String get id => 'write';
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final filePath = args['filePath'] as String;
    final content = args['content'] as String;
    
    // Check permission
    await ctx.checkPermission('write', patterns: [filePath]);
    
    // Write via SFTP
    await sftpClient.writeFile(filePath, content);
    
    return ToolResult(
      title: 'Written: $filePath',
      output: 'File written successfully',
    );
  }
}
```

#### 3.4 edit Tool
```dart
class EditTool extends Tool {
  final SFTPClient sftpClient;
  
  @override
  String get id => 'edit';
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final filePath = args['filePath'] as String;
    final edits = args['edits'] as List;
    
    // Check permission
    await ctx.checkPermission('edit', patterns: [filePath]);
    
    // Read current content
    final content = await sftpClient.readFile(filePath);
    final lines = content.split('\n');
    
    // Apply edits
    for (final edit in edits) {
      final lineNum = edit['line'] as int;
      final oldText = edit['oldText'] as String;
      final newText = edit['newText'] as String;
      
      if (lines[lineNum - 1].contains(oldText)) {
        lines[lineNum - 1] = lines[lineNum - 1].replaceAll(oldText, newText);
      }
    }
    
    // Write back
    await sftpClient.writeFile(filePath, lines.join('\n'));
    
    return ToolResult(
      title: 'Edited: $filePath',
      output: 'File edited successfully',
    );
  }
}
```

#### 3.5 glob Tool
```dart
class GlobTool extends Tool {
  final SSHClient sshClient;
  
  @override
  String get id => 'glob';
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final pattern = args['pattern'] as String;
    
    // Execute find command via SSH
    final result = await sshClient.execute(
      'find . -name "$pattern" -type f',
      workingDirectory: ctx.workingDirectory,
    );
    
    return ToolResult(
      title: 'Files matching: $pattern',
      output: result.stdout,
    );
  }
}
```

#### 3.6 grep Tool
```dart
class GrepTool extends Tool {
  final SSHClient sshClient;
  
  @override
  String get id => 'grep';
  
  @override
  Future<ToolResult> execute(Map<String, dynamic> args, ToolContext ctx) async {
    final pattern = args['pattern'] as String;
    final include = args['include'] as String?;
    
    // Build grep command
    var command = 'grep -rn "$pattern" .';
    if (include != null) {
      command += ' --include="$include"';
    }
    
    // Execute via SSH
    final result = await sshClient.execute(
      command,
      workingDirectory: ctx.workingDirectory,
    );
    
    return ToolResult(
      title: 'Search results: $pattern',
      output: result.stdout,
    );
  }
}
```

**الملفات المتوقعة:**
```
lib/core/tools/
├── tool.dart (base class)
├── tool_registry.dart
├── tool_context.dart
├── tool_result.dart
└── implementations/
    ├── bash_tool.dart
    ├── read_tool.dart
    ├── write_tool.dart
    ├── edit_tool.dart
    ├── glob_tool.dart
    └── grep_tool.dart
```

---

### 4. SSH Integration Layer

**المسؤولية:**
- إدارة اتصال SSH بالسيرفر
- تنفيذ الأوامر
- عمليات SFTP (قراءة/كتابة الملفات)
- إدارة الـ sessions

**التقنيات:**
- dartssh2 package

**الملفات المتوقعة:**
```
lib/core/ssh/
├── ssh_client.dart
├── sftp_client.dart
├── ssh_session.dart
└── models/
    ├── ssh_config.dart
    └── command_result.dart
```

---

### 5. Session Processor (المعالج الرئيسي)

**المسؤولية:**
- تنسيق العملية الكاملة من بداية لنهاية
- استقبال رسالة المستخدم
- إرسالها للـ AI
- معالجة streaming response
- تنفيذ tool calls
- إرجاع النتائج للـ AI
- حفظ المحادثة

**Flow الكامل:**

```
1. User sends message
   ↓
2. SessionProcessor.process(message)
   ↓
3. Build message history from database
   ↓
4. Call AI provider with history + tools
   ↓
5. Stream AI response:
   ├─→ Text chunk? → Update UI
   ├─→ Tool call? → Execute tool via SSH
   │                ↓
   │                Get result
   │                ↓
   │                Send result back to AI
   │                ↓
   │                Continue streaming
   └─→ Done? → Save to database
```

**الكود المتوقع:**
```dart
class SessionProcessor {
  final AIProvider aiProvider;
  final ToolRegistry toolRegistry;
  final SessionDao sessionDao;
  final MessageDao messageDao;
  
  Future<void> process({
    required String sessionId,
    required String userMessage,
  }) async {
    // 1. Save user message
    final userMsg = await messageDao.insert(
      sessionId: sessionId,
      role: 'user',
      parts: [TextPart(text: userMessage)],
    );
    
    // 2. Build message history
    final history = await _buildHistory(sessionId);
    
    // 3. Create assistant message
    final assistantMsg = await messageDao.insert(
      sessionId: sessionId,
      role: 'assistant',
      parts: [],
    );
    
    // 4. Stream AI response
    final stream = aiProvider.streamText(
      messages: history,
      tools: toolRegistry.getToolDefinitions(),
    );
    
    await for (final event in stream) {
      switch (event.type) {
        case 'text-delta':
          // Update UI with text
          await _handleTextDelta(assistantMsg.id, event.text);
          break;
          
        case 'tool-call':
          // Execute tool
          final result = await _executeTool(
            toolName: event.toolName,
            input: event.input,
            sessionId: sessionId,
          );
          
          // Send result back to AI
          await _sendToolResult(result);
          break;
          
        case 'done':
          // Save final message
          await messageDao.update(assistantMsg.id);
          break;
      }
    }
  }
  
  Future<ToolResult> _executeTool({
    required String toolName,
    required Map<String, dynamic> input,
    required String sessionId,
  }) async {
    final tool = toolRegistry.getTool(toolName);
    final context = ToolContext(
      sessionId: sessionId,
      workingDirectory: await _getWorkingDirectory(sessionId),
    );
    
    return await tool.execute(input, context);
  }
}
```

**الملفات المتوقعة:**
```
lib/core/session/
├── session_processor.dart
├── message_builder.dart
└── context_manager.dart
```

---

### 6. Permission System

**المسؤولية:**
- التحقق من صلاحيات تنفيذ الأدوات
- سؤال المستخدم عند الحاجة
- حفظ قرارات المستخدم

**الملفات المتوقعة:**
```
lib/core/permissions/
├── permission_service.dart
├── permission_rule.dart
└── permission_dialog.dart
```

---

### 7. Agent System

**المسؤولية:**
- تعريف أنواع الـ agents المختلفة
- كل agent له صلاحيات وأدوات مختلفة

**الـ Agents:**
- **build**: Agent افتراضي، كل الصلاحيات
- **explore**: للبحث السريع، read-only
- **plan**: للتخطيط، بدون تنفيذ

**الملفات المتوقعة:**
```
lib/core/agents/
├── agent.dart
├── agent_config.dart
└── agents/
    ├── build_agent.dart
    ├── explore_agent.dart
    └── plan_agent.dart
```

---

## 🔄 User Flow الكامل

### السيناريو: المستخدم يطلب "اعرض محتوى ملف app.js"

```
1. المستخدم يكتب: "اعرض محتوى ملف app.js"
   ↓
2. التطبيق يحفظ الرسالة في قاعدة البيانات
   ↓
3. التطبيق يبني message history
   ↓
4. التطبيق يرسل للـ AI (Anthropic):
   Messages: [
     { role: "user", content: "اعرض محتوى ملف app.js" }
   ]
   Tools: [read, write, bash, edit, glob, grep]
   ↓
5. AI يفكر ويقرر استخدام read tool:
   {
     "type": "tool_use",
     "name": "read",
     "input": {
       "filePath": "/home/user/project/app.js"
     }
   }
   ↓
6. التطبيق يستقبل tool call
   ↓
7. التطبيق يتحقق من الصلاحيات
   ↓
8. التطبيق يتصل بالسيرفر عبر SSH
   ↓
9. التطبيق يقرأ الملف عبر SFTP:
   sftpClient.readFile("/home/user/project/app.js")
   ↓
10. السيرفر يرجع محتوى الملف
   ↓
11. التطبيق يرسل النتيجة للـ AI:
   {
     "type": "tool_result",
     "content": "1: const express = require('express');\n2: ..."
   }
   ↓
12. AI يستقبل النتيجة ويرد:
   "هذا هو محتوى ملف app.js. الملف يحتوي على..."
   ↓
13. التطبيق يعرض الرد للمستخدم
   ↓
14. التطبيق يحفظ المحادثة في قاعدة البيانات
```

---

## 📚 المراجع والموارد

### OpenCode Source Code
- **المسار:** `/workspaces/ServMo/work/open/opencode/packages/opencode/src/`
- **الملفات المهمة:**
  - `session/processor.ts` - معالج الـ sessions
  - `session/llm.ts` - AI integration
  - `tool/tool.ts` - نظام الأدوات
  - `provider/provider.ts` - AI providers
  - `agent/agent.ts` - نظام الـ agents

### Nexor Mobile Current Code
- **المسار:** `/workspaces/ServMo/work/open/opencode/packages/nexor-mobile/lib/`
- **البنية الحالية:**
  - `domain/` - Entities and repositories
  - `data/` - Data sources and implementations
  - `presentation/` - UI and state management

### Packages المطلوبة
```yaml
dependencies:
  # SSH
  dartssh2: ^2.13.0
  
  # Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # HTTP
  dio: ^5.4.0
  
  # State Management (موجود)
  flutter_riverpod: ^2.5.1
  
  # Utilities
  uuid: ^4.3.0
  path: ^1.9.0
```

---

## ✅ معايير النجاح

### المرحلة 1 (MVP):
- [ ] الاتصال بسيرفر عبر SSH
- [ ] تنفيذ أمر bash بسيط
- [ ] قراءة ملف عبر SFTP
- [ ] محادثة بسيطة مع AI
- [ ] Tool call واحد يعمل

### المرحلة 2 (Core Features):
- [ ] كل الأدوات الأساسية تعمل (bash, read, write, edit, glob, grep)
- [ ] Session management كامل
- [ ] Streaming responses
- [ ] Permission system
- [ ] حفظ المحادثات محلياً

### المرحلة 3 (Advanced):
- [ ] Multiple agents
- [ ] Context management
- [ ] Error handling متقدم
- [ ] UI polish

---

## 📝 ملاحظات مهمة

### ما يجب تذكره:
1. **OpenCode Logic في التطبيق** - كل المنطق والذكاء في Flutter
2. **السيرفر للتنفيذ فقط** - السيرفر مجرد بيئة تنفيذ
3. **لا نحتاج OpenCode Server** - لا تثبيت، لا Node.js، لا شيء
4. **SSH هو الجسر** - كل التواصل مع السيرفر عبر SSH/SFTP
5. **AI في الـ Cloud** - نتصل بـ Anthropic/OpenAI APIs مباشرة

### الفرق عن الحل القديم:
```
❌ الحل القديم:
   Mobile App → HTTP → OpenCode Server → Execute

✅ الحل الجديد:
   Mobile App (OpenCode Logic) → SSH → Server → Execute
```

---

## 🎯 Tasks Section

<!-- 
  ⚠️ للمطور القادم:
  
  أضف المهام هنا بالتفصيل. كل مهمة يجب أن تحتوي على:
  - [ ] عنوان المهمة
  - الوصف التفصيلي
  - الملفات المتوقع إنشاؤها/تعديلها
  - معايير القبول (Acceptance Criteria)
  - التقدير الزمني
  
  مثال:
  
  ### Phase 1: Foundation
  
  #### Task 1.1: Setup Drift Database
  - [ ] Create database schema
  - [ ] Implement Sessions table
  - [ ] Implement Messages table
  - [ ] Implement MessageParts table
  - [ ] Create DAOs
  
  **Files:**
  - lib/data/database/app_database.dart
  - lib/data/database/tables/sessions_table.dart
  - lib/data/database/tables/messages_table.dart
  - lib/data/database/tables/message_parts_table.dart
  
  **Acceptance Criteria:**
  - [ ] Can create a session
  - [ ] Can save messages
  - [ ] Can retrieve message history
  
  **Estimate:** 3-4 days
  
  ---
  
  ابدأ إضافة المهام من هنا ↓
-->

### Phase 1: Foundation & SSH Integration

<!-- Tasks will be added here -->

---

### Phase 2: AI Integration

<!-- Tasks will be added here -->

---

### Phase 3: Tool System

<!-- Tasks will be added here -->

---

### Phase 4: Session Processing

<!-- Tasks will be added here -->

---

### Phase 5: Advanced Features

<!-- Tasks will be added here -->

---

## 📞 للتواصل والأسئلة

إذا كان لديك أي أسئلة حول هذه الخطة:
1. راجع قسم "المفاهيم الأساسية" أعلاه
2. راجع "User Flow الكامل" لفهم كيف تعمل الأمور
3. راجع OpenCode source code في المسار المذكور
4. اسأل في التعليقات أو افتح issue

---

**تاريخ الإنشاء:** 18 مارس 2026  
**الإصدار:** 1.0  
**الحالة:** جاهز للتنفيذ
