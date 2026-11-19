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
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/settings/store_profile_view.dart';
import 'package:account_book/views/add_customer/add_customer_view.dart';
import 'package:account_book/views/merchants/add_merchant_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({
      'store_name': 'متجر الاختبار',
      'store_phone': '+967771234567',
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

  group('Store Profile & Phone Input BiDi LTR Tests', () {
    testWidgets('StoreProfileView phone field has textDirection LTR and right alignment in Arabic', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: const StoreProfileView(),
        ),
      );
      await tester.pumpAndSettle();

      // Find phone text field by icon
      final phoneFieldFinder = find.widgetWithIcon(TextFormField, Icons.phone_rounded);
      expect(phoneFieldFinder, findsOneWidget);

      final editableTexts = tester.widgetList<EditableText>(find.byType(EditableText));
      // Second field in the form is phone (after store name)
      final phoneEditable = editableTexts.firstWhere(
        (e) => e.controller.text == '+967771234567',
      );
      expect(phoneEditable.textDirection, equals(TextDirection.ltr));
      expect(phoneEditable.textAlign, equals(TextAlign.right));

      // Type new phone number with + and verify it updates properly
      await tester.enterText(phoneFieldFinder, '+967 777 000 111');
      await tester.pumpAndSettle();

      final updatedEditable = tester.widgetList<EditableText>(find.byType(EditableText)).firstWhere(
        (e) => e.controller.text == '+967 777 000 111',
      );
      expect(updatedEditable.textDirection, equals(TextDirection.ltr));
      expect(updatedEditable.controller.text, equals('+967 777 000 111'));

      // Type Arabic-Indic digits with + and verify conversion to Latin ASCII digits
      await tester.enterText(phoneFieldFinder, '+٩٦٧٧٧١٢٣٤٥٦٧');
      await tester.pumpAndSettle();

      final convertedEditable = tester.widgetList<EditableText>(find.byType(EditableText)).firstWhere(
        (e) => e.controller.text == '+967771234567',
      );
      expect(convertedEditable.controller.text, equals('+967771234567'));
    });

    testWidgets('AddCustomerView phone fields have textDirection LTR', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: const AddCustomerView(),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to find phone input
      final phoneFinder = find.widgetWithIcon(TextFormField, Icons.phone_outlined);
      expect(phoneFinder, findsOneWidget);

      await tester.enterText(phoneFinder, '+967770000000');
      await tester.pumpAndSettle();

      final phoneEditable = tester.widgetList<EditableText>(find.byType(EditableText)).firstWhere(
        (e) => e.controller.text == '+967770000000',
      );
      expect(phoneEditable.textDirection, equals(TextDirection.ltr));
      expect(phoneEditable.textAlign, equals(TextAlign.right));
    });

    testWidgets('AddMerchantView phone field has textDirection LTR', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: const AddMerchantView(),
        ),
      );
      await tester.pumpAndSettle();

      final phoneFinder = find.widgetWithIcon(TextFormField, Icons.phone_rounded);
      expect(phoneFinder, findsOneWidget);

      await tester.enterText(phoneFinder, '+967771122334');
      await tester.pumpAndSettle();

      final phoneEditable = tester.widgetList<EditableText>(find.byType(EditableText)).firstWhere(
        (e) => e.controller.text == '+967771122334',
      );
      expect(phoneEditable.textDirection, equals(TextDirection.ltr));
      expect(phoneEditable.textAlign, equals(TextAlign.right));
    });
  });
}
