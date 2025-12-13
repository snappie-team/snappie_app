import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/utils/api_response.dart';
import '../../../core/helpers/api_response_helper.dart';
import '../../../core/helpers/json_mapping_helper.dart';
import '../../../data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> getUserById(int id);
  Future<UserSaved> getUserSaved();
  Future<List<int>> toggleSavedPlace(List<int> placeIds);
  Future<List<int>> toggleSavedPost(List<int> postIds);
  Future<UserSearchResult> searchUsers(String query,
      {int page = 1, int perPage = 10});
  Future<UserModel> updateUserProfile({
    String? username,
    String? email,
    String? name,
    String? gender,
    String? imageUrl,
    List<String>? foodTypes,
    List<String>? placeValues,
    String? phone,
    DateTime? dateOfBirth,
    String? bio,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
    Map<String, dynamic>? userSettings, // {language, theme}
    Map<String, dynamic>? userNotification, // {push_notification}
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient dioClient;
  UserRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.profile);
      // Helper kita langsung mengembalikan bagian "data" → Map<String,dynamic>
      // Response structure: { data: { user: {...}, stats: {...}, ... } }
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      // Extract user object from data.user
      final userData = raw['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw ServerException('User data not found in response', 500);
      }
      final userJson =
          flattenAdditionalInfoForUser(userData, removeContainer: false);
      return UserModel.fromJson(userJson);
    } on ApiResponseException catch (e) {
      if (e.errors != null)
        throw ValidationException(e.message, errors: e.errors);
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get profile: $e', 500);
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.userById.replaceFirst('{id}', id.toString()),
      );
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      // Response structure: { data: { user: {...}, ... } } or { data: {...user fields...} }
      // Check if user is nested or flat
      final userData =
          raw.containsKey('user') ? raw['user'] as Map<String, dynamic> : raw;
      final userJson =
          flattenAdditionalInfoForUser(userData, removeContainer: false);
      return UserModel.fromJson(userJson);
    } on ApiResponseException catch (e) {
      if (e.errors != null)
        throw ValidationException(e.message, errors: e.errors);
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user by ID: $e', 500);
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? username,
    String? email,
    String? name,
    String? gender,
    String? imageUrl,
    List<String>? foodTypes,
    List<String>? placeValues,
    String? phone,
    DateTime? dateOfBirth,
    String? bio,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
    Map<String, dynamic>? userSettings,
    Map<String, dynamic>? userNotification,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (username != null) payload['username'] = username;
      if (email != null) payload['email'] = email;
      if (name != null) payload['name'] = name;
      if (gender != null) payload['gender'] = gender;
      if (imageUrl != null) payload['image_url'] = imageUrl;
      if (phone != null) payload['phone'] = phone;
      if (dateOfBirth != null) {
        payload['date_of_birth'] = dateOfBirth.toIso8601String();
      }
      if (bio != null) payload['bio'] = bio;
      if (privacySettings != null) {
        payload['privacy_settings'] = privacySettings;
      }
      if (notificationPreferences != null) {
        payload['notification_preferences'] = notificationPreferences;
      }

      final additional = <String, dynamic>{};

      final prefs = <String, dynamic>{};
      if (foodTypes != null) prefs['food_type'] = foodTypes;
      if (placeValues != null) prefs['place_value'] = placeValues;
      if (prefs.isNotEmpty) additional['user_preferences'] = prefs;

      if (userSettings != null && userSettings.isNotEmpty) {
        additional['user_settings'] = userSettings;
      }
      if (userNotification != null && userNotification.isNotEmpty) {
        additional['user_notification'] = userNotification;
      }

      if (additional.isNotEmpty) payload['additional_info'] = additional;

      final resp = await dioClient.dio.post(
        ApiEndpoints.updateProfile,
        data: payload,
      );

      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      // Response structure: { data: { user: {...}, ... } } or { data: {...user fields...} }
      // Check if user is nested or flat
      final userData =
          raw.containsKey('user') ? raw['user'] as Map<String, dynamic> : raw;
      final userJson =
          flattenAdditionalInfoForUser(userData, removeContainer: false);
      return UserModel.fromJson(userJson);
    } on ApiResponseException catch (e) {
      if (e.errors != null) {
        throw ValidationException(e.message, errors: e.errors);
      }
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to update profile: $e', 500);
    }
  }

  @override
  Future<UserSaved> getUserSaved() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.userSaved);
      print('⭐ getUserSaved response: $resp');
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      return UserSaved.fromJson(raw);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user saved: $e', 500);
    }
  }

  @override
  Future<List<int>> toggleSavedPlace(List<int> placeIds) async {
    try {
      final resp = await dioClient.dio.post(
        ApiEndpoints.userSaved,
        data: {'saved_places': placeIds},
      );
      print('⭐ toggleSavedPlace response: $resp');
      // Response returns list of saved place IDs
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      final savedPlaces = raw['saved_places'] as List<dynamic>?;
      return savedPlaces?.map((e) => e as int).toList() ?? [];
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to toggle saved place: $e', 500);
    }
  }

  @override
  Future<List<int>> toggleSavedPost(List<int> postIds) async {
    try {
      final resp = await dioClient.dio.post(
        ApiEndpoints.userSaved,
        data: {'saved_posts': postIds},
      );
      print('⭐ toggleSavedPost response: $resp');
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );

      final savedPosts = raw['saved_posts'];
      if (savedPosts is List) {
        // Backend usually returns list of IDs; tolerate list of objects.
        return savedPosts
            .map((e) {
              if (e is int) return e;
              if (e is num) return e.toInt();
              if (e is Map && e['id'] is num) return (e['id'] as num).toInt();
              return null;
            })
            .whereType<int>()
            .toList();
      }

      return [];
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to toggle saved post: $e', 500);
    }
  }

  @override
  Future<UserSearchResult> searchUsers(String query,
      {int page = 1, int perPage = 10}) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.usersSearch,
        queryParameters: {
          'q': query,
          'page': page,
          'per_page': perPage,
        },
      );
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      return UserSearchResult.fromJson(raw);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to search users: $e', 500);
    }
  }

  Exception _handleDioException(DioException e) {
    final code = e.response?.statusCode ?? 500;
    if (code == 401) return AuthenticationException('Authentication failed');
    if (code == 403) return AuthorizationException('Access denied');
    if (code == 422) {
      return ValidationException(
        'Validation failed',
        errors: e.response?.data is Map ? e.response?.data['errors'] : null,
      );
    }
    return ServerException(
      (e.response?.data is Map && e.response?.data['message'] != null)
          ? e.response?.data['message']
          : 'Server error',
      code,
    );
  }
}
