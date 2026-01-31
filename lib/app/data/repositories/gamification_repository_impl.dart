import '../../core/network/network_info.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/gamification_remote_datasource.dart';
import '../models/gamification_model.dart';

abstract class GamificationRepository {
  Future<List<ExpTransaction>> getExpTransactions({String? period});
  Future<List<CoinTransaction>> getCoinTransactions({String? period});
  Future<PlaceGamificationStatus> getPlaceStatus({required int placeId});
}

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GamificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<ExpTransaction>> getExpTransactions({String? period}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getExpTransactions(period: period);
  }

  @override
  Future<List<CoinTransaction>> getCoinTransactions({String? period}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getCoinTransactions(period: period);
  }

  @override
  Future<PlaceGamificationStatus> getPlaceStatus({required int placeId}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }
    return await remoteDataSource.getPlaceStatus(placeId: placeId);
  }
}
