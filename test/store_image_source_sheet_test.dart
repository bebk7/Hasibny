import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:account_book/controllers/auth_controller.dart';
import 'package:account_book/controllers/customer_controller.dart';
import 'package:account_book/controllers/dashboard_controller.dart';
import 'package:account_book/controllers/invoice_controller.dart';
import 'package:account_book/controllers/lock_controller.dart';
import 'package:account_book/controllers/merchant_controller.dart';
import 'package:account_book/controllers/merchant_shortage_controller.dart';
import 'package:account_book/controllers/onboarding_controller.dart';
import 'package:account_book/controllers/settings_controller.dart';
import 'package:account_book/controllers/transaction_controller.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/settings/store_profile_view.dart';
import 'package:account_book/views/onboarding/create_store_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});

    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(MerchantShortageController());
    Get.put(InvoiceController());
    Get.put(OnboardingController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Store Image Source Sheet Zero-Overflow Tests', () {
    testWidgets('StoreProfileView image source sheet renders on compact screen without overflow', (tester) async {
      // Test on ultra-compact screen (320x568) with 1.3x text scale
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.3),
          ),
          child: GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('ar'),
            home: const StoreProfileView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the logo picker avatar
      final avatarFinder = find.byType(GestureDetector).first;
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // Verify the bottom sheet opened
      expect(find.text('select_image_source'.tr), findsOneWidget);
      expect(find.text('camera'.tr), findsOneWidget);
      expect(find.text('gallery'.tr), findsOneWidget);

      // Verify zero overflow exceptions
      expect(tester.takeException(), isNull);

      // Tap camera or gallery option to dismiss
      await tester.tap(find.text('camera'.tr));
      await tester.pumpAndSettle();
    });

    testWidgets('CreateStoreView image source sheet renders on compact screen without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.3),
          ),
          child: GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('ar'),
            home: const CreateStoreView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on logo placeholder
      final logoFinder = find.text('store_logo_label'.tr);
      expect(logoFinder, findsOneWidget);
      await tester.tap(logoFinder);
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('اختيار شعار المتجر'), findsOneWidget);
      expect(find.text('gallery'.tr), findsOneWidget);
      expect(find.text('camera'.tr), findsOneWidget);

      // Verify zero overflow exceptions
      expect(tester.takeException(), isNull);

      // Dismiss
      await tester.tap(find.text('camera'.tr));
      await tester.pumpAndSettle();
    });
  });
}
