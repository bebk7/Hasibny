class PhoneNumberHelper {
  /// Default country dialing code (Yemen +967)
  static const String defaultCountryCode = '+967';

  /// Normalizes any input phone number to standard international E.164 format (+XXXXXXXXXXX).
  ///
  /// Handles:
  /// - Leading 00 (e.g. 00967770000000 -> +967770000000)
  /// - Leading + (e.g. +967 770-000-000 -> +967770000000)
  /// - Local numbers with leading 0 (e.g. 0770000000 -> +967770000000)
  /// - Local numbers without 0 (e.g. 770000000 -> +967770000000)
  /// - Spaces, dashes, parentheses, dots
  /// - Arabic/Persian numerals conversion (e.g. ٠١٢٣٤٥٦٧٨٩ -> 0123456789)
  static String normalizeToE164(String input, {String? defaultCode, String? defaultCountryCode}) {
    if (input.trim().isEmpty) return '';

    // 1. Convert Arabic-Indic numerals to standard ASCII digits
    String cleaned = convertArabicDigitsToLatin(input.trim());

    // 2. Remove all non-digit characters except leading '+'
    final hasPlus = cleaned.startsWith('+');
    cleaned = cleaned.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return '';

    // 3. Handle '00' international prefix
    if (cleaned.startsWith('00')) {
      cleaned = cleaned.substring(2);
      return '+$cleaned';
    }

    // 4. If originally started with '+', return with '+'
    if (hasPlus) {
      return '+$cleaned';
    }

    // 5. If starts with country code without plus (e.g. 967..., 966..., 20..., 971...)
    if (cleaned.startsWith('967') && cleaned.length >= 12) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('966') && cleaned.length >= 12) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('20') && cleaned.length >= 11) {
      return '+$cleaned';
    }
    if (cleaned.startsWith('971') && cleaned.length >= 11) {
      return '+$cleaned';
    }

    // 6. Handle local numbers with leading 0 (e.g. 0770000000 -> +967770000000)
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // 7. Attach default country code
    final effectiveDefault = defaultCountryCode ?? defaultCode ?? PhoneNumberHelper.defaultCountryCode;
    final cleanDefaultCode = effectiveDefault.startsWith('+') ? effectiveDefault : '+$effectiveDefault';
    return '$cleanDefaultCode$cleaned';
  }

  /// Validates if the given phone number conforms to a valid international E.164 phone format.
  static bool isValidE164(String phone) {
    final normalized = normalizeToE164(phone);
    if (normalized.isEmpty) return false;

    // E.164 pattern: + followed by 7 to 15 digits
    final e164Regex = RegExp(r'^\+[1-9]\d{6,14}$');
    return e164Regex.hasMatch(normalized);
  }

  /// Formats phone number for display (e.g. +967 770 000 000)
  static String formatForDisplay(String phone) {
    final normalized = normalizeToE164(phone);
    if (normalized.isEmpty) return phone;

    // Yemen (+967 XX XXX XXX)
    if (normalized.startsWith('+967') && normalized.length == 13) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 6)} ${normalized.substring(6, 9)} ${normalized.substring(9)}';
    }
    // Saudi Arabia (+966 XX XXX XXXX)
    if (normalized.startsWith('+966') && normalized.length == 13) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 6)} ${normalized.substring(6, 9)} ${normalized.substring(9)}';
    }
    // Generic format: +CCC XXXX XXXX
    if (normalized.length > 7) {
      return '${normalized.substring(0, 4)} ${normalized.substring(4)}';
    }
    return normalized;
  }

  /// Converts Arabic-Indic and Eastern Arabic digits to standard ASCII digits
  static String convertArabicDigitsToLatin(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const ascii = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String res = input;
    for (int i = 0; i < 10; i++) {
      res = res.replaceAll(arabic[i], ascii[i]);
      res = res.replaceAll(persian[i], ascii[i]);
    }
    return res;
  }

  /// Strips all non-digit characters from the input string
  static String stripNonDigits(String input) {
    return convertArabicDigitsToLatin(input).replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Alias for stripNonDigits / sanitize
  static String sanitize(String input) => stripNonDigits(input);
}
