import 'package:dio/dio.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/leaderboard_model.dart';
import '../../../data/models/reward_model.dart';

abstract class AchievementRemoteDataSource {
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard();
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard();
  Future<List<UserAchievement>> getUserAchievements({int? userId});
  Future<List<UserAchievement>> getUserChallenges();
  Future<PaginatedUserRewards> getUserRewards(int userId,
      {int page = 1, int perPage = 10});
  Future<PaginatedAchievements> getAchievements(int userId,
      {int page = 1, int perPage = 10});
  Future<PaginatedChallenges> getChallenges(int userId,
      {int page = 1, int perPage = 10});
  Future<List<UserReward>> getAvailableRewards();
  Future<List<UserAchievement>> getClaimableChallenges();
  Future<ClaimChallengeResponse> claimChallenge(int challengeId);
  Future<List<UserAchievement>> getClaimHistory({int page = 1, int perPage = 20});
  Future<UserReward> redeemReward(int rewardId);
  Future<Map<String, dynamic>> useReward(int userRewardId);
}

class AchievementRemoteDataSourceImpl implements AchievementRemoteDataSource {
  final DioClient dioClient;
  AchievementRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.leaderboardWeekly);
      final rawList = extractApiResponseListData<LeaderboardEntry>(
        resp,
        (json) => LeaderboardEntry.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get weekly leaderboard: $e', 500);
    }
  }

  @override
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.leaderboardMonthly);
      final rawList = extractApiResponseListData<LeaderboardEntry>(
        resp,
        (json) => LeaderboardEntry.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get leaderboard: $e', 500);
    }
  }

  @override
  Future<List<UserAchievement>> getUserAchievements({int? userId}) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.userAchievementsProgress,
        queryParameters: userId != null ? {'user_id': userId} : null,
      );
      Logger.debug(
          'Response data: ${resp.data}', 'AchievementRemoteDataSource');
      final rawList = extractApiResponseListData<UserAchievement>(
        resp,
        (json) {
          // Ensure icon_url is set (backend may use image_url field name)
          final mapped = <String, dynamic>{
            ...json,
            'icon_url': json['icon_url'] ?? json['image_url'],
          };
          return UserAchievement.fromJson(mapped);
        },
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user achievements: $e', 500);
    }
  }

  @override
  Future<List<UserAchievement>> getUserChallenges() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.userChallengesProgress);
      final rawList = extractApiResponseListData<UserAchievement>(
        resp,
        (json) => UserAchievement.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user challenges: $e', 500);
    }
  }

  @override
  Future<PaginatedUserRewards> getUserRewards(int userId,
      {int page = 1, int perPage = 10}) async {
    try {
      final endpoint =
          ApiEndpoints.userRewards.replaceAll('{id}', userId.toString());
      final resp = await dioClient.dio.get(
        endpoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      return PaginatedUserRewards.fromJson(raw);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user rewards: $e', 500);
    }
  }

  @override
  Future<PaginatedAchievements> getAchievements(int userId,
      {int page = 1, int perPage = 10}) async {
    try {
      final endpoint =
          ApiEndpoints.userAchievements.replaceAll('{id}', userId.toString());
      final resp = await dioClient.dio.get(
        endpoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      return PaginatedAchievements.fromJson(raw);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user achievements: $e', 500);
    }
  }

  @override
  Future<PaginatedChallenges> getChallenges(int userId,
      {int page = 1, int perPage = 10}) async {
    try {
      final endpoint =
          ApiEndpoints.userChallenges.replaceAll('{id}', userId.toString());
      final resp = await dioClient.dio.get(
        endpoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      return PaginatedChallenges.fromJson(raw);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get user challenges: $e', 500);
    }
  }

  @override
  Future<List<UserReward>> getAvailableRewards() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.gamificationRewards);
      final rawList = extractApiResponseListData<UserReward>(
        resp,
        (json) => UserReward.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get available rewards: $e', 500);
    }
  }

  @override
  Future<List<UserAchievement>> getClaimableChallenges() async {
    try {
      final resp = await dioClient.dio.get(ApiEndpoints.claimableChallenges);
      final rawList = extractApiResponseListData<UserAchievement>(
        resp,
        (json) => UserAchievement.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get claimable challenges: $e', 500);
    }
  }

  @override
  Future<ClaimChallengeResponse> claimChallenge(int challengeId) async {
    try {
      final endpoint = ApiEndpoints.claimChallenge
          .replaceAll('{challenge_id}', challengeId.toString());
      final resp = await dioClient.dio.post(endpoint);
      return extractApiResponseData<ClaimChallengeResponse>(
        resp,
        (json) => ClaimChallengeResponse.fromJson(
            json as Map<String, dynamic>),
      );
    } on ApiResponseException catch (e) {
      if (e.statusCode == 409) {
        throw ConflictException(e.message);
      }
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        throw ConflictException(
          data is Map ? (data['message'] ?? 'Already claimed') : 'Already claimed',
        );
      }
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to claim challenge: $e', 500);
    }
  }

  @override
  Future<List<UserAchievement>> getClaimHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.challengeClaimHistory,
        queryParameters: {'page': page, 'limit': perPage},
      );
      final rawList = extractApiResponseListData<UserAchievement>(
        resp,
        (json) => UserAchievement.fromJson(json),
      );
      return rawList;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get claim history: $e', 500);
    }
  }

  @override
  Future<UserReward> redeemReward(int rewardId) async {
    try {
      final url = ApiEndpoints.redeemReward.replaceAll('{id}', rewardId.toString());
      final resp = await dioClient.dio.post(url);
      final data = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (d) => d as Map<String, dynamic>,
      );
      // The response contains reward, user_reward, user_stats
      // We return the user_reward as UserReward
      return UserReward.fromJson(data['user_reward'] as Map<String, dynamic>);
    } on ApiResponseException catch (e) {
      if (e.statusCode == 409) {
        throw ConflictException(e.message);
      }
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 500;
      if (code == 409) {
        throw ConflictException('Stok hadiah habis');
      }
      throw _handleDioException(e);
    } catch (e) {
      if (e is ConflictException) rethrow;
      throw ServerException('Failed to redeem reward: $e', 500);
    }
  }

  @override
  Future<Map<String, dynamic>> useReward(int userRewardId) async {
    try {
      final url = ApiEndpoints.useReward.replaceAll('{id}', userRewardId.toString());
      final resp = await dioClient.dio.post(url);
      final data = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (d) => d as Map<String, dynamic>,
      );
      return data;
    } on ApiResponseException catch (e) {
      if (e.statusCode == 409) {
        throw ConflictException(e.message);
      }
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 500;
      if (code == 409) {
        throw ConflictException('Kupon sudah dipakai');
      }
      throw _handleDioException(e);
    } catch (e) {
      if (e is ConflictException) rethrow;
      throw ServerException('Failed to use reward: $e', 500);
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
