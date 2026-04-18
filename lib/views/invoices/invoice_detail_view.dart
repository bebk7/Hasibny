import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/merchant_controller.dart';
import '../../models/invoice.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../../widgets/amount_field.dart';
import 'add_invoice_view.dart';

class InvoiceDetailView extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MerchantController>();
    final merchant = mc.getMerchantById(invoice.merchantId);
    final paid = invoice.isFullyPaid;
    final statusColor = paid ? AppTheme.gotColor : AppTheme.giveColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('#${invoice.invoiceNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.off(() => AddInvoiceView(
                merchantId: invoice.merchantId, invoice: invoice)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.pagePadding(context),
        child: Column(
          children: [
            // Status badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    paid ? Icons.check_circle : Icons.hourglass_bottom_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paid ? 'fully_paid'.tr : 'partially_paid'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: invoice.paymentPercentage,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(invoice.paymentPercentage * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount cards
            Row(
              children: [
                _AmountCard(
                    label: 'total_amount_label'.tr,
                    amount: invoice.totalAmount,
                    color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                _AmountCard(
                    label: 'paid_amount_label'.tr,
                    amount: invoice.paidAmount,
                    color: AppTheme.gotColor),
                const SizedBox(width: 12),
                _AmountCard(
                    label: 'remaining_amount'.tr,
                    amount: invoice.remainingAmount,
                    color: AppTheme.giveColor),
              ],
            ),
            const SizedBox(height: 20),

            // Line items
            if (invoice.items.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('invoice_items'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...invoice.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  CurrencyFormatter.format(item.total),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: AppTheme.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('details'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  _DetailRow(
                      label: 'invoice_number'.tr,
                      value: '#${invoice.invoiceNumber}'),
                  _DetailRow(
                      label: 'merchant_name'.tr,
                      value: merchant?.name ?? '-'),
                  _DetailRow(
                      label: 'date'.tr,
                      value: DateFormat('yyyy/MM/dd HH:mm')
                          .format(invoice.date)),
                  if (invoice.notes != null && invoice.notes!.isNotEmpty)
                    _DetailRow(label: 'notes'.tr, value: invoice.notes!),
                  _DetailRow(
                      label: 'created_at'.tr,
                      value: DateFormat('yyyy/MM/dd HH:mm')
                          .format(invoice.createdAt)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick pay button
            if (!paid)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showPayDialog(context),
                  icon: const Icon(Icons.payments_rounded, color: Colors.white),
                  label: Text('record_payment'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gotColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(BuildContext context) {
    final payCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('record_payment'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${'remaining_amount'.tr}: ${CurrencyFormatter.format(invoice.remainingAmount)}'),
            const SizedBox(height: 12),
            AmountField(
              controller: payCtrl,
              label: 'amount'.tr,
              hint: '0',
              icon: Icons.attach_money,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(payCtrl.text.trim());
              if (amount == null || amount <= 0) return;
              invoice.paidAmount =
                  (invoice.paidAmount + amount).clamp(0, invoice.totalAmount);
              Get.find<InvoiceController>().updateInvoice(invoice);
              Get.back();
              Get.back(); // Return to invoices list
            },
            child: Text('confirm'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_invoice'.tr),
        content: Text('delete_invoice_confirm'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.find<InvoiceController>().deleteInvoice(invoice.id);
              Get.back();
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _AmountCard(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(Responsive.isSmall(context) ? 10 : 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: Responsive.sp(context, 10))),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: Responsive.sp(context, 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
