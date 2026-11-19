import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:account_book/controllers/auth_controller.dart';
import 'package:account_book/controllers/customer_controller.dart';
import 'package:account_book/controllers/dashboard_controller.dart';
import 'package:account_book/controllers/lock_controller.dart';
import 'package:account_book/controllers/settings_controller.dart';
import 'package:account_book/controllers/transaction_controller.dart';
import 'package:account_book/core/core.dart';
import 'package:account_book/models/customer.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/add_customer/add_customer_view.dart';

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
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestApp(Widget home) {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      home: home,
    );
  }

  group('Edit Customer Exit Immediately Tests', () {
    testWidgets('AddCustomerView exits immediately upon pressing update button when editing customer', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final customer = Customer(
        name: 'أحمد صالح',
        phoneNumber: '777123456',
        currencyCode: 'YER',
      )..id = 1;

      final cc = Get.find<CustomerController>();
      cc.customers.assignAll([customer]);

      // Open a root screen with a button that pushes AddCustomerView
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => Get.to(() => AddCustomerView(customer: customer)),
                  child: const Text('Open Edit'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open AddCustomerView
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Verify we are on AddCustomerView
      expect(find.byType(AddCustomerView), findsOneWidget);
      expect(find.text('edit_customer'.tr), findsOneWidget);

      // Edit the customer name
      final nameField = find.widgetWithText(TextFormField, 'أحمد صالح');
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'أحمد صالح المحدث');
      await tester.pumpAndSettle();

      // Scroll down to update button and tap it
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final updateBtn = find.widgetWithText(AppButton, 'update'.tr);
      expect(updateBtn, findsOneWidget);
      await tester.tap(updateBtn);
      await tester.pumpAndSettle();

      // Verify AddCustomerView has exited immediately!
      expect(find.byType(AddCustomerView), findsNothing);
      expect(find.text('Open Edit'), findsOneWidget);
      expect(customer.name, equals('أحمد صالح المحدث'));

      // Let snackbar timer finish
      await tester.pumpAndSettle(const Duration(seconds: 4));
    });
  });
}
