import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import '../constants/environment_config.dart';
import '../../routes/app_pages.dart';

class DioClient {
  static const String skipAuthRefreshKey = 'skip_auth_refresh';
  static const String retryAttemptedKey = 'token_retry_attempted';
  static const String fallbackRetryKey = 'fallback_retry_attempted';

  late Dio _dio;
  
  DioClient() {
    _dio = Dio();
    _setupDio();
  }
  
  void _setupDio() {
    // Base options
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    
    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(_dio),
    ]);
  }
  
  Dio get dio => _dio;
}

// Auth interceptor to add auth headers
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[DioClient.skipAuthRefreshKey] == true) {
      handler.next(options);
      return;
    }

    try {
      final authService = getx.Get.find<AuthService>();
      final authHeaders = authService.getAuthHeaders();
      
      // Add auth headers to request
      options.headers.addAll(authHeaders);
    } catch (e) {
      // AuthService not available, continue without auth
      print('AuthService not available: $e');
    }
    
    handler.next(options);
  }
}

// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Error: ${err.message}');
    handler.next(err);
  }
}

// Error handling interceptor
class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final shouldSkipRefresh =
        requestOptions.extra[DioClient.skipAuthRefreshKey] == true;
    final hasRetried =
        requestOptions.extra[DioClient.retryAttemptedKey] == true;
    final hasFallbackRetried =
        requestOptions.extra[DioClient.fallbackRetryKey] == true;

    // Check if we should attempt fallback to local URL
    if (!hasFallbackRetried && _shouldAttemptFallback(err)) {
      final fallbackResponse = await _attemptFallbackRequest(requestOptions, err);
      if (fallbackResponse != null) {
        handler.resolve(fallbackResponse);
        return;
      }
    }

    // Skip refresh logic for login/register requests or already retried requests
    if (shouldSkipRefresh || hasRetried) {
      _logError(err);
      handler.next(err);
      return;
    }

    // Only attempt refresh for 401 errors (not 403)
    if (err.response?.statusCode == 401) {
      final authService = _tryGetAuthService();
      if (authService != null && authService.hasValidRefreshToken) {
        print('🔄 Token expired, attempting refresh...');
        final refreshed = await authService.refreshToken();
        
        if (refreshed && authService.token != null) {
          print('✅ Token refreshed, retrying request...');
          requestOptions.extra[DioClient.retryAttemptedKey] = true;
          requestOptions.headers['Authorization'] =
              'Bearer ${authService.token}';
          try {
            final response = await _dio.fetch(requestOptions);
            handler.resolve(response);
            return;
          } on DioException catch (retryError) {
            print('❌ Retry failed after refresh');
            handler.next(retryError);
            return;
          }
        } else {
          print('❌ Token refresh failed, logging out user');
          await authService.logout();
          getx.Get.offAllNamed(AppPages.LOGIN);
        }
      } else if (authService != null) {
        print('⚠️ No valid refresh token, logging out user');
        await authService.logout();
        getx.Get.offAllNamed(AppPages.LOGIN);
      }
    }

    _logError(err);
    handler.next(err);
  }

  void _logError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('Timeout error: ${err.message}');
        break;
      case DioExceptionType.badResponse:
        print('Bad response: ${err.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('Request cancelled');
        break;
      default:
        print('Network error: ${err.message}');
    }
  }

  AuthService? _tryGetAuthService() {
    if (getx.Get.isRegistered<AuthService>()) {
      return getx.Get.find<AuthService>();
    }
    return null;
  }

  bool _shouldAttemptFallback(DioException err) {
    if (!EnvironmentConfig.canUseFallback) {
      return false;
    }

    final statusCode = err.response?.statusCode;
    
    // Server errors (500-599)
    if (statusCode != null && statusCode >= 500 && statusCode < 600) {
      return true;
    }

    // Connection/timeout errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return true;
    }

    return false;
  }

  Future<Response?> _attemptFallbackRequest(
      RequestOptions requestOptions, DioException originalError) async {
    try {
      print('⚠️ Server error detected, attempting fallback to local URL...');
      
      // Enable fallback mode
      EnvironmentConfig.enableFallback();
      
      // Update the base URL to local
      final localBaseUrl = EnvironmentConfig.fullApiUrl;
      
      // Clone request options with new base URL
      final fallbackOptions = requestOptions.copyWith(
        baseUrl: localBaseUrl,
      );
      
      // Mark as fallback retry attempted
      fallbackOptions.extra[DioClient.fallbackRetryKey] = true;
      
      print('🔄 Retrying request with local URL: $localBaseUrl${fallbackOptions.path}');
      
      // Attempt the request with local URL
      final response = await _dio.fetch(fallbackOptions);
      
      print('✅ Fallback request successful!');
      return response;
      
    } on DioException catch (e) {
      print('❌ Fallback request failed: ${e.message}');
      // Disable fallback if it didn't work
      EnvironmentConfig.disableFallback();
      return null;
    } catch (e) {
      print('❌ Unexpected error during fallback: $e');
      EnvironmentConfig.disableFallback();
      return null;
    }
  }
}
