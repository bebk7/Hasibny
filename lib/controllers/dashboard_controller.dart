import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../themes/app_theme.dart';
import 'settings_controller.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var selectedCurrency = 'YER'.obs;
  var isLoading = false.obs;

  // Currency totals maps: { 'YER': {'toGive': x, 'toGet': y, 'net': z}, 'SAR': ..., 'USD': ... }
  var currencyTotals = <String, Map<String, double>>{
    'YER': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
    'SAR': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
    'USD': {'toGive': 0.0, 'toGet': 0.0, 'net': 0.0},
  }.obs;

  var recentTransactions = <TransactionModel>[].obs;
  var totalCustomers = 0.obs;
  var activeDebtors = 0.obs;
  var activeCreditors = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<SettingsController>()) {
      selectedCurrency.value =
          Get.find<SettingsController>().currentCurrency.value;
    }
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
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, e.toString(),
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTotals() async {
    final totals = await DatabaseService.getTotalsByCurrency();
    currencyTotals.assignAll(totals);
  }

  Future<void> loadRecentTransactions() async {
    final transactions = await DatabaseService.getRecentTransactions(10);
    recentTransactions.assignAll(transactions);
  }

  Future<void> loadCustomerStats() async {
    final customers = await DatabaseService.getAllCustomers();
    totalCustomers.value = customers.length;

    final balances = await DatabaseService.getAllCustomerBalances();
    int debtorsCount = 0;
    int creditorsCount = 0;

    for (final customer in customers) {
      final balance = balances[customer.id] ?? 0.0;
      if (balance < 0) debtorsCount++;
      if (balance > 0) creditorsCount++;
    }

    activeDebtors.value = debtorsCount;
    activeCreditors.value = creditorsCount;
  }

  void setCurrency(String code) {
    selectedCurrency.value = code;
  }

  double get currentToGive =>
      currencyTotals[selectedCurrency.value]?['toGive'] ?? 0.0;

  double get currentToGet =>
      currencyTotals[selectedCurrency.value]?['toGet'] ?? 0.0;

  double get currentNetBalance =>
      currencyTotals[selectedCurrency.value]?['net'] ?? 0.0;

  String formattedToGive(String code) {
    final val = currencyTotals[code]?['toGive'] ?? 0.0;
    return CurrencyFormatter.format(val, currencyCode: code);
  }

  String formattedToGet(String code) {
    final val = currencyTotals[code]?['toGet'] ?? 0.0;
    return CurrencyFormatter.format(val, currencyCode: code);
  }

  String formattedNet(String code) {
    final val = currencyTotals[code]?['net'] ?? 0.0;
    return CurrencyFormatter.formatAbs(val, currencyCode: code);
  }

  void refreshDashboard() {
    loadDashboardData();
  }
}
