import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/core/core.dart';

void main() {
  group('AppAppBarTitle Zero-Overflow & Auto-Scale Tests', () {
    testWidgets('Renders standard title in AppBar without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              title: const AppAppBarTitle('الملف التعريفي للمتجر'),
            ),
          ),
        ),
      );

      expect(find.text('الملف التعريفي للمتجر'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders exceptionally long multi-word title in compact viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568); // Extra compact phone
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const AppAppBarTitle('معاينة التقرير المالي الشامل والحسابات التفصيلية للمتجر'),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppAppBarTitle), findsOneWidget);
      expect(find.byType(FittedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
