import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';
import '../themes/app_theme.dart';
import 'dashboard_controller.dart';

class CustomerController extends GetxController {
  var customers = <Customer>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var filteredCustomers = <Customer>[].obs;
  var customerBalances = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
    searchQuery.listen((_) => filterCustomers());
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      final allCustomers = await DatabaseService.getAllCustomers();
      customers.assignAll(allCustomers);
      await loadCustomerBalances();
      filterCustomers();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_load_customers'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCustomerBalances() async {
    final balances = await DatabaseService.getAllCustomerBalances();
    customerBalances.assignAll(balances);
  }

  void filterCustomers() {
    if (searchQuery.value.isEmpty) {
      filteredCustomers.assignAll(customers);
    } else {
      filteredCustomers.assignAll(
        customers
            .where((customer) =>
                customer.name
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ||
                customer.phoneNumber
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()))
            .toList(),
      );
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await DatabaseService.addCustomer(customer);
      try {
        customer.firestoreId = await FirestoreService.addCustomer(customer);
        customer.isSynced = true;
        await DatabaseService.updateCustomer(customer);
      } catch (e) {
        debugPrint('Firestore add failed: $e');
      }
      await loadCustomers();
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_customer'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      customer.isSynced = false;
      await DatabaseService.updateCustomer(customer);
      try {
        await FirestoreService.updateCustomer(customer);
        customer.isSynced = true;
        await DatabaseService.updateCustomer(customer);
      } catch (e) {
        debugPrint('Firestore update failed: $e');
      }
      await loadCustomers();
      Get.snackbar('success'.tr, 'customer_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_customer'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteCustomer(int customerId) async {
    try {
      final c = getCustomerById(customerId);
      await DatabaseService.deleteCustomer(customerId);
      if (c != null && c.firestoreId != null) {
        try {
          await FirestoreService.deleteCustomer(c.firestoreId!, customerId);
        } catch (e) {
          debugPrint('Firestore delete failed: $e');
        }
      }
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

  // Get customers who owe money (negative balance)
  List<Customer> get debtors {
    return customers
        .where((customer) => getCustomerBalance(customer.id) < 0)
        .toList();
  }

  // Get customers who are owed money (positive balance)
  List<Customer> get creditors {
    return customers
        .where((customer) => getCustomerBalance(customer.id) > 0)
        .toList();
  }

  // Get customers with settled accounts (zero balance)
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
