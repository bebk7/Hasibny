import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/settings_controller.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';
import '../utils/phone_number_helper.dart';

class OnboardingController extends GetxController {
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyStoreNotes = 'store_notes';

  final RxBool isOnboarded = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkOnboardingStatus();
  }

  /// Checks if onboarding is completed.
  /// Seamlessly migrates existing installations with configured stores or existing data.
  Future<bool> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool? completed = prefs.getBool(keyOnboardingCompleted);

      if (completed == true) {
        isOnboarded.value = true;
        return true;
      }

      // Check for existing installation to protect current users
      final storeName = prefs.getString('store_name') ?? '';
      final hasStore = storeName.trim().isNotEmpty;

      bool hasData = false;
      try {
        final customers = await DatabaseService.getAllCustomers();
        final merchants = await DatabaseService.getAllMerchants();
        hasData = customers.isNotEmpty || merchants.isNotEmpty;
      } catch (_) {}

      if (hasStore || hasData) {
        await prefs.setBool(keyOnboardingCompleted, true);
        isOnboarded.value = true;
        return true;
      }

      isOnboarded.value = false;
      return false;
    } catch (_) {
      // Default to false so onboarding is presented if uninitialized
      isOnboarded.value = false;
      return false;
    }
  }

  /// Convenience alias for createStore
  Future<bool> createStoreProfile({
    required String name,
    required String fullPhoneNumber,
    required String defaultCurrencyCode,
    String? address,
    String? notes,
    String? logoPath,
  }) {
    return createStore(
      name: name,
      phone: fullPhoneNumber,
      countryCode: '',
      currencyCode: defaultCurrencyCode,
      address: address,
      notes: notes,
      logoPath: logoPath,
    );
  }

  /// Creates a new store record and marks onboarding as completed
  Future<bool> createStore({
    required String name,
    required String phone,
    required String countryCode,
    required String currencyCode,
    String? address,
    String? notes,
    String? logoPath,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      errorMessage.value = 'store_name_validation'.tr;
      return false;
    }

    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) {
      errorMessage.value = 'enter_valid_phone'.tr;
      return false;
    }

    final normalizedPhone = PhoneNumberHelper.normalizeToE164(
      cleanPhone,
      defaultCountryCode: countryCode,
    );

    if (!PhoneNumberHelper.isValidE164(normalizedPhone)) {
      errorMessage.value = 'enter_valid_phone'.tr;
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final sc = Get.find<SettingsController>();
      await sc.saveStoreProfile(
        name: cleanName,
        phone: normalizedPhone,
        address: address?.trim() ?? '',
        email: '',
        taxNumber: '',
        logoPath: logoPath,
      );
      sc.setCurrency(currencyCode);

      final prefs = await SharedPreferences.getInstance();
      if (notes != null && notes.trim().isNotEmpty) {
        await prefs.setString(keyStoreNotes, notes.trim());
      }
      await prefs.setBool(keyOnboardingCompleted, true);

      isOnboarded.value = true;
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'store_create_failed'.tr;
      return false;
    }
  }

  /// Restores a verified backup file and marks onboarding as completed
  Future<BackupRestoreSummary> restoreBackup({
    required File backupFile,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final bytes = await backupFile.readAsBytes();
      final summary = await BackupService.restoreBackup(
        backupBytes: bytes,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyOnboardingCompleted, true);

      isOnboarded.value = true;
      isLoading.value = false;
      return summary;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      rethrow;
    }
  }
}
