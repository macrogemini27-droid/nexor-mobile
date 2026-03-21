/// Server validation utilities
class ServerValidator {
  ServerValidator._();

  /// Validates server name (3-50 characters)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server name is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Server name must be at least 3 characters';
    }
    
    if (trimmed.length > 50) {
      return 'Server name must not exceed 50 characters';
    }
    
    return null;
  }

  /// Validates host (IP address or domain name)
  static String? validateHost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Host is required';
    }
    
    final trimmed = value.trim();
    
    // Check if it's a valid IP address
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    
    // Check if it's a valid domain name
    final domainRegex = RegExp(
      r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    );
    
    // Check if it's localhost
    if (trimmed == 'localhost') {
      return null;
    }
    
    if (!ipRegex.hasMatch(trimmed) && !domainRegex.hasMatch(trimmed)) {
      return 'Please enter a valid IP address or domain name';
    }
    
    return null;
  }

  /// Validates port (1-65535)
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

  /// Validates username (optional, but if provided must be 1-50 chars)
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Username is optional
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length > 50) {
      return 'Username must not exceed 50 characters';
    }
    
    return null;
  }

  /// Validates password (optional, but if provided must be 1-100 chars)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Password is optional
    }
    
    if (value.length > 100) {
      return 'Password must not exceed 100 characters';
    }
    
    return null;
  }
}
