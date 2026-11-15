import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/merchant.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';

class MerchantController extends GetxController {
  var merchants = <Merchant>[].obs;
  var filteredMerchants = <Merchant>[].obs;
  var merchantTotals = <int, double>{}.obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMerchants();
    searchQuery.listen((_) => _applyFilter());
  }

  Future<void> loadMerchants() async {
    isLoading.value = true;
    try {
      final all = await DatabaseService.getAllMerchants();
      merchants.assignAll(all);
      await loadMerchantTotals();
      _applyFilter();
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_merchants'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMerchantTotals() async {
    final totals = await DatabaseService.getAllMerchantTotals();
    merchantTotals.assignAll(totals);
  }

  void _applyFilter() {
    if (searchQuery.value.isEmpty) {
      filteredMerchants.assignAll(merchants);
    } else {
      final q = searchQuery.value.toLowerCase();
      filteredMerchants.assignAll(
        merchants.where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.phone.toLowerCase().contains(q) ||
            m.address.toLowerCase().contains(q)),
      );
    }
  }

  Future<void> addMerchant(Merchant merchant) async {
    try {
      await DatabaseService.addMerchant(merchant);
      SyncService.uploadMerchant(merchant);
      await loadMerchants();
      Get.snackbar('success'.tr, 'merchant_added_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_merchant'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> updateMerchant(Merchant merchant) async {
    try {
      await DatabaseService.updateMerchant(merchant);
      SyncService.uploadMerchant(merchant);
      await loadMerchants();
      Get.snackbar('success'.tr, 'merchant_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_merchant'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteMerchant(int id) async {
    try {
      await DatabaseService.deleteMerchant(id);
      SyncService.deleteMerchantRemote(id);
      await loadMerchants();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_delete_merchant'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Merchant? getMerchantById(int id) {
    try {
      return merchants.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  double getMerchantOwed(int merchantId) {
    return merchantTotals[merchantId] ?? 0.0;
  }
}
