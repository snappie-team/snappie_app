import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/font_size.dart';
import '../../../../data/models/gamification_response_model.dart';
import '../_display_widgets/app_icon.dart';

/// Full-screen modal widget for displaying unlocked achievements
///
/// Design:
/// - White background with close button
/// - Achievement icon inside circular pink radial gradient
/// - Date in orange pill badge
/// - Description text: "Anda memperoleh [name] dengan mencapai [target] ..."
class AchievementPopupWidget extends StatefulWidget {
  final AchievementSummary achievement;
  final Duration? autoCloseDuration;

  const AchievementPopupWidget({
    super.key,
    required this.achievement,
    this.autoCloseDuration,
  });

  @override
  State<AchievementPopupWidget> createState() => _AchievementPopupWidgetState();
}

class _AchievementPopupWidgetState extends State<AchievementPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    // Auto-close timer (only for activity-triggered popups)
    if (widget.autoCloseDuration != null) {
      _autoCloseTimer = Timer(widget.autoCloseDuration!, () {
        if (mounted) Get.back();
      });
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  static const _fullMonths = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatCompletedDate() {
    final completedAt = widget.achievement.completedAt;
    DateTime date = DateTime.now();
    if (completedAt != null) {
      try {
        date = DateTime.parse(completedAt);
      } catch (_) {}
    }
    return '${date.day} ${_fullMonths[date.month - 1]} ${date.year}';
  }

  TextSpan _buildAchievementText() {
    final name = widget.achievement.name ?? 'Achievement';
    final target = widget.achievement.criteriaTarget;
    final action = widget.achievement.criteriaAction;

    const goldStyle = TextStyle(color: Color(0xFFD4A017)); // gold
    final primaryStyle = TextStyle(color: AppColors.primary);

    TextSpan nameSpan = TextSpan(text: name, style: goldStyle);

    if (target != null && action != null) {
      final actionInfo = _actionLabel(action);
      return TextSpan(
        children: [
          const TextSpan(text: 'Anda memperoleh '),
          nameSpan,
          const TextSpan(text: ' dengan mencapai '),
          TextSpan(text: '$target ${actionInfo.unit}', style: primaryStyle),
          const TextSpan(text: ' pada '),
          TextSpan(text: actionInfo.context, style: primaryStyle),
          const TextSpan(text: '!'),
        ],
      );
    }
    if (target != null) {
      return TextSpan(
        children: [
          const TextSpan(text: 'Anda memperoleh '),
          nameSpan,
          const TextSpan(text: ' dengan mencapai '),
          TextSpan(text: '$target', style: primaryStyle),
          const TextSpan(text: '!'),
        ],
      );
    }
    return TextSpan(
      children: [
        const TextSpan(text: 'Anda berhasil menyelesaikan '),
        nameSpan,
        const TextSpan(text: '!'),
      ],
    );
  }

  /// Maps a criteria_action to its Indonesian unit and context text
  static ({String unit, String context}) _actionLabel(String action) {
    return switch (action) {
      'checkin'     => (unit: 'check-in', context: 'tempat'),
      'review'      => (unit: 'ulasan',   context: 'tempat'),
      'post'        => (unit: 'postingan', context: 'postingan'),
      'like'        => (unit: 'suka',     context: 'postingan'),
      'comment'     => (unit: 'komentar', context: 'postingan'),
      'follow'      => (unit: 'pengikut', context: 'pengguna'),
      'coin_earned' => (unit: 'koin',     context: 'koin'),
      'xp_earned'   => (unit: 'XP',       context: 'pengalaman'),
      'top_rank'    => (unit: 'peringkat', context: 'leaderboard'),
      _             => (unit: action,      context: action),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with close button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: AppIcon(AppAssets.icons.close,
                        color: AppColors.textSecondary, size: 24),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Achievement icon with pink radial gradient
                          _buildAchievementIcon(),

                          const SizedBox(height: 24),

                          // Date pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0), // light orange
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatCompletedDate(),
                              style: TextStyle(
                                color: const Color(0xFFE67E22), // orange
                                fontSize: FontSize.getSize(
                                    FontSizeOption.regular),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Description text
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: Text.rich(
                              _buildAchievementText(),
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: FontSize.getSize(
                                    FontSizeOption.xl),
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Rewards section (if any)
                          // if (widget.achievement.hasRewards) ...[
                          //   const SizedBox(height: 32),
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 24, vertical: 16),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.primarySurface,
                          //       borderRadius: BorderRadius.circular(16),
                          //     ),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         if (widget.achievement.rewardCoins !=
                          //                 null &&
                          //             widget.achievement.rewardCoins! >
                          //                 0) ...[
                          //           Icon(Icons.monetization_on,
                          //               color: Colors.amber, size: 24),
                          //           const SizedBox(width: 6),
                          //           Text(
                          //             '+${widget.achievement.rewardCoins} Koin',
                          //             style: TextStyle(
                          //               color: AppColors.textPrimary,
                          //               fontSize: FontSize.getSize(
                          //                   FontSizeOption.regular),
                          //               fontWeight: FontWeight.w700,
                          //             ),
                          //           ),
                          //         ],
                          //         if (widget.achievement.rewardCoins !=
                          //                 null &&
                          //             widget.achievement.rewardCoins! > 0 &&
                          //             widget.achievement.rewardXp != null &&
                          //             widget.achievement.rewardXp! > 0)
                          //           const SizedBox(width: 20),
                          //         if (widget.achievement.rewardXp != null &&
                          //             widget.achievement.rewardXp! >
                          //                 0) ...[
                          //           Icon(Icons.star,
                          //               color: Colors.amber, size: 24),
                          //           const SizedBox(width: 6),
                          //           Text(
                          //             '+${widget.achievement.rewardXp} XP',
                          //             style: TextStyle(
                          //               color: AppColors.textPrimary,
                          //               fontSize: FontSize.getSize(
                          //                   FontSizeOption.regular),
                          //               fontWeight: FontWeight.w700,
                          //             ),
                          //           ),
                          //         ],
                          //       ],
                          //     ),
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementIcon() {
    final iconUrl = widget.achievement.iconUrl;

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFCDD2).withOpacity(0.6), // soft pink center
            const Color(0xFFFFCDD2).withOpacity(0.15), // fading pink
            Colors.white.withOpacity(0.0), // transparent edge
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: _buildIconImage(iconUrl),
        ),
      ),
    );
  }

  Widget _buildIconImage(String? iconUrl) {
    if (iconUrl == null || iconUrl.isEmpty) {
      return _buildFallbackIcon();
    }

    // If it looks like an asset name (not a URL), use Image.asset
    if (!iconUrl.startsWith('http')) {
      return Image.asset(
        'assets/images/achievement/$iconUrl.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    // Network image
    return CachedNetworkImage(
      imageUrl: iconUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildFallbackIcon(),
      errorWidget: (context, url, error) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.emoji_events,
      size: 100,
      color: AppColors.primary,
    );
  }
}
