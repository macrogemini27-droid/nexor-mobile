import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// Service to manage OpenCode integration with Termux
class TermuxOpenCodeService {
  static const String TERMUX_PACKAGE = 'com.termux';
  static const String OPENCODE_PORT = '4096';

  /// Check if Termux is installed
  static Future<bool> isTermuxInstalled() async {
    try {
      const platform = MethodChannel('com.nexor.termux_check');
      final result = await platform.invokeMethod('isAppInstalled', {
        'packageName': TERMUX_PACKAGE,
      });
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  /// Check if OpenCode is running
  static Future<bool> isOpenCodeRunning() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://127.0.0.1:$OPENCODE_PORT/health'),
          )
          .timeout(Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Open Termux with setup commands
  static Future<void> setupOpenCodeInTermux() async {
    // Create setup script
    const setupCommands = '''
#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Setting up OpenCode..."

# Update packages
pkg update -y && pkg upgrade -y

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    pkg install -y nodejs
fi

# Install OpenCode
if ! command -v opencode &> /dev/null; then
    echo "📦 Installing OpenCode..."
    npm install -g opencode-ai
fi

# Create startup script
cat > ~/start-opencode.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Starting OpenCode on port $OPENCODE_PORT..."
opencode --port $OPENCODE_PORT
EOF

chmod +x ~/start-opencode.sh

# Start OpenCode
echo "✅ Setup complete! Starting OpenCode..."
~/start-opencode.sh
''';

    // Launch Termux with commands
    final uri = Uri.parse('termux://x/$setupCommands');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Start OpenCode in Termux
  static Future<void> startOpenCode() async {
    final uri = Uri.parse('termux://x/~/start-opencode.sh');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Guide user to install Termux
  static Future<void> guideTermuxInstallation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Install Termux'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nexor requires Termux to run OpenCode locally.'),
            SizedBox(height: 16),
            Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('1. Install Termux from F-Droid'),
            Text('2. Come back to Nexor'),
            Text('3. We\'ll setup everything automatically'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse('https://f-droid.org/packages/com.termux/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              Navigator.pop(context);
            },
            child: Text('Install Termux'),
          ),
        ],
      ),
    );
  }
}

/// Setup wizard screen
class OpenCodeSetupScreen extends StatefulWidget {
  @override
  _OpenCodeSetupScreenState createState() => _OpenCodeSetupScreenState();
}

class _OpenCodeSetupScreenState extends State<OpenCodeSetupScreen> {
  bool _isChecking = true;
  bool _termuxInstalled = false;
  bool _openCodeRunning = false;
  String _status = 'Checking...';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _status = 'Checking Termux installation...';
    });

    _termuxInstalled = await TermuxOpenCodeService.isTermuxInstalled();

    if (_termuxInstalled) {
      setState(() => _status = 'Checking OpenCode status...');
      _openCodeRunning = await TermuxOpenCodeService.isOpenCodeRunning();
    }

    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OpenCode Setup')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isChecking) ...[
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text(_status),
              ] else if (!_termuxInstalled) ...[
                Icon(Icons.warning, size: 64, color: Colors.orange),
                SizedBox(height: 24),
                Text(
                  'Termux Not Installed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                Text(
                  'Nexor needs Termux to run OpenCode locally on your device.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () =>
                      TermuxOpenCodeService.guideTermuxInstallation(context),
                  icon: Icon(Icons.download),
                  label: Text('Install Termux'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _checkStatus,
                  child: Text('I already installed it'),
                ),
              ] else if (!_openCodeRunning) ...[
                Icon(Icons.play_circle, size: 64, color: Colors.blue),
                SizedBox(height: 24),
                Text(
                  'Setup OpenCode',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                Text(
                  'OpenCode is not running. Let\'s set it up!',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await TermuxOpenCodeService.setupOpenCodeInTermux();
                    // Wait a bit then check again
                    await Future.delayed(Duration(seconds: 5));
                    _checkStatus();
                  },
                  icon: Icon(Icons.settings),
                  label: Text('Auto Setup'),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: _checkStatus,
                  child: Text('Check Again'),
                ),
              ] else ...[
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 24),
                Text(
                  'Ready!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                Text(
                  'OpenCode is running and ready to use.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to main app
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: Text('Start Using Nexor'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
