import 'package:flutter/services.dart';

/// A strict numeric-only [TextInputFormatter] that allows only ASCII digits (0-9).
///
/// It rejects:
/// - Decimal separators ('.' and ',')
/// - Arabic decimal separators ('٫' and '،')
/// - Currency symbols ('$', '€', 'ر.ي', etc.)
/// - Letters, whitespace, mathematical signs ('+', '-'), and emojis
///
/// It accurately tracks cursor position and selection offsets so that typing,
/// pasting, replacement, and deletion in the middle of text work smoothly.
class DigitsOnlyInputFormatter extends TextInputFormatter {
  const DigitsOnlyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Fast-path: if text already consists strictly of ASCII digits '0'-'9'
    bool allDigits = true;
    for (int i = 0; i < newValue.text.length; i++) {
      final code = newValue.text.codeUnitAt(i);
      if (code < 48 || code > 57) {
        allDigits = false;
        break;
      }
    }

    if (allDigits) {
      return newValue;
    }

    final StringBuffer buffer = StringBuffer();
    int newBaseOffset = 0;
    int newExtentOffset = 0;

    final baseOffset = newValue.selection.baseOffset;
    final extentOffset = newValue.selection.extentOffset;

    for (int i = 0; i < newValue.text.length; i++) {
      if (i == baseOffset) {
        newBaseOffset = buffer.length;
      }
      if (i == extentOffset) {
        newExtentOffset = buffer.length;
      }

      final code = newValue.text.codeUnitAt(i);
      // Strictly allow ASCII digits: '0' is 48, '9' is 57
      if (code >= 48 && code <= 57) {
        buffer.writeCharCode(code);
      }
    }

    if (baseOffset >= newValue.text.length) {
      newBaseOffset = buffer.length;
    }
    if (extentOffset >= newValue.text.length) {
      newExtentOffset = buffer.length;
    }

    final filtered = buffer.toString();

    return TextEditingValue(
      text: filtered,
      selection: newValue.selection.isCollapsed
          ? TextSelection.collapsed(offset: newExtentOffset)
          : TextSelection(
              baseOffset: newBaseOffset,
              extentOffset: newExtentOffset,
            ),
      composing: TextRange.empty,
    );
  }
}
