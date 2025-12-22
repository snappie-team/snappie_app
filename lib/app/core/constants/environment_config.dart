import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
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
  
  // Logging configuration
  static const bool enableLogging = true;
  static const bool enableVerboseLogging = true;
}
