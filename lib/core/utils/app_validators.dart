import 'package:get/get.dart';

/// Central input form validators
class AppValidators {
  AppValidators._();

  static String? required(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'field_required'.tr;
    }
    return null;
  }

  static String? positiveAmount(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'enter_amount'.tr;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return errorMessage ?? 'valid_amount'.tr;
    }
    return null;
  }

  static String? phone(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'enter_phone_error'.tr;
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 6) {
      return errorMessage ?? 'enter_phone_error'.tr;
    }
    return null;
  }

  static String? email(String? value, [String? errorMessage]) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'enter_email_first'.tr;
    }
    if (!value.contains('@') || !value.contains('.')) {
      return errorMessage ?? 'invalid_email'.tr;
    }
    return null;
  }
}

