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
import 'package:account_book/views/add_transaction/add_transaction_view.dart';

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

  testWidgets('AddTransactionView provides customer search and filtering in both give and got modes', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });

    final c1 = Customer(name: 'علي أحمد', phoneNumber: '777111222', currencyCode: 'YER')..id = 1;
    final c2 = Customer(name: 'خالد حسن', phoneNumber: '777333444', currencyCode: 'SAR')..id = 2;
    final customerCtrl = Get.find<CustomerController>();
    customerCtrl.customers.assignAll([c1, c2]);

    // Test Give (دفع)
    await tester.pumpWidget(buildTestApp(const AddTransactionView(initialType: TransactionType.give)));
    await tester.pumpAndSettle();

    // Verify initial hint in customer selector
    expect(find.text('بحث عن عميل بالاسم أو الهاتف...'), findsOneWidget);

    // Tap customer selector to open search bottom sheet
    await tester.tap(find.text('بحث عن عميل بالاسم أو الهاتف...'));
    await tester.pumpAndSettle();

    // Verify bottom sheet title and both customers are visible
    expect(find.text('اختيار العميل'), findsOneWidget);
    expect(find.text('علي أحمد'), findsOneWidget);
    expect(find.text('خالد حسن'), findsOneWidget);

    // Type in search field to filter
    final searchFieldFinder = find.widgetWithText(TextField, 'بحث عن عميل بالاسم أو الهاتف...');
    await tester.enterText(searchFieldFinder, 'علي');
    await tester.pumpAndSettle();

    // 'علي أحمد' should remain, 'خالد حسن' should be filtered out
    expect(find.text('علي أحمد'), findsOneWidget);
    expect(find.text('خالد حسن'), findsNothing);

    // Select 'علي أحمد'
    await tester.tap(find.text('علي أحمد'));
    await tester.pumpAndSettle();

    // Verify customer is selected and displayed in the main form
    expect(find.text('علي أحمد'), findsOneWidget);
    expect(find.text('777111222'), findsOneWidget);

    // Clear selected customer
    final clearBtnFinder = find.byIcon(Icons.clear_rounded);
    expect(clearBtnFinder, findsOneWidget);
    await tester.tap(clearBtnFinder);
    await tester.pumpAndSettle();
    expect(find.text('بحث عن عميل بالاسم أو الهاتف...'), findsOneWidget);

    // Re-open and search by phone number in Got (قبض) mode
    await tester.pumpWidget(buildTestApp(const AddTransactionView(initialType: TransactionType.got)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('بحث عن عميل بالاسم أو الهاتف...'));
    await tester.pumpAndSettle();

    final searchFieldFinder2 = find.widgetWithText(TextField, 'بحث عن عميل بالاسم أو الهاتف...');
    await tester.enterText(searchFieldFinder2, '333444');
    await tester.pumpAndSettle();

    expect(find.text('خالد حسن'), findsOneWidget);
    expect(find.text('علي أحمد'), findsNothing);

    await tester.tap(find.text('خالد حسن'));
    await tester.pumpAndSettle();

    expect(find.text('خالد حسن'), findsOneWidget);
    expect(find.text('777333444'), findsOneWidget);
  });
}
