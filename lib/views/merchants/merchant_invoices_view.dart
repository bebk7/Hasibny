import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/merchant_controller.dart';
import '../../models/invoice.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../invoices/add_invoice_view.dart';
import '../invoices/invoice_detail_view.dart';

class MerchantInvoicesView extends StatelessWidget {
  final int merchantId;
  const MerchantInvoicesView({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InvoiceController>();
    final mc = Get.find<MerchantController>();
    final merchant = mc.getMerchantById(merchantId);

    Future.microtask(() => ic.loadInvoicesForMerchant(merchantId));

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant?.name ?? 'invoices'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (merchant != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showMerchantInfo(context, merchant),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(context, ic),
          Expanded(
            child: Obx(() {
              if (ic.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ic.invoices.isEmpty) {
                return _buildEmpty(context);
              }
              return ListView.builder(
                padding: Responsive.pagePadding(context),
                physics: const BouncingScrollPhysics(),
                itemCount: ic.invoices.length,
                itemBuilder: (ctx, i) => _InvoiceCard(invoice: ic.invoices[i]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_invoice_fab',
        onPressed: () =>
            Get.to(() => AddInvoiceView(merchantId: merchantId)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, InvoiceController ic) {
    return Obx(() => Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF1E88E5)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _SumItem(
                  label: 'total_invoices_amount'.tr,
                  value: CurrencyFormatter.format(ic.totalAmount),
                  color: Colors.white),
              _divider(),
              _SumItem(
                  label: 'total_paid'.tr,
                  value: CurrencyFormatter.format(ic.totalPaid),
                  color: Colors.greenAccent),
              _divider(),
              _SumItem(
                  label: 'total_remaining'.tr,
                  value: CurrencyFormatter.format(ic.totalRemaining),
                  color: Colors.orangeAccent),
            ],
          ),
        ));
  }

  Widget _divider() => Container(
      width: 1, height: 36, margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white24);

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_invoices'.tr,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showMerchantInfo(BuildContext context, dynamic merchant) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(merchant.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (merchant.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.phone, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(merchant.phone),
              ]),
            ],
            if (merchant.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(merchant.address)),
              ]),
            ],
            if (merchant.notes != null && merchant.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.notes, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(merchant.notes!)),
              ]),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SumItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.sp(context, 10))),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: Responsive.sp(context, 14))),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final paid = invoice.isFullyPaid;
    final color = paid ? AppTheme.gotColor : AppTheme.giveColor;
    final pct = invoice.paymentPercentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          onTap: () =>
              Get.to(() => InvoiceDetailView(invoice: invoice)),
          onLongPress: () => _showOptions(context),
          child: Padding(
            padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(
                          paid
                              ? Icons.check_circle_outline
                              : Icons.receipt_outlined,
                          color: color,
                          size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#${invoice.invoiceNumber}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.sp(context, 14))),
                          Text(
                            DateFormat('yyyy/MM/dd').format(invoice.date),
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: Responsive.sp(context, 11)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(CurrencyFormatter.format(invoice.totalAmount),
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: Responsive.sp(context, 14))),
                        Text(
                          paid
                              ? 'fully_paid'.tr
                              : '${'remaining'.tr}: ${CurrencyFormatter.format(invoice.remainingAmount)}',
                          style: TextStyle(
                              color: color,
                              fontSize: Responsive.sp(context, 10),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final ic = Get.find<InvoiceController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppTheme.primaryColor),
              title: Text('edit_invoice'.tr),
              onTap: () {
                Get.back();
                Get.to(() => AddInvoiceView(
                    merchantId: invoice.merchantId, invoice: invoice));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppTheme.errorColor),
              title: Text('delete_invoice'.tr,
                  style: const TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Get.back();
                Get.dialog(AlertDialog(
                  title: Text('delete_invoice'.tr),
                  content: Text('delete_invoice_confirm'.tr),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: Text('cancel'.tr)),
                    TextButton(
                      onPressed: () {
                        ic.deleteInvoice(invoice.id);
                        Get.back();
                      },
                      child: Text('delete'.tr,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
