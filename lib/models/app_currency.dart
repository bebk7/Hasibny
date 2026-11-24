import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

enum CurrencyCode {
  yer,
  sar,
  usd,
}

class AppCurrency {
  final String code;
  final String symbolAr;
  final String symbolEn;
  final String nameAr;
  final String nameEn;
  final String flag;
  final int decimalDigits;

  const AppCurrency({
    required this.code,
    required this.symbolAr,
    required this.symbolEn,
    required this.nameAr,
    required this.nameEn,
    required this.flag,
    this.decimalDigits = 2,
  });

  String getSymbol({bool isArabic = true}) => isArabic ? symbolAr : symbolEn;
  String getName({bool isArabic = true}) => isArabic ? nameAr : nameEn;
  String get name => getName();

  static const AppCurrency yer = AppCurrency(
    code: 'YER',
    symbolAr: 'ر.ي',
    symbolEn: 'YER',
    nameAr: 'الريال اليمني',
    nameEn: 'Yemeni Rial',
    flag: '🇾🇪',
    decimalDigits: 0,
  );

  static const AppCurrency sar = AppCurrency(
    code: 'SAR',
    symbolAr: 'ر.س',
    symbolEn: 'SAR',
    nameAr: 'الريال السعودي',
    nameEn: 'Saudi Riyal',
    flag: '🇸🇦',
    decimalDigits: 2,
  );

  static const AppCurrency usd = AppCurrency(
    code: 'USD',
    symbolAr: '\$',
    symbolEn: '\$',
    nameAr: 'الدولار الأمريكي',
    nameEn: 'US Dollar',
    flag: '🇺🇸',
    decimalDigits: 2,
  );

  static const List<AppCurrency> supportedCurrencies = [
    yer,
    sar,
    usd,
  ];

  static AppCurrency fromCode(String? code) {
    if (code == null || code.trim().isEmpty) return yer;
    final trimmed = code.trim();
    final normalized = trimmed.toUpperCase();
    for (final c in supportedCurrencies) {
      if (c.code == normalized ||
          c.symbolAr == trimmed ||
          c.symbolEn.toUpperCase() == normalized ||
          c.nameAr == trimmed ||
          c.nameEn.toUpperCase() == normalized) {
        return c;
      }
    }
    if (normalized.contains('SAR') || trimmed.contains('ر.س') || trimmed.contains('سعودي')) {
      return sar;
    }
    if (normalized.contains('USD') || trimmed.contains('\$') || trimmed.contains('دولار')) {
      return usd;
    }
    return yer;
  }

  static String formatAmount(
    double amount, {
    required String currencyCode,
    bool isArabic = true,
    bool showSign = false,
    String? formatCode,
  }) {
    final currency = fromCode(currencyCode);
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final fmt = formatCode ??
        (Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>().currentNumberFormat.value
            : 'standard');

    String formattedNumber;
    if (currency.decimalDigits == 0 || absAmount == absAmount.truncateToDouble()) {
      final rawIntStr = currency.decimalDigits == 0
          ? absAmount.round().toString()
          : absAmount.toInt().toString();
      formattedNumber = applyNumberFormat(rawIntStr, null, fmt);
    } else {
      final str = absAmount.toStringAsFixed(currency.decimalDigits);
      final parts = str.split('.');
      var decPart = parts[1];
      while (decPart.endsWith('0') && decPart.length > 1) {
        decPart = decPart.substring(0, decPart.length - 1);
      }
      formattedNumber = applyNumberFormat(parts[0], decPart, fmt);
    }

    final symbol = currency.getSymbol(isArabic: isArabic);
    final signStr = showSign ? (isNegative ? '- ' : '+ ') : (isNegative ? '- ' : '');

    if (currency.code == 'USD') {
      if (fmt == 'arabicIndic') {
        return '$signStr$formattedNumber \$';
      }
      return '$signStr\$$formattedNumber';
    } else {
      return '$signStr$formattedNumber $symbol';
    }
  }

  static String applyNumberFormat(String intPart, String? decPart, [String? formatCode]) {
    final fmt = formatCode ??
        (Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>().currentNumberFormat.value
            : 'standard');
    String thousandsSep = ',';
    String decimalSep = '.';

    switch (fmt) {
      case 'european':
        thousandsSep = '.';
        decimalSep = ',';
        break;
      case 'spaces':
        thousandsSep = ' ';
        decimalSep = '.';
        break;
      case 'arabicIndic':
        thousandsSep = '٬';
        decimalSep = '٫';
        break;
      case 'standard':
      default:
        thousandsSep = ',';
        decimalSep = '.';
        break;
    }

    final digits = intPart.replaceAll('-', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(thousandsSep);
      buf.write(digits[i]);
    }
    String result = buf.toString();
    if (decPart != null && decPart.isNotEmpty) {
      result = '$result$decimalSep$decPart';
    }

    if (fmt == 'arabicIndic') {
      const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      for (int i = 0; i < 10; i++) {
        result = result.replaceAll(western[i], eastern[i]);
      }
    }

    return result;
  }
}
