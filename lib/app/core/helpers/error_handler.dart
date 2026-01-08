import '../services/logger_service.dart';
import '../errors/exceptions.dart';

/// Error Handler Utility
/// 
/// Centralized error handling untuk sanitize error messages
/// sebelum ditampilkan ke user. Technical errors di-log untuk debugging.
/// 
/// Usage:
/// ```dart
/// } catch (e) {
///   errorMessage.value = ErrorHandler.getReadableMessage(e);
/// }
/// ```
class ErrorHandler {
  // Generic user-friendly messages
  static const String _defaultErrorMessage = 'Terjadi kesalahan, silakan coba lagi';
  static const String _networkErrorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda';
  static const String _serverErrorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi';
  static const String _authErrorMessage = 'Sesi Anda telah berakhir. Silakan login kembali';
  static const String _validationErrorMessage = 'Data yang dimasukkan tidak valid';
  static const String _cameraErrorMessage = 'Gagal mengakses kamera. Pastikan izin kamera diberikan';
  static const String _locationErrorMessage = 'Gagal mendapatkan lokasi. Pastikan GPS aktif';
  static const String _uploadErrorMessage = 'Gagal mengunggah file. Silakan coba lagi';
  
  /// Get user-friendly error message from any exception
  /// 
  /// Logs the technical error for debugging and returns
  /// a sanitized message safe to display to users.
  static String getReadableMessage(
    dynamic error, {
    String? tag,
    String? fallbackMessage,
  }) {
    // Log technical error for debugging
    Logger.error(
      'Technical error occurred',
      error,
      error is Error ? error.stackTrace : null,
      tag ?? 'ErrorHandler',
    );
    
    // Return appropriate user-friendly message
    return _mapErrorToMessage(error, fallbackMessage);
  }
  
  /// Map exception type to user-friendly message
  static String _mapErrorToMessage(dynamic error, String? fallbackMessage) {
    // Handle typed exceptions from our app
    if (error is NetworkException) {
      return _networkErrorMessage;
    }
    
    if (error is ServerException) {
      // For server errors, we can show the message if it's user-friendly
      // Otherwise use generic message
      if (_isUserFriendlyMessage(error.message)) {
        return error.message;
      }
      return _serverErrorMessage;
    }
    
    if (error is AuthenticationException) {
      return _authErrorMessage;
    }
    
    if (error is ValidationException) {
      // Validation messages are usually user-friendly
      if (_isUserFriendlyMessage(error.message)) {
        return error.message;
      }
      return _validationErrorMessage;
    }
    
    // Handle common error string patterns
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('camera') || 
        errorString.contains('kamera')) {
      return _cameraErrorMessage;
    }
    
    if (errorString.contains('location') || 
        errorString.contains('gps') ||
        errorString.contains('lokasi')) {
      return _locationErrorMessage;
    }
    
    if (errorString.contains('upload') || 
        errorString.contains('unggah')) {
      return _uploadErrorMessage;
    }
    
    if (errorString.contains('network') || 
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('internet')) {
      return _networkErrorMessage;
    }
    
    // Return fallback or default message
    return fallbackMessage ?? _defaultErrorMessage;
  }
  
  /// Check if the message is safe to show to users
  /// 
  /// User-friendly messages should:
  /// - Not contain technical terms like "Exception", "Error", "null"
  /// - Not contain stack traces or file paths
  /// - Be in Indonesian or simple English
  static bool _isUserFriendlyMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // List of technical patterns that shouldn't be shown to users
    const technicalPatterns = [
      'exception',
      'error:',
      'null',
      'stacktrace',
      'stack trace',
      '.dart',
      'line ',
      'column ',
      'unexpected',
      'failed to',
      'cannot ',
      'unable to',
      'invalid ',
      'type \'',
      'nosuchmethoderror',
      'rangeerror',
      'typeerror',
      'assertion',
      'unhandled',
    ];
    
    for (final pattern in technicalPatterns) {
      if (lowerMessage.contains(pattern)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Convenience method for snackbar errors
  /// Returns a tuple of (title, message) for snackbars
  static ({String title, String message}) getSnackbarContent(
    dynamic error, {
    String? tag,
    String defaultTitle = 'Terjadi Kesalahan',
  }) {
    final message = getReadableMessage(error, tag: tag);
    return (title: defaultTitle, message: message);
  }
}
