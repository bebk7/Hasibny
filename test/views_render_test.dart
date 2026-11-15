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

import 'package:account_book/views/dashboard/dashboard_view.dart';
import 'package:account_book/views/settings/settings_view.dart';
import 'package:account_book/views/transactions/transactions_view.dart';
import 'package:account_book/views/merchants/merchants_view.dart';
import 'package:account_book/views/merchants/merchant_shortages_view.dart';
import 'package:account_book/views/merchants/product_search_view.dart';
import 'package:account_book/views/settings/store_profile_view.dart';

void main() {
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

  Widget buildTestApp(Widget home) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('ar', 'SA'),
      home: home,
    );
  }

  group('Full Screen Views Zero-Crash Rendering Tests', () {
    testWidgets('SettingsView renders all sections and tiles cleanly without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SettingsView), findsOneWidget);
      // Verify key setting sections exist
      expect(find.text('app_settings'.tr), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
      expect(find.text('data_management'.tr), findsOneWidget);
    });

    testWidgets('StoreProfileView renders cleanly without unbounded error', (tester) async {
      await tester.pumpWidget(buildTestApp(const StoreProfileView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(StoreProfileView), findsOneWidget);
    });

    testWidgets('TransactionsView renders with filters and summary without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const TransactionsView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(TransactionsView), findsOneWidget);
    });

    testWidgets('MerchantsView renders search and list cleanly without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const MerchantsView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(MerchantsView), findsOneWidget);
    });

    testWidgets('MerchantShortagesView renders summary and list cleanly without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const MerchantShortagesView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(MerchantShortagesView), findsOneWidget);
    });

    testWidgets('ProductSearchView renders input and search area without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const ProductSearchView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ProductSearchView), findsOneWidget);
    });

    testWidgets('DashboardView renders overview and quick actions without error', (tester) async {
      await tester.pumpWidget(buildTestApp(const DashboardView()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardView), findsOneWidget);
    });
  });
}
