# Architecture: Nexor Mobile with Embedded OpenCode

## Overview
Instead of cloning Termux, we use nodejs-mobile to run OpenCode directly inside the Flutter app.

## Components

```
┌─────────────────────────────────────────┐
│         Nexor Mobile App                │
├─────────────────────────────────────────┤
│  Flutter UI Layer                       │
│  ├── Chat Interface                     │
│  ├── File Browser                       │
│  ├── Terminal Emulator (xterm)         │
│  └── Settings                           │
├─────────────────────────────────────────┤
│  Bridge Layer (Method Channel)          │
│  ├── Start/Stop Server                 │
│  ├── Get Server Status                 │
│  └── HTTP Client (localhost)           │
├─────────────────────────────────────────┤
│  nodejs-mobile Runtime                  │
│  ├── Node.js v18+ (~30MB)              │
│  ├── OpenCode Server (bundled)         │
│  └── Dependencies (pre-installed)      │
└─────────────────────────────────────────┘
```

## Flow

### First Launch:
1. User opens app
2. Show splash screen with progress
3. Extract Node.js runtime (if needed)
4. Extract OpenCode files
5. Start OpenCode server on localhost:4096
6. Connect Flutter UI to localhost:4096
7. Show main interface

### Subsequent Launches:
1. User opens app
2. Check if server running
3. If not, start server
4. Connect UI
5. Ready in <2 seconds

## Implementation

### 1. Add nodejs-mobile to Flutter

```yaml
# pubspec.yaml
dependencies:
  nodejs_mobile: ^0.2.3
```

### 2. Bundle OpenCode

```
assets/
├── nodejs-project/
│   ├── package.json
│   ├── node_modules/
│   │   └── opencode-ai/
│   └── server.js
```

### 3. Start Server on App Launch

```dart
import 'package:nodejs_mobile/nodejs_mobile.dart';

class OpenCodeService {
  static Future<void> start() async {
    await NodejsMobile.startEngine('server.js');
    
    // Wait for server to be ready
    await _waitForServer();
  }
  
  static Future<void> _waitForServer() async {
    for (int i = 0; i < 30; i++) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:4096/health')
        );
        if (response.statusCode == 200) return;
      } catch (e) {
        await Future.delayed(Duration(seconds: 1));
      }
    }
    throw Exception('Server failed to start');
  }
}
```

### 4. Server Script (server.js)

```javascript
// assets/nodejs-project/server.js
const { spawn } = require('child_process');
const path = require('path');

// Start OpenCode
const opencode = spawn('node', [
  path.join(__dirname, 'node_modules/opencode-ai/dist/index.js'),
  '--port', '4096'
]);

opencode.stdout.on('data', (data) => {
  console.log(`OpenCode: ${data}`);
});

opencode.stderr.on('data', (data) => {
  console.error(`OpenCode Error: ${data}`);
});
```

## Advantages

✅ **Small Size**: ~80MB vs 300MB+
✅ **Fast Startup**: <2 seconds after first launch
✅ **No External Dependencies**: Everything bundled
✅ **Works Offline**: No internet needed after install
✅ **Simple Maintenance**: Update OpenCode via app update
✅ **No Licensing Issues**: Can be closed source
✅ **Better UX**: Seamless integration
✅ **Cross-Platform**: Works on Android & iOS

## Disadvantages

⚠️ **Limited Shell Access**: No full terminal like Termux
⚠️ **Fixed Node Version**: Can't easily upgrade Node.js
⚠️ **Larger APK**: ~80MB vs current ~25MB

## Alternative: Hybrid Approach

For users who want full terminal access:

```
Nexor Mobile App
├── Mode 1: Embedded (default)
│   └── Uses nodejs-mobile (80MB)
└── Mode 2: External
    └── Connects to Termux/Remote server
```

This gives users choice:
- Beginners: Use embedded mode (just works)
- Advanced: Use external mode (more control)

## Estimated Development Time

- Week 1: Integrate nodejs-mobile
- Week 2: Bundle OpenCode and test
- Week 3: UI integration and polish
- Week 4: Testing and bug fixes

**Total: 1 month**

## Conclusion

Using nodejs-mobile is the sweet spot:
- Better than requiring Termux (easier UX)
- Better than cloning Termux (smaller, simpler)
- Better than SSH-only (works offline)
- Better than full rewrite (faster development)
