import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/remote_assets.dart';

enum AvatarSize {
  small,
  medium,
  large,
  extraLarge,
}

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final AvatarSize size;
  final VoidCallback? onTap;
  final String? frameUrl;
  final bool showCrown;
  final String? topRankCrown;
  final Color? topRankColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = AvatarSize.medium,
    this.onTap,
    this.frameUrl,
    this.showCrown = false,
    this.topRankCrown,
    this.topRankColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();

    Widget avatarCircle = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarBackgroundColor(),
      ),
      padding: EdgeInsets.all(avatarSize * 0.12),
      child: _buildContent(),
    );

    final bool hasFrame = frameUrl != null && frameUrl!.isNotEmpty;
    final bool hasCrown =
        showCrown && topRankCrown != null && topRankCrown!.isNotEmpty;

    // Apply ranking border if needed
    if (hasCrown) {
      final isLarge = size == AvatarSize.large || size == AvatarSize.extraLarge;
      final offset = isLarge ? avatarSize * 0.28 : avatarSize * 0.3;
      avatarCircle = Container(
        margin: EdgeInsets.only(top: offset),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: topRankColor != null
              ? Border.all(
                  color: topRankColor!,
                  width: isLarge ? 4.0 : 3.0,
                )
              : null,
        ),
        child: avatarCircle,
      );
    }

    Widget avatar = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        avatarCircle,
        if (hasFrame) _buildFrameWidget(avatarSize),
        if (hasCrown) _buildCrownWidget(avatarSize),
      ],
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        width: _getSize(),
        height: _getSize(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback to local asset if network fails
          final filename = RemoteAssets.getExactFilename(imageUrl!);
          final localImagePath = RemoteAssets.localAvatar(filename);

          return Image.asset(
            localImagePath,
            fit: BoxFit.contain,
            width: _getSize(),
            height: _getSize(),
            errorBuilder: (context, error, stackTrace) {
              return _buildFallback();
            },
          );
        },
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Icon(
      Icons.person,
      size: _getIconSize(),
      color: AppColors.textSecondary,
    );
  }

  Widget _buildFrameWidget(double avatarSize) {
    final frameSize = avatarSize * 1.2;
    return Positioned(
      bottom: 0,
      child: IgnorePointer(
        child: Image.network(
          frameUrl!,
          width: frameSize,
          height: frameSize,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            final filename = RemoteAssets.getExactFilename(frameUrl!)
                .toLowerCase()
                .replaceAll('.png', '')
                .replaceAll('.webp', '');
            final localFramePath = _getLocalFramePath(filename);

            if (localFramePath == null) return const SizedBox.shrink();

            return Image.asset(
              localFramePath,
              width: frameSize,
              height: frameSize,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCrownWidget(double avatarSize) {
    final isLarge = size == AvatarSize.large || size == AvatarSize.extraLarge;
    final crownSize = isLarge ? avatarSize * 0.7 : avatarSize * 0.75;

    return Positioned(
      bottom: avatarSize * 0.85,
      child: IgnorePointer(
        child: Image.asset(
          topRankCrown!,
          width: crownSize,
          height: crownSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String? _getLocalFramePath(String frameName) {
    switch (frameName) {
      case 'creator':
        return AppAssets.frames.creator;
      case 'first':
        return AppAssets.frames.first;
      case 'mvp':
        return AppAssets.frames.mvp;
      default:
        return null;
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: _getSize(),
      height: _getSize(),
      color: AppColors.surfaceContainer,
      child: Center(
        child: SizedBox(
          width: _getSize() * 0.3,
          height: _getSize() * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case AvatarSize.small:
        return 40;
      case AvatarSize.medium:
        return 56;
      case AvatarSize.large:
        return 80;
      case AvatarSize.extraLarge:
        return 100;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AvatarSize.small:
        return 20;
      case AvatarSize.medium:
        return 28;
      case AvatarSize.large:
        return 40;
      case AvatarSize.extraLarge:
        return 60;
    }
  }

  Color _getAvatarBackgroundColor() {
    // Map avatar filenames to their colors (based on getAvatarOptions)
    final Map<String, Color> avatarColors = {
      'avatar_m1_hdpi.png': Colors.blue[100]!,
      'avatar_m2_hdpi.png': Colors.green[100]!,
      'avatar_m3_hdpi.png': Colors.orange[100]!,
      'avatar_m4_hdpi.png': Colors.grey[100]!,
      'avatar_f1_hdpi.png': Colors.orange[100]!,
      'avatar_f2_hdpi.png': Colors.yellow[100]!,
      'avatar_f3_hdpi.png': Colors.green[100]!,
      'avatar_f4_hdpi.png': Colors.pink[100]!,
    };

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final filename = RemoteAssets.getExactFilename(imageUrl!);
      final color = avatarColors[filename];

      return color ?? AppColors.surfaceContainer;
    }

    return AppColors.surfaceContainer;
  }

  // Available frames list (empty by default)
  static List<Map<String, dynamic>> getAvailableFrames() {
    return [];
  }
}
