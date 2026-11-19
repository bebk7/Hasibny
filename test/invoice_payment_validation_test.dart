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
import 'package:account_book/core/core.dart';
import 'package:account_book/models/invoice.dart';
import 'package:account_book/models/merchant.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/invoices/add_invoice_view.dart';
import 'package:account_book/views/invoices/invoice_detail_view.dart';
import 'package:account_book/widgets/amount_field.dart';

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

  group('Invoice Payment & Remaining Amount Validation Tests', () {
    test('Invoice model clamps remainingAmount to zero when paidAmount is large', () {
      final invoice = Invoice(
        invoiceNumber: 'INV-100',
        totalAmount: 1000.0,
        paidAmount: 1500.0,
        currencyCode: 'YER',
      );

      expect(invoice.remainingAmount, equals(0.0));
      expect(invoice.isFullyPaid, isTrue);
    });

    testWidgets('InvoiceDetailView payment dialog blocks overpayment with notice and allows valid payment', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final merchant = Merchant(name: 'مورد التجارة', phone: '777000000')..id = 1;
      final invoice = Invoice(
        merchantId: 1,
        invoiceNumber: 'INV-TEST-01',
        totalAmount: 1000.0,
        paidAmount: 400.0,
        currencyCode: 'YER',
      );
      invoice.id = 1;

      // Mock merchant controller
      final mc = Get.find<MerchantController>();
      mc.merchants.assignAll([merchant]);

      await tester.pumpWidget(buildTestApp(InvoiceDetailView(invoice: invoice)));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('#INV-TEST-01'), findsAtLeastNWidgets(1));
      expect(invoice.remainingAmount, equals(600.0));

      // Tap on record payment
      final payButton = find.text('record_give'.tr);
      await tester.scrollUntilVisible(payButton, 100);
      expect(payButton, findsOneWidget);
      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // Verify payment dialog opened
      expect(find.byType(AmountField), findsOneWidget);
      expect(find.text('تسديد كامل المتبقي (600 ر.ي)'), findsOneWidget);

      // 1. Enter an amount that exceeds remaining (e.g. 800)
      final amountFieldFinder = find.descendant(
        of: find.byType(AmountField),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(amountFieldFinder, '800');
      await tester.pumpAndSettle();

      // Verify real-time warning notice appears
      expect(find.textContaining('المبلغ المدخل يتجاوز المبلغ المتبقي'), findsOneWidget);

      // Attempt to confirm overpayment
      final confirmButton = find.text('تأكيد');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify dialog is NOT closed and payment is NOT accepted
      expect(find.byType(AmountField), findsOneWidget);
      expect(invoice.paidAmount, equals(400.0)); // Still old amount

      // 2. Now tap the quick "تسديد كامل المتبقي" button
      final payFullButton = find.text('تسديد كامل المتبقي (600 ر.ي)');
      await tester.tap(payFullButton);
      await tester.pumpAndSettle();

      // Warning notice should disappear
      expect(find.textContaining('المبلغ المدخل يتجاوز المبلغ المتبقي'), findsNothing);

      // Confirm valid payment
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify paid amount updated and invoice is fully paid
      expect(invoice.paidAmount, equals(1000.0));
      expect(invoice.remainingAmount, equals(0.0));
      expect(invoice.isFullyPaid, isTrue);
    });

    testWidgets('AddInvoiceView validator flags paid amount exceeding invoice total', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final invoice = Invoice(
        merchantId: 1,
        invoiceNumber: 'INV-TEST-02',
        totalAmount: 500.0,
        paidAmount: 200.0,
        currencyCode: 'YER',
      );
      invoice.id = 2;
      invoice.items = [
        InvoiceItem(name: 'سكر', quantity: 1, unitPrice: 500.0),
      ];

      await tester.pumpWidget(buildTestApp(AddInvoiceView(invoice: invoice)));
      await tester.pumpAndSettle();

      // Find paid amount field
      final paidFieldFinder = find.byType(AmountField);
      expect(paidFieldFinder, findsOneWidget);

      final textFieldFinder = find.descendant(
        of: paidFieldFinder,
        matching: find.byType(TextFormField),
      );

      // Enter 800 when total is 500
      await tester.enterText(textFieldFinder, '800');
      await tester.pumpAndSettle();

      // Scroll down and tap save button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final saveBtn = find.widgetWithText(AppButton, 'save'.tr).last;
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Validator error should appear
      expect(find.text('paid_amount_cannot_exceed_total'.tr), findsOneWidget);
    });
  });
}
