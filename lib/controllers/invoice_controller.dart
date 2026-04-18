import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/invoice.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../themes/app_theme.dart';
import 'merchant_controller.dart';

class InvoiceController extends GetxController {
  var invoices = <Invoice>[].obs;
  var isLoading = false.obs;
  var selectedMerchantId = 0.obs;

  Future<void> loadInvoicesForMerchant(int merchantId) async {
    selectedMerchantId.value = merchantId;
    isLoading.value = true;
    try {
      final list = await DatabaseService.getInvoicesForMerchant(merchantId);
      invoices.assignAll(list);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_load_invoices'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await DatabaseService.addInvoice(invoice);
      SyncService.uploadInvoice(invoice);
      await loadInvoicesForMerchant(invoice.merchantId);
      _refreshMerchantTotals();
      Get.snackbar('success'.tr, 'invoice_added_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_invoice'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      await DatabaseService.updateInvoice(invoice);
      SyncService.uploadInvoice(invoice);
      await loadInvoicesForMerchant(invoice.merchantId);
      _refreshMerchantTotals();
      Get.snackbar('success'.tr, 'invoice_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_invoice'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await DatabaseService.deleteInvoice(id);
      SyncService.deleteInvoiceRemote(id);
      await loadInvoicesForMerchant(selectedMerchantId.value);
      _refreshMerchantTotals();
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_delete_invoice'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  double get totalAmount =>
      invoices.fold(0.0, (s, i) => s + i.totalAmount);

  double get totalPaid =>
      invoices.fold(0.0, (s, i) => s + i.paidAmount);

  double get totalRemaining =>
      invoices.fold(0.0, (s, i) => s + i.remainingAmount);

  void _refreshMerchantTotals() {
    if (Get.isRegistered<MerchantController>()) {
      Get.find<MerchantController>().loadMerchantTotals();
    }
  }
}
