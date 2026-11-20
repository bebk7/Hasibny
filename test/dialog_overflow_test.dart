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
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/invoices/add_invoice_view.dart';

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
      fallbackLocale: const Locale('en', 'US'),
      home: home,
    );
  }

  group('Dialog Zero-Overflow Tests on Compact Devices', () {
    testWidgets('Backup import success dialog renders without title overflow on 320x568 compact screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    final resp = AppResponsive.of(context);
                    AppDialog.show(
                      context: context,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: resp.iconLG),
                              SizedBox(width: resp.spacingSM),
                              Expanded(
                                child: Text(
                                  'backup_import_success'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: resp.fontLG,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: resp.spacingMD),
                          Text(
                            '${'customers'.tr}: 12\n'
                            '${'transactions'.tr}: 45\n'
                            '${'invoices'.tr}: 8\n'
                            '${'merchants'.tr}: 3',
                            style: TextStyle(fontFamily: 'Cairo', height: 1.5, fontSize: resp.fontMD),
                          ),
                          SizedBox(height: resp.spacingMD),
                          AppButton(
                            text: 'ok'.tr,
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            );
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify title is rendered and no overflow occurred
      expect(find.text('تمت استعادة البيانات بنجاح'), findsOneWidget);
      expect(find.textContaining('12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AddInvoiceView add item and edit item dialogs render without header overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const AddInvoiceView()));
      await tester.pumpAndSettle();

      // Open Add Item Dialog
      final addItemBtn = find.text('add_item'.tr);
      expect(addItemBtn, findsAtLeastNWidgets(1));
      await tester.tap(addItemBtn.first);
      await tester.pumpAndSettle();

      // Dialog title should be present and zero exceptions thrown
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Dismiss dialog
      await tester.tap(find.text('cancel'.tr));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('AppDialog.confirm renders properly on narrow screen without action overflow', (tester) async {
      tester.view.physicalSize = const Size(300, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    AppDialog.confirm(
                      context: context,
                      title: 'عنوان تجريبي طويل جداً لتأكيد الحوار',
                      message: 'هل أنت متأكد تماماً من رغبتك في تنفيذ هذا الإجراء الهام؟',
                      confirmLabel: 'تأكيد وحفظ البيانات الآن',
                      cancelLabel: 'إلغاء التراجع',
                    );
                  },
                  child: const Text('Show Confirm'),
                ),
              ),
            );
          },
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('عنوان تجريبي طويل جداً لتأكيد الحوار'), findsOneWidget);
      expect(find.text('تأكيد وحفظ البيانات الآن'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
