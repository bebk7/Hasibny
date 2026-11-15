import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central application helper utilities
class AppUtils {
  AppUtils._();

  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }
}

