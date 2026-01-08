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

  /// Create user-friendly error message from technical error
  factory CloudinaryUploadResult.friendlyError(String technicalError) {
    String friendlyMessage;
    
    if (technicalError.contains('SocketException') || 
        technicalError.contains('Connection refused') ||
        technicalError.contains('Network is unreachable')) {
      friendlyMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
    } else if (technicalError.contains('TimeoutException') ||
               technicalError.contains('timed out')) {
      friendlyMessage = 'Koneksi timeout. Coba lagi dengan jaringan yang lebih stabil.';
    } else if (technicalError.contains('File too large') ||
               technicalError.contains('exceeds')) {
      friendlyMessage = 'Ukuran file terlalu besar. Maksimal 10MB.';
    } else if (technicalError.contains('Invalid image') ||
               technicalError.contains('unsupported')) {
      friendlyMessage = 'Format gambar tidak didukung. Gunakan JPG atau PNG.';
    } else {
      friendlyMessage = 'Gagal mengunggah gambar. Silakan coba lagi.';
    }
    
    return CloudinaryUploadResult(
      error: friendlyMessage,
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

  /// Maximum file size in bytes (10MB)
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  
  /// Maximum retry attempts
  static const int maxRetryAttempts = 3;

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
    // Validate file exists
    if (!await file.exists()) {
      return CloudinaryUploadResult.error('File tidak ditemukan');
    }

    // Validate file size
    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      Logger.warning('File size too large: ${sizeMB}MB (max: 10MB)', 'CloudinaryService');
      return CloudinaryUploadResult.error(
        'Ukuran file terlalu besar (${sizeMB}MB). Maksimal 10MB.',
      );
    }

    Logger.debug('File size: ${(fileSize / 1024).toStringAsFixed(1)}KB', 'CloudinaryService');

    // Attempt upload with retry mechanism
    return _uploadWithRetry(
      file,
      folder: folder,
      progressCallback: progressCallback,
      quality: quality,
    );
  }

  /// Upload with retry mechanism and exponential backoff
  Future<CloudinaryUploadResult> _uploadWithRetry(
    File file, {
    required String folder,
    UploadProgressCallback? progressCallback,
    required int quality,
    int attempt = 1,
  }) async {
    try {
      Logger.debug('Upload attempt $attempt/$maxRetryAttempts', 'CloudinaryService');
      Logger.debug('Uploading image: ${file.path}', 'CloudinaryService');
      Logger.debug('Folder: $folder', 'CloudinaryService');

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
        final errorMsg = response?.error?.message ?? 'Unknown upload error';
        Logger.error('Upload error: $errorMsg', null, null, 'CloudinaryService');
        
        // Retry on certain errors
        if (_shouldRetry(errorMsg) && attempt < maxRetryAttempts) {
          return _retryAfterDelay(
            file,
            folder: folder,
            progressCallback: progressCallback,
            quality: quality,
            attempt: attempt,
          );
        }
        
        return CloudinaryUploadResult.friendlyError(errorMsg);
      }

      final result = response?.data;
      if (result == null) {
        if (attempt < maxRetryAttempts) {
          return _retryAfterDelay(
            file,
            folder: folder,
            progressCallback: progressCallback,
            quality: quality,
            attempt: attempt,
          );
        }
        return CloudinaryUploadResult.error('Gagal mengunggah gambar. Silakan coba lagi.');
      }

      // Generate optimized URL with quality transformation
      final optimizedUrl = _generateOptimizedUrl(result.secureUrl, quality);
      Logger.debug('Upload success: $optimizedUrl', 'CloudinaryService');

      return CloudinaryUploadResult(
        publicId: result.publicId,
        url: result.url,
        secureUrl: optimizedUrl,
        width: result.width,
        height: result.height,
        format: result.format,
        bytes: result.bytes,
        success: true,
      );
    } catch (e, stackTrace) {
      Logger.error('Upload exception (attempt $attempt)', e, stackTrace, 'CloudinaryService');
      
      // Retry on network-related errors
      if (_shouldRetry(e.toString()) && attempt < maxRetryAttempts) {
        return _retryAfterDelay(
          file,
          folder: folder,
          progressCallback: progressCallback,
          quality: quality,
          attempt: attempt,
        );
      }
      
      return CloudinaryUploadResult.friendlyError(e.toString());
    }
  }

  /// Check if error is retryable
  bool _shouldRetry(String error) {
    final retryableErrors = [
      'SocketException',
      'Connection refused',
      'Connection reset',
      'Connection closed',
      'timeout',
      'timed out',
      'Network is unreachable',
      'No route to host',
      'temporarily unavailable',
      '503',
      '502',
      '504',
    ];
    
    return retryableErrors.any((e) => error.toLowerCase().contains(e.toLowerCase()));
  }

  /// Retry upload after exponential backoff delay
  Future<CloudinaryUploadResult> _retryAfterDelay(
    File file, {
    required String folder,
    UploadProgressCallback? progressCallback,
    required int quality,
    required int attempt,
  }) async {
    // Exponential backoff: 1s, 2s, 4s
    final delaySeconds = 1 << (attempt - 1);
    Logger.debug('Retrying in ${delaySeconds}s...', 'CloudinaryService');
    
    await Future.delayed(Duration(seconds: delaySeconds));
    
    return _uploadWithRetry(
      file,
      folder: folder,
      progressCallback: progressCallback,
      quality: quality,
      attempt: attempt + 1,
    );
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
