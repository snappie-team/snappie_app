/// Remote Assets Configuration
/// 
/// This file contains URLs for remote assets stored in the cloud.
/// Uses template-based approach for better maintainability.
/// References AppAssets for local fallback paths to avoid duplication.
library;

import 'app_assets.dart';

class RemoteAssets {
  RemoteAssets._();

  // Cloudinary Configuration
  static const String cloudName = 'deqnkuhbv';
  static const String version = 'v1761044273';
  // https://res.cloudinary.com/deqnkuhbv/image/upload/v1761044273/snappie/assets/avatar/avatar_m4_mdpi.png
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName/image/upload/$version/snappie/assets';

  // Template methods for building URLs dynamically
  static String asset(String path) => '$baseUrl/$path';
  
  static String avatar(String filename) => '$baseUrl/avatar/$filename';
  
  static String logo(String filename) => '$baseUrl/logos/$filename';
  
  static String icon(String filename) => '$baseUrl/icons/$filename';
  
  static String splash(String filename) => '$baseUrl/splash/$filename';
  
  static String banner(String filename) => '$baseUrl/banners/$filename';
  
  static String placeholder(String filename) => '$baseUrl/placeholders/$filename';
  
  static String background(String filename) => '$baseUrl/backgrounds/$filename';

  // https://res.cloudinary.com/deqnkuhbv/image/upload/v1761683559/places/01K8P8BHBW4P60YEG5T59GAMQ6.png
  static String image(String filename) => '$baseUrl/places/$filename';

  // Local fallback paths - reference AppAssets for consistency
  /// Get local avatar path from filename (e.g., 'avatar_m1_hdpi.png' -> AppAssets.avatar path)
  static String localAvatar(String filename) {
    // Parse gender and number from filename (e.g., 'avatar_m1_hdpi.png' -> m, 1)
    final regex = RegExp(r'avatar_([mf])(\d)');
    final match = regex.firstMatch(filename);
    
    if (match != null) {
      final gender = match.group(1); // 'm' or 'f'
      final number = int.parse(match.group(2) ?? '1');
      
      if (gender == 'm') {
        return AppAssets.avatar.avatarMale(number);
      } else {
        return AppAssets.avatar.avatarFemale(number);
      }
    }
    
    // Fallback if parsing fails
    return AppAssets.avatar.avatarMale(1);
  }
  
  /// Get local logo path
  static String get localLogo => AppAssets.logo.darkHdpi;
  
  /// Get local icon path from filename
  static String localIcon(String filename) => 'assets/icon/$filename';

  // Common predefined assets (for convenience)
  static String get defaultAvatar => avatar('avatar_m1_hdpi.png');
  static String get placeholderAvatar => avatar('placeholder.png');
  
  static String get appLogo => logo('app_logo.png');
  static String get appLogoWhite => logo('app_logo_white.png');
  static String get appLogoTransparent => logo('app_logo_transparent.png');
  
  static String get notificationIcon => icon('notification.png');
  static String get errorIcon => icon('error.png');
  static String get successIcon => icon('success.png');
  
  static String get splashBackground => splash('background.png');
  static String get splashLogo => splash('logo.png');
  
  static String get homeBanner => banner('home_banner.jpg');
  static String get promoBanner => banner('promo_banner.jpg');
  
  static String get placeholderImage => placeholder('image_placeholder.png');
  static String get noImageAvailable => placeholder('no_image.png');
  
  static String get authBackground => background('auth_bg.png');
  static String get homeBackground => background('home_bg.png');

  // Helper method to validate URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Gets the filename from a URL without path or query parameters
  static String getExactFilename(String url) {
    return url.split('/').last.split('?').first;
  }
}
