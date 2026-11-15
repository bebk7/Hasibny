import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';
import 'dashboard_controller.dart';

class CustomerController extends GetxController {
  var customers = <Customer>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedCurrencyFilter = 'all'.obs;
  var filteredCustomers = <Customer>[].obs;
  var customerBalances = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
    searchQuery.listen((_) => filterCustomers());
    selectedCurrencyFilter.listen((_) => filterCustomers());
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final allCustomers = await DatabaseService.getAllCustomers();
      customers.assignAll(allCustomers);
      await loadCustomerBalances();
      filterCustomers();
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_customers'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomerBalances() async {
    final balances = await DatabaseService.getAllCustomerBalances();
    customerBalances.assignAll(balances);
    customerBalances.refresh();
  }

  void adjustCustomerBalance({
    required int customerId,
    required double amount,
    required TransactionType type,
  }) {
    final current = customerBalances[customerId] ?? 0.0;
    customerBalances[customerId] = type == TransactionType.give
        ? current - amount
        : current + amount;
    customerBalances.refresh();
  }

  Future<void> updateCustomerBalance(int customerId) async {
    final balance = await DatabaseService.getCustomerBalance(customerId);
    customerBalances[customerId] = balance;
    customerBalances.refresh();
  }

  void setCurrencyFilter(String filter) {
    selectedCurrencyFilter.value = filter;
  }

  void filterCustomers() {
    var result = customers.toList();

    if (selectedCurrencyFilter.value != 'all') {
      result = result
          .where((c) => c.currencyCode == selectedCurrencyFilter.value)
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.phoneNumber.toLowerCase().contains(q))
          .toList();
    }

    filteredCustomers.assignAll(result);
  }

  bool customerExists({
    required String name,
    required String currencyCode,
    int? excludeId,
  }) {
    final normalizedName = name.trim().toLowerCase();
    final normalizedCurr = currencyCode.trim().toUpperCase();
    return customers.any((c) =>
        c.id != excludeId &&
        c.name.trim().toLowerCase() == normalizedName &&
        c.currencyCode.trim().toUpperCase() == normalizedCurr);
  }

  Future<int?> addCustomer(Customer customer) async {
    if (customerExists(
      name: customer.name,
      currencyCode: customer.currencyCode,
    )) {
      Get.snackbar(
        'error'.tr,
        'customer_already_exists_currency'.tr,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    try {
      final id = await DatabaseService.addCustomer(customer);
      customer.id = id;
      SyncService.uploadCustomer(customer);
      await loadCustomers();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
      return id;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_customer'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      return null;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    if (customerExists(
      name: customer.name,
      currencyCode: customer.currencyCode,
      excludeId: customer.id,
    )) {
      Get.snackbar(
        'error'.tr,
        'customer_already_exists_currency'.tr,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      await DatabaseService.updateCustomer(customer);
      SyncService.uploadCustomer(customer);
      await loadCustomers();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
      Get.snackbar('success'.tr, 'customer_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_customer'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      return false;
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    try {
      await DatabaseService.deleteCustomer(customerId);
      SyncService.deleteCustomerRemote(customerId);
      await loadCustomers();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_delete_customer'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  double getCustomerBalance(int customerId) {
    return customerBalances[customerId] ?? 0.0;
  }

  Customer? getCustomerById(int id) {
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Customer> get debtors {
    return customers
        .where((customer) => getCustomerBalance(customer.id) < 0)
        .toList();
  }

  List<Customer> get creditors {
    return customers
        .where((customer) => getCustomerBalance(customer.id) > 0)
        .toList();
  }

  List<Customer> get settled {
    return customers
        .where((customer) => getCustomerBalance(customer.id) == 0)
        .toList();
  }

  Future<void> clearAllData() async {
    await DatabaseService.clearAllData();
    await loadCustomers();
  }
}
