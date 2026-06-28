import 'package:flutter/material.dart';
import 'package:account_book/controllers/customer_controller.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/firestore_service.dart';
import '../themes/app_theme.dart';
import 'dashboard_controller.dart';

class TransactionController extends GetxController {
  var transactions = <TransactionModel>[].obs;
  var allTransactions = <TransactionModel>[].obs;
  var filteredAllTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var selectedCustomerId = 0.obs;
  var currentFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllTransactions();
  }

  Future<void> loadAllTransactions() async {
    isLoading.value = true;
    try {
      final all = await DatabaseService.getAllTransactions();
      allTransactions.assignAll(all);
      _applyFilter();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_load_transactions'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    switch (currentFilter.value) {
      case 'give':
        filteredAllTransactions.assignAll(
          allTransactions.where((t) => t.type == TransactionType.give).toList(),
        );
        break;
      case 'got':
        filteredAllTransactions.assignAll(
          allTransactions.where((t) => t.type == TransactionType.got).toList(),
        );
        break;
      default:
        filteredAllTransactions.assignAll(allTransactions);
    }
  }

  double get totalGiveAll => allTransactions
      .where((t) => t.type == TransactionType.give)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalGotAll => allTransactions
      .where((t) => t.type == TransactionType.got)
      .fold(0.0, (s, t) => s + t.amount);

  Future<void> loadTransactionsForCustomer(int customerId) async {
    selectedCustomerId.value = customerId;
    isLoading.value = true;
    try {
      final customerTransactions =
          await DatabaseService.getTransactionsForCustomer(customerId);
      transactions.assignAll(customerTransactions);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_load_transactions'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction({
    required int customerId,
    required double amount,
    required TransactionType type,
    required String description,
  }) async {
    try {
      final transaction = TransactionModel(
        amount: amount,
        type: type,
        description: description,
        customerId: customerId,
      );

      await DatabaseService.addTransaction(transaction);
      try {
        transaction.firestoreId = await FirestoreService.addTransaction(transaction);
        transaction.isSynced = true;
        await DatabaseService.updateTransaction(transaction);
      } catch (e) {
        debugPrint('Firestore add failed: $e');
      }
      await loadTransactionsForCustomer(customerId);
      await loadAllTransactions();
      final customerController = Get.find<CustomerController>();
      await customerController.loadCustomerBalances();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_transaction'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      transaction.isSynced = false;
      await DatabaseService.updateTransaction(transaction);
      try {
        await FirestoreService.updateTransaction(transaction);
        transaction.isSynced = true;
        await DatabaseService.updateTransaction(transaction);
      } catch (e) {
        debugPrint('Firestore update failed: $e');
      }
      await loadTransactionsForCustomer(selectedCustomerId.value);

      // Refresh customer controller to update balances
      final customerController = Get.find<CustomerController>();
      await customerController.loadCustomerBalances();

      Get.snackbar('success'.tr, 'transaction_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_transaction'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      final t = transactions.firstWhereOrNull((x) => x.id == transactionId) ?? 
                allTransactions.firstWhereOrNull((x) => x.id == transactionId);
      await DatabaseService.deleteTransaction(transactionId);
      if (t != null && t.firestoreId != null) {
        try {
          await FirestoreService.deleteTransaction(t.firestoreId!);
        } catch (e) {
          debugPrint('Firestore delete failed: $e');
        }
      }
      await loadTransactionsForCustomer(selectedCustomerId.value);
      await loadAllTransactions();
      final customerController = Get.find<CustomerController>();
      await customerController.loadCustomerBalances();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_delete_transaction'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  double getCustomerBalance(int customerId) {
    double balance = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.give) {
        balance -= transaction.amount;
      } else {
        balance += transaction.amount;
      }
    }
    return balance;
  }

  List<TransactionModel> getGiveTransactions() {
    return transactions.where((t) => t.type == TransactionType.give).toList();
  }

  List<TransactionModel> getGotTransactions() {
    return transactions.where((t) => t.type == TransactionType.got).toList();
  }

  double getTotalGiveAmount() {
    return getGiveTransactions().fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalGotAmount() {
    return getGotTransactions().fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> clearAllData() async {
    transactions.clear();
    selectedCustomerId.value = 0;
    await loadAllTransactions();
  }
}
