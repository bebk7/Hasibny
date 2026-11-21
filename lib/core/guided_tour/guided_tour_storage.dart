import 'package:shared_preferences/shared_preferences.dart';

/// Elite Guided Tour Storage Service
/// Handles persistence of tour completion and dismissal states across app sessions.
class GuidedTourStorage {
  static const String _prefix = 'guided_tour_';
  static const String _keyCompleted = '_completed';
  static const String _keySkipped = '_skipped';

  static GuidedTourStorage? _instance;
  static GuidedTourStorage get instance => _instance ??= GuidedTourStorage._();

  GuidedTourStorage._();

  // In-memory cache for synchronous fast checks
  final Map<String, bool> _completedCache = {};
  final Map<String, bool> _skippedCache = {};
  bool _initialized = false;

  /// Initialize and warm up cache
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        if (key.endsWith(_keyCompleted)) {
          final tourId = key.substring(_prefix.length, key.length - _keyCompleted.length);
          _completedCache[tourId] = prefs.getBool(key) ?? false;
        } else if (key.endsWith(_keySkipped)) {
          final tourId = key.substring(_prefix.length, key.length - _keySkipped.length);
          _skippedCache[tourId] = prefs.getBool(key) ?? false;
        }
      }
    }
    _initialized = true;
  }

  /// Check whether a tour has been completed
  Future<bool> isTourCompleted(String tourId) async {
    if (_completedCache.containsKey(tourId)) {
      return _completedCache[tourId]!;
    }
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool('$_prefix$tourId$_keyCompleted') ?? false;
    _completedCache[tourId] = val;
    return val;
  }

  /// Check whether a tour was skipped
  Future<bool> isTourSkipped(String tourId) async {
    if (_skippedCache.containsKey(tourId)) {
      return _skippedCache[tourId]!;
    }
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool('$_prefix$tourId$_keySkipped') ?? false;
    _skippedCache[tourId] = val;
    return val;
  }

  /// Check whether the tour has already been seen (completed OR skipped)
  Future<bool> hasTourBeenSeen(String tourId) async {
    final completed = await isTourCompleted(tourId);
    if (completed) return true;
    final skipped = await isTourSkipped(tourId);
    return skipped;
  }

  /// Synchronous fast-check if cache is initialized
  bool isTourSeenSync(String tourId) {
    return (_completedCache[tourId] == true) || (_skippedCache[tourId] == true);
  }

  /// Mark tour as completed
  Future<void> markTourCompleted(String tourId) async {
    _completedCache[tourId] = true;
    _skippedCache[tourId] = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId$_keyCompleted', true);
    await prefs.setBool('$_prefix$tourId$_keySkipped', false);
  }

  /// Mark tour as skipped
  Future<void> markTourSkipped(String tourId) async {
    _skippedCache[tourId] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId$_keySkipped', true);
  }

  /// Reset a specific tour's state
  Future<void> resetTour(String tourId) async {
    _completedCache.remove(tourId);
    _skippedCache.remove(tourId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tourId$_keyCompleted');
    await prefs.remove('$_prefix$tourId$_keySkipped');
  }

  /// Reset all guided tours across the entire application
  Future<void> resetAllTours() async {
    _completedCache.clear();
    _skippedCache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Clear memory cache (useful for testing)
  void clearCacheForTesting() {
    _completedCache.clear();
    _skippedCache.clear();
    _initialized = false;
  }
}
