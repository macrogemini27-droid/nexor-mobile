import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'permission_rule.dart';

class PermissionService {
  final FlutterSecureStorage _storage;
  final List<PermissionRule> _rules = [];
  final List<PermissionRule> _sessionRules = [];
  final StreamController<List<PermissionRule>> _rulesController =
      StreamController<List<PermissionRule>>.broadcast();

  static const String _storageKey = 'permission_rules';

  // Dangerous command patterns
  static final List<RegExp> _dangerousPatterns = [
    RegExp(r'\brm\s+-rf\b', caseSensitive: false),
    RegExp(r'\brm\s+.*\s+-rf\b', caseSensitive: false),
    RegExp(r'\bsudo\s+rm\b', caseSensitive: false),
    RegExp(r'\bdd\s+if=', caseSensitive: false),
    RegExp(r'\bmkfs\b', caseSensitive: false),
    RegExp(r'\bformat\b', caseSensitive: false),
    RegExp(r'>\s*/dev/', caseSensitive: false),
    RegExp(r'\bchmod\s+-R\s+777\b', caseSensitive: false),
    RegExp(r'\bchown\s+-R\b', caseSensitive: false),
    RegExp(r'\bcurl\s+.*\|\s*bash\b', caseSensitive: false),
    RegExp(r'\bwget\s+.*\|\s*bash\b', caseSensitive: false),
    RegExp(r'\b:\(\)\{\s*:\|:&\s*\};:', caseSensitive: false), // Fork bomb
  ];

  PermissionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    _loadRules();
  }

  Stream<List<PermissionRule>> get rulesStream => _rulesController.stream;
  List<PermissionRule> get rules => [..._rules, ..._sessionRules];

  /// Check if a tool operation is allowed
  Future<bool> checkPermission(
    String toolName,
    List<String> patterns, {
    required Future<bool> Function() onAsk,
  }) async {
    // Check for dangerous patterns first
    if (_isDangerous(toolName, patterns)) {
      // Always ask for dangerous operations
      return await onAsk();
    }

    // Check existing rules
    final matchingRule = _findMatchingRule(toolName, patterns);
    if (matchingRule != null) {
      switch (matchingRule.action) {
        case PermissionAction.allow:
          return true;
        case PermissionAction.deny:
          return false;
        case PermissionAction.ask:
          return await onAsk();
      }
    }

    // No rule found, ask user
    return await onAsk();
  }

  /// Check if patterns contain dangerous operations
  bool _isDangerous(String toolName, List<String> patterns) {
    if (toolName == 'bash') {
      for (final pattern in patterns) {
        for (final dangerousPattern in _dangerousPatterns) {
          if (dangerousPattern.hasMatch(pattern)) {
            return true;
          }
        }
      }
    }

    if (toolName == 'write' || toolName == 'edit') {
      for (final pattern in patterns) {
        // Check for system files
        if (pattern.startsWith('/etc/') ||
            pattern.startsWith('/sys/') ||
            pattern.startsWith('/proc/') ||
            pattern.startsWith('/dev/')) {
          return true;
        }
      }
    }

    return false;
  }

  /// Find a matching permission rule
  PermissionRule? _findMatchingRule(String toolName, List<String> patterns) {
    // Check session rules first (temporary)
    for (final rule in _sessionRules.reversed) {
      if (rule.toolName == toolName && _patternsMatch(rule.patterns, patterns)) {
        return rule;
      }
    }

    // Check permanent rules
    for (final rule in _rules.reversed) {
      if (rule.toolName == toolName && _patternsMatch(rule.patterns, patterns)) {
        return rule;
      }
    }

    return null;
  }

  /// Check if patterns match
  bool _patternsMatch(List<String> rulePatterns, List<String> checkPatterns) {
    for (final rulePattern in rulePatterns) {
      for (final checkPattern in checkPatterns) {
        if (checkPattern.contains(rulePattern) ||
            rulePattern.contains(checkPattern)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Add a permission rule
  Future<void> addRule(PermissionRule rule) async {
    if (rule.isTemporary) {
      _sessionRules.add(rule);
    } else {
      _rules.add(rule);
      await _saveRules();
    }
    _rulesController.add(rules);
  }

  /// Remove a permission rule
  Future<void> removeRule(PermissionRule rule) async {
    _rules.remove(rule);
    _sessionRules.remove(rule);
    await _saveRules();
    _rulesController.add(rules);
  }

  /// Clear all session rules
  void clearSessionRules() {
    _sessionRules.clear();
    _rulesController.add(rules);
  }

  /// Clear all rules
  Future<void> clearAllRules() async {
    _rules.clear();
    _sessionRules.clear();
    await _saveRules();
    _rulesController.add(rules);
  }

  /// Load rules from storage
  Future<void> _loadRules() async {
    try {
      final json = await _storage.read(key: _storageKey);
      if (json != null) {
        final List<dynamic> data = jsonDecode(json);
        _rules.clear();
        _rules.addAll(data.map((e) => PermissionRule.fromJson(e)));
        _rulesController.add(rules);
      }
    } catch (e) {
      // Ignore load errors
    }
  }

  /// Save rules to storage
  Future<void> _saveRules() async {
    try {
      final json = jsonEncode(_rules.map((e) => e.toJson()).toList());
      await _storage.write(key: _storageKey, value: json);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Dispose resources
  void dispose() {
    _rulesController.close();
  }
}
