import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'auth_test_helpers.dart';

void main() {
  patrolTest(
    'UC1.4 - Registrasi sukses lanjut ke main',
    ($) async {
      await initAtRegister($);
      await fillRegisterStep1($);

      await $(#food_type_0).tap();
      await $(#food_type_1).tap();
      await $(#food_type_2).tap();
      await $.tester.ensureVisible(find.byKey(const Key('register_next_button')));
      await pumpAuthUi($);
      await $(#register_next_button).tap();
      await pumpAuthUi($);

      await $(#place_value_0).tap();
      await $(#place_value_1).tap();
      await $(#place_value_2).tap();
      await $.tester.ensureVisible(find.byKey(const Key('register_submit_button')));
      await pumpAuthUi($);
      await $(#register_submit_button).tap();
      await $.pump(const Duration(seconds: 3));
      await pumpAuthUi($, milliseconds: 1000);

      expect($(#bottom_nav_home), findsOneWidget);
      expect($(#bottom_nav_profile), findsOneWidget);
    },
  );

  patrolTest(
    'UC1.5 - Registrasi tidak bisa lanjut jika food types kurang dari 3',
    ($) async {
      await initAtRegister($);
      await fillRegisterStep1($);

      await $(#food_type_0).tap();
      await $(#food_type_1).tap();
      await pumpAuthUi($);

      expect($(#register_next_button), findsOneWidget);
      expect($(#place_value_0), findsNothing);
    },
  );
}
