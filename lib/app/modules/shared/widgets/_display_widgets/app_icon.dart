import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';

/// Custom widget untuk menampilkan SVG icon dari local assets
/// 
/// Widget ini memudahkan penggunaan SVG icon lokal dengan fitur:
/// - Color tinting (reliable dengan SVG)
/// - Size customization
/// - Scalable untuk semua resolusi
/// - Fallback icon
/// 
/// Contoh penggunaan:
/// ```dart
/// AppIcon(AppAssets.icons.home, size: 24, color: Colors.blue)
/// AppIcon.forButton(AppAssets.icons.close, color: Colors.white)
/// ```
class AppIcon extends StatelessWidget {
  /// Path ke SVG asset icon (dari AppAssets.icons.*)
  final String assetPath;
  
  /// Ukuran icon (width & height sama)
  final double? size;
  
  /// Warna untuk tinting icon
  final Color? color;
  
  /// BoxFit untuk SVG
  final BoxFit fit;
  
  /// Fallback icon jika asset tidak ditemukan
  final IconData? fallbackIcon;

  const AppIcon(
    this.assetPath, {
    super.key,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
    this.fallbackIcon,
  });

  /// Constructor khusus untuk IconButton
  /// 
  /// Usage:
  /// ```dart
  /// IconButton(
  ///   icon: AppIcon.forButton(AppAssets.icons.close, color: Colors.white),
  ///   onPressed: () {},
  /// )
  /// ```
  const AppIcon.forButton(
    this.assetPath, {
    super.key,
    this.size = 24.0,
    this.color,
    this.fit = BoxFit.contain,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = AppColors.textSecondary;
    return SvgPicture.asset(
      assetPath,
      width: size ?? 24.0,
      height: size ?? 24.0,
      fit: fit,
      colorFilter: ColorFilter.mode(
        color ?? defaultColor,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (context) {
        // Fallback ke Material Icon jika asset tidak ditemukan
        if (fallbackIcon != null) {
          return Icon(
            fallbackIcon,
            size: size ?? 24.0,
            color: color,
          );
        }
        // Default fallback icon
        return Icon(
          Icons.image_not_supported,
          size: size ?? 24.0,
          color: color ?? Colors.grey,
        );
      },
    );
  }
}

/// Extension untuk memudahkan penggunaan AppIcon dengan IconButton
extension AppIconButton on Widget {
  /// Wrap AppIcon dalam IconButton
  /// 
  /// Usage:
  /// ```dart
  /// AppIcon(AppAssets.icons.close).asButton(onPressed: () {})
  /// ```
  Widget asButton({
    required VoidCallback? onPressed,
    double? iconSize,
    Color? color,
    String? tooltip,
  }) {
    return IconButton(
      icon: this,
      onPressed: onPressed,
      iconSize: iconSize,
      color: color,
      tooltip: tooltip,
    );
  }
}
