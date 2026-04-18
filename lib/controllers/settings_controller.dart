import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyOption {
  final String code;
  final String symbol;
  final String label;
  const CurrencyOption(
      {required this.code, required this.symbol, required this.label});
}

class SettingsController extends GetxController {
  static const _keyLanguage = 'language';
  static const _keyDarkMode = 'dark_mode';
  static const _keyCurrency = 'currency';
  static const _keyStoreName = 'store_name';
  static const _keyStorePhone = 'store_phone';
  static const _keyStoreAddress = 'store_address';
  static const _keyStoreEmail = 'store_email';
  static const _keyStoreTaxNumber = 'store_tax_number';
  static const _keyStoreLogo = 'store_logo';

  final RxString currentLanguage = 'en'.obs;
  final RxBool isDarkMode = false.obs;
  final RxString currentCurrency = 'USD'.obs;

  final RxString storeName = ''.obs;
  final RxString storePhone = ''.obs;
  final RxString storeAddress = ''.obs;
  final RxString storeEmail = ''.obs;
  final RxString storeTaxNumber = ''.obs;
  final RxString storeLogoPath = ''.obs;

  static const List<CurrencyOption> currencies = [
    CurrencyOption(code: 'USD', symbol: '\$', label: 'USD - دولار أمريكي'),
    CurrencyOption(code: 'SAR', symbol: 'ر.س', label: 'SAR - ريال سعودي'),
    CurrencyOption(code: 'YER', symbol: '﷼', label: 'YER - ريال يمني'),
  ];

  bool get isArabic => currentLanguage.value == 'ar';

  String get currencySymbol => currencies
      .firstWhere((c) => c.code == currentCurrency.value,
          orElse: () => currencies[0])
      .symbol;

  String get currencyLabel => currencies
      .firstWhere((c) => c.code == currentCurrency.value,
          orElse: () => currencies[0])
      .label;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_keyLanguage) ?? 'en';
    final dark = prefs.getBool(_keyDarkMode) ?? false;
    final currency = prefs.getString(_keyCurrency) ?? 'USD';

    currentLanguage.value = lang;
    isDarkMode.value = dark;
    currentCurrency.value = currency;

    storeName.value = prefs.getString(_keyStoreName) ?? '';
    storePhone.value = prefs.getString(_keyStorePhone) ?? '';
    storeAddress.value = prefs.getString(_keyStoreAddress) ?? '';
    storeEmail.value = prefs.getString(_keyStoreEmail) ?? '';
    storeTaxNumber.value = prefs.getString(_keyStoreTaxNumber) ?? '';
    storeLogoPath.value = prefs.getString(_keyStoreLogo) ?? '';

    if (lang == 'ar') {
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLanguage() async {
    final newLang = currentLanguage.value == 'en' ? 'ar' : 'en';
    currentLanguage.value = newLang;
    if (newLang == 'ar') {
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, newLang);
  }

  void setLanguage(String lang) async {
    currentLanguage.value = lang;
    if (lang == 'ar') {
      Get.updateLocale(const Locale('ar', 'SA'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  void setCurrency(String code) async {
    currentCurrency.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, code);
  }

  Future<void> saveStoreProfile({
    required String name,
    required String phone,
    required String address,
    required String email,
    required String taxNumber,
    String? logoPath,
  }) async {
    storeName.value = name;
    storePhone.value = phone;
    storeAddress.value = address;
    storeEmail.value = email;
    storeTaxNumber.value = taxNumber;
    if (logoPath != null) storeLogoPath.value = logoPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreName, name);
    await prefs.setString(_keyStorePhone, phone);
    await prefs.setString(_keyStoreAddress, address);
    await prefs.setString(_keyStoreEmail, email);
    await prefs.setString(_keyStoreTaxNumber, taxNumber);
    if (logoPath != null) await prefs.setString(_keyStoreLogo, logoPath);
  }

  Future<void> setStoreLogo(String path) async {
    storeLogoPath.value = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreLogo, path);
  }

  Future<void> removeStoreLogo() async {
    storeLogoPath.value = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStoreLogo);
  }

  void toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDarkMode.value);
  }
}
