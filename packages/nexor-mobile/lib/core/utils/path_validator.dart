class PathValidator {
  /// Validate if a file path is safe to access
  static bool isValidPath(String path) {
    if (path.isEmpty) return false;
    
    // Check for null bytes
    if (path.contains('\x00')) return false;
    
    // Check for path traversal attempts
    if (path.contains('..')) return false;
    
    // Check for absolute paths to system directories
    final systemPaths = [
      '/etc/',
      '/sys/',
      '/proc/',
      '/dev/',
      '/boot/',
      '/root/',
    ];
    
    for (final systemPath in systemPaths) {
      if (path.startsWith(systemPath)) return false;
    }
    
    return true;
  }

  /// Sanitize a file path
  static String sanitizePath(String path) {
    // Remove null bytes
    path = path.replaceAll('\x00', '');
    
    // Remove multiple slashes
    path = path.replaceAll(RegExp(r'/+'), '/');
    
    // Remove trailing slashes
    if (path.endsWith('/') && path.length > 1) {
      path = path.substring(0, path.length - 1);
    }
    
    return path;
  }

  /// Check if path is absolute
  static bool isAbsolutePath(String path) {
    return path.startsWith('/');
  }

  /// Normalize a path
  static String normalizePath(String path) {
    path = sanitizePath(path);
    
    // Split into components
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final normalized = <String>[];
    
    for (final part in parts) {
      if (part == '.') {
        continue;
      } else if (part == '..') {
        if (normalized.isNotEmpty) {
          normalized.removeLast();
        }
      } else {
        normalized.add(part);
      }
    }
    
    final result = '/${normalized.join('/')}';
    return result == '/' ? result : result;
  }

  /// Get file extension
  static String? getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1 || lastDot == path.length - 1) {
      return null;
    }
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Check if file is text-based
  static bool isTextFile(String path) {
    final ext = getExtension(path);
    if (ext == null) return false;
    
    const textExtensions = [
      'txt', 'md', 'json', 'xml', 'yaml', 'yml', 'toml',
      'js', 'ts', 'jsx', 'tsx', 'dart', 'java', 'py', 'rb',
      'go', 'rs', 'c', 'cpp', 'h', 'hpp', 'cs', 'php',
      'html', 'css', 'scss', 'sass', 'less',
      'sh', 'bash', 'zsh', 'fish',
      'sql', 'graphql', 'proto',
      'log', 'conf', 'config', 'ini', 'env',
    ];
    
    return textExtensions.contains(ext);
  }
}
