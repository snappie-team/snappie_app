import 'package:flutter/foundation.dart';
import '../constants/environment_config.dart';

/// Log severity levels
enum LogLevel { debug, info, warning, error }

/// Centralized logging service for the Snappie app.
/// 
/// Features:
/// - Level-based logging (debug, info, warning, error)
/// - Automatic filtering of debug logs in production
/// - Emoji prefixes for visual distinction
/// - Optional tag support for categorization
/// - Crash reporting integration ready
/// 
/// Usage:
/// ```dart
/// Logger.debug('Loading data...');
/// Logger.info('User logged in', 'Auth');
/// Logger.warning('Cache expired');
/// Logger.error('Failed to fetch', error, stackTrace);
/// ```
class Logger {
  static const String _defaultTag = 'Snappie';
  
  /// Log a debug message (hidden in production)
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }
  
  /// Log an info message
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }
  
  /// Log a warning message
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }
  
  /// Log an error with optional error object and stack trace
  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    _log(LogLevel.error, message, tag);
    
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', tag);
    }
    
    if (stackTrace != null && kDebugMode) {
      _log(LogLevel.error, 'StackTrace: $stackTrace', tag);
    }
    
    // Production: send to crash reporting service
    if (EnvironmentConfig.isProduction && error != null) {
      _recordToCrashlytics(error, stackTrace, message);
    }
  }
  
  /// Internal logging implementation
  static void _log(LogLevel level, String message, [String? tag]) {
    // Skip debug logs in production
    if (EnvironmentConfig.isProduction && level == LogLevel.debug) {
      return;
    }
    
    // Only log in debug mode to prevent leaking info in release builds
    if (!kDebugMode && level != LogLevel.error) {
      return;
    }
    
    final prefix = _getPrefix(level);
    final tagStr = tag ?? _defaultTag;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    
    // Use debugPrint for proper truncation of long messages
    debugPrint('$prefix [$timestamp][$tagStr] $message');
  }
  
  /// Get emoji prefix for log level
  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }
  
  /// Record error to crash reporting service (Firebase Crashlytics)
  /// TODO: Uncomment when firebase_crashlytics is added
  static void _recordToCrashlytics(
    Object error,
    StackTrace? stackTrace,
    String message,
  ) {
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: message,
    // );
  }
  
  /// Set user identifier for crash reports
  static void setUserId(String userId) {
    if (kDebugMode) {
      debug('User ID set: $userId', 'Logger');
    }
    // FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }
  
  /// Log a custom key-value for crash reports
  static void setCustomKey(String key, dynamic value) {
    if (kDebugMode) {
      debug('Custom key: $key = $value', 'Logger');
    }
    // FirebaseCrashlytics.instance.setCustomKey(key, value);
  }
}
