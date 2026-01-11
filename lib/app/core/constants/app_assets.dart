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

  /// Asset logo (assets/images/logo/)
  static const logo = _AppLogo();

  /// Asset avatar (assets/images/avatar/)
  static const avatar = _AppAvatar();

  /// Asset frames (assets/images/frames/)
  static const frames = _AppFrames();

  /// Asset icons (assets/icon/)
  static const icons = _AppIcons();

  /// Asset SVG icons (assets/iconsvg/)
  static const iconsSvg = _AppIconsSvg();
}

/// Asset gambar di folder assets/images/
class _AppImages {
  const _AppImages();

  // === Base Path ===
  static const String _basePath = 'assets/images';

  // === Background ===
  String get background => '$_basePath/background/background.png';

  // === Onboarding ===
  String get onboarding1 => '$_basePath/onboarding/onboarding1.png';
  String get onboarding2 => '$_basePath/onboarding/onboarding2.png';
  String get onboarding3 => '$_basePath/onboarding/onboarding3.png';
  String get onboarding4 => '$_basePath/background/onboarding4.webp';
  
  // === Mascot ===
  String get mascot => '$_basePath/onboarding/onboarding4-add.png';

  // === Icons / Illustrations ===
  String get coin => '$_basePath/generals/coin.png';
  String get coins => '$_basePath/generals/coins.png';
  String get coupon => '$_basePath/generals/coupon.png';
  String get find => '$_basePath/generals/find.png';
  String get friends => '$_basePath/generals/friends.png';
  String get gift => '$_basePath/generals/gift.png';
  String get leaderboard => '$_basePath/generals/leaderboard.png';
  String get loading => '$_basePath/generals/loading.png';
  String get logout => '$_basePath/generals/logout.png';
  String get target => '$_basePath/generals/target.png';
  String get unlocked => '$_basePath/generals/unlocked.png';

  // === Mission ===
  String get mission => '$_basePath/generals/mission.png';
  String get missionSuccess => '$_basePath/generals/mission_success.png';
  String get missionFailed => '$_basePath/generals/mission_failed.png';

  // === Achievement ===
  String get achievement => '$_basePath/generals/achievement.png';
  String achievementCoin({bool isFemale = false}) =>
      '$_basePath/achievement/achievement_coin_${isFemale ? 'f' : 'm'}.png';
  String achievementLove({bool isFemale = false}) =>
      '$_basePath/achievement/achievement_love_${isFemale ? 'f' : 'm'}.png';
  String achievementMvp({bool isFemale = false}) =>
      '$_basePath/achievement/achievement_mvp_${isFemale ? 'f' : 'm'}.png';
  String achievementStreak({bool isFemale = false}) =>
      '$_basePath/achievement/achievement_streak_${isFemale ? 'f' : 'm'}.png';
  String achievementXp({bool isFemale = false}) =>
      '$_basePath/achievement/achievement_xp_${isFemale ? 'f' : 'm'}.png';

  // === Challenge ===
  String challenge({bool isFemale = false}) =>
      '$_basePath/generals/challenge_${isFemale ? 'f' : 'm'}.png';

  // === Food Types ===
  String get food1 => '$_basePath/food/food1.png';
  String get food2 => '$_basePath/food/food2.png';
  String get food3 => '$_basePath/food/food3.png';
  String get food4 => '$_basePath/food/food4.png';
  String get food5 => '$_basePath/food/food5.png';
  String get food6 => '$_basePath/food/food6.png';
  String get food7 => '$_basePath/food/food7.png';
  String get food8 => '$_basePath/food/food8.png';
  String get food9 => '$_basePath/food/food9.png';
  String get food10 => '$_basePath/food/food10.png';
  String get food11 => '$_basePath/food/food11.png';
  String get food12 => '$_basePath/food/food12.png';
  String get food13 => '$_basePath/food/food13.png';
  String get food14 => '$_basePath/food/food14.png';
}

/// Asset logo di folder assets/images/logo/
class _AppLogo {
  const _AppLogo();

  static const String _basePath = 'assets/images/logo';

  /// Logo untuk dark mode
  String get darkHdpi => '$_basePath/dark-hdpi.png';
}

/// Asset avatar di folder assets/images/avatar/
class _AppAvatar {
  const _AppAvatar();

