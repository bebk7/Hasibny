import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/core/core.dart';

void main() {
  group('Core Responsive Engine & Breakpoints Tests', () {
    testWidgets('Extra compact device (320x568 - iPhone SE 1st gen / Small Android)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isExtraCompact, isTrue);
      expect(resp.isCompact, isTrue);
      expect(resp.isSmall, isTrue);
      expect(resp.isStandard, isFalse);
      expect(resp.isTablet, isFalse);
      expect(resp.isDesktop, isFalse);
      expect(resp.isPortrait, isTrue);
      expect(resp.isLandscape, isFalse);
      expect(resp.pagePadding, equals(10.0));
      expect(resp.cardRadius, equals(10.0));
    });

    testWidgets('Standard phone (360x800 - Modern Android Phone)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isExtraCompact, isFalse);
      expect(resp.isCompact, isFalse);
      expect(resp.isSmall, isFalse);
      expect(resp.isStandard, isTrue);
      expect(resp.isTablet, isFalse);
      expect(resp.pagePadding, equals(16.0));
      expect(resp.cardRadius, equals(14.0));
    });

    testWidgets('Tablet portrait (768x1024 - iPad / Android Tablet)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isExtraCompact, isFalse);
      expect(resp.isSmall, isFalse);
      expect(resp.isStandard, isFalse);
      expect(resp.isTablet, isTrue);
      expect(resp.isDesktop, isFalse);
      expect(resp.pagePadding, equals(24.0));
      expect(resp.cardRadius, equals(18.0));
    });

    testWidgets('Tablet landscape (1024x768 - Wide Tablet Mode)', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isLandscape, isTrue);
      expect(resp.isPortrait, isFalse);
      expect(resp.isTablet, isFalse);
      expect(resp.isDesktop, isTrue);
      expect(resp.isLarge, isTrue);
      expect(resp.gridColumns(minItemWidth: 200), greaterThanOrEqualTo(4));
    });

    testWidgets('Desktop / Expanded display (1440x900)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isDesktop, isTrue);
      expect(resp.isExpanded, isTrue);
      expect(resp.cardMaxWidth, equals(AppBreakpoints.maxCardWidth));
      expect(resp.maxContentWidth, equals(AppBreakpoints.maxContentWidth));
      expect(resp.dialogWidth, lessThanOrEqualTo(AppBreakpoints.maxDialogWidth));
    });
  });

  group('Typography & Scaling Safety Tests', () {
    testWidgets('Extreme text scale factor (2.0) remains clamped within safe thresholds', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.textScaleFactor, equals(2.0));
      // Display title must not exceed maximum limit (34.0)
      expect(resp.displayTitle, lessThanOrEqualTo(34.0));
      // Page title must not exceed maximum limit (26.0)
      expect(resp.pageTitle, lessThanOrEqualTo(26.0));
      // Body text must not exceed maximum limit (17.0)
      expect(resp.bodyText, lessThanOrEqualTo(17.0));
      // Caption text must not exceed maximum limit (13.0)
      expect(resp.captionText, lessThanOrEqualTo(13.0));
    });

    testWidgets('Extra compact device text sizing maintains readable lower bounds', (tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 0.8;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.pageTitle, greaterThanOrEqualTo(18.0));
      expect(resp.sectionTitle, greaterThanOrEqualTo(15.0));
      expect(resp.bodyText, greaterThanOrEqualTo(12.0));
      expect(resp.captionText, greaterThanOrEqualTo(9.5));
    });
  });

  group('RTL & Insets Dynamic Detection Tests', () {
    testWidgets('Arabic RTL provides correct forward and back icons', (tester) async {
      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                resp = AppResponsive.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resp.isRtl, isTrue);
      expect(resp.isLtr, isFalse);
      expect(resp.forwardIcon, equals(Icons.chevron_left_rounded));
      expect(resp.backIcon, equals(Icons.chevron_right_rounded));
    });

    testWidgets('English LTR provides standard navigation icons', (tester) async {
      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.isRtl, isFalse);
      expect(resp.isLtr, isTrue);
      expect(resp.forwardIcon, equals(Icons.chevron_right_rounded));
      expect(resp.backIcon, equals(Icons.chevron_left_rounded));
    });

    testWidgets('System bar insets and virtual keyboard detection', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 48, left: 0, right: 0);
      tester.view.viewInsets = const FakeViewPadding(top: 0, bottom: 280, left: 0, right: 0);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetPadding();
        tester.view.resetViewInsets();
      });

      late AppResponsive resp;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resp = AppResponsive.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resp.safeTop, equals(24.0));
      expect(resp.safeBottom, equals(48.0));
      expect(resp.keyboardInset, equals(280.0));
      expect(resp.isKeyboardOpen, isTrue);
    });
  });

  group('Central Core Widgets Zero-Overflow Multi-Viewport Tests', () {
    final viewports = [
      const Size(320, 568),  // Extra compact phone
      const Size(360, 800),  // Standard phone
      const Size(768, 1024), // Tablet portrait
      const Size(1200, 800), // Desktop
    ];

    for (final size in viewports) {
      testWidgets('Core Widgets render without RenderFlex overflow on ${size.width}x${size.height}', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppPageContainer(
                child: Builder(
                  builder: (context) => Column(
                    children: [
                      const AppSectionHeader(
                        title: 'لوحة التحكم والمحفظة',
                        subtitle: 'تفاصيل الحسابات والأرصدة الحالية',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'متجر البركة للمواد الغذائية والكماليات',
                                style: AppTextStyles.cardTitle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const AppBadge(
                              label: 'نشط',
                              isFilled: true,
                              color: AppColors.got,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AppTextField(
                        labelText: 'المبلغ الإجمالي',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'له (قبض)',
                              variant: AppButtonVariant.got,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: 'عليه (صرف)',
                              variant: AppButtonVariant.destructive,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AppCard), findsOneWidget);
        expect(find.byType(AppButton), findsNWidgets(2));
      });
    }

    testWidgets('AppResponsiveGrid dynamically adjusts columns without clipping', (tester) async {
      tester.view.physicalSize = const Size(700, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppResponsiveGrid(
              minItemWidth: 160,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                6,
                (i) => AppCard(
                  child: Center(child: Text('Card $i')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AppCard), findsNWidgets(6));
    });

    testWidgets('AppEmptyState, AppLoading, and AppErrorState render cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(
                  child: AppEmptyState(
                    title: 'لا توجد معاملات',
                    subtitle: 'أضف أول معاملة للبدء في دفتر الحسابات',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                const AppLoading(message: 'جاري تحميل البيانات...'),
                AppErrorState(
                  message: 'حدث خطأ في استعادة النسخة الاحتياطية',
                  onRetry: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('لا توجد معاملات'), findsOneWidget);
      expect(find.text('جاري تحميل البيانات...'), findsOneWidget);
      expect(find.text('حدث خطأ في استعادة النسخة الاحتياطية'), findsOneWidget);
    });
  });
}
