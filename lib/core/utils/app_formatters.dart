import 'package:flutter/services.dart';
export '../../utils/currency_formatter.dart';
export '../../utils/digits_only_input_formatter.dart';
export '../../utils/phone_number_helper.dart';

/// Central facade for input formatters and formatting utilities
class AppFormatters {
  AppFormatters._();

  static final List<TextInputFormatter> digitsOnly = [
    FilteringTextInputFormatter.digitsOnly,
  ];
}

