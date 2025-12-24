/// Centralized local asset management
///
/// File ini mengelola semua path asset lokal dalam aplikasi.
/// Gunakan class ini untuk mengakses asset agar mudah di-maintain dan konsisten.
///
/// Contoh penggunaan:
/// ```dart
/// Image.asset(AppAssets.images.background)
/// Image.asset(AppAssets.images.coin)
/// ```
library;

/// Main class untuk mengakses semua asset
class AppAssets {
  AppAssets._();

  /// Asset gambar (assets/images/)
  static const images = _AppImages();

  /// Asset logo (assets/logo/)
  static const logo = _AppLogo();

  /// Asset avatar (assets/avatar/)
  static const avatar = _AppAvatar();

  /// Asset splash (assets/splash/)
  static const splash = _AppSplash();

  /// Asset frames (assets/frames/)
  static const frames = _AppFrames();
}

/// Asset gambar di folder assets/images/
class _AppImages {
  const _AppImages();

  // === Base Path ===
  static const String _basePath = 'assets/images';

  // === Background ===
  String get background => '$_basePath/background.png';

  // === Onboarding ===
  String get onboarding1 => '$_basePath/onboarding1.png';
  String get onboarding2 => '$_basePath/onboarding2.png';
  String get onboarding3 => '$_basePath/onboarding3.png';
  String get onboarding4 => '$_basePath/onboarding4.png';

  // === Icons / Illustrations ===
  String get coin => '$_basePath/coin.png';
  String get coins => '$_basePath/coins.png';
  String get coupon => '$_basePath/coupon.png';
  String get find => '$_basePath/find.png';
  String get friends => '$_basePath/friends.png';
  String get gift => '$_basePath/gift.png';
  String get leaderboard => '$_basePath/leaderboard.png';
  String get loading => '$_basePath/loading.png';
  String get logout => '$_basePath/logout.png';
  String get target => '$_basePath/target.png';
  String get unlocked => '$_basePath/unlocked.png';

  // === Mission ===
  String get mission => '$_basePath/mission.png';
  String get missionSuccess => '$_basePath/mission_success.png';
  String get missionFailed => '$_basePath/mission_failed.png';

  // === Achievement ===
  String get achievement => '$_basePath/achievement.png';
  String achievementCoin({bool isFemale = false}) =>
      '$_basePath/achievement_coin_${isFemale ? 'f' : 'm'}.png';
  String achievementLove({bool isFemale = false}) =>
      '$_basePath/achievement_love_${isFemale ? 'f' : 'm'}.png';
  String achievementMvp({bool isFemale = false}) =>
      '$_basePath/achievement_mvp_${isFemale ? 'f' : 'm'}.png';
  String achievementStreak({bool isFemale = false}) =>
      '$_basePath/achievement_streak_${isFemale ? 'f' : 'm'}.png';
  String achievementXp({bool isFemale = false}) =>
      '$_basePath/achievement_xp_${isFemale ? 'f' : 'm'}.png';

  // === Challenge ===
  String challenge({bool isFemale = false}) =>
      '$_basePath/challenge_${isFemale ? 'f' : 'm'}.png';
}

/// Asset logo di folder assets/logo/
class _AppLogo {
  const _AppLogo();

  static const String _basePath = 'assets/logo';

  /// Logo untuk dark mode dengan berbagai resolusi
  String darkHdpi() => '$_basePath/dark-hdpi.png';
  String darkMdpi() => '$_basePath/dark-mdpi.png';
  String darkXhdpi() => '$_basePath/dark-xhdpi.png';
  String darkXxhdpi() => '$_basePath/dark-xxhdpi.png';
  String darkXxxhdpi() => '$_basePath/dark-xxxhdpi.png';

  /// Mendapatkan logo yang sesuai berdasarkan pixel ratio
  String getAppropriate(double pixelRatio) {
    if (pixelRatio <= 1.0) return darkMdpi();
    if (pixelRatio <= 1.5) return darkHdpi();
    if (pixelRatio <= 2.0) return darkXhdpi();
    if (pixelRatio <= 3.0) return darkXxhdpi();
    return darkXxxhdpi();
  }
}

/// Asset avatar di folder assets/avatar/
class _AppAvatar {
  const _AppAvatar();

  static const String _basePath = 'assets/avatar';

  /// Default avatar placeholder
  String get defaultAvatar => '$_basePath/default.png';
}

/// Asset splash di folder assets/splash/
class _AppSplash {
  const _AppSplash();

  static const String _basePath = 'assets/splash';

  /// Splash screen image
  String get splash => '$_basePath/splash.png';
}

/// Asset frames di folder assets/frames/
class _AppFrames {
  const _AppFrames();

  static const String _basePath = 'assets/frames';

  /// Frame by name
  String byName(String name) => '$_basePath/$name.png';
}
