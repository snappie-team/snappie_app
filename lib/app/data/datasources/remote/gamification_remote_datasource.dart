import 'package:dio/dio.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/helpers/api_response_helper.dart';
import '../../../routes/api_endpoints.dart';
import '../../models/gamification_model.dart';

abstract class GamificationRemoteDataSource {
  Future<List<ExpTransaction>> getExpTransactions({String? period});
  Future<List<CoinTransaction>> getCoinTransactions({String? period});
  Future<PlaceGamificationStatus> getPlaceStatus({required int placeId});
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final DioClient dioClient;
  GamificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ExpTransaction>> getExpTransactions({String? period}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }
      
      final resp = await dioClient.dio.get(
        ApiEndpoints.expTransactions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      return extractApiResponseListData<ExpTransaction>(
        resp,
        (json) => ExpTransaction.fromJson(json),
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get exp transactions: $e', 500);
    }
  }

  @override
  Future<List<CoinTransaction>> getCoinTransactions({String? period}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (period != null) {
        queryParams['period'] = period;
      }
      
      final resp = await dioClient.dio.get(
        ApiEndpoints.coinTransactions,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      // Response structure: { data: { transactions: [...], pagination: {...} } }
      final raw = extractApiResponseData<Map<String, dynamic>>(
        resp,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      
      final transactionsList = raw['transactions'] as List<dynamic>? ?? [];
      return transactionsList
          .map((json) => CoinTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get coin transactions: $e', 500);
    }
  }

  @override
  Future<PlaceGamificationStatus> getPlaceStatus({required int placeId}) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.gamificationPlaceStatus,
        queryParameters: {'place_id': placeId},
      );

      return extractApiResponseData<PlaceGamificationStatus>(
        resp,
        (json) => PlaceGamificationStatus.fromJson(
          json as Map<String, dynamic>,
        ),
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get place status: $e', 500);
    }
  }

  ServerException _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      return ServerException('Unauthorized', 401);
    }
    if (e.response?.statusCode == 404) {
      return ServerException('Not found', 404);
    }
    final message = e.response?.data?['message'] ?? 'Network error';
    return ServerException(message, e.response?.statusCode ?? 500);
  }
}
