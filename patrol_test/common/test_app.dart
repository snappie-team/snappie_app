import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/core/constants/app_theme.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/core/errors/auth_result.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import 'package:snappie_app/firebase_options.dart';

import '../mocks/mock_repositories.dart';
import '../mocks/mock_services.dart';

Future<void> initTestApp({
  required dynamic $,
  String? initialRoute,
  bool isLoggedIn = true,
  AuthResult? loginResult,
  String? registerError,
}) async {
  Get.testMode = true;
  await _ensureFirebaseInitialized();
  await _ensureEnvInitialized();
  await EasyLocalization.ensureInitialized();
  Get.reset();

  registerMockCoreServices(
    isLoggedIn: isLoggedIn,
    loginResult: loginResult,
    registerError: registerError,
  );
  registerMockRepositories();

  final route =
      initialRoute ?? (isLoggedIn ? AppPages.MAIN : AppPages.ONBOARDING);

  await $.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('id'), Locale('en')],
      path: 'assets/translations',
      startLocale: const Locale('id'),
      fallbackLocale: const Locale('id'),
      useOnlyLangCode: true,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: 'Snappie App Test',
            initialRoute: route,
            getPages: AppPages.routes,
            scaffoldMessengerKey: AppSnackbar.messengerKey,
            unknownRoute: GetPage(
              name: '/not-found',
              page: () => const SizedBox.shrink(),
            ),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    ),
  );

  // Hindari timeout pada pumpAndSettle akibat animasi/timer yang tidak idle.
  await $.pump();
  await $.pump(const Duration(milliseconds: 300));
  await $.pump(const Duration(milliseconds: 700));
}

Future<void> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> _ensureEnvInitialized() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    dotenv.testLoad(
      fileInput: '''
ENVIRONMENT=development
API_VERSION=/api/v1
APP_VERSION=1.0.0
APP_VERSION_CODE=1
REGISTRATION_API_KEY=test-registration-key
LOCAL_BASE_URL=http://127.0.0.1:8000
HOST_BASE_URL=https://example.com
''',
    );
  }
}
