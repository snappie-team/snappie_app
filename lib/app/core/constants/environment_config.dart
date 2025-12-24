import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // Fallback flag - when true, use local URL instead of production
  static bool _useFallbackUrl = false;
  
  // Helper method to get environment variables (no default values)
  static String _getEnv(String key) {
    try {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        throw Exception('Environment variable $key is not set in .env file');
      }
      return value;
    } catch (e) {
      throw Exception('Failed to load environment variable $key: $e');
    }
  }

  // Environment Type
  static String get environmentType => _getEnv('ENVIRONMENT');

  static String get apiVersion => _getEnv('API_VERSION');
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  
  // Registration API Key
  static String get registrationApiKey => _getEnv('REGISTRATION_API_KEY');
  
  // Select Environment Type
  static String get baseUrl {
    // If fallback is enabled, always use local URL
    if (_useFallbackUrl) {
      return _getEnv('LOCAL_BASE_URL');
    }
    
    switch (environmentType) {
      case 'development':
        return _getEnv('LOCAL_BASE_URL');
      case 'production':
        return _getEnv('HOST_BASE_URL');
      default:
        return _getEnv('LOCAL_BASE_URL');
    }
  }

  static String get fullApiUrl => '$baseUrl$apiVersion';
  static String get localUrl => '${_getEnv('LOCAL_BASE_URL')}$apiVersion';
  static String get productionUrl => '${_getEnv('HOST_BASE_URL')}$apiVersion';
  
  // Fallback management
  static bool get isUsingFallback => _useFallbackUrl;
  
  static void enableFallback() {
    _useFallbackUrl = true;
    print('🔄 Fallback enabled: Now using local URL');
  }
  
  static void disableFallback() {
    _useFallbackUrl = false;
    print('✅ Fallback disabled: Using configured environment URL');
  }
  
  static bool get isProduction => environmentType == 'production';
  static bool get canUseFallback => isProduction && !_useFallbackUrl;
  
  // Logging configuration
  static const bool enableLogging = true;
  static const bool enableVerboseLogging = true;
}
