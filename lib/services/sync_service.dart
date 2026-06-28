import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../models/merchant.dart';
import '../models/invoice.dart';
import '../models/merchant_shortage.dart';
import '../themes/app_theme.dart';
import 'database_service.dart';
import 'firestore_service.dart';

class SyncService {
  static Future<bool> hasRemoteData() async {
    return await FirestoreService.hasRemoteData();
  }

  static Future<void> uploadAll() async {
    try {
      final customers = await DatabaseService.getAllCustomers();
      for (final c in customers) {
        c.firestoreId = await FirestoreService.addCustomer(c);
        c.isSynced = true;
        await DatabaseService.updateCustomer(c);
      }

      final transactions = await DatabaseService.getAllTransactions();
      for (final t in transactions) {
        t.firestoreId = await FirestoreService.addTransaction(t);
        t.isSynced = true;
        await DatabaseService.updateTransaction(t);
      }

      final merchants = await DatabaseService.getAllMerchants();
      for (final m in merchants) {
        m.firestoreId = await FirestoreService.addMerchant(m);
        m.isSynced = true;
        await DatabaseService.updateMerchant(m);
      }

      final invoices = await DatabaseService.getAllInvoices();
      for (final inv in invoices) {
        inv.firestoreId = await FirestoreService.addInvoice(inv);
        inv.isSynced = true;
        await DatabaseService.updateInvoice(inv);
      }

      final shortages = await DatabaseService.getAllShortages();
      for (final s in shortages) {
        s.firestoreId = await FirestoreService.addShortage(s);
        s.isSynced = true;
        await DatabaseService.updateMerchantShortage(s);
      }
    } catch (e) {
      debugPrint('SyncService.uploadAll error: $e');
    }
  }

  static Future<void> downloadAll() async {
    try {
      final data = await FirestoreService.downloadAll();

      final customers = data['customers'] as List<Customer>;
      for (final c in customers) await DatabaseService.addCustomer(c);

      final transactions = data['transactions'] as List<TransactionModel>;
      for (final t in transactions) await DatabaseService.addTransaction(t);

      final merchants = data['merchants'] as List<Merchant>;
      for (final m in merchants) await DatabaseService.addMerchant(m);

      final invoices = data['invoices'] as List<Invoice>;
      for (final inv in invoices) await DatabaseService.addInvoice(inv);

      final shortages = data['shortages'] as List<MerchantShortage>;
      for (final s in shortages) await DatabaseService.addMerchantShortage(s);
    } catch (e) {
      debugPrint('SyncService.downloadAll error: $e');
      Get.snackbar(
        'sync_error'.tr,
        'sync_error_msg'.tr,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  static Future<void> uploadInvoice(Invoice invoice) async {
    try {
      invoice.firestoreId = await FirestoreService.addInvoice(invoice);
      invoice.isSynced = true;
      await DatabaseService.updateInvoice(invoice);
    } catch (e) {
      debugPrint('uploadInvoice error: $e');
    }
  }

  static Future<void> deleteInvoiceRemote(String firestoreId) async {
    try {
      await FirestoreService.deleteInvoice(firestoreId);
    } catch (e) {
      debugPrint('deleteInvoiceRemote error: $e');
    }
  }

  static Future<void> uploadMerchant(Merchant merchant) async {
    try {
      merchant.firestoreId = await FirestoreService.addMerchant(merchant);

      merchant.isSynced = true;

      await DatabaseService.updateMerchant(merchant);
    } catch (e) {
      debugPrint('uploadMerchant error: $e');
    }
  }

  static Future<void> deleteMerchantRemote(
    String firestoreId,
    int localId,
  ) async {
    try {
      await FirestoreService.deleteMerchant(
        firestoreId,
        localId,
      );
    } catch (e) {
      debugPrint('deleteMerchantRemote error: $e');
    }
  }

  static Future<void> uploadShortage(
    MerchantShortage shortage,
  ) async {
    try {
      shortage.firestoreId = await FirestoreService.addShortage(shortage);

      shortage.isSynced = true;

      await DatabaseService.updateMerchantShortage(
        shortage,
      );
    } catch (e) {
      debugPrint('uploadShortage error: $e');
    }
  }

  static Future<void> deleteShortageRemote(
    String firestoreId,
  ) async {
    try {
      await FirestoreService.deleteShortage(
        firestoreId,
      );
    } catch (e) {
      debugPrint('deleteShortageRemote error: $e');
    }
  }
}
