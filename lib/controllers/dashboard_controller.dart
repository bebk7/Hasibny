import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../themes/app_theme.dart';
import '../utils/currency_formatter.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var totalToGive = 0.0.obs;
  var totalToGet = 0.0.obs;
  var recentTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var totalCustomers = 0.obs;
  var activeDebtors = 0.obs;
  var activeCreditors = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        loadTotals(),
        loadRecentTransactions(),
        loadCustomerStats(),
      ]);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTotals() async {
    totalToGive.value = await DatabaseService.getTotalToGive();
    totalToGet.value = await DatabaseService.getTotalToGet();
  }

  Future<void> loadRecentTransactions() async {
    final transactions = await DatabaseService.getRecentTransactions(10);
    recentTransactions.assignAll(transactions);
  }

  Future<void> loadCustomerStats() async {
    final customers = await DatabaseService.getAllCustomers();
    totalCustomers.value = customers.length;

    int debtorsCount = 0;
    int creditorsCount = 0;

    for (final customer in customers) {
      final balance = await DatabaseService.getCustomerBalance(customer.id);
      if (balance < 0) debtorsCount++;
      if (balance > 0) creditorsCount++;
    }

    activeDebtors.value = debtorsCount;
    activeCreditors.value = creditorsCount;
  }

  double get netBalance => totalToGet.value - totalToGive.value;

  String get formattedNetBalance {
    return CurrencyFormatter.formatAbs(netBalance);
  }

  String get formattedTotalToGive =>
      CurrencyFormatter.format(totalToGive.value);

  String get formattedTotalToGet => CurrencyFormatter.format(totalToGet.value);

  void refreshDashboard() {
    loadDashboardData();
  }
}
