import 'package:get/get.dart';
import 'package:snappie_app/app/core/services/google_auth_service.dart';

enum AuthErrorType {
  network,
  userNotFound,
  hasActiveSession,
  unknown,
}

class AuthResult {
  final bool success;
  final AuthErrorType? errorType;
  final String? message;
  final int? statusCode;
  final Object? cause;

  const AuthResult._({
    required this.success,
    this.errorType,
    this.message,
    this.statusCode,
    this.cause,
  });

  factory AuthResult.ok({String? message}) {
    return AuthResult._(
      success: true,
      message: message,
    );
  }

  factory AuthResult.fail(
    AuthErrorType errorType, {
    String? message,
    int? statusCode,
    Object? cause,
  }) {
    return AuthResult._(
      success: false,
      errorType: errorType,
      message: message,
      statusCode: statusCode,
      cause: cause,
    );
  }
}
