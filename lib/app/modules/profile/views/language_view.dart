import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_keys.g.dart';

/// Language selection page with simple radio options and a save button.
class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String _selected = 'id'; // Default value
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe to access context.locale here
    _selected = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: tr(LocaleKeys.language_title),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _buildOption(
                value: 'id',
                label: tr(LocaleKeys.language_indonesian),
              ),
              const SizedBox(height: 12),
              _buildOption(
                value: 'en',
                label: tr(LocaleKeys.language_english),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          tr(LocaleKeys.language_save),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    )]);
  }

  Widget _buildOption({required String value, required String label}) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selected,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _selected = val ?? value),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    
    // Switch locale
    await context.setLocale(Locale(_selected));
    
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    setState(() => _saving = false);
    
    Get.snackbar(
      tr(LocaleKeys.language_success_title),
      tr(LocaleKeys.language_success_message),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    // Optional: Navigate back after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Get.back();
    });
  }
}
