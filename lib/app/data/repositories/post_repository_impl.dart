import '../../core/network/network_info.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/post_remote_datasource.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

/// Post Repository - No domain layer, direct Model return
/// Throws exceptions instead of returning Either<Failure, T>
class PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PostRepository({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Get all posts
  /// Throws: [NetworkException], [ServerException]
  Future<List<PostModel>> getPosts({
    int page = 1,
    bool trending = false,
    bool following = false,
  }) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    final posts = await remoteDataSource.getPosts(
      page: page,
      trending: trending,
      following: following,
    );
    return posts;
  }

  /// Get post by ID
  /// Throws: [NetworkException], [ServerException]
  Future<PostModel> getPostById(int id) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    final post = await remoteDataSource.getPostById(id);
    return post;
  }

  /// Get posts by place ID
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException]
  Future<List<PostModel>> getPostsByPlaceId(int placeId,
      {int page = 1, int perPage = 20}) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.getPostsByPlaceId(placeId,
        page: page, perPage: perPage);
  }

  /// Get posts by user ID
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException]
  Future<List<PostModel>> getPostsByUserId(int userId,
      {int page = 1, int perPage = 20}) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.getPostsByUserId(userId,
        page: page, perPage: perPage);
  }

  /// Toggle like on a post
  /// Returns true if post is now liked, false if unliked
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException]
  Future<bool> toggleLikePost(int postId) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.toggleLikePost(postId);
  }

  /// Create a comment on a post
  /// Returns the created CommentModel
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException]
  Future<CommentModel> createComment(int postId, String comment) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.createComment(postId, comment);
  }

  /// Create a new post
  /// Returns the created PostModel
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException], [ValidationException]
  Future<PostModel> createPost({
    required int placeId,
    required String content,
    List<String>? imageUrls,
    List<String>? hashtags,
    String? locationDetails,
  }) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.createPost(
      placeId: placeId,
      content: content,
      imageUrls: imageUrls,
      hashtags: hashtags,
      locationDetails: locationDetails,
    );
  }

  /// Delete a post
  /// Throws: [NetworkException], [ServerException], [AuthenticationException], [AuthorizationException]
  Future<void> deletePost(int postId) async {
    if (!(await networkInfo.isConnected)) {
      throw NetworkException('No internet connection');
    }

    await remoteDataSource.deletePost(postId);
  }
}
