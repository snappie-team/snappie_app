import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/font_size.dart';
import '../../../../routes/app_pages.dart';

/// Modal "Harta Karun" (Treasure Chest) based on the provided design.
/// Prompts the user to check out challenges.
class TreasureChestModal extends StatelessWidget {
  final VoidCallback onDismiss;

  const TreasureChestModal({
    super.key,
    required this.onDismiss,
  });

  static Future<void> show({
    required VoidCallback onDismiss,
  }) {
    return Get.dialog(
      TreasureChestModal(
        onDismiss: onDismiss,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button (X)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                    onDismiss();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
                ),
              ),

              // Chest Image
              Image.asset(
                AppAssets.images.chest,
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),

              // Title Text
              Text(
                'Ikuti tantangan dan dapatkan hadiahnya!',
                style: TextStyle(
                  fontSize: FontSize.getSize(FontSizeOption.medium),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  // "Nanti Saja" Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        onDismiss();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFF2994A), width: 1.5),
                        foregroundColor: const Color(0xFFF2994A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Nanti Saja',
                        style: TextStyle(
                          fontSize: FontSize.getSize(FontSizeOption.regular),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // "Lihat Tantangan" Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onDismiss();
                        Get.toNamed(AppPages.CHALLENGES);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2994A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Lihat Tantangan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.getSize(FontSizeOption.regular),
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
      ),
    );
  }
}
