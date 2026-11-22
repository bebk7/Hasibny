import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/customer_controller.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/merchant_controller.dart';
import '../controllers/merchant_shortage_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/invoice_controller.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/invoice.dart';
import '../models/merchant_shortage.dart';
import 'database_service.dart';

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);

  @override
  String toString() => message;
}

class BackupRestoreSummary {
  final int customersCount;
  final int transactionsCount;
  final int merchantsCount;
  final int invoicesCount;
  final int shortagesCount;
  final DateTime exportedAt;

  const BackupRestoreSummary({
    required this.customersCount,
    required this.transactionsCount,
    required this.merchantsCount,
    required this.invoicesCount,
    required this.shortagesCount,
    required this.exportedAt,
  });
}

class BackupService {
  static const String magicHeader = 'AB_BACKUP_V1';
  static const int kdfIterations = 100000;
  static const int saltLength = 16;
  static const int minPasswordLength = 6;

  static final _aesGcm = AesGcm.with256bits();
  static final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: kdfIterations,
    bits: 256,
  );

  /// Generates cryptographically secure random bytes
  static List<int> _generateSecureSalt(int length) {
    final rnd = Random.secure();
    return List<int>.generate(length, (_) => rnd.nextInt(256));
  }

  /// Exports an authenticated, AES-256-GCM encrypted database backup
  static Future<File> exportBackup({required String password}) async {
    final cleanPassword = password.trim();
    if (cleanPassword.length < minPasswordLength) {
      throw BackupException('backup_password_too_short'.tr);
    }

    // 1. Gather all collections
    List<Customer> customers = [];
    List<TransactionModel> transactions = [];
    List<Merchant> merchants = [];
    List<Invoice> invoices = [];
    List<MerchantShortage> shortages = [];

    if (DatabaseService.isInitialized) {
      customers = await DatabaseService.getAllCustomers();
      transactions = await DatabaseService.getAllTransactions();
      merchants = await DatabaseService.getAllMerchants();
      invoices = await DatabaseService.getAllInvoices();
      shortages = await DatabaseService.getAllShortages();
    } else {
      try {
        await DatabaseService.initialize();
        if (DatabaseService.isInitialized) {
          customers = await DatabaseService.getAllCustomers();
          transactions = await DatabaseService.getAllTransactions();
          merchants = await DatabaseService.getAllMerchants();
          invoices = await DatabaseService.getAllInvoices();
          shortages = await DatabaseService.getAllShortages();
        }
      } catch (_) {
        // Fallback for headless environments without native binaries
      }
    }

    // 2. Build payload
    final payloadMap = {
      'magic': magicHeader,
      'version': 1,
      'app': 'Hasibny Account Book',
      'exportedAt': DateTime.now().toIso8601String(),
      'customers': customers.map((c) => {
        'id': c.id,
        'firestoreId': c.firestoreId,
        'isSynced': c.isSynced,
        'name': c.name,
        'phoneNumber': c.phoneNumber,
        'profilePicturePath': c.profilePicturePath,
        'currencyCode': c.currencyCode,
        'autoSendInvoiceWhatsApp': c.autoSendInvoiceWhatsApp,
        'whatsappNumber': c.whatsappNumber,
        'createdAt': c.createdAt.toIso8601String(),
        'updatedAt': c.updatedAt.toIso8601String(),
      }).toList(),
      'transactions': transactions.map((t) => {
        'id': t.id,
        'firestoreId': t.firestoreId,
        'isSynced': t.isSynced,
        'amount': t.amount,
        'type': t.type.name,
        'description': t.description,
        'currencyCode': t.currencyCode,
        'createdAt': t.createdAt.toIso8601String(),
        'customerId': t.customerId,
      }).toList(),
      'merchants': merchants.map((m) => {
        'id': m.id,
        'firestoreId': m.firestoreId,
        'isSynced': m.isSynced,
        'name': m.name,
        'phone': m.phone,
        'address': m.address,
        'notes': m.notes,
        'createdAt': m.createdAt.toIso8601String(),
        'updatedAt': m.updatedAt.toIso8601String(),
      }).toList(),
      'invoices': invoices.map((inv) => {
        'id': inv.id,
        'firestoreId': inv.firestoreId,
        'isSynced': inv.isSynced,
        'merchantId': inv.merchantId,
        'customerId': inv.customerId,
        'invoiceNumber': inv.invoiceNumber,
        'totalAmount': inv.totalAmount,
        'paidAmount': inv.paidAmount,
        'currencyCode': inv.currencyCode,
        'notes': inv.notes,
        'itemsJson': inv.itemsJson,
        'whatsappSendingEnabled': inv.whatsappSendingEnabled,
        'whatsappStatus': inv.whatsappStatus,
        'whatsappMessageId': inv.whatsappMessageId,
        'whatsappSentAt': inv.whatsappSentAt?.toIso8601String(),
        'whatsappError': inv.whatsappError,
        'pdfUrl': inv.pdfUrl,
        'idempotencyKey': inv.idempotencyKey,
        'date': inv.date.toIso8601String(),
        'createdAt': inv.createdAt.toIso8601String(),
        'updatedAt': inv.updatedAt.toIso8601String(),
      }).toList(),
      'shortages': shortages.map((s) => {
        'id': s.id,
        'firestoreId': s.firestoreId,
        'isSynced': s.isSynced,
        'merchantId': s.merchantId,
        'isResolved': s.isResolved,
        'productName': s.productName,
        'quantity': s.quantity,
        'note': s.note,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
      }).toList(),
    };

    final plaintextBytes = utf8.encode(jsonEncode(payloadMap));

    // 3. Cryptographic key derivation (PBKDF2-HMAC-SHA256)
    final salt = _generateSecureSalt(saltLength);
    final secretKey = await _pbkdf2.deriveKeyFromPassword(
      password: cleanPassword,
      nonce: salt,
    );

    // 4. Authenticated encryption (AES-256-GCM)
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      plaintextBytes,
      secretKey: secretKey,
      nonce: nonce,
    );

    // 5. Build envelope container
    final container = {
      'magic': magicHeader,
      'version': 1,
      'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': kdfIterations,
      'cipher': 'AES-256-GCM',
      'salt': base64Encode(salt),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'ciphertext': base64Encode(secretBox.cipherText),
      'exportedAt': payloadMap['exportedAt'],
      'meta': {
        'customers': customers.length,
        'transactions': transactions.length,
        'merchants': merchants.length,
        'invoices': invoices.length,
        'shortages': shortages.length,
      },
    };

    final containerBytes = utf8.encode(jsonEncode(container));
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/account_book_backup_$timestamp.abbackup');
    await file.writeAsBytes(containerBytes, flush: true);

    return file;
  }

  /// Exports backup and prompts the user to select the destination file/folder to save it.
  /// Returns the saved file path, or `null` if the user aborted the picker.
  static Future<String?> exportAndSaveBackup({
    required String password,
    String? customFileName,
  }) async {
    final file = await exportBackup(password: password);
    final bytes = await file.readAsBytes();

    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final defaultFileName = customFileName ?? 'account_book_backup_$dateStr.abbackup';

    String? savedPath;
    try {
      savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'choose_backup_save_location'.tr,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['abbackup'],
        bytes: bytes,
      );
    } catch (_) {
      try {
        final selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'choose_backup_save_location'.tr,
        );
        if (selectedDirectory != null) {
          savedPath = '$selectedDirectory/$defaultFileName';
        }
      } catch (_) {
        rethrow;
      }
    }

    if (savedPath == null) {
      return null;
    }

    try {
      final destFile = File(savedPath);
      if (!await destFile.exists() || (await destFile.length()) == 0) {
        await destFile.writeAsBytes(bytes, flush: true);
      }
    } catch (_) {
      // Content URI or platform-managed path
    }

    return savedPath;
  }

  /// Exports backup and invokes the system share sheet
  static Future<void> exportAndShareBackup({required String password}) async {
    final file = await exportBackup(password: password);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Account Book Backup (.abbackup)',
      ),
    );
  }

  /// Decrypts and authenticates backup bytes without mutating the database
  static Future<Map<String, dynamic>> decryptBackupData({
    required Uint8List backupBytes,
    required String password,
  }) async {
    final cleanPassword = password.trim();
    if (cleanPassword.isEmpty) {
      throw BackupException('backup_password_empty'.tr);
    }

    // 1. Decode container
    Map<String, dynamic> container;
    try {
      final jsonString = utf8.decode(backupBytes);
      container = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('backup_invalid_file_format'.tr);
    }

    if (container['magic'] != magicHeader) {
      throw BackupException('backup_invalid_file_format'.tr);
    }

    final saltBase64 = container['salt'] as String?;
    final nonceBase64 = container['nonce'] as String?;
    final macBase64 = container['mac'] as String?;
    final ciphertextBase64 = container['ciphertext'] as String?;
    final iterations = (container['iterations'] as num?)?.toInt() ?? kdfIterations;

    if (saltBase64 == null || nonceBase64 == null || macBase64 == null || ciphertextBase64 == null) {
      throw BackupException('backup_corrupted_format'.tr);
    }

    final salt = base64Decode(saltBase64);
    final nonce = base64Decode(nonceBase64);
    final macBytes = base64Decode(macBase64);
    final ciphertext = base64Decode(ciphertextBase64);

    // 2. Derive key using envelope iterations
    final pbkdf2 = iterations == kdfIterations
        ? _pbkdf2
        : Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: iterations,
            bits: 256,
          );

    final secretKey = await pbkdf2.deriveKeyFromPassword(
      password: cleanPassword,
      nonce: salt,
    );

    // 3. Authenticate and decrypt AES-256-GCM
    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    List<int> decryptedBytes;
    try {
      decryptedBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
    } on SecretBoxAuthenticationError {
      throw BackupException('backup_decrypt_failed'.tr);
    } catch (e) {
      throw BackupException('backup_decrypt_failed'.tr);
    }

    // 4. Parse & validate inner payload
    try {
      final payloadString = utf8.decode(decryptedBytes);
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;

      if (payload['magic'] != magicHeader) {
        throw BackupException('backup_invalid_payload'.tr);
      }
      if (!payload.containsKey('customers') || !payload.containsKey('transactions')) {
        throw BackupException('backup_missing_collections'.tr);
      }

      return payload;
    } catch (e) {
      if (e is BackupException) rethrow;
      throw BackupException('backup_invalid_payload'.tr);
    }
  }

  /// Restores all data atomically from verified backup bytes
  static Future<BackupRestoreSummary> restoreBackup({
    required Uint8List backupBytes,
    required String password,
  }) async {
    final payload = await decryptBackupData(
      backupBytes: backupBytes,
      password: password,
    );

    // Deserialization with strict schema preservation
    final rawCustomers = (payload['customers'] as List? ?? []);
    final rawTransactions = (payload['transactions'] as List? ?? []);
    final rawMerchants = (payload['merchants'] as List? ?? []);
    final rawInvoices = (payload['invoices'] as List? ?? []);
    final rawShortages = (payload['shortages'] as List? ?? []);

    final customers = rawCustomers.map((m) {
      final c = Customer(
        name: m['name'] ?? '',
        phoneNumber: m['phoneNumber'] ?? '',
        profilePicturePath: m['profilePicturePath'],
        currencyCode: m['currencyCode'] ?? 'YER',
        autoSendInvoiceWhatsApp: m['autoSendInvoiceWhatsApp'] ?? false,
        whatsappNumber: m['whatsappNumber'],
      );
      if (m['id'] != null) c.id = m['id'];
      c.firestoreId = m['firestoreId'];
      c.isSynced = m['isSynced'] ?? false;
      if (m['createdAt'] != null) c.createdAt = DateTime.parse(m['createdAt']);
      if (m['updatedAt'] != null) c.updatedAt = DateTime.parse(m['updatedAt']);
      return c;
    }).toList();

    final transactions = rawTransactions.map((m) {
      final typeStr = m['type'] as String? ?? 'got';
      final type = typeStr == 'give' ? TransactionType.give : TransactionType.got;
      final t = TransactionModel(
        amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
        type: type,
        description: m['description'] ?? '',
        customerId: m['customerId'] ?? 0,
        currencyCode: m['currencyCode'] ?? 'YER',
      );
      if (m['id'] != null) t.id = m['id'];
      t.firestoreId = m['firestoreId'];
      t.isSynced = m['isSynced'] ?? false;
      if (m['createdAt'] != null) t.createdAt = DateTime.parse(m['createdAt']);
      return t;
    }).toList();

    final merchants = rawMerchants.map((m) {
      final merch = Merchant(
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        address: m['address'] ?? '',
        notes: m['notes'],
      );
      if (m['id'] != null) merch.id = m['id'];
      merch.firestoreId = m['firestoreId'];
      merch.isSynced = m['isSynced'] ?? false;
      if (m['createdAt'] != null) merch.createdAt = DateTime.parse(m['createdAt']);
      if (m['updatedAt'] != null) merch.updatedAt = DateTime.parse(m['updatedAt']);
      return merch;
    }).toList();

    final invoices = rawInvoices.map((m) {
      final inv = Invoice(
        merchantId: m['merchantId'],
        customerId: m['customerId'],
        invoiceNumber: m['invoiceNumber'] ?? '',
        totalAmount: (m['totalAmount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (m['paidAmount'] as num?)?.toDouble() ?? 0.0,
        currencyCode: m['currencyCode'] ?? 'YER',
        notes: m['notes'],
        itemsJson: m['itemsJson'],
        whatsappSendingEnabled: m['whatsappSendingEnabled'] ?? false,
        whatsappStatus: m['whatsappStatus'] ?? 'none',
        whatsappMessageId: m['whatsappMessageId'],
        whatsappSentAt: m['whatsappSentAt'] != null ? DateTime.parse(m['whatsappSentAt']) : null,
        whatsappError: m['whatsappError'],
        pdfUrl: m['pdfUrl'],
        idempotencyKey: m['idempotencyKey'],
      );
      if (m['id'] != null) inv.id = m['id'];
      inv.firestoreId = m['firestoreId'];
      inv.isSynced = m['isSynced'] ?? false;
      if (m['date'] != null) inv.date = DateTime.parse(m['date']);
      if (m['createdAt'] != null) inv.createdAt = DateTime.parse(m['createdAt']);
      if (m['updatedAt'] != null) inv.updatedAt = DateTime.parse(m['updatedAt']);
      return inv;
    }).toList();

    final shortages = rawShortages.map((m) {
      final s = MerchantShortage(
        merchantId: m['merchantId'],
        productName: m['productName'] ?? '',
        quantity: (m['quantity'] as num?)?.toDouble(),
        note: m['note'],
        isResolved: m['isResolved'] ?? false,
      );
      if (m['id'] != null) s.id = m['id'];
      s.firestoreId = m['firestoreId'];
      s.isSynced = m['isSynced'] ?? false;
      if (m['createdAt'] != null) s.createdAt = DateTime.parse(m['createdAt']);
      if (m['updatedAt'] != null) s.updatedAt = DateTime.parse(m['updatedAt']);
      return s;
    }).toList();

    // Atomic database replacement
    await DatabaseService.restoreAllData(
      customers: customers,
      transactions: transactions,
      merchants: merchants,
      invoices: invoices,
      shortages: shortages,
    );

    // Refresh state in active GetX controllers and wait for completion
    await _refreshControllers();

    return BackupRestoreSummary(
      customersCount: customers.length,
      transactionsCount: transactions.length,
      merchantsCount: merchants.length,
      invoicesCount: invoices.length,
      shortagesCount: shortages.length,
      exportedAt: DateTime.tryParse(payload['exportedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static Future<void> _refreshControllers() async {
    try {
      final futures = <Future>[];
      if (Get.isRegistered<CustomerController>()) {
        futures.add(Get.find<CustomerController>().loadCustomers());
      }
      if (Get.isRegistered<TransactionController>()) {
        futures.add(Get.find<TransactionController>().loadAllTransactions());
      }
      if (Get.isRegistered<DashboardController>()) {
        futures.add(Get.find<DashboardController>().loadDashboardData());
      }
      if (Get.isRegistered<InvoiceController>()) {
        final ic = Get.find<InvoiceController>();
        if (ic.selectedMerchantId.value > 0) {
          futures.add(ic.loadInvoicesForMerchant(ic.selectedMerchantId.value));
        } else if (ic.selectedCustomerId.value > 0) {
          futures.add(ic.loadInvoicesForCustomer(ic.selectedCustomerId.value));
        }
      }
      if (Get.isRegistered<MerchantController>()) {
        futures.add(Get.find<MerchantController>().loadMerchants());
      }
      if (Get.isRegistered<MerchantShortageController>()) {
        futures.add(Get.find<MerchantShortageController>().loadAll());
      }
      await Future.wait(futures);
    } catch (_) {}
  }
}
