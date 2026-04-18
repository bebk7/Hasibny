import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'services/database_service.dart';
import 'controllers/customer_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/lock_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/merchant_controller.dart';
import 'controllers/invoice_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/merchant_shortage_controller.dart';
import 'themes/app_theme.dart';
import 'translations/app_translations.dart';
import 'views/auth/auth_view.dart';
import 'views/auth/email_verification_view.dart';
import 'views/home/home_view.dart';
import 'views/lock/lock_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AccountBookApp());
}

class AccountBookApp extends StatefulWidget {
  const AccountBookApp({super.key});

  @override
  State<AccountBookApp> createState() => _AccountBookAppState();
}

class _AccountBookAppState extends State<AccountBookApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize database
    await DatabaseService.initialize();

    // Initialize controllers
    Get.put(SettingsController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(InvoiceController());
    Get.put(MerchantShortageController());
    Get.put(AuthController());

    // Remove splash and show app
    FlutterNativeSplash.remove();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF1565C0),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    final settingsController = Get.find<SettingsController>();
    return Obx(() {
      final isArabic = settingsController.isArabic;
      final isDark = settingsController.isDarkMode.value;
      return GetMaterialApp(
        title: 'Hasibny',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        translations: AppTranslations(),
        locale: isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US'),
        fallbackLocale: const Locale('en', 'US'),
        builder: (context, child) => Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
        home: Obx(() {
          final ac = Get.find<AuthController>();
          final lc = Get.find<LockController>();
          if (ac.firebaseUser.value == null) {
            return const AuthView();
          }
          if (!ac.isEmailVerified.value) {
            return const EmailVerificationView();
          }
          if (lc.isLockEnabled && !lc.isUnlocked.value) {
            return const LockView();
          }
          return const HomeView();
        }),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      );
    });
  }
}
