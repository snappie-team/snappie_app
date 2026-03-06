import '../../core/network/network_info.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/achievement_remote_datasource.dart';
import '../models/achievement_model.dart';
import '../models/leaderboard_model.dart';
import '../models/reward_model.dart';

abstract class AchievementRepository {
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard();
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard();
  Future<List<UserAchievement>> getUserAchievements({int? userId});
  Future<List<UserAchievement>> getUserChallenges();
  Future<PaginatedUserRewards> getUserRewards(int userId,
      {int page, int perPage});
  Future<PaginatedAchievements> getAchievements(int userId,
      {int page, int perPage});
  Future<PaginatedChallenges> getChallenges(int userId,
      {int page, int perPage});
  Future<List<UserReward>> getAvailableRewards();
  Future<List<UserAchievement>> getClaimableChallenges();
  Future<ClaimChallengeResponse> claimChallenge(int challengeId);
  Future<List<UserAchievement>> getClaimHistory({int page, int perPage});
  Future<UserReward> redeemReward(int rewardId);
  Future<Map<String, dynamic>> useReward(int userRewardId);
}

class AchievementRepositoryImpl implements AchievementRepository {
  final AchievementRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AchievementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getWeeklyLeaderboard();
  }

  @override
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getMonthlyLeaderboard();
  }

  @override
  Future<List<UserAchievement>> getUserAchievements({int? userId}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserAchievements(userId: userId);
  }

  @override
  Future<List<UserAchievement>> getUserChallenges() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserChallenges();
  }

  @override
  Future<PaginatedUserRewards> getUserRewards(int userId,
      {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserRewards(userId,
        page: page, perPage: perPage);
  }

  @override
  Future<PaginatedAchievements> getAchievements(int userId,
      {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getAchievements(userId,
        page: page, perPage: perPage);
  }

  @override
  Future<PaginatedChallenges> getChallenges(int userId,
      {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getChallenges(userId,
        page: page, perPage: perPage);
  }

  @override
  Future<List<UserReward>> getAvailableRewards() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getAvailableRewards();
  }

  @override
  Future<List<UserAchievement>> getClaimableChallenges() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getClaimableChallenges();
  }

  @override
  Future<ClaimChallengeResponse> claimChallenge(int challengeId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.claimChallenge(challengeId);
  }

  @override
  Future<List<UserAchievement>> getClaimHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getClaimHistory(page: page, perPage: perPage);
  }

  @override
  Future<UserReward> redeemReward(int rewardId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.redeemReward(rewardId);
  }

  @override
  Future<Map<String, dynamic>> useReward(int userRewardId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.useReward(userRewardId);
  }
}
