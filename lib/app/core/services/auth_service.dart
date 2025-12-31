import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:snappie_app/app/core/helpers/api_response_helper.dart';
import 'package:snappie_app/app/core/network/dio_client.dart';
import 'package:snappie_app/app/data/models/user_model.dart';
import 'package:snappie_app/app/data/datasources/local/user_local_datasource.dart';
import 'package:snappie_app/app/core/errors/auth_result.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import '../constants/app_constants.dart';
import '../constants/environment_config.dart';
import '../../routes/api_endpoints.dart';
import '../helpers/json_mapping_helper.dart';
import 'google_auth_service.dart';

class AuthService extends GetxService {
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expires_at';
  static const String _refreshTokenExpiryKey = 'refresh_token_expires_at';

  String? _token;
  String? _userEmail;
  UserModel? _userData;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  DateTime? _refreshTokenExpiry;
  Future<bool>? _refreshFuture;

  // Observable for login status
  final _isLoggedIn = false.obs;
  RxBool get isLoggedInObs => _isLoggedIn;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAuthData();
  }

  bool get isLoggedIn {
    final loggedIn = _token != null && _token!.isNotEmpty;
    _isLoggedIn.value = loggedIn;
    return loggedIn;
  }

  String? get token => _token;
  String? get userEmail => _userEmail;
  UserModel? get userData => _userData;
  bool get hasValidAccessToken {
    if (_token == null || _token!.isEmpty) {
      return false;
    }
    if (_tokenExpiry == null) {
      return true;
    }
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  bool get hasValidRefreshToken {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      return false;
    }
    if (_refreshTokenExpiry == null) {
      return true;
    }
    return DateTime.now().isBefore(_refreshTokenExpiry!);
  }

  Future<bool> refreshToken() async {
    if (!hasValidRefreshToken) {
      Logger.warning('Cannot refresh token: refresh token missing or expired', 'Auth');
      return false;
    }

    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final future = _performRefreshToken();
    _refreshFuture = future;

    try {
      return await future;
    } finally {
      if (identical(_refreshFuture, future)) {
        _refreshFuture = null;
      }
    }
  }

  Future<bool> _performRefreshToken() async {
    final dioClient = DioClient();
    final candidates = ApiEndpoints.refreshTokenCandidates;

    for (var i = 0; i < candidates.length; i++) {
      final endpoint = candidates[i];
      final isLast = i == candidates.length - 1;
      final requestUrl = ApiEndpoints.getFullUrl(endpoint);

      try {
        Logger.debug('Attempting refresh with token: ${_refreshToken?.substring(0, 10)}...', 'Auth');
        final response = await dioClient.dio.post(
          requestUrl,
          data: {'refresh_token': _refreshToken},
          options: dio_lib.Options(
            extra: {
              DioClient.skipAuthRefreshKey: true,
            },
            headers: getAuthHeaders(useRegistrationKey: true),
          ),
        );

        if (response.statusCode == 200) {
          final data = extractApiResponseData(
            response,
            (json) => Map<String, dynamic>.from(
              json as Map<String, dynamic>,
            ),
          );

          final token = data['token'] as String?;
          if (token == null || token.isEmpty) {
            return false;
          }

          final Map<String, dynamic>? userPayload = data['user'] == null
              ? null
              : Map<String, dynamic>.from(
                  data['user'] as Map<String, dynamic>,
                );

          await _saveAuthSession(
            token: token,
            userPayload: userPayload,
            refreshToken: (data['refresh_token'] as String?) ?? _refreshToken,
            tokenExpiry: _parseStoredDate(data['expires_at'] as String?),
            refreshTokenExpiry: _parseStoredDate(
              data['refresh_token_expires_at'] as String?,
            ),
          );

          _isLoggedIn.value = true;
          return true;
        }
      } on dio_lib.DioException catch (e) {
        if (e.response?.statusCode == 404 && !isLast) {
          Logger.warning('Refresh endpoint $requestUrl not found. Trying fallback...', 'Auth');
          continue;
        }
        _logRefreshError(e);
        return false;
      } catch (e) {
        _logRefreshError(e);
        return false;
      }
    }

    return false;
  }

  void _logRefreshError(Object error) {
    Logger.error('REFRESH TOKEN ERROR', error, null, 'Auth');
    if (error is dio_lib.DioException) {
      Logger.debug('DioError Type: ${error.type}', 'Auth');
      Logger.debug('DioError Message: ${error.message}', 'Auth');
      Logger.debug('DioError Response: ${error.response?.data}', 'Auth');
      Logger.debug('DioError Status: ${error.response?.statusCode}', 'Auth');
    }
  }

  Future<void> _loadAuthData() async {
    try {
      Logger.debug('LOADING AUTH DATA FROM STORAGE...', 'Auth');
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      _userEmail = prefs.getString(_userEmailKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      _tokenExpiry = _parseStoredDate(prefs.getString(_tokenExpiryKey));
      _refreshTokenExpiry =
          _parseStoredDate(prefs.getString(_refreshTokenExpiryKey));

      Logger.debug('Loaded refresh token: ${_refreshToken != null ? "${_refreshToken!.substring(0, 10)}..." : "null"}', 'Auth');
      Logger.debug('Token expiry: $_tokenExpiry', 'Auth');
      Logger.debug('Refresh token expiry: $_refreshTokenExpiry', 'Auth');
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null && userDataString.isNotEmpty) {
        // Parse user data from JSON string
        _userData = UserModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(userDataString)));
      }

      _isLoggedIn.value = _token != null && _token!.isNotEmpty;
    } catch (e) {
      Logger.error('Error loading auth data', e, null, 'Auth');
    }
  }

  // TODO: replace /auth/login email-only with Firebase-ID-token check before public release.
  Future<AuthResult> loginWithEmail(String email) async {
    /// Backend login with email only (without Google Sign In)
    Logger.info('Login with email: $email', 'Auth');
    try {
      final dioClient = DioClient();
      final requestUrl = ApiEndpoints.getFullUrl(ApiEndpoints.login);

      final response = await dioClient.dio.post(
        requestUrl,
        data: {'email': email},
        options: dio_lib.Options(
          headers: getAuthHeaders(useRegistrationKey: true),
          extra: {
            DioClient.skipAuthRefreshKey:
                true, // Skip refresh interceptor for login
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = extractApiResponseData(response,
            (json) => Map<String, dynamic>.from(json as Map<String, dynamic>));

        Logger.debug('LOGIN RESPONSE DATA KEYS: ${data.keys.toList()}', 'Auth');

        final Map<String, dynamic>? userData = data['user'] == null
            ? null
            : Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String?;
        final refreshTokenFromResponse = data['refresh_token'] as String?;

        if (token == null || token.isEmpty) {
          Logger.error('No token received from server', null, null, 'Auth');
          return AuthResult.fail(
            AuthErrorType.unknown,
            message: 'No token received from server',
            statusCode: response.statusCode,
          );
        }

        Logger.debug('Token received: ${token.substring(0, 10)}...', 'Auth');
        Logger.debug('Refresh token received: ${refreshTokenFromResponse != null ? "${refreshTokenFromResponse.substring(0, 10)}..." : "NULL"}', 'Auth');

        await _saveAuthSession(
          token: token,
          userPayload: userData,
          refreshToken: refreshTokenFromResponse,
          tokenExpiry: _parseStoredDate(data['expires_at'] as String?),
          refreshTokenExpiry:
              _parseStoredDate(data['refresh_token_expires_at'] as String?),
        );

        _isLoggedIn.value = true;
        return AuthResult.ok(message: 'Login successful');
      } else {
        Logger.error('Unexpected status code: ${response.statusCode}', null, null, 'Auth');
        return AuthResult.fail(
          AuthErrorType.unknown,
          message: 'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on dio_lib.DioException catch (e) {
      Logger.error('LOGIN DIO ERROR: ${e.response?.statusCode}', e, null, 'Auth');
      Logger.debug('DioError Response: ${e.response?.data}', 'Auth');

      final statusCode = e.response?.statusCode;

      // Sign out from Google if user is signed in with Google
      try {
        final googleAuthService = Get.find<GoogleAuthService>();
        if (googleAuthService.isLoggedIn) {
          await googleAuthService.signOut();
        }
      } catch (signOutError) {
        Logger.error('Error signing out from Google', signOutError, null, 'Auth');
      }

      // Status-code based auth failures
      // User tidak ditemukan / belum terdaftar
      if (statusCode == 404 || statusCode == 401) {
        return AuthResult.fail(
          AuthErrorType.userNotFound,
          message: 'User not found',
          statusCode: statusCode,
          cause: e,
        );
      }

      if (statusCode == 409) {
        Logger.warning('Conflict error during login', 'Auth');
        return AuthResult.fail(
          AuthErrorType.hasActiveSession,
          message: 'Has active session',
          statusCode: statusCode,
          cause: e,
        );
      }

      // Network-ish failures
      final isNetworkError = statusCode == null &&
          (e.type == dio_lib.DioExceptionType.connectionTimeout ||
              e.type == dio_lib.DioExceptionType.sendTimeout ||
              e.type == dio_lib.DioExceptionType.receiveTimeout ||
              e.type == dio_lib.DioExceptionType.connectionError);

      if (isNetworkError) {
        return AuthResult.fail(
          AuthErrorType.network,
          message: 'Network error',
          cause: e,
        );
      }

      return AuthResult.fail(
        AuthErrorType.unknown,
        message: 'Login failed',
        statusCode: statusCode,
        cause: e,
      );
    } catch (e) {
      Logger.error('LOGIN ERROR', e, null, 'Auth');
      return AuthResult.fail(
        AuthErrorType.unknown,
        message: 'Login failed',
        cause: e,
      );
    }
  }

  /// Complete login flow: Google Sign In + Backend Login
  Future<AuthResult> login() async {
    /* ---------- Step 1: Google Sign-In ---------- */
    final googleAuthService = Get.find<GoogleAuthService>();
    final userCredential = await googleAuthService.signInWithGoogle();

    if (userCredential == null) {
      Logger.info('Google Sign In was cancelled', 'Auth');
      return AuthResult.fail(
        AuthErrorType.unknown,
        message: 'Google Sign In was cancelled',
      );
    }

    final user = userCredential.user;
    if (user == null || user.email == null) {
      Logger.error('No user data from Google Sign In', null, null, 'Auth');
      return AuthResult.fail(
        AuthErrorType.unknown,
        message: 'No user data from Google Sign In',
      );
    }

    /* ---------- Step 2: Backend Login ---------- */
    return await loginWithEmail(user.email!);
  }

  // TODO: replace /auth/login email-only with Firebase-ID-token check before public release.
  Future<bool> registerUser({
    required String name,
    required String username,
    required String email,
    required String gender,
    required String imageUrl,
    required List<String> foodTypes,
    required List<String> placeValues,
  }) async {
    
    /// Register new user with backend API
    try {
      final dio = dio_lib.Dio(
        dio_lib.BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      final requestUrl = ApiEndpoints.getFullUrl(ApiEndpoints.register);
      final requestData = {
        'name': name,
        'username': username,
        'email': email,
        'gender': gender,
        'image_url': imageUrl,
        'food_type': foodTypes,
        'place_value': placeValues,
      };

      final response = await dio
          .post(
        requestUrl,
        data: requestData,
        options: dio_lib.Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${EnvironmentConfig.registrationApiKey}',
          },
        ),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          Logger.error('REGISTER REQUEST TIMEOUT after 60 seconds', null, null, 'Auth');
          throw dio_lib.DioException(
            requestOptions: dio_lib.RequestOptions(path: requestUrl),
            type: dio_lib.DioExceptionType.connectionTimeout,
            message:
                'Connection timeout - Server membutuhkan waktu terlalu lama',
          );
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          // Use loginWithEmail to avoid triggering Google Sign In popup again
          final loginResult = await loginWithEmail(email);

          if (!loginResult.success) {
            return false;
          }

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      Logger.error('REGISTRATION ERROR', e, null, 'Auth');

      if (e is dio_lib.DioException) {
        Logger.debug('DioError Type: ${e.type}', 'Auth');
        Logger.debug('DioError Message: ${e.message}', 'Auth');
        Logger.debug('DioError Response: ${e.response?.data}', 'Auth');
        Logger.debug('DioError Status: ${e.response?.statusCode}', 'Auth');
      }

      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Call logout API if we have a token
      if (_token != null) {
        final dio = dio_lib.Dio();
        await dio.post(
          '${AppConstants.baseUrl}${AppConstants.apiVersion}/auth/logout',
          options: dio_lib.Options(
            headers: {
              'Authorization': 'Bearer $_token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );
      }

      // Sign out from Google if user is signed in with Google
      try {
        final googleAuthService = Get.find<GoogleAuthService>();
        if (googleAuthService.isLoggedIn) {
          await googleAuthService.signOut();
        }
      } catch (e) {
        Logger.error('Error signing out from Google', e, null, 'Auth');
      }
    } catch (e) {
      Logger.debug('Logout API error: $e', 'Auth');
    } finally {
      // Clear local data regardless of API call success
      _token = null;
      _userEmail = null;
      _userData = null;
      _refreshToken = null;
      _tokenExpiry = null;
      _refreshTokenExpiry = null;
      _refreshFuture = null;

      // Update observable
      _isLoggedIn.value = false;

      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userDataKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_refreshTokenExpiryKey);

      // Clear cached user data from local database
      try {
        final userLocalDataSource = Get.find<UserLocalDataSource>();
        await userLocalDataSource.clearCachedUser();
        await userLocalDataSource.clearAuthToken();
        Logger.info('Cleared local user cache', 'Auth');
      } catch (e) {
        Logger.error('Error clearing local cache', e, null, 'Auth');
      }
    }
  }

  // Get auth headers for API calls
  Map<String, String> getAuthHeaders({bool useRegistrationKey = false}) {
    if (!useRegistrationKey && _token != null && _token!.isNotEmpty) {
      return {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Authorization': 'Bearer ${EnvironmentConfig.registrationApiKey}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  DateTime? _parseStoredDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Future<void> _saveAuthSession({
    required String token,
    Map<String, dynamic>? userPayload,
    String? refreshToken,
    DateTime? tokenExpiry,
    DateTime? refreshTokenExpiry,
  }) async {
    _token = token;
    _refreshToken = refreshToken;
    _tokenExpiry = tokenExpiry;
    _refreshTokenExpiry = refreshTokenExpiry;

    if (userPayload != null) {
      final userJson =
          flattenAdditionalInfoForUser(userPayload, removeContainer: false);
      _userData = UserModel.fromJson(userJson);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    if (_userEmail != null && _userEmail!.isNotEmpty) {
      await prefs.setString(_userEmailKey, _userEmail!);
    }

    if (userPayload != null) {
      await prefs.setString(_userDataKey, jsonEncode(userPayload));
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
      Logger.debug('Saved refresh token: ${refreshToken.substring(0, 10)}...', 'Auth');
    } else {
      await prefs.remove(_refreshTokenKey);
      Logger.warning('No refresh token to save', 'Auth');
    }

    await _persistDateTime(prefs, _tokenExpiryKey, tokenExpiry);
    await _persistDateTime(prefs, _refreshTokenExpiryKey, refreshTokenExpiry);
  }

  Future<void> _persistDateTime(
      SharedPreferences prefs, String key, DateTime? value) async {
    if (value != null) {
      await prefs.setString(key, value.toIso8601String());
    } else {
      await prefs.remove(key);
    }
  }
}
