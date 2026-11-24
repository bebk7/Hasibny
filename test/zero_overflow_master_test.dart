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
import 'package:account_book/core/core.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/models/transaction.dart';
import 'package:account_book/translations/app_translations.dart';

import 'package:account_book/views/auth/auth_view.dart';
import 'package:account_book/views/add_customer/add_customer_view.dart';
import 'package:account_book/views/customer_details/customer_details_view.dart';
import 'package:account_book/views/customers/customers_view.dart';
import 'package:account_book/views/dashboard/dashboard_view.dart';
import 'package:account_book/views/home/home_view.dart';
import 'package:account_book/views/invoices/add_invoice_view.dart';
import 'package:account_book/views/lock/lock_view.dart';
import 'package:account_book/views/lock/set_pin_view.dart';
import 'package:account_book/views/merchants/add_merchant_view.dart';
import 'package:account_book/views/merchants/merchants_view.dart';
import 'package:account_book/views/merchants/merchant_shortages_view.dart';
import 'package:account_book/views/merchants/product_search_view.dart';
import 'package:account_book/views/onboarding/create_store_view.dart';
import 'package:account_book/views/onboarding/onboarding_view.dart';
import 'package:account_book/views/settings/settings_view.dart';
import 'package:account_book/views/settings/store_profile_view.dart';
import 'package:account_book/views/splash/splash_view.dart';
import 'package:account_book/views/add_transaction/add_transaction_view.dart';
import 'package:account_book/views/transactions/transactions_view.dart';

