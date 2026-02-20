import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/font_size.dart';

/// Data model for each tour step.
class _TourStep {
  final int tabIndex;
  final String title;
  final String description;

  const _TourStep({
    required this.tabIndex,
    required this.title,
    required this.description,
  });
}

/// Full-screen overlay that shows coach-mark tooltips pointing at each
/// bottom navigation tab.
///
/// Appears after first registration and guides the user through
/// all 4 main tabs (Beranda, Jelajahi, Artikel, Akun).
class TabTourOverlay extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const TabTourOverlay({
    super.key,
    required this.currentStep,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  static const List<_TourStep> _steps = [
    _TourStep(
      tabIndex: 0,
      title: 'Bagikan Pengalamanmu',
      description:
          'Upload cerita kuliner hidden gems dan lihat postingan pengguna lainnya.',
    ),
    _TourStep(
      tabIndex: 1,
      title: 'Temukan Hidden Gems',
      description:
          'Cari tempat kuliner tersembunyi di sekitarmu dan baca review pengguna lain.',
    ),
    _TourStep(
      tabIndex: 2,
      title: 'Baca Artikel Menarik',
      description:
          'Temukan tips, ulasan, dan rekomendasi kuliner dari berbagai penjuru.',
    ),
    _TourStep(
      tabIndex: 3,
      title: 'Kelola Akunmu',
      description:
          'Lihat profil, kumpulkan pencapaian, dan atur preferensi akunmu.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStep >= _steps.length) return const SizedBox.shrink();

    final step = _steps[currentStep];
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Bottom nav is roughly 80pt tall (icon + label + top bar + padding)
    // NavItem area starts after 16px side padding, each tab is 1/4 of (screen - 32)
    const double navHorizontalPadding = 16;
    final double tabWidth =
        (screenWidth - navHorizontalPadding * 2) / _steps.length;
    final double tabCenterX =
        navHorizontalPadding + (step.tabIndex * tabWidth) + (tabWidth / 2);

    // Tooltip dimensions
    const double tooltipWidth = 280;
    const double arrowSize = 12;

    // Tooltip horizontal position — clamp so it doesn't overflow screen
    double tooltipLeft = tabCenterX - tooltipWidth / 2;
    tooltipLeft = tooltipLeft.clamp(16.0, screenWidth - tooltipWidth - 16.0);

    // Arrow horizontal position relative to tooltip
    final double arrowLeftInTooltip = tabCenterX - tooltipLeft - arrowSize;

    // Tooltip bottom position — sits above the nav bar
    final double tooltipBottom = bottomPadding + 16;

    return Stack(
      children: [
        // ─── Semi-transparent backdrop ───────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // absorb taps
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
          ),
        ),

        // ─── Highlight ring around active tab ────────────
        // Positioned(
        //   bottom: bottomPadding + 16, // aligned with nav items
        //   left: tabCenterX - 30,
        //   child: Container(
        //     width: 60,
        //     height: 60,
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       border: Border.all(color: AppColors.primary, width: 2.5),
        //       color: const Color.fromRGBO(255, 255, 255, 0.15),
        //     ),
        //   ),
        // ),

        // ─── Tooltip bubble ──────────────────────────────
        Positioned(
          bottom: tooltipBottom,
          left: tooltipLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bubble
              Container(
                width: tooltipWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: step indicator + close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currentStep + 1}/${_steps.length}',
                          style: TextStyle(
                            fontSize:
                                FontSize.getSize(FontSizeOption.mediumSmall),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        GestureDetector(
                          onTap: onSkip,
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: FontSize.getSize(FontSizeOption.medium),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: FontSize.getSize(FontSizeOption.regular),
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        if (currentStep > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onBack,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: Text(
                                'Kembali',
                                style: TextStyle(
                                  fontSize:
                                      FontSize.getSize(FontSizeOption.regular),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              currentStep == _steps.length - 1
                                  ? 'Selesai'
                                  : 'Lanjut',
                              style: TextStyle(
                                fontSize:
                                    FontSize.getSize(FontSizeOption.regular),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow pointer (pointing down to tab)
              Padding(
                padding: EdgeInsets.only(
                    left: arrowLeftInTooltip.clamp(16, tooltipWidth - 40)),
                child: CustomPaint(
                  size: Size(arrowSize * 2, arrowSize),
                  painter: _ArrowPainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Paints a small downward-pointing triangle (tooltip arrow).
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    // Shadow
    canvas.drawShadow(path, const Color.fromRGBO(0, 0, 0, 0.1), 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
