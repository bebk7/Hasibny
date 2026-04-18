import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class CurrencyFormatter {
  static String _formatNumber(double amount) {
    String value;
    if (amount == amount.truncateToDouble()) {
      value = amount.toInt().toString();
    } else {
      final s = amount.toStringAsFixed(2);
      if (s.endsWith('00')) {
        value = amount.toInt().toString();
      } else if (s.endsWith('0')) {
        value = s.substring(0, s.length - 1);
      } else {
        value = s;
      }
    }
    return _addThousandSeparators(value);
  }

  static String _addThousandSeparators(String value) {
    final parts = value.split('.');
    final intPart = parts[0];
    final isNeg = intPart.startsWith('-');
    final digits = isNeg ? intPart.substring(1) : intPart;

    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final formatted = (isNeg ? '-' : '') + buf.toString();
    return parts.length > 1 ? '$formatted.${parts[1]}' : formatted;
  }

  static String format(double amount, {String? symbol}) {
    final sym = symbol ?? Get.find<SettingsController>().currencySymbol;
    return '${_formatNumber(amount)} $sym';
  }

  static String formatAbs(double amount, {String? symbol}) {
    final sym = symbol ?? Get.find<SettingsController>().currencySymbol;
    return '${_formatNumber(amount.abs())} $sym';
  }

  // ─── Amount to Arabic words ──────────────────────────────────────────

  static const _onesAr = [
    '', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة',
    'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
    'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر',
    'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر',
  ];

  static const _tensAr = [
    '', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون',
    'ستون', 'سبعون', 'ثمانون', 'تسعون',
  ];

  static const _onesEn = [
    '', 'One', 'Two', 'Three', 'Four', 'Five',
    'Six', 'Seven', 'Eight', 'Nine', 'Ten',
    'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen',
  ];

  static const _tensEn = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
    'Sixty', 'Seventy', 'Eighty', 'Ninety',
  ];

  static String amountToWords(double amount) {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final n = amount.truncate().abs();
    if (n == 0) return isAr ? 'صفر' : 'Zero';
    return isAr ? _toWordsAr(n) : _toWordsEn(n);
  }

  static String _toWordsAr(int n) {
    if (n < 20) return _onesAr[n];
    if (n < 100) {
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return _tensAr[t];
      return '${_onesAr[o]} و${_tensAr[t]}';
    }
    if (n < 1000) {
      final h = n ~/ 100;
      final r = n % 100;
      final hStr = h == 1 ? 'مائة' : h == 2 ? 'مائتان' : '${_onesAr[h]} مائة';
      return r == 0 ? hStr : '$hStr و${_toWordsAr(r)}';
    }
    if (n < 1000000) {
      final th = n ~/ 1000;
      final r = n % 1000;
      String thStr;
      if (th == 1) {
        thStr = 'ألف';
      } else if (th == 2) {
        thStr = 'ألفان';
      } else if (th <= 10) {
        thStr = '${_onesAr[th]} آلاف';
      } else {
        thStr = '${_toWordsAr(th)} ألف';
      }
      return r == 0 ? thStr : '$thStr و${_toWordsAr(r)}';
    }
    if (n < 1000000000) {
      final m = n ~/ 1000000;
      final r = n % 1000000;
      String mStr;
      if (m == 1) {
        mStr = 'مليون';
      } else if (m == 2) {
        mStr = 'مليونان';
      } else if (m <= 10) {
        mStr = '${_onesAr[m]} ملايين';
      } else {
        mStr = '${_toWordsAr(m)} مليون';
      }
      return r == 0 ? mStr : '$mStr و${_toWordsAr(r)}';
    }
    return n.toString();
  }

  static String _toWordsEn(int n) {
    if (n < 20) return _onesEn[n];
    if (n < 100) {
      final t = n ~/ 10;
      final o = n % 10;
      if (o == 0) return _tensEn[t];
      return '${_tensEn[t]}-${_onesEn[o]}';
    }
    if (n < 1000) {
      final h = n ~/ 100;
      final r = n % 100;
      return r == 0
          ? '${_onesEn[h]} Hundred'
          : '${_onesEn[h]} Hundred and ${_toWordsEn(r)}';
    }
    if (n < 1000000) {
      final th = n ~/ 1000;
      final r = n % 1000;
      return r == 0
          ? '${_toWordsEn(th)} Thousand'
          : '${_toWordsEn(th)} Thousand ${_toWordsEn(r)}';
    }
    if (n < 1000000000) {
      final m = n ~/ 1000000;
      final r = n % 1000000;
      return r == 0
          ? '${_toWordsEn(m)} Million'
          : '${_toWordsEn(m)} Million ${_toWordsEn(r)}';
    }
    return n.toString();
  }
}
