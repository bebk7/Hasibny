import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/utils/digits_only_input_formatter.dart';

void main() {
  group('DigitsOnlyInputFormatter Unit Tests', () {
    const formatter = DigitsOnlyInputFormatter();

    test('Allows pure ASCII digits unchanged', () {
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(
        text: '123450',
        selection: TextSelection.collapsed(offset: 6),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '123450');
      expect(res.selection.baseOffset, 6);
      expect(res.selection.extentOffset, 6);
    });

    test('Rejects decimal separators . and ,', () {
      const oldVal = TextEditingValue(
        text: '123',
        selection: TextSelection.collapsed(offset: 3),
      );
      const newVal = TextEditingValue(
        text: '123.45',
        selection: TextSelection.collapsed(offset: 6),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '12345');
      expect(res.selection.baseOffset, 5);
    });

    test('Rejects Arabic decimal separator ٫ and comma ،', () {
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(
        text: '120٫50،99',
        selection: TextSelection.collapsed(offset: 9),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '1205099');
      expect(res.selection.baseOffset, 7);
    });

    test('Rejects currency symbols, signs (+, -), spaces, and letters', () {
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(
        text: '\$ -150 YER + 20 USD abc',
        selection: TextSelection.collapsed(offset: 23),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '15020');
    });

    test('Preserves cursor position when inserting non-digits in the middle', () {
      // old text: "1234"
      // User types "." at index 2 -> text: "12.34", cursor at index 3
      const oldVal = TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 2),
      );
      const newVal = TextEditingValue(
        text: '12.34',
        selection: TextSelection.collapsed(offset: 3),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '1234');
      // Cursor should remain at index 2 (after '2', before '3')
      expect(res.selection.baseOffset, 2);
      expect(res.selection.extentOffset, 2);
    });

    test('Preserves cursor when typing valid digit in the middle', () {
      // old text: "1234", cursor at index 2
      // User types "9" -> text: "12934", cursor at index 3
      const oldVal = TextEditingValue(
        text: '1234',
        selection: TextSelection.collapsed(offset: 2),
      );
      const newVal = TextEditingValue(
        text: '12934',
        selection: TextSelection.collapsed(offset: 3),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '12934');
      expect(res.selection.baseOffset, 3);
      expect(res.selection.extentOffset, 3);
    });

    test('Handles pasting formatted currency in the middle', () {
      // old text: "1050"
      // User pastes "$99.00" between "10" and "50"
      // new text: "10$99.0050", cursor after paste at index 8
      const oldVal = TextEditingValue(
        text: '1050',
        selection: TextSelection.collapsed(offset: 2),
      );
      const newVal = TextEditingValue(
        text: '10\$99.0050',
        selection: TextSelection.collapsed(offset: 8),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '10990050');
      // Before cursor in newVal: '1', '0', '$', '9', '9', '.', '0', '0'
      // Digits kept before cursor: '1', '0', '9', '9', '0', '0' (6 digits)
      expect(res.selection.baseOffset, 6);
      expect(res.selection.extentOffset, 6);
    });

    test('Handles range selection replacement correctly', () {
      // old text: "123456"
      // User selects "34" (base: 2, extent: 4) and pastes "a8b"
      // newVal: "12a8b56", selection collapsed at index 5
      const oldVal = TextEditingValue(
        text: '123456',
        selection: TextSelection(baseOffset: 2, extentOffset: 4),
      );
      const newVal = TextEditingValue(
        text: '12a8b56',
        selection: TextSelection.collapsed(offset: 5),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '12856');
      // In newVal up to offset 5: '1','2','a','8','b' -> 3 digits: '1','2','8'
      expect(res.selection.baseOffset, 3);
      expect(res.selection.extentOffset, 3);
    });

    test('Handles empty text input gracefully', () {
      const oldVal = TextEditingValue(
        text: '123',
        selection: TextSelection.collapsed(offset: 3),
      );
      const newVal = TextEditingValue.empty;
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '');
      expect(res.selection.baseOffset, 0);
    });
  });
}
