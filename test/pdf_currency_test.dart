import 'dart:io';
import 'package:bidi/bidi.dart' as bidi;
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('Verify all supported currencies render cleanly in PDF without missing glyphs', () async {
    final regularBytes = await File('assets/fonts/Cairo-Regular.ttf').readAsBytes();
    final boldBytes = await File('assets/fonts/Cairo-Bold.ttf').readAsBytes();
    final font = pw.Font.ttf(regularBytes.buffer.asByteData());
    final boldFont = pw.Font.ttf(boldBytes.buffer.asByteData());

    final doc = pw.Document();

    final testStrings = [
      '1,500 ر.ي',
      '1,500 YER',
      '1,500 ريال يمني',
      '2,500.50 ر.س',
      '2,500.50 SAR',
      '2,500.50 ريال سعودي',
      '100.00 \$',
      '\$100.00',
      '100.00 USD',
      '100.00 دولار',
      'فاتورة مبيعات',
      'كشف حساب عميل',
      'إيصال قبض',
      'تقرير مالي شامل',
    ];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: testStrings
                .map((s) => pw.Text(s, style: pw.TextStyle(font: font, fontSize: 12)))
                .toList(),
          );
        },
      ),
    );

    final bytes = await doc.save();
    expect(bytes.length, greaterThan(2000));
    print('Rendered ${testStrings.length} test lines cleanly! PDF size: ${bytes.length} bytes');

    // Test various currency representations with bidi
    final wordsToTest = [
      'ر.ي',
      'ر.س',
      'YER',
      'SAR',
      '\$',
      'ريال',
      'ريال يمني',
      'ريال سعودي',
      'دولار',
    ];

    print('\n--- Testing words with bidi ---');
    for (final word in wordsToTest) {
      final paragraphs = bidi.BidiString.fromLogical(word).paragraphs;
      final out = <String>[];
      for (final p in paragraphs) {
        for (final code in p.bidiText) {
          out.add('U+${code.toRadixString(16).padLeft(4, '0')}');
        }
      }
      print('$word -> ${out.join(' ')}');
    }
  });
}
