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
  }) {
    final currency = fromCode(currencyCode);
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    String formattedNumber;
    if (currency.decimalDigits == 0 || absAmount == absAmount.truncateToDouble()) {
      if (currency.decimalDigits == 0) {
        formattedNumber = _addThousandSeparators(absAmount.round().toString());
      } else {
        formattedNumber = _addThousandSeparators(absAmount.toInt().toString());
      }
    } else {
      final str = absAmount.toStringAsFixed(currency.decimalDigits);
      final parts = str.split('.');
      final intPart = _addThousandSeparators(parts[0]);
      var decPart = parts[1];
      while (decPart.endsWith('0') && decPart.length > 1) {
        decPart = decPart.substring(0, decPart.length - 1);
      }
      formattedNumber = '$intPart.$decPart';
    }

    final symbol = currency.getSymbol(isArabic: isArabic);
    final signStr = showSign ? (isNegative ? '- ' : '+ ') : (isNegative ? '- ' : '');

    if (currency.code == 'USD') {
      return '$signStr\$$formattedNumber';
    } else {
      return '$signStr$formattedNumber $symbol';
    }
  }

  static String _addThousandSeparators(String value) {
    final digits = value.replaceAll('-', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
