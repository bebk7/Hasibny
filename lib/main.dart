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
import 'controllers/onboarding_controller.dart';
import 'themes/app_theme.dart';
import 'translations/app_translations.dart';
import 'views/auth/auth_view.dart';
import 'views/auth/email_verification_view.dart';
import 'views/home/home_view.dart';
import 'views/lock/lock_view.dart';
import 'views/onboarding/onboarding_view.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // 1. Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Initialize Database
    await DatabaseService.initialize();

    // 3. Register Controllers
    Get.put(SettingsController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(InvoiceController());
    Get.put(MerchantShortageController());
    Get.put(AuthController());
    final onboardingController = Get.put(OnboardingController());

    // 4. Check onboarding status (handles existing installations seamlessly)
    await onboardingController.checkOnboardingStatus();
  } catch (e, stack) {
    debugPrint('App initialization error: $e\n$stack');
  } finally {
    // Remove native splash screen now that app is ready to render directly
    FlutterNativeSplash.remove();
  }

  runApp(const AccountBookApp());
}

class AccountBookApp extends StatelessWidget {
  const AccountBookApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final clampedScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.25,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            ),
          );
        },
        home: Obx(() {
          final oc = Get.find<OnboardingController>();
          final ac = Get.find<AuthController>();
          final lc = Get.find<LockController>();

          // 1. First-Run Onboarding (if not completed)
          if (!oc.isOnboarded.value) {
            return const OnboardingView();
          }

          // 2. App Lock
          if (lc.isLockEnabled && !lc.isUnlocked.value) {
            return const LockView();
          }

          // 3. Logged-in User
          if (ac.isLoggedIn) {
            if (!ac.isEmailVerified.value) {
              return const EmailVerificationView();
            }
            return const HomeView();
          }

          // 4. Guest Mode
          if (ac.isGuestMode.value) {
            return const HomeView();
          }

          // 5. Auth / Login
          return const AuthView();
        }),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      );
    });
  }
}
