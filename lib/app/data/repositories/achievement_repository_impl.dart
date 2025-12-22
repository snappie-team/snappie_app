import '../../core/network/network_info.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/achievement_remote_datasource.dart';
import '../models/achievement_model.dart';
import '../models/leaderboard_model.dart';
import '../models/reward_model.dart';

abstract class AchievementRepository {
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard();
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard();
  Future<List<UserAchievement>> getUserAchievements();
  Future<List<UserAchievement>> getUserChallenges();
  Future<PaginatedUserRewards> getUserRewards(int userId, {int page, int perPage});
  Future<PaginatedAchievements> getAchievements(int userId, {int page, int perPage});
  Future<PaginatedChallenges> getChallenges(int userId, {int page, int perPage});
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
  Future<List<UserAchievement>> getUserAchievements() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserAchievements();
  }

  @override
  Future<List<UserAchievement>> getUserChallenges() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserChallenges();
  }

  @override
  Future<PaginatedUserRewards> getUserRewards(int userId, {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getUserRewards(userId, page: page, perPage: perPage);
  }

  @override
  Future<PaginatedAchievements> getAchievements(int userId, {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getAchievements(userId, page: page, perPage: perPage);
  }

  @override
  Future<PaginatedChallenges> getChallenges(int userId, {int page = 1, int perPage = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getChallenges(userId, page: page, perPage: perPage);
  }
}
