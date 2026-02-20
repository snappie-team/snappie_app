import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/place_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_pages.dart';

enum CardSize {
  small,
  large,
  fullWidth,
}

class CardConfig {
  final double imageHeight;
  final EdgeInsets contentPadding;
  final double titleFontSize;
  final int titleMaxLines;
  final double descriptionFontSize;
  final int descriptionMaxLines;
  final double ratingIconSize;
  final double ratingFontSize;
  final double overlayIconSize;
  final double borderRadius;
  final EdgeInsets margin;
  final double? width;
  final double? height;

  CardConfig({
    required this.imageHeight,
    required this.contentPadding,
    required this.titleFontSize,
    required this.titleMaxLines,
    required this.descriptionFontSize,
    required this.descriptionMaxLines,
    required this.ratingIconSize,
    required this.ratingFontSize,
    required this.overlayIconSize,
    required this.borderRadius,
    required this.margin,
    this.width,
    this.height,
  });
}

class PlaceCardWidget extends StatelessWidget {
  final PlaceModel place;
  final CardSize cardSize;
  final bool showOverlayIcon;
  final IconData? overlayIcon;
  final Color? overlayIconColor;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const PlaceCardWidget({
    super.key,
    required this.place,
    this.cardSize = CardSize.large,
    this.showOverlayIcon = false,
    this.overlayIcon = Icons.store,
    this.overlayIconColor,
    this.backgroundColor,
    this.margin,
    this.padding,
  });

  CardConfig _getCardConfig() {
    switch (cardSize) {
      case CardSize.small:
        return CardConfig(
          imageHeight: 80,
          contentPadding: const EdgeInsets.all(8),
          titleFontSize: 14,
          titleMaxLines: 1,
          descriptionFontSize: 10,
          descriptionMaxLines: 1,
          ratingIconSize: 14,
          ratingFontSize: 12,
          overlayIconSize: 32,
          borderRadius: 8,
          margin: const EdgeInsets.only(bottom: 8),
          width: 180,
          height: 160,
        );
      case CardSize.large:
        return CardConfig(
          imageHeight: 100,
          contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          titleFontSize: 16,
          titleMaxLines: 1,
          descriptionFontSize: 12,
          descriptionMaxLines: 2,
          ratingIconSize: 18,
          ratingFontSize: 14,
          overlayIconSize: 48,
          borderRadius: 4,
          margin: const EdgeInsets.fromLTRB(16, 0, 0, 12),
          width: 270,
          height: 230,
        );
      case CardSize.fullWidth:
        return CardConfig(
          imageHeight: 100,
          contentPadding: const EdgeInsets.all(8),
          titleFontSize: 16,
          titleMaxLines: 1,
          descriptionFontSize: 12,
          descriptionMaxLines: 2,
          ratingIconSize: 18,
          ratingFontSize: 14,
          overlayIconSize: 48,
          borderRadius: 4,
          margin: const EdgeInsets.only(bottom: 12),
          width: 270,
          height: 240,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardConfig = _getCardConfig();

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: AppColors.error,
      //     width: 1,
      //   ),
      // ),
      width: cardConfig.width,
      height: cardConfig.height,
      margin: cardConfig.margin,
      child: GestureDetector(
        key: Key('place_card_${place.id}'),
        onTap: () => Get.toNamed(AppPages.PLACE_DETAIL, arguments: place),
        child: Container(
          padding: padding ?? cardConfig.contentPadding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.backgroundContainer,
            borderRadius: BorderRadius.circular(cardConfig.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with optional overlay icon
              _buildImageSection(cardConfig),

              // Content
              _buildContentSection(cardConfig),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(CardConfig config) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(config.borderRadius)),
          child: Container(
            height: config.height! * 0.60,
            width: double.infinity,
            color: AppColors.background,
            child: Image.network(
              (place.imageUrls != null &&
                      place.imageUrls!.isNotEmpty &&
                      place.imageUrls!.first.url != null)
                  ? place.imageUrls!.first.url!
                  : 'https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/146/2024/04/30/Sagarmatha-3522761961.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.textTertiary,
                      size: config.imageHeight * 0.3,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Overlay icon (optional)
        if (showOverlayIcon)
          Positioned.fill(
            child: Center(
              child: Container(
                width: config.overlayIconSize,
                height: config.overlayIconSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  overlayIcon,
                  color: overlayIconColor ?? AppColors.primary,
                  size: config.overlayIconSize * 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentSection(CardConfig config) {
    return Padding(
      padding: config.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Place Name with Rating
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name ?? 'Unknown Place',
                  style: TextStyle(
                    fontSize: config.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: config.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cardSize != CardSize.small) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: config.ratingIconSize,
                ),
                const SizedBox(width: 4),
                Text(
                  (place.avgRating ?? 0.0).toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: config.ratingFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),

          if (cardSize != CardSize.small) ...[
            const SizedBox(height: 6),

            // Short Description
            Text(
              place.placeDetail?.shortDescription ?? 'Tempat makan yang nyaman',
              style: TextStyle(
                fontSize: config.descriptionFontSize,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
              maxLines: config.descriptionMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
