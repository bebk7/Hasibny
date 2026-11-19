import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/merchant.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import '../services/whatsapp_service.dart';
import '../themes/app_theme.dart';
import 'merchant_controller.dart';

class InvoiceController extends GetxController {
  var invoices = <Invoice>[].obs;
  var isLoading = false.obs;
  var selectedMerchantId = 0.obs;
  var selectedCustomerId = 0.obs;

  Future<void> loadInvoicesForMerchant(int merchantId) async {
    selectedMerchantId.value = merchantId;
    isLoading.value = true;
    try {
      final list = await DatabaseService.getInvoicesForMerchant(merchantId);
      invoices.assignAll(list);
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_invoices'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoicesForCustomer(int customerId) async {
    selectedCustomerId.value = customerId;
    isLoading.value = true;
    try {
      final list = await DatabaseService.getInvoicesForCustomer(customerId);
      invoices.assignAll(list);
    } catch (e) {
      if (!Get.testMode && Get.context != null) {
        Get.snackbar('error'.tr, '${'failed_load_invoices'.tr}: $e',
            backgroundColor: AppTheme.errorColor, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addInvoice(Invoice invoice, {Customer? customer, Merchant? merchant}) async {
    try {
      if (invoice.totalAmount > 0 && invoice.paidAmount > invoice.totalAmount) {
        invoice.paidAmount = invoice.totalAmount;
      }
      // 1. Determine customer if not directly provided
      Customer? resolvedCustomer = customer;
      if (resolvedCustomer == null && invoice.customerId != null) {
        resolvedCustomer = await DatabaseService.getCustomerById(invoice.customerId!);
      }

      Merchant? resolvedMerchant = merchant;
      if (resolvedMerchant == null && invoice.merchantId != null) {
        resolvedMerchant = await DatabaseService.getMerchantById(invoice.merchantId!);
      }

      // 2. Check if automated WhatsApp delivery is eligible
      final shouldSend = resolvedCustomer != null &&
          WhatsAppService.shouldAutoSend(customer: resolvedCustomer);

      if (shouldSend) {
        invoice.whatsappSendingEnabled = true;
        invoice.whatsappStatus = 'pending';
      }

      // 3. Save invoice in local database first (non-blocking)
      final newId = await DatabaseService.addInvoice(invoice);
      invoice.id = newId;

      // 4. Sync to Firestore
      SyncService.uploadInvoice(invoice);

      // 5. If eligible, trigger background delivery
      if (shouldSend) {
        WhatsAppService.triggerInvoiceDelivery(
          invoice: invoice,
          customer: resolvedCustomer,
        );
        Get.snackbar(
          'success'.tr,
          'invoice_saved_whatsapp_sending'.tr,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'success'.tr,
          'invoice_added_success'.tr,
          backgroundColor: AppTheme.successColor,
          colorText: Colors.white,
        );
      }

      // 6. Refresh views
      if (invoice.merchantId != null) {
        await loadInvoicesForMerchant(invoice.merchantId!);
        _refreshMerchantTotals();
      } else if (invoice.customerId != null) {
        await loadInvoicesForCustomer(invoice.customerId!);
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_add_invoice'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> updateInvoice(Invoice invoice) async {
    try {
      if (invoice.totalAmount > 0 && invoice.paidAmount > invoice.totalAmount) {
        invoice.paidAmount = invoice.totalAmount;
      }
      await DatabaseService.updateInvoice(invoice);
      SyncService.uploadInvoice(invoice);
      if (invoice.merchantId != null) {
        await loadInvoicesForMerchant(invoice.merchantId!);
        _refreshMerchantTotals();
      } else if (invoice.customerId != null) {
        await loadInvoicesForCustomer(invoice.customerId!);
      }
      Get.snackbar('success'.tr, 'invoice_updated_success'.tr,
          backgroundColor: AppTheme.successColor, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('error'.tr, '${'failed_update_invoice'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  /// Manually trigger or resend invoice delivery via WhatsApp without duplicating records
  Future<void> resendWhatsAppDelivery({
    required Invoice invoice,
    Customer? customer,
    Merchant? merchant,
  }) async {
    try {
      Customer? resolvedCust = customer;
      if (resolvedCust == null && invoice.customerId != null) {
        resolvedCust = await DatabaseService.getCustomerById(invoice.customerId!);
      }

      Merchant? resolvedMerch = merchant;
      if (resolvedMerch == null && invoice.merchantId != null) {
        resolvedMerch = await DatabaseService.getMerchantById(invoice.merchantId!);
      }

      await WhatsAppService.processDelivery(
        invoice: invoice,
        customer: resolvedCust,
        merchant: resolvedMerch,
        isManualTrigger: true,
      );

      // Refresh list
      if (invoice.merchantId != null) {
        await loadInvoicesForMerchant(invoice.merchantId!);
      } else if (invoice.customerId != null) {
        await loadInvoicesForCustomer(invoice.customerId!);
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'whatsapp_failed'.tr}: $e',
          backgroundColor: AppTheme.errorColor, colorText: Colors.white);
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await DatabaseService.deleteInvoice(id);
      SyncService.deleteInvoiceRemote(id);
      if (selectedMerchantId.value > 0) {
        await loadInvoicesForMerchant(selectedMerchantId.value);
      } else if (selectedCustomerId.value > 0) {
        await loadInvoicesForCustomer(selectedCustomerId.value);
      }
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
