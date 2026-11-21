import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:account_book/core/core.dart';
import 'package:account_book/translations/app_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GuidedTourStorage.instance.clearCacheForTesting();
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('ar', 'SA');
  });

  group('GuidedTourStorage Persistence Unit Tests', () {
    test('Initial tour state is neither completed nor skipped', () async {
      final storage = GuidedTourStorage.instance;
      expect(await storage.isTourCompleted('test_tour'), isFalse);
      expect(await storage.isTourSkipped('test_tour'), isFalse);
      expect(await storage.hasTourBeenSeen('test_tour'), isFalse);
    });

    test('markTourCompleted sets completed state and hasTourBeenSeen', () async {
      final storage = GuidedTourStorage.instance;
      await storage.markTourCompleted('test_tour');

      expect(await storage.isTourCompleted('test_tour'), isTrue);
      expect(await storage.isTourSkipped('test_tour'), isFalse);
      expect(await storage.hasTourBeenSeen('test_tour'), isTrue);
    });

    test('markTourSkipped sets skipped state and hasTourBeenSeen', () async {
      final storage = GuidedTourStorage.instance;
      await storage.markTourSkipped('test_tour');

      expect(await storage.isTourCompleted('test_tour'), isFalse);
      expect(await storage.isTourSkipped('test_tour'), isTrue);
      expect(await storage.hasTourBeenSeen('test_tour'), isTrue);
    });

    test('resetTour resets only the targeted tour', () async {
      final storage = GuidedTourStorage.instance;
      await storage.markTourCompleted('tour_a');
      await storage.markTourCompleted('tour_b');

      await storage.resetTour('tour_a');

      expect(await storage.hasTourBeenSeen('tour_a'), isFalse);
      expect(await storage.hasTourBeenSeen('tour_b'), isTrue);
    });

    test('resetAllTours clears all tour records', () async {
      final storage = GuidedTourStorage.instance;
      await storage.markTourCompleted('tour_1');
      await storage.markTourSkipped('tour_2');
      await storage.markTourCompleted('tour_3');

      await storage.resetAllTours();

      expect(await storage.hasTourBeenSeen('tour_1'), isFalse);
      expect(await storage.hasTourBeenSeen('tour_2'), isFalse);
      expect(await storage.hasTourBeenSeen('tour_3'), isFalse);
    });
  });

  group('AppTours Predefined Configurations Unit Tests', () {
    test('Dashboard Tour configuration is well-formed', () {
      final tour = AppTours.buildDashboardTour();
      expect(tour.tourId, equals(AppTours.dashboardTourId));
      expect(tour.stepCount, equals(5));
      expect(tour.steps.map((s) => s.id), equals([
        'dash_header',
        'dash_actions',
        'dash_currencies',
        'dash_balances',
        'dash_fab',
      ]));
    });

    test('Customers Tour configuration is well-formed', () {
      final tour = AppTours.buildCustomersTour();
      expect(tour.tourId, equals(AppTours.customersTourId));
      expect(tour.stepCount, equals(3));
      expect(tour.steps.map((s) => s.id), equals([
        'cust_search',
        'cust_list',
        'cust_add',
      ]));
    });

    test('Transactions Tour configuration is well-formed', () {
      final tour = AppTours.buildTransactionsTour();
      expect(tour.tourId, equals(AppTours.transactionsTourId));
      expect(tour.stepCount, equals(3));
      expect(tour.steps.map((s) => s.id), equals([
        'tx_filter',
        'tx_list',
        'tx_export',
      ]));
    });

    test('Settings Tour configuration is well-formed', () {
      final tour = AppTours.buildSettingsTour();
      expect(tour.tourId, equals(AppTours.settingsTourId));
      expect(tour.stepCount, equals(4));
      expect(tour.steps.map((s) => s.id), equals([
        'set_store',
        'set_backup',
        'set_security',
        'set_guided',
      ]));
    });
  });

  group('GuidedTourTooltip Widget Tests', () {
    testWidgets('Renders title, description, step badge, and progress bar', (tester) async {
      final step = GuidedTourStep(
        id: 'step_1',
        targetKey: GlobalKey(),
        title: 'عنوان تجريبي',
        description: 'هذا شرح مفصل للخاصية في الجولة التعليمية.',
        icon: Icons.star_rounded,
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 0,
              totalSteps: 3,
              onNext: () {},
              onPrevious: () {},
              onSkip: () {},
              onFinish: () {},
            ),
          ),
        ),
      );

      expect(find.text('عنوان تجريبي'), findsOneWidget);
      expect(find.text('هذا شرح مفصل للخاصية في الجولة التعليمية.'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      // Previous button hidden on first step
      expect(find.text('tour_prev'.tr), findsNothing);
      // Next button visible
      expect(find.text('tour_next'.tr), findsOneWidget);
      // Skip button visible
      expect(find.text('tour_skip'.tr), findsOneWidget);
    });

    testWidgets('Intermediate step displays Previous button', (tester) async {
      bool prevTapped = false;
      bool nextTapped = false;

      final step = GuidedTourStep(
        id: 'step_2',
        targetKey: GlobalKey(),
        title: 'Step 2',
        description: 'Intermediate step description.',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 1,
              totalSteps: 3,
              onNext: () => nextTapped = true,
              onPrevious: () => prevTapped = true,
              onSkip: () {},
              onFinish: () {},
            ),
          ),
        ),
      );

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('tour_prev'.tr), findsOneWidget);
      expect(find.text('tour_next'.tr), findsOneWidget);

      await tester.tap(find.text('tour_prev'.tr));
      expect(prevTapped, isTrue);

      await tester.tap(find.text('tour_next'.tr));
      expect(nextTapped, isTrue);
    });

    testWidgets('Final step displays Finish button and checkmark icon', (tester) async {
      bool finishTapped = false;

      final step = GuidedTourStep(
        id: 'step_3',
        targetKey: GlobalKey(),
        title: 'Step 3',
        description: 'Final step description.',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 2,
              totalSteps: 3,
              onNext: () {},
              onPrevious: () {},
              onSkip: () {},
              onFinish: () => finishTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('tour_finish'.tr), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await tester.tap(find.text('tour_finish'.tr));
      expect(finishTapped, isTrue);
    });

    testWidgets('Skip button invokes onSkip callback', (tester) async {
      bool skipTapped = false;

      final step = GuidedTourStep(
        id: 'step_1',
        targetKey: GlobalKey(),
        title: 'Step 1',
        description: 'Description',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 0,
              totalSteps: 2,
              onNext: () {},
              onPrevious: () {},
              onSkip: () => skipTapped = true,
              onFinish: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('tour_skip'.tr));
      expect(skipTapped, isTrue);
    });

    testWidgets('RTL Arabic chevron orientation differs from LTR English', (tester) async {
      final step = GuidedTourStep(
        id: 'step_2',
        targetKey: GlobalKey(),
        title: 'Step 2',
        description: 'Orientation test',
      );

      // In Arabic RTL: Next chevron points Left, Prev chevron points Right
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'SA'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 1,
              totalSteps: 3,
              onNext: () {},
              onPrevious: () {},
              onSkip: () {},
              onFinish: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget); // Next in RTL
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget); // Prev in RTL

      // In English LTR: Next chevron points Right, Prev chevron points Left
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: GuidedTourTooltip(
              step: step,
              currentStepIndex: 1,
              totalSteps: 3,
              onNext: () {},
              onPrevious: () {},
              onSkip: () {},
              onFinish: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget); // Next in LTR
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget); // Prev in LTR
    });

    testWidgets('Extreme accessibility font scale (2.0x) renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final step = GuidedTourStep(
        id: 'step_overflow_test',
        targetKey: GlobalKey(),
        title: 'عنوان طويل جداً لتجربة قياس النصوص والخطوط',
        description: 'شرح مفصل ومطول جداً لاختبار عدم حدوث أي تجاوز أو تجاوز هندسي عند تفعيل خطوط النظام الكبيرة.',
        icon: Icons.shield_rounded,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2.0),
          ),
          child: GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('ar', 'SA'),
            home: Scaffold(
              body: GuidedTourTooltip(
                step: step,
                currentStepIndex: 1,
                totalSteps: 4,
                onNext: () {},
                onPrevious: () {},
                onSkip: () {},
                onFinish: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('2 / 4'), findsOneWidget);
    });

    testWidgets('Compact screen (320x568 iPhone SE 1st gen) renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final step = GuidedTourStep(
        id: 'step_compact_test',
        targetKey: GlobalKey(),
        title: 'شاشة ضيقة للغاية',
        description: 'نص تجريبي للتحقق من تكيف العرض مع أدق الشاشات المحمولة بدون أي overflow.',
        icon: Icons.phone_android_rounded,
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 568)),
          child: GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('ar', 'SA'),
            home: Scaffold(
              body: GuidedTourTooltip(
                step: step,
                currentStepIndex: 0,
                totalSteps: 3,
                onNext: () {},
                onPrevious: () {},
                onSkip: () {},
                onFinish: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('شاشة ضيقة للغاية'), findsOneWidget);
    });
  });

  group('Full Guided Tour Flow Integration Tests', () {
    testWidgets('GuidedTourScope and GuidedTourTarget step navigation flow', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      final step1 = GuidedTourStep(
        id: 'step1',
        targetKey: key1,
        title: 'Target Step 1',
        description: 'Description for Target 1',
      );

      final step2 = GuidedTourStep(
        id: 'step2',
        targetKey: key2,
        title: 'Target Step 2',
        description: 'Description for Target 2',
      );

      final config = GuidedTourConfig(
        tourId: 'integration_tour',
        title: 'Integration Tour',
        scope: 'integration_scope',
        disableMovingAnimation: true,
        steps: [step1, step2],
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: GuidedTourScope(
            scope: 'integration_scope',
            disableMovingAnimation: true,
            child: Scaffold(
              body: Column(
                children: [
                  GuidedTourTarget(
                    step: step1,
                    child: const Text('Widget 1'),
                  ),
                  GuidedTourTarget(
                    step: step2,
                    child: const Text('Widget 2'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Widget 1'), findsOneWidget);
      expect(find.text('Widget 2'), findsOneWidget);

      final manager = GuidedTourManager.instance;
      final BuildContext context = tester.element(find.byType(Scaffold));

      // Start Tour
      await manager.startTour(context, config);
      await tester.pump(const Duration(milliseconds: 500));

      expect(manager.isTourActive.value, isTrue);
      expect(manager.currentStepIndex.value, equals(0));
      expect(find.text('Target Step 1'), findsOneWidget);

      // Advance to Step 2
      manager.next();
      await tester.pump(const Duration(milliseconds: 500));

      expect(manager.currentStepIndex.value, equals(1));
      expect(find.text('Target Step 2'), findsOneWidget);

      // Finish Tour
      await manager.finish();
      await tester.pump(const Duration(milliseconds: 500));

      expect(manager.isTourActive.value, isFalse);
      expect(await GuidedTourStorage.instance.isTourCompleted('integration_tour'), isTrue);
      expect(await GuidedTourStorage.instance.hasTourBeenSeen('integration_tour'), isTrue);
    });

    testWidgets('Skipping a tour marks it as skipped in persistent storage', (tester) async {
      final key1 = GlobalKey();
      final step1 = GuidedTourStep(
        id: 'step_skip',
        targetKey: key1,
        title: 'Skippable Target',
        description: 'Skippable Description',
      );

      final config = GuidedTourConfig(
        tourId: 'skippable_tour',
        title: 'Skippable Tour',
        scope: 'skippable_scope',
        disableMovingAnimation: true,
        steps: [step1],
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: GuidedTourScope(
            scope: 'skippable_scope',
            disableMovingAnimation: true,
            child: Scaffold(
              body: GuidedTourTarget(
                step: step1,
                child: const Text('Skippable Widget'),
              ),
            ),
          ),
        ),
      );

      final manager = GuidedTourManager.instance;
      final BuildContext context = tester.element(find.byType(Scaffold));

      await manager.startTour(context, config);
      await tester.pump(const Duration(milliseconds: 500));
      expect(manager.isTourActive.value, isTrue);

      await manager.skip();
      await tester.pump(const Duration(milliseconds: 500));

      expect(manager.isTourActive.value, isFalse);
      expect(await GuidedTourStorage.instance.isTourSkipped('skippable_tour'), isTrue);
      expect(await GuidedTourStorage.instance.hasTourBeenSeen('skippable_tour'), isTrue);
    });

    testWidgets('Replay API resets storage and restarts tour', (tester) async {
      final storage = GuidedTourStorage.instance;
      await storage.markTourCompleted('replay_tour');
      expect(await storage.hasTourBeenSeen('replay_tour'), isTrue);

      final key1 = GlobalKey();
      final step1 = GuidedTourStep(
        id: 'step_replay',
        targetKey: key1,
        title: 'Replay Target',
        description: 'Replay Description',
      );

      final config = GuidedTourConfig(
        tourId: 'replay_tour',
        title: 'Replay Tour',
        scope: 'replay_scope',
        disableMovingAnimation: true,
        steps: [step1],
      );

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          home: GuidedTourScope(
            scope: 'replay_scope',
            disableMovingAnimation: true,
            child: Scaffold(
              body: GuidedTourTarget(
                step: step1,
                child: const Text('Replay Widget'),
              ),
            ),
          ),
        ),
      );

      final manager = GuidedTourManager.instance;
      final BuildContext context = tester.element(find.byType(Scaffold));

      await manager.replayTour(context, config);
      await tester.pump(const Duration(milliseconds: 500));

      expect(manager.isTourActive.value, isTrue);
      expect(await storage.isTourCompleted('replay_tour'), isFalse);

      await manager.finish();
      await tester.pump(const Duration(milliseconds: 500));
      expect(await storage.isTourCompleted('replay_tour'), isTrue);
    });
  });
}
