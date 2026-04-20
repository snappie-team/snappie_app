import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';

Future<void> pumpAuthUi(PatrolIntegrationTester $, {int milliseconds = 700}) async {
  await $.pump();
  await $.pump(Duration(milliseconds: milliseconds));
}

Future<void> initAtLogin(
  PatrolIntegrationTester $, {
  dynamic loginResult,
}) async {
  await initTestApp(
    $: $,
    initialRoute: AppPages.LOGIN,
    isLoggedIn: false,
    loginResult: loginResult,
  );
}

Future<void> initAtRegister(PatrolIntegrationTester $) async {
  await initTestApp(
    $: $,
    initialRoute: AppPages.REGISTER,
    isLoggedIn: false,
  );
}

Future<void> fillRegisterStep1(PatrolIntegrationTester $) async {
  final authController = Get.find<AuthController>();
  authController.registerEmailController.text = 'test@snappie.com';

  await $(#register_firstname_field).enterText('Test');
  await $(#register_lastname_field).enterText('User');
  await $(#register_gender_male).tap();
  await $(#avatar_option_0).tap();
  await $.tester.ensureVisible(find.byKey(const Key('register_username_field')));
  await pumpAuthUi($);
  await $(#register_username_field).enterText('testuser12');
  await $.pump(const Duration(milliseconds: 800));

  await $(#register_next_button).tap();
  await pumpAuthUi($);
}
