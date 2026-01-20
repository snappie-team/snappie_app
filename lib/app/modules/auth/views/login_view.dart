import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/localization/locale_keys.g.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthController controller;
  String _currentLocale = 'id';

  @override
  void initState() {
    super.initState();
    controller = Get.find<AuthController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: ValueKey(_currentLocale), // Force rebuild when locale changes
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.images.onboarding4),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mascot Image
                        Image.asset(
                          AppAssets.images.mascot,
                          width: 200,
                          height: 200,
                        ),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                        // Masuk dengan Google Button
                        Obx(() => ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.loginWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      tr(LocaleKeys.login_sign_in_google),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),

                            const SizedBox(height: 12),

                            // Daftar dengan Google Button
                            Obx(() => OutlinedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : controller.signUpWithGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(
                                  color: Color(0xFFFFA500),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                disabledForegroundColor: Colors.grey.shade400,
                              ),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.grey),
                                      ),
                                    )
                                  : Text(
                                      tr(LocaleKeys.login_sign_up_google),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),

                            const SizedBox(height: 24),

                            // Terms and Conditions Text
                            RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: tr(LocaleKeys.login_terms_prefix),
                              ),
                              TextSpan(
                                text: tr(LocaleKeys.login_terms_link),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(AppPages.TNC);
                                  },
                              ),
                              TextSpan(
                                text: tr(LocaleKeys.login_terms_middle),
                              ),
                              TextSpan(
                                text: tr(LocaleKeys.login_privacy_link),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.toNamed(AppPages.TNC);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
