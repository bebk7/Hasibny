import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:account_book/controllers/auth_controller.dart';
import 'package:account_book/controllers/customer_controller.dart';
import 'package:account_book/controllers/dashboard_controller.dart';
import 'package:account_book/controllers/invoice_controller.dart';
import 'package:account_book/controllers/lock_controller.dart';
import 'package:account_book/controllers/merchant_controller.dart';
import 'package:account_book/controllers/merchant_shortage_controller.dart';
import 'package:account_book/controllers/settings_controller.dart';
import 'package:account_book/controllers/transaction_controller.dart';
import 'package:account_book/core/core.dart';
import 'package:account_book/services/backup_service.dart';
import 'package:account_book/translations/app_translations.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  final Directory tempDir;
  MockPathProviderPlatform(this.tempDir);

  @override
  Future<String?> getTemporaryPath() async => tempDir.path;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;

  @override
  Future<String?> getApplicationSupportPath() async => tempDir.path;
}

class TestableDashboardController extends DashboardController {
  int reloadCount = 0;
  bool reloadCalled = false;

  @override
  Future<void> loadDashboardData() async {
    reloadCount++;
    reloadCalled = true;
    totalCustomers.value = 1;
    currencyTotals['YER'] = {'toGive': 25000.0, 'toGet': 0.0, 'net': -25000.0};
  }
}

Future<Uint8List> createMockEncryptedBackup({
  required String password,
  int iterations = 1000,
}) async {
  final aesGcm = AesGcm.with256bits();
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  );

  final salt = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160];
  final secretKey = await pbkdf2.deriveKeyFromPassword(
    password: password,
    nonce: salt,
  );

  final payload = {
    'magic': BackupService.magicHeader,
    'version': 1,
    'app': 'Hasibny Account Book',
    'exportedAt': DateTime.now().toIso8601String(),
    'customers': [
      {'id': 1, 'name': 'أحمد سعيد', 'phoneNumber': '+966500000000', 'currencyCode': 'YER'}
    ],
    'transactions': [
      {'id': 1, 'amount': 25000.0, 'type': 'give', 'description': 'دفعة سابقة', 'currencyCode': 'YER', 'customerId': 1}
    ],
    'merchants': [],
    'invoices': [],
    'shortages': [],
  };

  final plaintext = utf8.encode(jsonEncode(payload));
  final nonce = aesGcm.newNonce();
  final secretBox = await aesGcm.encrypt(
    plaintext,
    secretKey: secretKey,
    nonce: nonce,
  );

  final container = {
    'magic': BackupService.magicHeader,
    'version': 1,
    'kdf': 'PBKDF2-HMAC-SHA256',
    'iterations': iterations,
    'cipher': 'AES-256-GCM',
    'salt': base64Encode(salt),
    'nonce': base64Encode(secretBox.nonce),
    'mac': base64Encode(secretBox.mac.bytes),
    'ciphertext': base64Encode(secretBox.cipherText),
    'exportedAt': payload['exportedAt'],
  };

  return Uint8List.fromList(utf8.encode(jsonEncode(container)));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('backup_test_dir_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    GuidedTourStorage.instance.clearCacheForTesting();

    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('ar', 'SA');

    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put<DashboardController>(TestableDashboardController());
    Get.put(MerchantController());
    Get.put(MerchantShortageController());
    Get.put(InvoiceController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Guided Tour Root-Cause Fix Tests', () {
    test('Existing user with configured store or onboarded status defaults to autoTours disabled', () async {
      SharedPreferences.setMockInitialValues({
        'store_name': 'مؤسسة التجارة الحديثة',
        'onboarding_completed': true,
      });

      final storage = GuidedTourStorage.instance;
      storage.clearCacheForTesting();
      await storage.init();

      // Auto-tours must be false for existing users to protect them from intrusive popups
      expect(storage.isAutoToursEnabled.value, isFalse);

      // All tours should report as already seen
      expect(await storage.hasTourBeenSeen(AppTours.dashboardTourId), isTrue);
      expect(await storage.hasTourBeenSeen(AppTours.customersTourId), isTrue);
      expect(await storage.hasTourBeenSeen(AppTours.transactionsTourId), isTrue);
      expect(await storage.hasTourBeenSeen(AppTours.settingsTourId), isTrue);
    });

    test('Fresh user enables auto-tours, and presenting a tour marks it immediately seen', () async {
      SharedPreferences.setMockInitialValues({});

      final storage = GuidedTourStorage.instance;
      storage.clearCacheForTesting();
      await storage.init();

      expect(storage.isAutoToursEnabled.value, isTrue);
      expect(await storage.hasTourBeenSeen(AppTours.dashboardTourId), isFalse);

      // Mark seen immediately (as done on first presentation)
      await storage.markTourSeen(AppTours.dashboardTourId);
      expect(await storage.hasTourBeenSeen(AppTours.dashboardTourId), isTrue);

      // Even on subsequent sessions without completing all steps, it remains seen
      expect(await storage.hasTourBeenSeen(AppTours.dashboardTourId), isTrue);
    });

    test('User can toggle auto-tours in settings', () async {
      final storage = GuidedTourStorage.instance;
      await storage.setAutoToursEnabled(false);
      expect(storage.isAutoToursEnabled.value, isFalse);
      expect(await storage.hasTourBeenSeen('any_tour'), isTrue);

      await storage.setAutoToursEnabled(true);
      expect(storage.isAutoToursEnabled.value, isTrue);
    });

    test('Skipping a tour marks global tour seen and prevents sequential popups', () async {
      final storage = GuidedTourStorage.instance;
      storage.clearCacheForTesting();
      await storage.init();

      await GuidedTourManager.instance.skip();
      expect(await storage.hasTourBeenSeen(AppTours.dashboardTourId), isTrue);
      expect(await storage.hasTourBeenSeen(AppTours.customersTourId), isTrue);
    });
  });

  group('Backup Restore Immediate Dashboard Update Tests', () {
    test('BackupService.restoreBackup immediately reloads DashboardController totals', () async {
      final dc = Get.find<DashboardController>() as TestableDashboardController;

      // Reset test counters after onInit
      dc.reloadCalled = false;
      dc.reloadCount = 0;
      dc.totalCustomers.value = 0;
      dc.currencyTotals['YER'] = {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0};

      expect(dc.reloadCalled, isFalse);
      expect(dc.reloadCount, equals(0));

      const password = 'TestPassword123!';
      final backupBytes = await createMockEncryptedBackup(password: password);

      // Restore backup using BackupService.restoreBackup
      final summary = await BackupService.restoreBackup(
        backupBytes: backupBytes,
        password: password,
      );

      expect(summary.customersCount, equals(1));
      expect(summary.transactionsCount, equals(1));

      // Verify that DashboardController.loadDashboardData was called immediately during restore
      expect(dc.reloadCalled, isTrue);
      expect(dc.reloadCount, greaterThanOrEqualTo(1));
      expect(dc.totalCustomers.value, equals(1));
      expect(dc.currentToGive, equals(25000.0));
    });
  });
}
