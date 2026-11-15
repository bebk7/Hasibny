import 'dart:math' as math;

/// Dynamic dimension and font scaling utilities with strict safety bounds
class AppScaling {
  AppScaling._();

  /// Calculates a bounded font size based on text scale factor and screen width factor
  static double scaleFont(
    double baseSize, {
    required double widthFactor,
    required double textScaleFactor,
    double? min,
    double? max,
  }) {
    final calculated = baseSize * widthFactor * textScaleFactor;
    final minBound = min ?? (baseSize * 0.80);
    final maxBound = max ?? (baseSize * 1.30);
    return calculated.clamp(minBound, maxBound);
  }

  /// Calculates a bounded dynamic dimension based on a base value and scale factor
  static double scaleDimension(
    double baseValue, {
    required double scaleFactor,
    double? min,
    double? max,
  }) {
    final calculated = baseValue * scaleFactor;
    final minBound = min ?? (baseValue * 0.75);
    final maxBound = max ?? (baseValue * 1.50);
    return calculated.clamp(minBound, maxBound);
  }

  /// Clamps a numeric value safely between a min and max
  static double clamp(double value, double min, double max) {
    if (min > max) {
      return math.min(min, math.max(value, max));
    }
    return value.clamp(min, max);
  }
}

