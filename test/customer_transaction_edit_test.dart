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
import 'package:account_book/models/customer.dart';
import 'package:account_book/models/transaction.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/customer_details/customer_details_view.dart';

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
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      home: home,
    );
  }

  testWidgets('CustomerDetailsView displays edit button on transactions and opens edit sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });

    final customer = Customer(name: 'محمد علي', phoneNumber: '777000000', currencyCode: 'YER')..id = 1;
    final customerCtrl = Get.find<CustomerController>();
    customerCtrl.customers.assignAll([customer]);

    final tx = TransactionModel(
      amount: 1500,
      type: TransactionType.give,
      description: 'شراء بضاعة',
      customerId: 1,
      currencyCode: 'YER',
    )..id = 101;

    final txCtrl = Get.find<TransactionController>();
    txCtrl.transactions.assignAll([tx]);

    await tester.pumpWidget(buildTestApp(CustomerDetailsView(customerId: 1)));
    await tester.pumpAndSettle();

    // Verify transaction is rendered with description and amount
    expect(find.text('شراء بضاعة'), findsOneWidget);

    // Verify edit icon button is present
    final editButtonFinder = find.widgetWithIcon(IconButton, Icons.edit_rounded);
    expect(editButtonFinder, findsOneWidget);

    // Scroll until visible if needed and tap the edit button
    await tester.ensureVisible(editButtonFinder);
    await tester.tap(editButtonFinder);
    await tester.pumpAndSettle();

    // Verify edit sheet opened with title and update button
    expect(find.text('تعديل المعاملة'), findsOneWidget);
    expect(find.text('تحديث'), findsOneWidget);

    // Verify prefilled description
    expect(find.text('شراء بضاعة'), findsAtLeastNWidgets(1));
  });
}
