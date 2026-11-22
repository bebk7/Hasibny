import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Elite Guided Tour Storage Service
/// Handles persistence of tour completion, dismissal, and global auto-tour preferences across app sessions.
class GuidedTourStorage {
  static const String _prefix = 'guided_tour_';
  static const String _keyCompleted = '_completed';
  static const String _keySkipped = '_skipped';
  static const String _keyAutoEnabled = 'guided_tours_auto_enabled';
  static const String _keyGlobalSeen = 'guided_tours_global_seen';

  static GuidedTourStorage? _instance;
  static GuidedTourStorage get instance => _instance ??= GuidedTourStorage._();

  GuidedTourStorage._();

  // In-memory cache for synchronous fast checks
  final Map<String, bool> _completedCache = {};
  final Map<String, bool> _skippedCache = {};
  final RxBool isAutoToursEnabled = false.obs;
  bool _initialized = false;
  bool _globalSeen = false;

  /// Initialize and warm up cache
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    // Check if auto-tours setting exists
    if (prefs.containsKey(_keyAutoEnabled)) {
      isAutoToursEnabled.value = prefs.getBool(_keyAutoEnabled) ?? false;
    } else {
      // For existing users with configured stores or onboarding completed, default to false
      final storeName = prefs.getString('store_name') ?? '';
      final onboarded = prefs.getBool('onboarding_completed') ?? false;
      if (storeName.trim().isNotEmpty || onboarded) {
        isAutoToursEnabled.value = false;
        await prefs.setBool(_keyAutoEnabled, false);
      } else {
        isAutoToursEnabled.value = true;
      }
    }

    _globalSeen = prefs.getBool(_keyGlobalSeen) ?? false;

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

  /// Toggle automatic tour presentation for the entire app
  Future<void> setAutoToursEnabled(bool enabled) async {
    isAutoToursEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoEnabled, enabled);
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

  /// Check whether the tour has already been seen (completed OR skipped OR auto-tours disabled)
  Future<bool> hasTourBeenSeen(String tourId) async {
    if (!isAutoToursEnabled.value) return true;

    final completed = await isTourCompleted(tourId);
    if (completed) return true;
    final skipped = await isTourSkipped(tourId);
    if (skipped) return true;

    return _globalSeen;
  }

  /// Synchronous fast-check if cache is initialized
  bool isTourSeenSync(String tourId) {
    if (!isAutoToursEnabled.value) return true;
    return (_completedCache[tourId] == true) || (_skippedCache[tourId] == true) || _globalSeen;
  }

  /// Mark tour as presented/seen immediately so it never auto-triggers again
  Future<void> markTourSeen(String tourId) async {
    _skippedCache[tourId] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId$_keySkipped', true);
  }

  /// Mark that the user has seen the app tour globally
  Future<void> markGlobalTourSeen() async {
    _globalSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGlobalSeen, true);
  }

  /// Mark tour as completed
  Future<void> markTourCompleted(String tourId) async {
    _completedCache[tourId] = true;
    _skippedCache[tourId] = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId$_keyCompleted', true);
    await prefs.setBool('$_prefix$tourId$_keySkipped', false);
    await markGlobalTourSeen();
  }

  /// Mark tour as skipped
  Future<void> markTourSkipped(String tourId) async {
    _skippedCache[tourId] = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourId$_keySkipped', true);
    await markGlobalTourSeen();
  }

  /// Reset a specific tour's state
  Future<void> resetTour(String tourId) async {
    _completedCache.remove(tourId);
    _skippedCache.remove(tourId);
    _globalSeen = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGlobalSeen);
    await prefs.remove('$_prefix$tourId$_keyCompleted');
    await prefs.remove('$_prefix$tourId$_keySkipped');
  }

  /// Reset all guided tours across the entire application
  Future<void> resetAllTours() async {
    _completedCache.clear();
    _skippedCache.clear();
    _globalSeen = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGlobalSeen);
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
    _globalSeen = false;
    isAutoToursEnabled.value = true;
  }
}
