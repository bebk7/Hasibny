import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/utils/responsive.dart';

void main() {
  group('Responsive Breakpoints & Layout Tests', () {
    testWidgets('Extra small phone (320x568 - iPhone SE 1st gen / small Android)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isExtraSmall(context), isTrue);
              expect(Responsive.isSmall(context), isTrue);
              expect(Responsive.isMedium(context), isFalse);
              expect(Responsive.isLarge(context), isFalse);
              expect(Responsive.isShort(context), isTrue);
              expect(Responsive.cardRadius(context), 10);
              expect(Responsive.avatarRadius(context), 22);
              expect(Responsive.iconSize(context), 18);
              expect(Responsive.fabSize(context), 48);

              // Verify bounded font scaling
              final fontSize = Responsive.responsiveFontSize(context, 16);
              expect(fontSize, greaterThanOrEqualTo(12));
              expect(fontSize, lessThanOrEqualTo(20));

              // Verify spacing
              expect(AppSpacing.xs(context), 4.0);
              expect(AppSpacing.sm(context), 8.0);
              expect(AppSpacing.md(context), 12.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Standard phone (360x800 - Standard Android)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isExtraSmall(context), isFalse);
              expect(Responsive.isSmall(context), isFalse);
              expect(Responsive.isMedium(context), isTrue);
              expect(Responsive.isLarge(context), isFalse);
              expect(Responsive.isShort(context), isFalse);
              expect(Responsive.cardRadius(context), 14);
              expect(Responsive.avatarRadius(context), 36);
              expect(Responsive.iconSize(context), 24);
              expect(Responsive.fabSize(context), 56);

              expect(AppSpacing.xs(context), 6.0);
              expect(AppSpacing.sm(context), 10.0);
              expect(AppSpacing.md(context), 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Large phone (412x915 - Pixel 7 / Galaxy S23)', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isSmall(context), isFalse);
              expect(Responsive.isMedium(context), isTrue);
              expect(Responsive.isLarge(context), isFalse);
              expect(Responsive.gridColumns(context, minItemWidth: 180), 2);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Tablet (768x1024 - iPad / Android Tablet)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isSmall(context), isFalse);
              expect(Responsive.isTablet(context), isTrue);
              expect(Responsive.isLarge(context), isTrue);
              expect(Responsive.gridColumns(context, minItemWidth: 180), greaterThanOrEqualTo(3));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Landscape orientation (844x390)', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isLandscape(context), isTrue);
              expect(Responsive.isShort(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Android Navigation Bar & Inset Tests', () {
    testWidgets('3-button navigation mode (48dp bottom inset)', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(bottom: 48, top: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.safeBottom(context), 48.0);
              expect(Responsive.safeTop(context), 24.0);
              final pagePadding = Responsive.pagePadding(context);
              // 16 base bottom + 48 safe bottom = 64
              expect(pagePadding.bottom, 64.0);

              // tabPadding includes additional bottom clearance for FAB
              final tabPadding = Responsive.tabPadding(context);
              expect(tabPadding.bottom, greaterThanOrEqualTo(100.0));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Gesture navigation mode (16dp bottom inset)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(bottom: 16, top: 44);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.safeBottom(context), 16.0);
              expect(Responsive.safeTop(context), 44.0);
              final pagePadding = Responsive.pagePadding(context);
              expect(pagePadding.bottom, 16.0 + 16.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('Keyboard open state with navigation insets', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      tester.view.padding = const FakeViewPadding(bottom: 48);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.isKeyboardOpen(context), isTrue);
              expect(Responsive.keyboardInset(context), 280.0);
              expect(Responsive.safeBottom(context), 48.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Accessibility & Font Scaling Tests', () {
    testWidgets('Extreme text scale factor (2.0) is bounded safely', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0),
            ),
            child: Builder(
              builder: (context) {
                final baseFontSize = 14.0;
                final scaled = Responsive.responsiveFontSize(
                  context,
                  baseFontSize,
                  min: 11.0,
                  max: 18.0,
                );
                // Even with 2.0x system text scale, should clamp at max 18.0
                expect(scaled, lessThanOrEqualTo(18.0));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });
  });
}
