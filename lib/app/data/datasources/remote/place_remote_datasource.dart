import 'package:dio/dio.dart';
import 'package:snappie_app/app/core/helpers/json_mapping_helper.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import '../../models/place_model.dart';

abstract class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getPlaces({
    List<String>? foodTypes,
    List<String>? placeValues,
    int? perPage,
    int? page,
    String? search,
    double? minRating,
    double? latitude,
    double? longitude,
    double? radius,
    bool? popular,
    bool? partner,
    bool? activeOnly,
  });

  Future<PlaceModel> getPlaceById(int id);
}

class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final DioClient dioClient;

  PlaceRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<PlaceModel>> getPlaces({
    List<String>? foodTypes,
    List<String>? placeValues,
    int? perPage = 20,
    int? page = 1,
    String? search,
    double? minRating,
    double? latitude,
    double? longitude,
    double? radius,
    bool? popular,
    bool? partner,
    bool? activeOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
        'page': page,
      };
      if (foodTypes != null && foodTypes.isNotEmpty) {
        queryParams['food_type'] = foodTypes;
      }
      if (placeValues != null && placeValues.isNotEmpty) {
        queryParams['place_value'] = placeValues;
      }
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (minRating != null) queryParams['min_rating'] = minRating;
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;
        // if (radius != null) queryParams['radius'] = radius;
      }
      if (popular != null) queryParams['popular'] = popular;
      if (partner != null) queryParams['partner'] = partner;
      if (activeOnly != null) queryParams['active_only'] = activeOnly;

      final response = await dioClient.dio.get(
        ApiEndpoints.places,
        queryParameters: queryParams,
      );

      return extractApiResponseListData<PlaceModel>(
        response,
        (json) {
          final raw = Map<String, dynamic>.from(json as Map<String, dynamic>);
          final placeJson =
              flattenAdditionalInfoForPlace(raw, removeContainer: false);
          return PlaceModel.fromJson(placeJson);
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<PlaceModel> getPlaceById(int id) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.replaceId(ApiEndpoints.placeDetail, '$id'),
      );

      final raw = extractApiResponseData<Map<String, dynamic>>(
        response,
        (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      );
      final placeJson =
          flattenAdditionalInfoForPlace(raw, removeContainer: false);
      return PlaceModel.fromJson(placeJson);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('Place not found', 404);
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
    }
  }
}
