import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../data/models/place_model.dart';

/// Result dari MissionConfirmModal
class MissionConfirmResult {
  final bool confirmed;
  final bool hideUsername;

  MissionConfirmResult({
    required this.confirmed,
    required this.hideUsername,
  });
}

/// Modal konfirmasi untuk memulai misi
class MissionConfirmModal extends StatefulWidget {
  final PlaceModel place;

  const MissionConfirmModal({
    super.key,
    required this.place,
  });

  static Future<MissionConfirmResult?> show({
    required PlaceModel place,
  }) {
    return Get.dialog<MissionConfirmResult>(
      MissionConfirmModal(place: place),
      barrierDismissible: false,
    );
  }

  @override
  State<MissionConfirmModal> createState() => _MissionConfirmModalState();
}

class _MissionConfirmModalState extends State<MissionConfirmModal> {
  bool _agreeToShare = false;
  bool _hideUsername = false;

  void _onConfirm() {
    Get.back(
      result: MissionConfirmResult(
        confirmed: true,
        hideUsername: _hideUsername,
      ),
    );
  }

  void _onCancel() {
    Get.back(
      result: MissionConfirmResult(
        confirmed: false,
        hideUsername: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot image
            Image.asset(
              AppAssets.images.mission,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Title/Description
            Text(
              'Temukan dan foto area duduk favoritmu yang paling nyaman di tempat ini!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox 1 - Agree to share
            _buildCheckboxItem(
              value: _agreeToShare,
              onChanged: (value) =>
                  setState(() => _agreeToShare = value ?? false),
              text:
                  'Dengan mengunggah foto, Anda setuju bahwa foto tersebut akan ditampilkan di halaman aplikasi',
            ),
            const SizedBox(height: 12),

            // Checkbox 2 - Hide username
            _buildCheckboxItem(
              value: _hideUsername,
              onChanged: (value) =>
                  setState(() => _hideUsername = value ?? false),
              text: 'Sembunyikan username',
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _agreeToShare ? _onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      disabledBackgroundColor: AppColors.primary.withAlpha(50),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: AppColors.border, width: 1.5),
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
