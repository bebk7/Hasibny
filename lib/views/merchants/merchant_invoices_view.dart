import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/merchant_controller.dart';
import '../../core/core.dart';
import '../../models/invoice.dart';
import '../../services/export_service.dart';
import '../invoices/add_invoice_view.dart';
import '../invoices/invoice_detail_view.dart';

class MerchantInvoicesView extends StatelessWidget {
  final int merchantId;
  const MerchantInvoicesView({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    final ic = Get.find<InvoiceController>();
    final mc = Get.find<MerchantController>();
    final resp = AppResponsive.of(context);
    final merchant = mc.getMerchantById(merchantId);

    Future.microtask(() => ic.loadInvoicesForMerchant(merchantId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          merchant?.name ?? 'invoices'.tr,
          style: AppTypography.pageTitle(context),
        ),
        actions: [
          if (merchant != null) ...[
            IconButton(
              tooltip: 'preview_report'.tr,
              icon: Icon(Icons.visibility_outlined, size: resp.iconSM),
              onPressed: () => ExportService.previewMerchantReport(
                merchant: merchant,
                invoices: ic.invoices,
              ),
            ),
            IconButton(
              tooltip: 'export_pdf'.tr,
              icon: Icon(Icons.picture_as_pdf_rounded, size: resp.iconSM),
              onPressed: () => _exportPDF(context, merchant, ic.invoices),
            ),
            IconButton(
              tooltip: 'merchant_info'.tr,
              icon: Icon(Icons.info_outline_rounded, size: resp.iconSM),
              onPressed: () => _showMerchantInfo(context, merchant),
            ),
          ],
          SizedBox(width: resp.spacing2XS),
        ],
      ),
      body: AppPageContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildSummaryHeader(context, ic, resp),
            Expanded(
              child: Obx(() {
                if (ic.isLoading.value) {
                  return const Center(child: AppLoading());
                }
                if (ic.invoices.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'no_invoices'.tr,
                      actionLabel: 'add_invoice'.tr,
                      actionIcon: Icons.add_rounded,
                      onAction: () => Get.to(() => AddInvoiceView(merchantId: merchantId)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    resp.pagePadding,
                    resp.spacing2XS,
                    resp.pagePadding,
                    resp.pagePadding + resp.bottomInset,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: ic.invoices.length,
                  itemBuilder: (ctx, i) => _InvoiceCard(invoice: ic.invoices[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_invoice_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.to(() => AddInvoiceView(merchantId: merchantId));
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSummaryHeader(
      BuildContext context, InvoiceController ic, AppResponsive resp) {
    return Obx(() => Container(
          margin: EdgeInsets.symmetric(
            horizontal: resp.pagePadding,
            vertical: resp.spacingXS,
          ),
          padding: EdgeInsets.all(resp.spacingSM + 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(resp.cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _SumItem(
                label: 'total_invoices_amount'.tr,
                value: CurrencyFormatter.format(ic.totalAmount),
                color: Colors.white,
              ),
              _divider(),
              _SumItem(
                label: 'total_paid'.tr,
                value: CurrencyFormatter.format(ic.totalPaid),
                color: const Color(0xFF6EE7B7), // Mint green
              ),
              _divider(),
              _SumItem(
                label: 'total_remaining'.tr,
                value: CurrencyFormatter.format(ic.totalRemaining),
                color: const Color(0xFFFDBA74), // Orange
              ),
            ],
          ),
        ));
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: Colors.white24,
      );

  void _showMerchantInfo(BuildContext context, dynamic merchant) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(resp.spacingSM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.store_rounded, color: AppColors.primary, size: resp.iconMD),
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Text(
                  merchant.name,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w800,
                    fontSize: resp.fontLG,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM),
          const Divider(height: 1),
          SizedBox(height: resp.spacingSM),
          if (merchant.phone.isNotEmpty)
            _infoRow(Icons.phone_rounded, 'phone_number'.tr, merchant.phone, isDark, resp),
          if (merchant.address.isNotEmpty)
            _infoRow(Icons.location_on_rounded, 'address'.tr, merchant.address, isDark, resp),
          if (merchant.notes != null && merchant.notes!.isNotEmpty)
            _infoRow(Icons.notes_rounded, 'notes'.tr, merchant.notes!, isDark, resp),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark, AppResponsive resp) {
    return Padding(
      padding: EdgeInsets.only(bottom: resp.spacingSM),
      child: Row(
        children: [
          Icon(icon, size: resp.iconSM - 2, color: isDark ? AppColors.darkPrimary : AppColors.primary),
          SizedBox(width: resp.spacingSM),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: resp.fontSM,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: resp.fontSM,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _exportPDF(BuildContext context, dynamic merchant, List<Invoice> invoices) async {
    HapticFeedback.lightImpact();
    await ExportService.exportMerchantInvoicesToPDF(
      merchant: merchant,
      invoices: invoices,
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
    final resp = AppResponsive.of(context);

    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: resp.fontXS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: resp.fontMD,
                letterSpacing: -0.3,
              ),
            ),
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
    final resp = AppResponsive.of(context);
    final paid = invoice.isFullyPaid;
    final color = paid ? AppColors.got : AppColors.give;
    final pct = invoice.paymentPercentage;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: resp.spacingSM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 1.2,
        ),
        boxShadow: AppShadows.subtle(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(resp.cardRadius),
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(() => InvoiceDetailView(invoice: invoice));
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showOptions(context);
          },
          child: Padding(
            padding: EdgeInsets.all(resp.spacingSM + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(resp.radiusSM),
                        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          paid ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                          color: color,
                          size: resp.iconSM,
                        ),
                      ),
                    ),
                    SizedBox(width: resp.spacingSM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${invoice.invoiceNumber}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800,
                              fontSize: resp.fontMD,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy/MM/dd').format(invoice.date),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontSize: resp.fontXS,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: resp.spacingSM),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: resp.isTablet ? 170 : 135,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              CurrencyFormatter.format(invoice.totalAmount),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w900,
                                fontSize: resp.fontMD,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              paid
                                  ? 'fully_paid'.tr
                                  : '${'remaining'.tr}: ${CurrencyFormatter.format(invoice.remainingAmount)}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: color,
                                fontSize: resp.fontXS,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: resp.spacingSM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(resp.radiusXS),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
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

    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(
              'edit_invoice'.tr,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Get.back();
              Get.to(() => AddInvoiceView(
                    merchantId: invoice.merchantId,
                    invoice: invoice,
                  ));
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            ),
            title: Text(
              'delete_invoice'.tr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Get.back();
              _confirmDelete(context, ic);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, InvoiceController ic) {
    AppDialog.confirm(
      context: context,
      title: 'delete_invoice'.tr,
      message: 'delete_invoice_confirm'.tr,
      confirmLabel: 'delete'.tr,
      isDestructive: true,
      onConfirm: () => ic.deleteInvoice(invoice.id),
    );
  }
}
