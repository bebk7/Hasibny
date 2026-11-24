import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../models/app_currency.dart';

class CurrencyFormatter {
  static String format(
    double amount, {
    String? currencyCode,
    String? symbol,
    bool showSign = false,
  }) {
    final isAr = Get.locale?.languageCode == 'ar';
    if (currencyCode != null && currencyCode.isNotEmpty) {
      return AppCurrency.formatAmount(
        amount,
        currencyCode: currencyCode,
        isArabic: isAr,
        showSign: showSign,
      );
    }

    if (symbol != null) {
      final formattedNum = _formatNumber(amount.abs());
      final sign = amount < 0 ? '- ' : (showSign ? '+ ' : '');
      if (symbol == '\$') {
        return '$sign\$$formattedNum';
      }
      return '$sign$formattedNum $symbol';
    }

    final defaultCode = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().currentCurrency.value
        : 'YER';

    return AppCurrency.formatAmount(
      amount,
      currencyCode: defaultCode,
      isArabic: isAr,
      showSign: showSign,
    );
  }

  static String formatAbs(
    double amount, {
    String? currencyCode,
    String? symbol,
  }) {
    return format(
      amount.abs(),
      currencyCode: currencyCode,
      symbol: symbol,
      showSign: false,
    );
  }

  static String _formatNumber(double amount, [String? formatCode]) {
    String intPart;
    String? decPart;
    if (amount == amount.truncateToDouble()) {
      intPart = amount.toInt().toString();
    } else {
      final s = amount.toStringAsFixed(2);
      final parts = s.split('.');
      intPart = parts[0];
      decPart = parts[1];
      if (decPart.endsWith('00')) {
        decPart = null;
      } else if (decPart.endsWith('0')) {
        decPart = decPart.substring(0, 1);
      }
    }
    return AppCurrency.applyNumberFormat(intPart, decPart, formatCode);
  }

  // ─── Amount to words with currency support ───────────────────────────

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

  static String amountToWords(double amount, {String? currencyCode}) {
    final isAr = Get.locale?.languageCode == 'ar';
    final n = amount.truncate().abs();
    final curr = currencyCode != null ? AppCurrency.fromCode(currencyCode) : null;
    final currName = curr != null ? ' ${curr.getName(isArabic: isAr)}' : '';

    if (n == 0) return (isAr ? 'صفر' : 'Zero') + currName;
    final words = isAr ? _toWordsAr(n) : _toWordsEn(n);
    return words + currName;
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