  static const String _basePath = 'assets/images/avatar';

  /// Selectable avatars untuk profile
  String avatarMale(int number) => '$_basePath/avatar_m${number}_hdpi.png';
  String avatarFemale(int number) => '$_basePath/avatar_f${number}_hdpi.png';
}


/// Asset frames di folder assets/images/frames/
class _AppFrames {
  const _AppFrames();

  static const String _basePath = 'assets/images/frames';

  /// Frame by name
  String get creator => '$_basePath/creator.png';
  String get first => '$_basePath/first.png';
  String get mvp => '$_basePath/mvp.png';
}

/// Asset icons di folder assets/icon/
class _AppIcons {
  const _AppIcons();

  static const String _basePath = 'assets/icon';

  // === Navigation ===
  String get homeActive => '$_basePath/Icon Home.png';
  String get homeInactive => '$_basePath/Icon Home-1.png';
  String get exploreActive => '$_basePath/Icon Explore.png';
  String get exploreInactive => '$_basePath/Icon Explore-1.png';
  String get articleActive => '$_basePath/Icon Article.png';
  String get articleInactive => '$_basePath/Icon Article-1.png';
  String get meTimeActive => '$_basePath/Icon Me Time.png';
  String get nongkrong => '$_basePath/Icon Nongkrong.png';
  String get pasangan => '$_basePath/Icon Pasangan.png';

  // === Actions ===
  String get back => '$_basePath/Back.png';
  String get close => '$_basePath/Close.png';
  String get search => '$_basePath/Search Active.png';
  String get camera => '$_basePath/camera mini.png';
  String get capture => '$_basePath/Capture.png';
  String get download => '$_basePath/Download.png';
  String get share => '$_basePath/Bagikan.png';
  String get addFriend => '$_basePath/Tambah Teman.png';
  String get moreOptions => '$_basePath/More.png';
  String get moreOptions2 => '$_basePath/More-2.png';
  String get moreOptions3 => '$_basePath/More-3.png';
  String get moreOptionsDots => '$_basePath/more dots.png';

  // === Features ===
  String get checklist => '$_basePath/Icon Checklist.png';
  String get comment => '$_basePath/Icon Comment.png';
  String get laptop => '$_basePath/Icon Laptop.png';
  String get notification => '$_basePath/Notifikasi.png';
  String get leaderboard => '$_basePath/Papan Peringkat Fix.png';
  String get achievement => '$_basePath/Penghargaan Fix.png';
  String get coupon => '$_basePath/Tukar Kupon Fix.png';

  // === Settings ===
  String get profile => '$_basePath/Data Diri.png';
  String get profileAlt => '$_basePath/Data Diri-1.png';
  String get setting => '$_basePath/Setting.png';
  String get location => '$_basePath/Lokasi.png';
  String get faq => '$_basePath/FAQ.png';
  String get language => '$_basePath/Ubah Bahasa.png';
  String get changePassword => '$_basePath/Ubah Kata Sandi.png';
  String get helpCenter => '$_basePath/Pusat Bantuan.png';
  String get logout => '$_basePath/Logout.png';

  // === Rating & Status ===
  String get ratingEmpty => '$_basePath/Rating Empty.png';
  String get ratingFilled => '$_basePath/Rating.png';
  String get ratingAlt => '$_basePath/Rating-1.png';
  String get success => '$_basePath/Success.png';
  String get cursor => '$_basePath/cursor.png';
  String get union => '$_basePath/Union.png';

  // === Media ===
  String get video => '$_basePath/video.png';

  // === Generic Icons ===
  String get icon1 => '$_basePath/Icon.png';
  String get icon2 => '$_basePath/Icon-1.png';
  String get icon3 => '$_basePath/Icon-2.png';
  String get save => '$_basePath/Simpan.png';

  // === Placeholders for Future Icon Assets ===
  // NOTE: These icons need to be designed and added to assets/icon/
  // Using Material Icons as fallback until PNG assets are ready
  
