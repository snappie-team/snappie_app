import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: backgroundColor ?? AppColors.surfaceContainer,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
      errorWidget: (context, url, error) => this.errorWidget ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surfaceContainer,
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.image_not_supported,
              color: AppColors.textTertiary,
              size: (width != null && height != null)
                  ? (width! < height! ? width! * 0.4 : height! * 0.4)
                  : 24,
            ),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