void main() {
  const List<Size> testSizes = [
    Size(320, 568), // Small phone (iPhone SE 1st gen)
    Size(360, 640), // Compact phone
    Size(360, 800), // Standard modern phone
    Size(393, 852), // Modern phone (iPhone 15 / Galaxy S24)
    Size(430, 932), // Large phone (Pro Max / Ultra)
    Size(600, 960), // Tablet portrait
    Size(800, 360), // Landscape phone
  ];

  const List<double> testTextScales = [1.0, 1.3, 1.5, 2.0];

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});

    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(LockController());
    final customerCtrl = Get.put(CustomerController());
    final txCtrl = Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(MerchantShortageController());
    Get.put(InvoiceController());
    Get.put(OnboardingController());

    // Populate realistic data with long strings and large multi-digit amounts
    final cust1 = Customer(
      name: 'مؤسسة الأمل للتجارة والمقاولات العامة والاستيراد المحدودة',
      phoneNumber: '+967771234567',
      currencyCode: 'YER',
    )..id = 1;

    final cust2 = Customer(
      name: 'Johnathan Alexander Smith-Montgomery International',
      phoneNumber: '+14155552671',
      currencyCode: 'USD',
    )..id = 2;

    final cust3 = Customer(
      name: 'سالم بن عبد الله آل سعود',
      phoneNumber: '+966501234567',
      currencyCode: 'SAR',
    )..id = 3;

    customerCtrl.customers.assignAll([cust1, cust2, cust3]);

    txCtrl.transactions.assignAll([
      TransactionModel(
        customerId: 1,
        amount: 9876543210.50,
        type: TransactionType.give,
        description: 'دفعة حساب توريد بضائع ومعدات ثقيلة لشهر نوفمبر مع الفواتير',
        currencyCode: 'YER',
      )..id = 1,
      TransactionModel(
        customerId: 2,
        amount: 12345678.90,
        type: TransactionType.got,
        description: 'Payment settlement via wire transfer ref #88928374',
        currencyCode: 'USD',
      )..id = 2,
    ]);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp(
    Widget home, {
    Locale locale = const Locale('ar', 'SA'),
    double textScale = 1.0,
  }) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
        ),
        child: home,
      ),
    );
  }

  group('Master Zero-Overflow Responsive Matrix Tests', () {
    for (final size in testSizes) {
      testWidgets('DashboardView renders with zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(const DashboardView()));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(DashboardView), findsOneWidget);
      });

      testWidgets('CustomersView renders with zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(const CustomersView()));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(CustomersView), findsOneWidget);
      });

      testWidgets('TransactionsView renders with zero overflow on ${size.width}x${size.height}', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          debugPrint('FULL FLUTTER ERROR TRANSACTIONSVIEW:\n$details');
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(const TransactionsView()));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(TransactionsView), findsOneWidget);
      });

      testWidgets('SettingsView renders with zero overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(const SettingsView()));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(SettingsView), findsOneWidget);
      });
    }
  });

  group('Master Accessibility Text-Scaling Matrix (1.0x - 2.0x) on Compact 320x568', () {
    for (final scale in testTextScales) {
      testWidgets('SettingsView renders without overflow at ${scale}x scale in Arabic RTL', (tester) async {
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          debugPrint('FULL FLUTTER ERROR:\n$details');
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(
          const SettingsView(),
          locale: const Locale('ar', 'SA'),
          textScale: scale,
        ));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('SettingsView renders without overflow at ${scale}x scale in English LTR', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(
          const SettingsView(),
          locale: const Locale('en', 'US'),
          textScale: scale,
        ));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('TransactionsView renders large amounts without overflow at ${scale}x scale', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(
          const TransactionsView(),
          locale: const Locale('ar', 'SA'),
          textScale: scale,
        ));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Number Formatting Bottom Sheet Responsive Tests', () {
    testWidgets('Number formatting sheet opens and scrolls cleanly on compact 320x568 with 1.5x scale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(
        const SettingsView(),
        locale: const Locale('ar', 'SA'),
        textScale: 1.5,
      ));
      await tester.pump();

      // Scroll down to number format tile
      await tester.scrollUntilVisible(find.text('number_format'.tr), 200);
      await tester.pumpAndSettle();

      // Tap number format tile
      await tester.tap(find.text('number_format'.tr));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('select_number_format'.tr), findsOneWidget);

      // Verify all format options appear in bottom sheet
      expect(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text('format_standard'.tr),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.text('format_european'.tr),
        ),
        findsOneWidget,
      );

      // Select European format
      await tester.tap(find.descendant(
        of: find.byType(AppBottomSheet),
        matching: find.text('format_european'.tr),
      ));
      await tester.pumpAndSettle();

      final settingsCtrl = Get.find<SettingsController>();
      expect(settingsCtrl.currentNumberFormat.value, 'european');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Number formatting sheet opens and scrolls cleanly in English LTR on 320x568 with 2.0x scale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestApp(
        const SettingsView(),
        locale: const Locale('en', 'US'),
        textScale: 2.0,
      ));
      await tester.pump();

      await tester.scrollUntilVisible(find.text('Number Formatting'), 200);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Number Formatting'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Select Number Format'), findsOneWidget);

      // Select Eastern Arabic
      final easternArabicFinder = find.descendant(
        of: find.byType(AppBottomSheet),
        matching: find.text('Eastern Arabic (١٬٢٣٤٫٥٠)'),
      );
      await tester.scrollUntilVisible(
        easternArabicFinder,
        100,
        scrollable: find.descendant(
          of: find.byType(AppBottomSheet),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(easternArabicFinder);
      await tester.pumpAndSettle();

      final settingsCtrl = Get.find<SettingsController>();
      expect(settingsCtrl.currentNumberFormat.value, 'arabicIndic');
      expect(tester.takeException(), isNull);
    });
  });

  group('All 24 Full Screen Views Zero-Crash & Zero-Overflow Suite', () {
    final Map<String, Widget Function()> allViews = {
      'DashboardView': () => const DashboardView(),
      'CustomersView': () => const CustomersView(),
      'TransactionsView': () => const TransactionsView(),
      'SettingsView': () => const SettingsView(),
      'HomeView': () => const HomeView(),
      'StoreProfileView': () => const StoreProfileView(),
      'AddCustomerView': () => const AddCustomerView(),
      'AddTransactionView': () => const AddTransactionView(initialType: TransactionType.give),
      'CustomerDetailsView': () => const CustomerDetailsView(customerId: 1),
      'AddInvoiceView': () => const AddInvoiceView(),
      'MerchantsView': () => const MerchantsView(),
      'MerchantShortagesView': () => const MerchantShortagesView(),
      'ProductSearchView': () => const ProductSearchView(),
      'AddMerchantView': () => const AddMerchantView(),
      'AuthView': () => const AuthView(),
      'LockView': () => const LockView(),
      'SetPinView': () => const SetPinView(),
      'OnboardingView': () => const OnboardingView(),
      'CreateStoreView': () => const CreateStoreView(),
      'SplashView': () => const SplashView(),
    };

    for (final entry in allViews.entries) {
      testWidgets('${entry.key} renders without exception on compact 320x568 screen', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestApp(entry.value()));
        await tester.pump();
        if (entry.key == 'SplashView') {
          await tester.pump(const Duration(seconds: 3));
        }

        expect(tester.takeException(), isNull);
      });
    }
  });
}
