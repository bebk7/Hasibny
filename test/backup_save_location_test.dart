import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:account_book/services/backup_service.dart';
import 'package:account_book/services/database_service.dart';
import 'package:account_book/translations/app_translations.dart';
import 'package:account_book/views/settings/settings_view.dart';

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

class MockFilePicker extends FilePicker {
  String? returnSavePath;
  String? lastDialogTitle;
  String? lastFileName;
  Uint8List? lastBytes;
  FileType? lastType;
  List<String>? lastAllowedExtensions;

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    lastDialogTitle = dialogTitle;
    lastFileName = fileName;
    lastType = type;
    lastAllowedExtensions = allowedExtensions;
    lastBytes = bytes;
    return returnSavePath;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late MockFilePicker mockFilePicker;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('backup_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir);
    try {
      await DatabaseService.initialize();
    } catch (_) {}
  });

  tearDownAll(() async {
    try {
      await DatabaseService.close();
    } catch (_) {}
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});

    Get.put(SettingsController());
    Get.put(AuthController());
    Get.put(LockController());
    Get.put(CustomerController());
    Get.put(TransactionController());
    Get.put(DashboardController());
    Get.put(MerchantController());
    Get.put(MerchantShortageController());
    Get.put(InvoiceController());

    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;
  });

  group('Backup Save to User Chosen Location Tests', () {
    test('Translation keys exist in ar and en', () {
      final translations = AppTranslations();
      final ar = translations.keys['ar']!;
      final en = translations.keys['en']!;

      expect(ar['save_to_files'], isNotEmpty);
      expect(ar['choose_backup_save_location'], isNotEmpty);
      expect(ar['backup_saved_success'], isNotEmpty);
      expect(ar['backup_save_canceled'], isNotEmpty);
      expect(ar['share_backup'], isNotEmpty);

      expect(en['save_to_files'], isNotEmpty);
      expect(en['choose_backup_save_location'], isNotEmpty);
      expect(en['backup_saved_success'], isNotEmpty);
      expect(en['backup_save_canceled'], isNotEmpty);
      expect(en['share_backup'], isNotEmpty);
    });

    test('exportAndSaveBackup saves file to path chosen by user and is decryptable', () async {
      const password = 'SuperSecretBackupPassword123';
      final chosenDestination = '${tempDir.path}/user_selected_backup.abbackup';
      mockFilePicker.returnSavePath = chosenDestination;

      final savedPath = await BackupService.exportAndSaveBackup(
        password: password,
      );

      expect(savedPath, equals(chosenDestination));
      expect(mockFilePicker.lastFileName, contains('account_book_backup_'));
      expect(mockFilePicker.lastFileName, endsWith('.abbackup'));
      expect(mockFilePicker.lastAllowedExtensions, equals(['abbackup']));
      expect(mockFilePicker.lastBytes, isNotNull);

      // Verify the file was written to disk
      final savedFile = File(chosenDestination);
      expect(savedFile.existsSync(), isTrue);
      expect(savedFile.lengthSync(), greaterThan(0));

      // Verify the written file is valid encrypted backup data
      final bytes = await savedFile.readAsBytes();
      final decrypted = await BackupService.decryptBackupData(
        backupBytes: bytes,
        password: password,
      );
      expect(decrypted['magic'], equals(BackupService.magicHeader));
    });

    test('exportAndSaveBackup returns null when user cancels file picker', () async {
      const password = 'SuperSecretBackupPassword123';
      mockFilePicker.returnSavePath = null; // User cancelled

      final savedPath = await BackupService.exportAndSaveBackup(
        password: password,
      );

      expect(savedPath, isNull);
    });

    testWidgets('Settings view export backup dialog shows save to files, share and cancel buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar'),
          home: const Scaffold(body: SettingsView()),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap backup tile in settings
      await tester.scrollUntilVisible(find.text('backup_restore_title'.tr), 200);
      await tester.tap(find.text('backup_restore_title'.tr));
      await tester.pumpAndSettle();

      // Tap on export backup option inside dialog
      final exportOption = find.text('تصدير وحفظ ملف .abbackup مشفر في مجلد تختاره');
      expect(exportOption, findsOneWidget);
      await tester.tap(exportOption);
      await tester.pumpAndSettle();

      // Verify export dialog displays primary "تصدير وحفظ في الملفات" button
      expect(find.text('save_to_files'.tr), findsOneWidget);
      expect(find.text('share_backup'.tr), findsOneWidget);
      expect(find.text('cancel'.tr), findsWidgets);

      // Dismiss dialog
      await tester.tap(find.text('cancel'.tr).last);
      await tester.pumpAndSettle();
    });
  });
}
