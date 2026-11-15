import 'package:flutter_test/flutter_test.dart';
import 'package:account_book/utils/phone_number_helper.dart';

void main() {
  group('PhoneNumberHelper Tests', () {
    test('Converts Arabic-Indic digits to Latin digits', () {
      expect(PhoneNumberHelper.convertArabicDigitsToLatin('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(PhoneNumberHelper.convertArabicDigitsToLatin('٧٧١٢٣٤٥٦٧'), '771234567');
    });

    test('Normalizes Yemen numbers correctly to E.164', () {
      expect(PhoneNumberHelper.normalizeToE164('771234567'), '+967771234567');
      expect(PhoneNumberHelper.normalizeToE164('0771234567'), '+967771234567');
      expect(PhoneNumberHelper.normalizeToE164('00967771234567'), '+967771234567');
      expect(PhoneNumberHelper.normalizeToE164('+967771234567'), '+967771234567');
      expect(PhoneNumberHelper.normalizeToE164('٧٧١٢٣٤٥٦٧'), '+967771234567');
    });

    test('Normalizes Saudi numbers correctly to E.164', () {
      expect(PhoneNumberHelper.normalizeToE164('0501234567', defaultCountryCode: '+966'), '+966501234567');
      expect(PhoneNumberHelper.normalizeToE164('+966501234567'), '+966501234567');
      expect(PhoneNumberHelper.normalizeToE164('00966501234567'), '+966501234567');
    });

    test('Validates E.164 phone numbers correctly', () {
      expect(PhoneNumberHelper.isValidE164('+967771234567'), true);
      expect(PhoneNumberHelper.isValidE164('+966501234567'), true);
      expect(PhoneNumberHelper.isValidE164('+14155552671'), true);
      expect(PhoneNumberHelper.isValidE164('123'), false);
      expect(PhoneNumberHelper.isValidE164('invalid_phone'), false);
    });

    test('Formats numbers for display nicely', () {
      final formattedYemen = PhoneNumberHelper.formatForDisplay('771234567');
      expect(formattedYemen, '+967 77 123 4567');

      final formattedSaudi = PhoneNumberHelper.formatForDisplay('+966501234567');
      expect(formattedSaudi, '+966 50 123 4567');
    });
  });
}
