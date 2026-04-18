import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockController extends GetxController {
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyBioEnabled = 'bio_enabled';
  static const _keyPin = 'app_pin';

  final RxBool isPinEnabled = false.obs;
  final RxBool isBioEnabled = false.obs;
  final RxBool isUnlocked = false.obs;
  final RxBool bioAvailable = false.obs;

  final _auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _checkBioAvailability();
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

  Future<void> _checkBioAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      bioAvailable.value = canCheck && isDeviceSupported;
    } catch (_) {
      bioAvailable.value = false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'biometric_reason'.tr,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (result) isUnlocked.value = true;
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPinAsync(String entered) async {
    final saved = await _getSavedPin();
    final ok = saved == entered;
    if (ok) isUnlocked.value = true;
    return ok;
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
