import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:account_book/controllers/onboarding_controller.dart';
import 'package:account_book/controllers/settings_controller.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/onboarding/onboarding_view.dart';
import 'package:account_book/views/onboarding/create_store_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
  });

  group('OnboardingController Unit Tests', () {
    test('Fresh installation defaults to not onboarded', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = Get.put(OnboardingController());

      final status = await controller.checkOnboardingStatus();
      expect(status, isFalse);
      expect(controller.isOnboarded.value, isFalse);
    });

    test('Existing installation with store_name automatically marks onboarding completed', () async {
      SharedPreferences.setMockInitialValues({
        'store_name': 'سوبرماركت الأمل',
      });
      final controller = Get.put(OnboardingController());

      final status = await controller.checkOnboardingStatus();
      expect(status, isTrue);
      expect(controller.isOnboarded.value, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingController.keyOnboardingCompleted), isTrue);
    });

    test('Already onboarded installation preserves completed status', () async {
      SharedPreferences.setMockInitialValues({
        OnboardingController.keyOnboardingCompleted: true,
      });
      final controller = Get.put(OnboardingController());

      final status = await controller.checkOnboardingStatus();
      expect(status, isTrue);
      expect(controller.isOnboarded.value, isTrue);
    });

    test('createStore rejects empty store name', () async {
      SharedPreferences.setMockInitialValues({});
      Get.put(SettingsController());
      final controller = Get.put(OnboardingController());

      final result = await controller.createStore(
        name: '   ',
        phone: '771234567',
        countryCode: '+967',
        currencyCode: 'YER',
      );

      expect(result, isFalse);
      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.isOnboarded.value, isFalse);
    });

    test('createStore rejects invalid phone number', () async {
      SharedPreferences.setMockInitialValues({});
      Get.put(SettingsController());
      final controller = Get.put(OnboardingController());

      final result = await controller.createStore(
        name: 'متجر التقنية',
        phone: '123',
        countryCode: '+967',
        currencyCode: 'YER',
      );

      expect(result, isFalse);
      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.isOnboarded.value, isFalse);
    });

    test('createStore succeeds with valid inputs and sets preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = Get.put(SettingsController());
      final controller = Get.put(OnboardingController());
      await Future.delayed(Duration.zero);

      final result = await controller.createStore(
        name: 'مؤسسة السلام التجارية',
        phone: '771234567',
        countryCode: '+967',
        currencyCode: 'YER',
        address: 'صنعاء - شارع حدة',
        notes: 'ملاحظات المتجر التجريبية',
      );

      expect(result, isTrue);
      expect(controller.isOnboarded.value, isTrue);
      expect(settings.storeName.value, 'مؤسسة السلام التجارية');
      expect(settings.storePhone.value, '+967771234567');
      expect(settings.storeAddress.value, 'صنعاء - شارع حدة');
      expect(settings.currentCurrency.value, 'YER');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingController.keyOnboardingCompleted), isTrue);
      expect(prefs.getString(OnboardingController.keyStoreNotes), 'ملاحظات المتجر التجريبية');
      expect(prefs.getString('store_name'), 'مؤسسة السلام التجارية');
      expect(prefs.getString('store_phone'), '+967771234567');
    });
  });

  group('Onboarding Widgets UI Tests', () {
    testWidgets('OnboardingView renders title, description, and both option cards', (tester) async {
      SharedPreferences.setMockInitialValues({});
      Get.put(OnboardingController());

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: const OnboardingView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header title and description
      expect(find.text('مرحباً بك في دفتر الحسابات'), findsOneWidget);
      expect(find.text('إدارة متكاملة لحساباتك وديونك ومتاجرك بكل سهولة وأمان'), findsOneWidget);

      // Check options
      expect(find.text('إنشاء متجر جديد'), findsOneWidget);
      expect(find.text('استيراد نسخة احتياطية'), findsOneWidget);
    });

    testWidgets('CreateStoreView renders logo placeholder, inputs, and create button', (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      SharedPreferences.setMockInitialValues({});
      Get.put(SettingsController());
      Get.put(OnboardingController());

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: const CreateStoreView(),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('إنشاء متجر'), findsOneWidget);

      // Check circular logo placeholder label
      expect(find.text('الشعار'), findsOneWidget);

      // Check create button
      expect(find.text('إنشاء'), findsOneWidget);

      // Verify form fields can receive text
      final storeNameField = find.byType(TextFormField).first;
      await tester.enterText(storeNameField, 'متجر البركة');
      expect(find.text('متجر البركة'), findsOneWidget);
    });
  });
}
