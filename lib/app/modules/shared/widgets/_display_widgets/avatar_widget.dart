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

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = AvatarSize.medium,
    this.onTap,
    this.frameUrl,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getSize();
    
    Widget avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarBackgroundColor(),
        border: Border.all(
          color: AppColors.textOnPrimary,
          width: avatarSize * 0.05,
        ),
      ),
      padding: EdgeInsets.all(avatarSize * 0.05),
      child: _buildContent(),
    );

    // Add frame if provided
    if (frameUrl != null && frameUrl!.isNotEmpty) {
      avatar = Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          _buildFrame(),
        ],
      );
    }

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

  Widget _buildFrame() {
    return Image.network(
      frameUrl!,
      width: _getSize(),
      height: _getSize(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to local asset if network fails
        final filename = RemoteAssets.getExactFilename(frameUrl!).toLowerCase().replaceAll('.png', '').replaceAll('.webp', '');
        final localFramePath = _getLocalFramePath(filename);
        
        if (localFramePath == null) {
          return const SizedBox.shrink();
        }
        
        return Image.asset(
          localFramePath,
          width: _getSize(),
          height: _getSize(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If both fail, don't show frame
            return const SizedBox.shrink();
          },
        );
      },
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
      'avatar_f1_hdpi.png': Colors.orange[100]! ,
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
