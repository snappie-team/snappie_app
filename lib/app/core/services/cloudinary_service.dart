import 'dart:io';

import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_api/uploader/uploader.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'logger_service.dart';

/// Cloudinary folder structure
class CloudinaryFolder {
  static const String checkins = 'snappie/checkins';
  static const String missions = 'snappie/missions';
  static const String reviews = 'snappie/reviews';
  static const String profiles = 'snappie/profiles';
  static const String posts = 'snappie/posts';
}

/// Upload progress callback type
typedef UploadProgressCallback = void Function(int sent, int total);

/// Cloudinary upload result
class CloudinaryUploadResult {
  final String? publicId;
  final String? url;
  final String? secureUrl;
  final int? width;
  final int? height;
  final String? format;
  final int? bytes;
  final String? error;
  final bool success;

  CloudinaryUploadResult({
    this.publicId,
    this.url,
    this.secureUrl,
    this.width,
    this.height,
    this.format,
    this.bytes,
    this.error,
    this.success = false,
  });

  factory CloudinaryUploadResult.fromUploadResult(dynamic result) {
    return CloudinaryUploadResult(
      publicId: result.publicId,
      url: result.url,
      secureUrl: result.secureUrl,
      width: result.width,
      height: result.height,
      format: result.format,
      bytes: result.bytes,
      success: true,
    );
  }

  factory CloudinaryUploadResult.error(String message) {
    return CloudinaryUploadResult(
      error: message,
      success: false,
    );
  }
}

/// Cloudinary Service for image uploads
/// Uses the official cloudinary_api package for uploading
class CloudinaryService {
  late final Cloudinary _cloudinary;
  late final Uploader _uploader;
  late final String _uploadPreset;

  /// Initialize service with environment variables
  CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'uploads';

    if (cloudName.isEmpty) {
      throw Exception('CLOUDINARY_CLOUD_NAME is not set in .env file');
    }

    // Create Cloudinary instance from URL string
    final cloudinaryUrl = 'cloudinary://$apiKey:$apiSecret@$cloudName';
    _cloudinary = Cloudinary.fromStringUrl(cloudinaryUrl);
    _uploader = _cloudinary.uploader();

    Logger.debug('Initialized with cloud: $cloudName', 'CloudinaryService');
  }

  /// Upload an image file to Cloudinary
  ///
  /// [file] - The file to upload
  /// [folder] - The folder to upload to (use CloudinaryFolder constants)
  /// [progressCallback] - Optional callback for upload progress
  /// [quality] - Image quality (80-100, default 85)
  ///
  /// Returns [CloudinaryUploadResult] with the uploaded image details
  Future<CloudinaryUploadResult> uploadImage(
    File file, {
    String folder = CloudinaryFolder.checkins,
    UploadProgressCallback? progressCallback,
    int quality = 85,
  }) async {
    try {
      Logger.debug('Uploading image: ${file.path}', 'CloudinaryService');
      Logger.debug('Folder: $folder', 'CloudinaryService');
      Logger.debug('Quality: $quality', 'CloudinaryService');
      Logger.debug('Upload preset: $_uploadPreset', 'CloudinaryService');

      final response = await _uploader.upload(
        file,
        params: UploadParams(
          uploadPreset: _uploadPreset,
          folder: folder,
          resourceType: 'image',
        ),
        progressCallback: progressCallback != null
            ? (sent, total) => progressCallback(sent, total)
            : null,
      );

      if (response?.error != null) {
        Logger.error('Upload error: ${response?.error?.message}', null, null, 'CloudinaryService');
        return CloudinaryUploadResult.error(
          response?.error?.message ?? 'Unknown upload error',
        );
      }

      final result = response?.data;
      if (result == null) {
        return CloudinaryUploadResult.error('No upload result received');
      }

      // Generate optimized URL with quality transformation
      final optimizedUrl = _generateOptimizedUrl(result.secureUrl, quality);
      Logger.debug('Upload success: $optimizedUrl', 'CloudinaryService');

      // Update the result with optimized URL
      final optimizedResult = CloudinaryUploadResult(
        publicId: result.publicId,
        url: result.url,
        secureUrl: optimizedUrl,
        width: result.width,
        height: result.height,
        format: result.format,
        bytes: result.bytes,
        success: true,
      );

      return optimizedResult;
    } catch (e, stackTrace) {
      Logger.error('Upload exception', e, stackTrace, 'CloudinaryService');
      return CloudinaryUploadResult.error(e.toString());
    }
  }

  /// Generate optimized URL with quality and format transformations
  /// Cloudinary URL format: https://res.cloudinary.com/{cloud}/{type}/{transformations}/{public_id}
  String _generateOptimizedUrl(String? originalUrl, int quality) {
    if (originalUrl == null || originalUrl.isEmpty) {
      return '';
    }

    // Insert transformation parameters into the URL
    // Format: q_{quality}/f_auto/c_limit/
    // q_{quality} - quality setting
    // f_auto - automatic format selection (WebP, JPEG, etc)
    // c_limit - limit to avoid distortion

    final transformations = 'q_$quality,f_auto,c_limit';
    final optimizedUrl = originalUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/$transformations/',
    );

    return optimizedUrl;
  }

  /// Upload an image file specifically for check-ins
  Future<CloudinaryUploadResult> uploadCheckinImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) {
    return uploadImage(
      file,
      folder: CloudinaryFolder.checkins,
      progressCallback: progressCallback,
      quality: 85, // Good quality for check-in photos
    );
  }

  /// Upload an image file specifically for reviews
  Future<CloudinaryUploadResult> uploadReviewImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) {
    return uploadImage(
      file,
      folder: CloudinaryFolder.reviews,
      progressCallback: progressCallback,
      quality: 85, // Good quality for review photos
    );
  }

  /// Upload an image file specifically for profile pictures
  Future<CloudinaryUploadResult> uploadProfileImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) {
    return uploadImage(
      file,
      folder: CloudinaryFolder.profiles,
      progressCallback: progressCallback,
      quality: 90, // Higher quality for profile pictures
    );
  }

  /// Upload an image file specifically for posts
  Future<CloudinaryUploadResult> uploadPostImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) {
    return uploadImage(
      file,
      folder: CloudinaryFolder.posts,
      progressCallback: progressCallback,
      quality: 85, // Good quality for post photos
    );
  }

  /// Get the Cloudinary instance for URL generation
  Cloudinary get cloudinary => _cloudinary;
}
