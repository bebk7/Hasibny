import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_theme.dart';

class LockController extends GetxController with WidgetsBindingObserver {
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyBioEnabled = 'bio_enabled';
  static const _keyPin = 'app_pin';

  final RxBool isPinEnabled = false.obs;
  final RxBool isBioEnabled = false.obs;
  final RxBool isUnlocked = false.obs;
  final RxBool bioAvailable = false.obs;
  final RxBool isHardwareSupported = false.obs;
  final RxBool hasEnrolledBiometrics = false.obs;
  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;
  final RxBool isCheckingBiometrics = false.obs;

  final _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  DateTime? _pausedAt;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    checkBioAvailability();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (!_isAuthenticating) {
        _pausedAt = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isAuthenticating) {
        // Dialog or biometric prompt triggered lifecycle change; do not lock.
        return;
      }
      if (_pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!);
        _pausedAt = null;
        // Re-lock if lock is enabled and app was in background for > 500ms
        if (isLockEnabled && elapsed.inMilliseconds >= 500) {
          lock();
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isPinEnabled.value = prefs.getBool(_keyPinEnabled) ?? false;
    isBioEnabled.value = prefs.getBool(_keyBioEnabled) ?? false;
    // If no lock enabled, consider unlocked
    if (!isPinEnabled.value && !isBioEnabled.value) {
      isUnlocked.value = true;
    }
  }

  Future<void> checkBioAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      isHardwareSupported.value = canCheck && isDeviceSupported;

      final types = await _auth.getAvailableBiometrics();
      availableBiometrics.assignAll(types);
      hasEnrolledBiometrics.value = types.isNotEmpty;
      bioAvailable.value = isHardwareSupported.value && hasEnrolledBiometrics.value;
    } catch (_) {
      isHardwareSupported.value = false;
      hasEnrolledBiometrics.value = false;
      bioAvailable.value = false;
    }
  }

  String get biometricName {
    final isAr = Get.locale?.languageCode == 'ar';
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return isAr ? 'بصمة الإصبع' : 'Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.face)) {
      return isAr ? 'بصمة الوجه' : 'Face ID';
    }
    return isAr ? 'البصمة الحيوية' : 'Biometrics';
  }

  Future<bool> authenticateWithBiometrics() async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;
    isCheckingBiometrics.value = true;
    try {
      final result = await _auth.authenticate(
        localizedReason: 'biometric_reason'.tr,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (result) {
        isUnlocked.value = true;
      }
      return result;
    } catch (e) {
      return false;
    } finally {
      isCheckingBiometrics.value = false;
      Future.delayed(const Duration(milliseconds: 600), () {
        _isAuthenticating = false;
      });
    }
  }

  Future<bool> requestEnableBiometrics() async {
    if (_isAuthenticating) return false;
    await checkBioAvailability();
    try {
      if (!isHardwareSupported.value) {
        Get.snackbar(
          'error'.tr,
          'biometric_not_supported'.tr,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (!hasEnrolledBiometrics.value) {
        Get.snackbar(
          'error'.tr,
          'biometric_not_enrolled'.tr,
          backgroundColor: AppTheme.warningColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      _isAuthenticating = true;
      final success = await _auth.authenticate(
        localizedReason: 'biometric_auth_reason'.tr,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (success) {
        await toggleBiometric(true);
        Get.snackbar(
          'success'.tr,
          'biometric_activated'.tr,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'error'.tr,
          'biometric_auth_failed'.tr,
          backgroundColor: AppTheme.errorColor,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'biometric_auth_failed'.tr,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        _isAuthenticating = false;
      });
    }
  }

  Future<bool> requestDisableBiometrics() async {
    if (_isAuthenticating) return false;
    _isAuthenticating = true;
    try {
      final success = await _auth.authenticate(
        localizedReason: 'biometric_verify_to_disable'.tr,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (success) {
        await toggleBiometric(false);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 600), () {
        _isAuthenticating = false;
      });
    }
  }

  Future<bool> verifyPinAsync(String entered) async {
    final saved = await _getSavedPin();
    final ok = saved == entered;
    if (ok) isUnlocked.value = true;
    return ok;
  }

  Future<bool> verifyCurrentPin(String entered) async {
    final saved = await _getSavedPin();
    return saved != null && saved == entered;
  }

  Future<String?> _getSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
    isPinEnabled.value = true;
    await prefs.setBool(_keyPinEnabled, true);
  }

  Future<void> removePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
    isPinEnabled.value = false;
    await prefs.setBool(_keyPinEnabled, false);
    if (!isBioEnabled.value) isUnlocked.value = true;
  }

  Future<void> toggleBiometric(bool value) async {
    isBioEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBioEnabled, value);
    if (!isPinEnabled.value && !value) isUnlocked.value = true;
  }

  bool get isLockEnabled => isPinEnabled.value || isBioEnabled.value;

  void lock() {
    if (isLockEnabled) isUnlocked.value = false;
  }
}
