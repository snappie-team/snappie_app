import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum BannerSize {
  standard,
  compact,
}

class BannerConfig {
  final Color backgroundColor;
  final double? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color titleColor;
  final Color subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;

  const BannerConfig({
    required this.backgroundColor,
    this.borderRadius,
    this.margin,
    required this.padding,
    required this.titleColor,
    required this.subtitleColor,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.titleFontWeight,
    required this.subtitleFontWeight,
  });
}

class PromotionalBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Image? imageAsset;
  final BannerSize size;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const PromotionalBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.imageAsset,
    this.size = BannerSize.standard,
    this.onTap,
    this.showCloseButton = false,
    this.onClose,
  });

  BannerConfig _getBannerConfig() {
    switch (size) {
      case BannerSize.standard:
        return BannerConfig(
          backgroundColor: AppColors.backgroundContainer,
          borderRadius: 12,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          titleColor: AppColors.textPrimary,
          subtitleColor: AppColors.textSecondary,
          titleFontSize: 16,
          subtitleFontSize: 12,
          titleFontWeight: FontWeight.w600,
          subtitleFontWeight: FontWeight.normal,
        );
      case BannerSize.compact:
        return BannerConfig(
          backgroundColor: AppColors.backgroundContainer,
          borderRadius: null,
          margin: null,
          padding: const EdgeInsets.all(20),
          titleColor: AppColors.accent,
          subtitleColor: AppColors.textSecondary,
          titleFontSize: 16,
          subtitleFontSize: 12,
          titleFontWeight: FontWeight.w600,
          subtitleFontWeight: FontWeight.normal,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getBannerConfig();

    Widget banner = Stack(
      children: [
        Container(
          width: double.infinity,
          padding: config.padding,
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: config.borderRadius != null
                ? BorderRadius.circular(config.borderRadius!)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: config.titleFontSize,
                        fontWeight: config.titleFontWeight,
                        color: config.titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: config.subtitleFontSize,
                        fontWeight: config.subtitleFontWeight,
                        color: config.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  // color: iconBackgroundColor,
                  // borderRadius: BorderRadius.circular(30),
                ),
                child: imageAsset != null
                    ? ClipRect(
                        child: imageAsset!,
                      )
                    : Icon(
                        icon,
                        color: iconColor,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        // Close button positioned at top right
        if (showCloseButton && onClose != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );

    // Wrap with margin if specified
    if (config.margin != null) {
      banner = Padding(
        padding: config.margin!,
        child: banner,
      );
    }

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      banner = GestureDetector(
        onTap: onTap,
        child: banner,
      );
    }

    return banner;
  }
}
