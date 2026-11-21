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
import 'package:account_book/controllers/settings_controller.dart';
import 'package:account_book/controllers/transaction_controller.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/utils/phone_number_helper.dart';
import 'package:account_book/views/auth/auth_view.dart';
import 'package:account_book/views/customer_details/customer_details_view.dart';
import 'package:account_book/views/settings/settings_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      'currency': 'YER',
      'language': 'ar',
    });

    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(MerchantShortageController());
    Get.put(InvoiceController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Currency Setting Reactive Updates Tests', () {
    testWidgets('SettingsView updates default currency immediately when changed in settings', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final sc = Get.find<SettingsController>();
      final dc = Get.find<DashboardController>();

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: const SettingsView(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially currency is YER
      expect(find.text('YER'), findsWidgets);
      expect(sc.currentCurrency.value, equals('YER'));
      expect(dc.selectedCurrency.value, equals('YER'));

      // Change currency to SAR
      sc.setCurrency('SAR');
      await tester.pumpAndSettle();

      // Verify immediate reactive update in Settings UI without restart
      expect(find.text('SAR'), findsWidgets);
      expect(sc.currentCurrency.value, equals('SAR'));
      expect(dc.selectedCurrency.value, equals('SAR'));

      // Change currency to USD
      sc.setCurrency('USD');
      await tester.pumpAndSettle();

      // Verify immediate reactive update in Settings UI without restart
      expect(find.text('USD'), findsWidgets);
      expect(sc.currentCurrency.value, equals('USD'));
      expect(dc.selectedCurrency.value, equals('USD'));
    });
  });

  group('Continue As Guest Tests', () {
    testWidgets('Clicking Continue as Guest activates guest mode and pops back if canPop', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      final ac = Get.find<AuthController>();
      ac.isGuestMode.value = false;

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () => Get.to(() => const AuthView()),
                child: const Text('Open Auth'),
              );
            }),
          ),
        ),
      );
      await tester.pump();

      // Open AuthView
      await tester.tap(find.text('Open Auth'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AuthView), findsOneWidget);

      // Find "المتابعة كضيف" (continue_as_guest)
      final guestBtn = find.text('continue_as_guest'.tr);
      expect(guestBtn, findsOneWidget);

      await tester.tap(guestBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify guest mode is active
      expect(ac.isGuestMode.value, isTrue);

      // Verify user was returned back to previous screen
      expect(find.byType(AuthView), findsNothing);
      expect(find.text('Open Auth'), findsOneWidget);
    });
  });

  group('Phone Number BiDi Display Tests (SAR & USD)', () {
    test('PhoneNumberHelper.bidiSafe protects international numbers starting with +', () {
      // Saudi Arabia (+966)
      const saudiPhone = '+966501234567';
      final bidiSaudi = PhoneNumberHelper.bidiSafe(saudiPhone);
      expect(bidiSaudi, equals('\u202A+966501234567\u202C'));

      // Saudi Arabia with spaces
      const saudiPhoneSpaced = '+966 50 123 4567';
      final bidiSaudiSpaced = PhoneNumberHelper.bidiSafe(saudiPhoneSpaced);
      expect(bidiSaudiSpaced, equals('\u202A+966 50 123 4567\u202C'));

      // United States (+1)
      const usPhone = '+15551234567';
      final bidiUs = PhoneNumberHelper.bidiSafe(usPhone);
      expect(bidiUs, equals('\u202A+15551234567\u202C'));

      // United States formatted
      const usPhoneFormatted = '+1 (555) 123-4567';
      final bidiUsFormatted = PhoneNumberHelper.bidiSafe(usPhoneFormatted);
      expect(bidiUsFormatted, equals('\u202A+1 (555) 123-4567\u202C'));

      // Plain digits without + or symbols
      const plainDigits = '777123456';
      expect(PhoneNumberHelper.bidiSafe(plainDigits), equals('777123456'));
    });

    testWidgets('CustomerDetailsView displays SAR phone with LTR text direction and safe bidi embedding', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final customer = Customer(
        name: 'سالم الدوسري',
        phoneNumber: '+966501234567',
        whatsappNumber: '+966501234567',
        currencyCode: 'SAR',
      )..id = 101;

      final cc = Get.find<CustomerController>();
      cc.customers.assignAll([customer]);

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: CustomerDetailsView(customerId: customer.id),
        ),
      );
      await tester.pumpAndSettle();

      // Find the phone Text widget in CustomerDetailsView
      final phoneFinder = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.data != null) {
          return widget.data!.contains('+966501234567') && widget.textDirection == TextDirection.ltr;
        }
        return false;
      });

      expect(phoneFinder, findsWidgets);
    });

    testWidgets('CustomerDetailsView displays USD phone with LTR text direction and safe bidi embedding', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));

      final customer = Customer(
        name: 'John Smith',
        phoneNumber: '+1 (555) 123-4567',
        currencyCode: 'USD',
      )..id = 102;

      final cc = Get.find<CustomerController>();
      cc.customers.assignAll([customer]);

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: CustomerDetailsView(customerId: customer.id),
        ),
      );
      await tester.pumpAndSettle();

      // Find the phone Text widget in CustomerDetailsView
      final phoneFinder = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.data != null) {
          return widget.data!.contains('+1 (555) 123-4567') && widget.textDirection == TextDirection.ltr;
        }
        return false;
      });

      expect(phoneFinder, findsWidgets);
    });
  });
}