  // TODO: Add to assets/icon/ directory
  // String get favorite => '$_basePath/favorite.png';
  // String get favoriteBorder => '$_basePath/favorite_border.png';
  // String get bookmark => '$_basePath/bookmark.png';
  // String get bookmarkBorder => '$_basePath/bookmark_border.png';
  // String get star => '$_basePath/star.png';
  // String get starBorder => '$_basePath/star_border.png';
  // String get coin => '$_basePath/coin.png';
  // String get send => '$_basePath/send.png';
  // String get add => '$_basePath/add.png';
  // String get delete => '$_basePath/delete.png';
  // String get flag => '$_basePath/flag.png';

  /// Get icon by filename dynamically
  String byName(String filename) => '$_basePath/$filename';
}

/// Asset SVG icons di folder assets/iconsvg/
class _AppIconsSvg {
  const _AppIconsSvg();

  // === Base Path ===
  static const String _basePath = 'assets/iconsvg';

  // === Navigation Icons ===
  String get home => '$_basePath/Icon Home.svg';
  String get homeActive => '$_basePath/Icon Home-1.svg';
  String get explore => '$_basePath/Icon Explore.svg';
  String get exploreActive => '$_basePath/Icon Explore-1.svg';
  String get article => '$_basePath/Icon Article.svg';
  String get articleActive => '$_basePath/Icon Article-1.svg';
  String get profile => '$_basePath/Data Diri.svg';
  String get profileActive => '$_basePath/Data Diri-1.svg';

  // === Action Icons ===
  String get loveActive => '$_basePath/Icon Love.svg';
  String get loveInactive => '$_basePath/Icon Love-1.svg';
  String get back => '$_basePath/Back.svg';
  String get close => '$_basePath/Close.svg';
  String get search => '$_basePath/Search Active.svg';
  String get notification => '$_basePath/Notifikasi.svg';
  String get setting => '$_basePath/Setting.svg';
  String get share => '$_basePath/Bagikan.svg';
  String get saveInactive => '$_basePath/Simpan.svg';
  String get saveActive => '$_basePath/Simpan-1.svg';
  String get download => '$_basePath/Download.svg';
  String get addFriend => '$_basePath/Tambah Teman.svg';
  String get create => '$_basePath/create.svg';
  
  // === Content Icons ===
  String get capture => '$_basePath/Capture.svg';
  String get camera => '$_basePath/camera mini.svg';
  String get video => '$_basePath/video.svg';
  String get comment => '$_basePath/Icon Comment.svg';
  String get location => '$_basePath/Lokasi.svg';
  String get cursor => '$_basePath/cursor.svg';
  String get union => '$_basePath/Union.svg';
  String get checklist => '$_basePath/Icon Checklist.svg';

  // === Category Icons ===
  String get meTime => '$_basePath/Icon Me Time.svg';
  String get nongkrong => '$_basePath/Icon Nongkrong.svg';
  String get pasangan => '$_basePath/Icon Pasangan.svg';
  String get laptop => '$_basePath/Icon Laptop.svg';

  // === Menu Icons ===
  String get logout => '$_basePath/Logout.svg';
  String get faq => '$_basePath/FAQ.svg';
  String get language => '$_basePath/Ubah Bahasa.svg';
  String get changePassword => '$_basePath/Ubah Kata Sandi.svg';
  String get helpCenter => '$_basePath/Pusat Bantuan.svg';
  
  // === Gamification Icons ===
  String get leaderboard => '$_basePath/Papan Peringkat Fix.svg';
  String get achievement => '$_basePath/Penghargaan Fix.svg';
  String get coupon => '$_basePath/Tukar Kupon Fix.svg';

  // === Rating Icons ===
  String get ratingEmpty => '$_basePath/Rating Empty.svg';
  String get rating => '$_basePath/Rating.svg';
  String get ratingAlt => '$_basePath/Rating-1.svg';
  String get success => '$_basePath/Success.svg';

  // === More Options ===
  String get more => '$_basePath/More.svg';
  String get moreOption1 => '$_basePath/More-1.svg';
  String get moreOption2 => '$_basePath/More-2.svg';
  String get moreOption3 => '$_basePath/More-3.svg';
  String get moreDots => '$_basePath/more dots.svg';

  // === Generic Icons ===
  String get icon => '$_basePath/Icon.svg';
  String get icon1 => '$_basePath/Icon-1.svg';
  String get icon2 => '$_basePath/Icon-2.svg';

  /// Get SVG icon by filename dynamically
  String byName(String filename) => '$_basePath/$filename';
}
