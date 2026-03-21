# Nexor Mobile

**AI-powered mobile coding assistant with embedded OpenCode logic**

Nexor Mobile is a standalone Flutter application that brings OpenCode's AI-powered development capabilities to your mobile device. It executes commands on remote servers via SSH/SFTP while running all AI logic locally on the device.

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│  Nexor Mobile (Standalone App)         │
├─────────────────────────────────────────┤
│                                         │
│  🧠 Embedded OpenCode Logic             │
│  ├─ AI Integration (3 providers)       │
│  ├─ Session Management (SQLite)        │
│  ├─ Tool Orchestration (6 tools)       │
│  ├─ Message Processing                 │
│  ├─ Permission System                  │
│  └─ Agent System                        │
│                                         │
│  📡 SSH/SFTP Client                     │
│  ├─ Command Execution                  │
│  ├─ File Operations                    │
│  └─ Connection Management              │
│                                         │
│  💾 Local Storage                       │
│  ├─ Hive (Server configs)              │
│  └─ Drift/SQLite (Sessions & messages) │
│                                         │
└─────────────────────────────────────────┘
           ↓ SSH Connection
┌─────────────────────────────────────────┐
│  🖥️ Remote Server                       │
│  └─ Execution only (no OpenCode needed)│
└─────────────────────────────────────────┘
```

## ✨ Features

### Core Capabilities
- ✅ **Standalone Operation**: All OpenCode logic runs on your device
- ✅ **SSH/SFTP Access**: Direct server access without OpenCode server
- ✅ **Multi-AI Support**: Choose between Claude, GPT-4, or Gemini
- ✅ **6 Development Tools**: bash, read, write, edit, glob, grep
- ✅ **Permission System**: Review dangerous operations before execution
- ✅ **Session Management**: Persistent conversation history
- ✅ **Server Management**: Manage multiple SSH servers
- ✅ **File Browser**: Browse and edit remote files

### AI Providers
1. **Anthropic Claude** (claude-3-5-sonnet)
2. **OpenAI GPT-4** (gpt-4)
3. **Google Gemini** (gemini-pro)

### Development Tools
1. **bash**: Execute shell commands
2. **read**: Read file contents
3. **write**: Create/overwrite files
4. **edit**: Edit specific lines in files
5. **glob**: Find files by pattern
6. **grep**: Search file contents

## 📋 Requirements

### Development
- Flutter SDK ≥3.2.0
- Dart SDK ≥3.2.0
- Android Studio / Xcode (for mobile builds)

### Runtime
- Android 6.0+ or iOS 12.0+
- Internet connection (for AI API calls)
- SSH access to a remote server

### API Keys (Required)
You'll need at least one API key:
- Anthropic API key (for Claude)
- OpenAI API key (for GPT-4)
- Google API key (for Gemini)

## 🚀 Setup

### 1. Install Dependencies
```bash
cd /path/to/nexor-mobile
flutter pub get
```

### 2. Generate Code
```bash
# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs

# Or watch for changes during development
dart run build_runner watch --delete-conflicting-outputs
```

### 3. Run the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

## 📱 Usage

### First Time Setup

1. **Add SSH Server**
   - Open the app
   - Go to Servers tab
   - Add your server credentials (host, port, username, password/key)
   - Test connection

2. **Configure AI Provider**
   - Go to Settings → AI Provider
   - Select your preferred provider
   - Enter your API key
   - Save

3. **Start Coding**
   - Go to Chat tab
   - Create new conversation
   - Select project directory
   - Start chatting with AI!

### Example Conversations

**Check server status:**
```
User: Show me the system information
AI: [Executes: uname -a, df -h, free -m]
```

**Fix a bug:**
```
User: There's a syntax error in app.js, can you fix it?
AI: [Reads app.js, identifies error, fixes it, writes back]
```

**Deploy code:**
```
User: Deploy the latest changes to production
AI: [Executes: git pull, npm install, pm2 restart]
```

## 🏛️ Project Structure

```
lib/
├── core/                    # Core business logic
│   ├── ai/                 # AI providers & models
│   │   ├── providers/      # Anthropic, OpenAI, Google
│   │   ├── models/         # AI message models
│   │   └── streaming/      # SSE parser
│   ├── ssh/                # SSH & SFTP clients
│   ├── tools/              # Tool system (6 tools)
│   ├── session/            # Session processing
│   ├── permissions/        # Permission system
│   └── utils/              # Utilities
├── data/                   # Data layer
│   ├── database/           # Drift/SQLite (sessions)
│   │   ├── tables/         # Table definitions
│   │   └── daos/           # Data access objects
│   ├── datasources/        # Data sources
│   │   └── local/          # Hive (server configs)
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
├── presentation/           # Presentation layer
│   ├── screens/            # App screens
│   ├── widgets/            # Reusable widgets
│   ├── providers/          # Riverpod providers
│   └── theme/              # Design system
└── services/               # External services
```

## 🔧 Configuration

### SSH Configuration
- **Host**: IP address or domain
- **Port**: SSH port (default: 22)
- **Username**: SSH username
- **Auth**: Password or private key
- **Timeout**: Connection timeout (default: 30s)

### AI Configuration
- **Provider**: Anthropic, OpenAI, or Google
- **API Key**: Your provider API key
- **Model**: Auto-selected based on provider
- **Max Tokens**: 4096 (default)
- **Temperature**: 0.7 (default)

## 🔒 Security

### Data Storage
- **API Keys**: Stored in platform secure storage (Keychain/Keystore)
- **SSH Passwords**: Stored in platform secure storage
- **Sessions**: Stored in local SQLite database
- **Server Configs**: Stored in local Hive database

### Permission System
The app includes a permission system that prompts for confirmation before executing:
- Destructive commands (rm -rf, dd, mkfs, etc.)
- System modifications (chmod 777, chown -R, etc.)
- Piped downloads (curl | bash, wget | bash)
- Critical file operations

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/core/tools/bash_tool_test.dart
```

### Build for Production
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📚 Documentation

- [Implementation Complete Report](IMPLEMENTATION_COMPLETE.md)
- [Architecture Documentation](EMBEDDED_ARCHITECTURE.md)
- [Build Documentation](BUILD_DOCUMENTATION.md)

## 🐛 Known Issues

1. **No Tests**: Test coverage is currently 0%. Tests need to be added.
2. **Flutter Required**: Build testing requires Flutter SDK installation.
3. **Future Features**: Some UI features show "coming soon" messages:
   - Message regeneration
   - File attachment in chat
   - Search/filter in conversations
   - Directory picker
   - Export conversations

## 🛣️ Roadmap

### Short Term
- [ ] Add unit tests for core logic
- [ ] Add widget tests for UI
- [ ] Implement message regeneration
- [ ] Add file attachment support
- [ ] Implement directory picker

### Long Term
- [ ] Add code completion
- [ ] Implement real-time collaboration
- [ ] Add terminal emulator
- [ ] Support multiple sessions simultaneously
- [ ] Add offline mode with sync

## 📄 License

MIT

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting PRs.

## 📞 Support

For issues and questions:
- GitHub Issues: https://github.com/anomalyco/opencode
- Documentation: https://opencode.ai/docs
