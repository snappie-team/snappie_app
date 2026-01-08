import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';

/// Language Switcher Widget
/// 
/// Example usage in settings page:
/// ```dart
/// LanguageSwitcherWidget()
/// ```
class LanguageSwitcherWidget extends StatelessWidget {
  const LanguageSwitcherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildLanguageButton(
                context,
                'ID',
                'id',
                Icons.flag,
              ),
              const SizedBox(width: 8),
              _buildLanguageButton(
                context,
                'EN',
                'en',
                Icons.flag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String label,
    String languageCode,
    IconData icon,
  ) {
    final isSelected = context.locale.languageCode == languageCode;

    return GestureDetector(
      onTap: () async {
        final newLocale = Locale(languageCode);
        await context.setLocale(newLocale);
        Get.updateLocale(newLocale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Language Dropdown
/// 
/// Example usage:
/// ```dart
/// LanguageDropdown()
/// ```
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;

    return DropdownButton<String>(
      value: currentLocale,
      icon: const Icon(Icons.language),
      underline: Container(),
      items: const [
        DropdownMenuItem(
          value: 'id',
          child: Text('🇮🇩 Bahasa Indonesia'),
        ),
        DropdownMenuItem(
          value: 'en',
          child: Text('🇬🇧 English'),
        ),
      ],
      onChanged: (String? languageCode) async {
        if (languageCode != null) {
          final newLocale = Locale(languageCode);
          await context.setLocale(newLocale);
          Get.updateLocale(newLocale);
        }
      },
    );
  }
}
