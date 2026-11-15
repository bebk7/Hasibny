import 'package:flutter/material.dart';
import 'package:account_book/controllers/customer_controller.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';
import 'dashboard_controller.dart';

class TransactionController extends GetxController {
  var transactions = <TransactionModel>[].obs;
  var allTransactions = <TransactionModel>[].obs;
  var filteredAllTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var selectedCustomerId = 0.obs;
  var currentFilter = 'all'.obs;
  var selectedCurrencyFilter = 'all'.obs;

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
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_transactions'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    _applyFilter();
  }

  void setCurrencyFilter(String currency) {
    selectedCurrencyFilter.value = currency;
    _applyFilter();
  }

  void _applyFilter() {
    var result = allTransactions.toList();

    // Currency filter
    if (selectedCurrencyFilter.value != 'all') {
      result = result
          .where((t) => t.currencyCode == selectedCurrencyFilter.value)
          .toList();
    }

    // Type filter
    if (currentFilter.value == 'give') {
      result = result.where((t) => t.type == TransactionType.give).toList();
    } else if (currentFilter.value == 'got') {
      result = result.where((t) => t.type == TransactionType.got).toList();
    }

    filteredAllTransactions.assignAll(result);
  }

  double getTotalGive(String currencyCode) {
    return allTransactions
        .where((t) => t.currencyCode == currencyCode && t.type == TransactionType.give)
        .fold(0.0, (s, t) => s + t.amount);
  }

  double getTotalGot(String currencyCode) {
    return allTransactions
        .where((t) => t.currencyCode == currencyCode && t.type == TransactionType.got)
        .fold(0.0, (s, t) => s + t.amount);
  }

  Future<void> loadTransactionsForCustomer(int customerId) async {
    selectedCustomerId.value = customerId;
    isLoading.value = true;
    try {
      final customerTransactions =
          await DatabaseService.getTransactionsForCustomer(customerId);
      transactions.assignAll(customerTransactions);
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_transactions'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction({
    required int customerId,
    required double amount,
    required TransactionType type,
    required String description,
    String? currencyCode,
    DateTime? createdAt,
  }) async {
    try {
      // If currencyCode not provided, fetch from customer
      String effectiveCurrency = currencyCode ?? 'YER';
      if (currencyCode == null) {
        final customer = await DatabaseService.getCustomerById(customerId);
        if (customer != null && customer.currencyCode.isNotEmpty) {
          effectiveCurrency = customer.currencyCode;
        }
      }

      final transaction = TransactionModel(
        amount: amount,
        type: type,
        description: description,
        customerId: customerId,
        currencyCode: effectiveCurrency,
      );
      if (createdAt != null) {
        transaction.createdAt = createdAt;
      }

      await DatabaseService.addTransaction(transaction);
      SyncService.uploadTransaction(transaction);

      // Immediately adjust balance in memory for zero-latency screen update
      if (Get.isRegistered<CustomerController>()) {
        final customerController = Get.find<CustomerController>();
        customerController.adjustCustomerBalance(
          customerId: customerId,
          amount: amount,
          type: type,
        );
      }

      await loadTransactionsForCustomer(customerId);
      await loadAllTransactions();
      
      if (Get.isRegistered<CustomerController>()) {
        final customerController = Get.find<CustomerController>();
        await customerController.loadCustomerBalances();
      }
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
      await DatabaseService.updateTransaction(transaction);
      SyncService.uploadTransaction(transaction);
      await loadTransactionsForCustomer(selectedCustomerId.value);
      await loadAllTransactions();

      if (Get.isRegistered<CustomerController>()) {
        final customerController = Get.find<CustomerController>();
        await customerController.loadCustomerBalances();
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }

      Get.snackbar('success'.tr, 'transaction_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_transaction'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteTransaction(int transactionId, [int? customerId]) async {
    try {
      final target = transactions.firstWhereOrNull((t) => t.id == transactionId) ??
          allTransactions.firstWhereOrNull((t) => t.id == transactionId);

      await DatabaseService.deleteTransaction(transactionId);
      SyncService.deleteTransactionRemote(transactionId);

      if (target != null && Get.isRegistered<CustomerController>()) {
        final customerController = Get.find<CustomerController>();
        customerController.adjustCustomerBalance(
          customerId: target.customerId,
          amount: target.amount,
          type: target.type == TransactionType.give
              ? TransactionType.got
              : TransactionType.give,
        );
      }

      await loadTransactionsForCustomer(selectedCustomerId.value);
      await loadAllTransactions();
      
      if (Get.isRegistered<CustomerController>()) {
        final customerController = Get.find<CustomerController>();
        await customerController.loadCustomerBalances();
      }
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

  double get totalGiveForCustomer => getTotalGiveAmount();
  double get totalGotForCustomer => getTotalGotAmount();

  Future<void> clearAllData() async {
    transactions.clear();
    selectedCustomerId.value = 0;
    await loadAllTransactions();
  }
}
