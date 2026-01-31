import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const LoadingOverlayWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final Color overlayColor = AppColors.surfaceContainer;
    final double overlayOpacity = 0.75;
    final Color indicatorColor = AppColors.primary;
    final double indicatorSize = 40;

    final alpha = (overlayOpacity * 255).round().clamp(0, 255);
    final r = (overlayColor.r * 255.0).round() & 0xff;
    final g = (overlayColor.g * 255.0).round() & 0xff;
    final b = (overlayColor.b * 255.0).round() & 0xff;
    final color = Color.fromARGB(alpha, r, g, b);

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: AbsorbPointer(
            child: ColoredBox(
              color: color,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: indicatorSize,
                      height: indicatorSize,
                      child: CircularProgressIndicator(
                        color: indicatorColor,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
