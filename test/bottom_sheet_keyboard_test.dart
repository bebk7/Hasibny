import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/core/widgets/app_bottom_sheet.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('AppBottomSheet adapts to keyboard viewInsets without shooting to top', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      title: 'إضافة صنف ناقص',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            key: const Key('name_field'),
                            decoration: const InputDecoration(labelText: 'اسم المنتج'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            key: const Key('qty_field'),
                            decoration: const InputDecoration(labelText: 'الكمية'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Open sheet
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('إضافة صنف ناقص'), findsOneWidget);
    expect(find.byKey(const Key('name_field')), findsOneWidget);

    // Simulate keyboard opening (viewInsets.bottom = 300)
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    // Verify title is still clearly visible and not cut off above y=0
    final titleTopLeft = tester.getTopLeft(find.text('إضافة صنف ناقص'));
    expect(titleTopLeft.dy, greaterThanOrEqualTo(0.0));

    // Reset viewInsets
    tester.view.resetViewInsets();
  });
}
