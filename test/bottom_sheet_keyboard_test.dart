import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/core/core.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('AppBottomSheet adapts to keyboard viewInsets without shooting to top', (tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0; // logical: 360 x 640
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });

    final productCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              final resp = AppResponsive.of(context);
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      title: 'إضافة صنف ناقص',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const Key('name_field'),
                            controller: productCtrl,
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
                            decoration: InputDecoration(
                              labelText: 'اسم المنتج / الصنف',
                              prefixIcon: Icon(Icons.inventory_2_rounded, size: resp.iconSM),
                            ),
                          ),
                          SizedBox(height: resp.spacingSM),
                          TextField(
                            key: const Key('qty_field'),
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
                            decoration: InputDecoration(
                              labelText: 'الكمية',
                              prefixIcon: Icon(Icons.numbers_rounded, size: resp.iconSM),
                            ),
                          ),
                          SizedBox(height: resp.spacingSM),
                          TextField(
                            key: const Key('note_field'),
                            controller: noteCtrl,
                            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
                            decoration: InputDecoration(
                              labelText: 'ملاحظات',
                              prefixIcon: Icon(Icons.notes_rounded, size: resp.iconSM),
                            ),
                          ),
                          SizedBox(height: resp.spacingLG),
                          AppButton(
                            key: const Key('submit_btn'),
                            text: 'إضافة',
                            icon: Icons.add_rounded,
                            onPressed: () {},
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

    // 1. Open sheet
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('إضافة صنف ناقص'), findsOneWidget);
    expect(find.byKey(const Key('name_field')), findsOneWidget);
    expect(find.byKey(const Key('submit_btn')), findsOneWidget);

    final titleRect1 = tester.getRect(find.text('إضافة صنف ناقص'));
    final submitRect1 = tester.getRect(find.byKey(const Key('submit_btn')));
    expect(titleRect1.top, greaterThanOrEqualTo(0.0));
    expect(submitRect1.bottom, lessThanOrEqualTo(640.0));

    // 2. Open keyboard (300 logical px) and focus name field
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 2.0);
    await tester.tap(find.byKey(const Key('name_field')));
    await tester.pumpAndSettle();

    // Verify title is still clearly visible and NOT cut off above y=0
    final titleRect2 = tester.getRect(find.text('إضافة صنف ناقص'));
    final nameRect2 = tester.getRect(find.byKey(const Key('name_field')));
    expect(titleRect2.top, greaterThanOrEqualTo(0.0));
    // The name field stays below the title
    expect(nameRect2.top, greaterThan(titleRect2.bottom));
    expect(titleRect2.top, lessThan(340.0));
  });
}
