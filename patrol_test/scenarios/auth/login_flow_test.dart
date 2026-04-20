import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/core/errors/auth_result.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import 'auth_test_helpers.dart';

void main() {
  patrolTest(
    'UC1.1 - Onboarding sampai login page',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.ONBOARDING,
        isLoggedIn: false,
      );

      await $(#onboarding_next_button).tap();
      await pumpAuthUi($);
      await $(#onboarding_next_button).tap();
      await pumpAuthUi($);
      await $(#onboarding_start_button).tap();
      await pumpAuthUi($);

      expect($(#login_google_button), findsOneWidget);
    },
  );

  patrolTest(
    'UC1.2 - Login Google sukses ke main',
    ($) async {
      await initAtLogin($, loginResult: AuthResult.ok());

      await $(#login_google_button).tap();
      await pumpAuthUi($, milliseconds: 900);

      expect($(#bottom_nav_home), findsOneWidget);
      expect($(#bottom_nav_profile), findsOneWidget);
    },
  );

  patrolTest(
    'UC1.3 - Login user baru diarahkan ke register',
    ($) async {
      await initAtLogin(
        $,
        loginResult: AuthResult.fail(AuthErrorType.userNotFound),
      );

      await $(#login_google_button).tap();
      await pumpAuthUi($, milliseconds: 900);

      expect($(#register_firstname_field), findsOneWidget);
      expect($(#register_username_field), findsOneWidget);
    },
  );

  patrolTest(
    'UC1.6 - Login dibatalkan tetap di halaman login',
    ($) async {
      await initAtLogin(
        $,
        loginResult: AuthResult.fail(
          AuthErrorType.unknown,
          message: 'Google Sign In was cancelled',
        ),
      );

      await $(#login_google_button).tap();
      await pumpAuthUi($, milliseconds: 900);

      expect($(#login_google_button), findsOneWidget);
      expect($(#bottom_nav_home), findsNothing);
    },
  );

  patrolTest(
    'UC1.7 - Login has active session tampil pesan',
    ($) async {
      await initAtLogin(
        $,
        loginResult: AuthResult.fail(
          AuthErrorType.hasActiveSession,
          message: 'Masih ada sesi aktif. Silakan coba lagi.',
        ),
      );

      await $(#login_google_button).tap();
      await pumpAuthUi($, milliseconds: 900);

      expect($('Session Active'), findsOneWidget);
    },
  );

  patrolTest(
    'UC1.8 - Auto login masuk ke main',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      expect($(#bottom_nav_home), findsOneWidget);
      expect($(#bottom_nav_profile), findsOneWidget);
    },
  );
}
