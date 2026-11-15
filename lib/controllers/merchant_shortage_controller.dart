import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/merchant_shortage.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';

class MerchantShortageController extends GetxController {
  final shortages = <MerchantShortage>[].obs;
  final isLoading = false.obs;

  // null means "all shortages" mode; non-null means filtered by merchant
  int? _currentMerchantId;

  Future<void> loadAll() async {
    _currentMerchantId = null;
    isLoading.value = true;
    try {
      final list = await DatabaseService.getAllShortages();
      shortages.assignAll(list);
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_shortages'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadForMerchant(int merchantId) async {
    _currentMerchantId = merchantId;
    isLoading.value = true;
    try {
      final list = await DatabaseService.getShortagesForMerchant(merchantId);
      shortages.assignAll(list);
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_shortages'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _reload() async {
    if (_currentMerchantId != null) {
      await loadForMerchant(_currentMerchantId!);
    } else {
      await loadAll();
    }
  }

  Future<void> addShortage(MerchantShortage shortage) async {
    try {
      await DatabaseService.addMerchantShortage(shortage);
      SyncService.uploadShortage(shortage);
      await _reload();
      Get.snackbar('success'.tr, 'shortage_added_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_shortage'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> toggleResolved(MerchantShortage shortage) async {
    try {
      shortage.isResolved = !shortage.isResolved;
      await DatabaseService.updateMerchantShortage(shortage);
      SyncService.uploadShortage(shortage);
      await _reload();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_shortage'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteShortage(int id) async {
    try {
      await DatabaseService.deleteMerchantShortage(id);
      SyncService.deleteShortageRemote(id);
      await _reload();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_delete_shortage'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  int get totalCount => shortages.length;
  int get resolvedCount => shortages.where((s) => s.isResolved).length;
  int get pendingCount => shortages.where((s) => !s.isResolved).length;
}
