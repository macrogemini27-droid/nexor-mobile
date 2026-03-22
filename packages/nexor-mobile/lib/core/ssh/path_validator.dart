import '../errors/error_types.dart';

/// Validates file paths to prevent path traversal attacks
class PathValidator {
  /// Validates that a path is within the allowed root directory
  /// 
  /// Throws [PathValidationException] if:
  /// - Path contains '..' components
  /// - Path resolves outside allowedRoot
  /// - Path is absolute and doesn't start with allowedRoot
  static String validatePath(String path, String allowedRoot) {
    // Normalize the allowed root
    final root = _normalizePath(allowedRoot);
    
    // Normalize and resolve the input path
    final normalized = _normalizePath(path);
    
    // Check for '..' components (path traversal attempt)
    if (normalized.contains('/../') || 
        normalized.endsWith('/..') || 
        normalized == '..' ||
        normalized.startsWith('../')) {
      throw PathValidationException(
        path,
        'Path contains ".." components'
      );
    }
    
    // Resolve to absolute path
    final absolute = _resolveAbsolute(normalized, root);
    
    // Verify the resolved path starts with allowed root
    if (!absolute.startsWith(root)) {
      throw PathValidationException(
        path,
        'Path resolves outside allowed root'
      );
    }
    
    // Additional check: ensure no '..' after normalization
    final parts = absolute.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.contains('..')) {
      throw PathValidationException(
        path,
        'Path contains ".." after normalization'
      );
    }
    
    return absolute;
  }
  
  /// Sanitizes a path by normalizing separators and removing redundant components
  static String sanitizePath(String path) {
    if (path.isEmpty) return '/';
    
    // Normalize path separators
    var sanitized = path.replaceAll(r'\', '/');
    
    // Remove duplicate slashes
    sanitized = sanitized.replaceAll(RegExp(r'/+'), '/');
    
    // Remove trailing slash unless it's root
    if (sanitized.length > 1 && sanitized.endsWith('/')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }
    
    return sanitized;
  }
  
  /// Normalizes a path by removing redundant separators and components
  static String _normalizePath(String path) {
    if (path.isEmpty) return '/';
    
    // Replace backslashes with forward slashes
    var normalized = path.replaceAll(r'\', '/');
    
    // Remove duplicate slashes
    normalized = normalized.replaceAll(RegExp(r'/+'), '/');
    
    // Ensure absolute paths start with /
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    
    // Remove trailing slash unless it's root
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    
    return normalized;
  }
  
  /// Resolves a path to absolute form relative to root
  static String _resolveAbsolute(String path, String root) {
    // If path is already absolute, return it
    if (path.startsWith('/')) {
      return path;
    }
    
    // Otherwise, join with root
    final combined = root.endsWith('/') ? '$root$path' : '$root/$path';
    return _normalizePath(combined);
  }
  
  /// Validates multiple paths in a single call
  static List<String> validatePaths(List<String> paths, String allowedRoot) {
    return paths.map((path) => validatePath(path, allowedRoot)).toList();
  }
  
  /// Checks if a path is safe without throwing an exception
  static bool isSafePath(String path, String allowedRoot) {
    try {
      validatePath(path, allowedRoot);
      return true;
    } catch (e) {
      return false;
    }
  }
}
