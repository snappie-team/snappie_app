import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../data/models/gamification_response_model.dart';
import '../_display_widgets/app_icon.dart';

/// Animated popup widget for displaying unlocked achievements
/// 
/// Features:
/// - Scale animation entrance with elastic curve
/// - Gradient background
/// - Achievement icon, name, level display
/// - Reward coins and XP display
/// - Auto-close after 3 seconds
/// - Manual close button
class AchievementPopupWidget extends StatefulWidget {
  final AchievementSummary achievement;
  final Duration autoCloseDuration;

  const AchievementPopupWidget({
    super.key,
    required this.achievement,
    this.autoCloseDuration = const Duration(seconds: 3),
  });

  @override
  State<AchievementPopupWidget> createState() => _AchievementPopupWidgetState();
}

class _AchievementPopupWidgetState extends State<AchievementPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();

    // Setup scale animation
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();

    // Auto-close timer
    _autoCloseTimer = Timer(widget.autoCloseDuration, () {
      if (mounted) Get.back();
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: AppIcon(AppAssets.iconsSvg.close, color: Colors.white, size: 24),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const SizedBox(height: 8),

              // Achievement icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Achievement unlocked text
              const Text(
                'Achievement Unlocked!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Achievement name
              Text(
                widget.achievement.name ?? 'Achievement',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              // Level display (if exists)
              if (widget.achievement.level != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.achievement.levelText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Rewards section
              if (widget.achievement.hasRewards)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Coins reward
                      if (widget.achievement.rewardCoins != null &&
                          widget.achievement.rewardCoins! > 0)
                        _RewardItem(
                          icon: Icons.monetization_on,
                          label: '${widget.achievement.rewardCoins} Coins',
                          color: Colors.amber,
                        ),

                      // XP reward
                      if (widget.achievement.rewardXp != null &&
                          widget.achievement.rewardXp! > 0)
                        _RewardItem(
                          icon: Icons.star,
                          label: '${widget.achievement.rewardXp} XP',
                          color: Colors.amberAccent,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reward item widget for displaying coins or XP
class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
