import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/merchant_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/invoice.dart';
import '../../models/merchant.dart';
import '../../services/export_service.dart';
import '../../widgets/amount_field.dart';
import 'add_invoice_view.dart';

class InvoiceDetailView extends StatefulWidget {
  final Invoice invoice;
  const InvoiceDetailView({super.key, required this.invoice});

  @override
  State<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends State<InvoiceDetailView> {
  Invoice get invoice => widget.invoice;

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    Merchant? merchant;
    if (invoice.merchantId != null && Get.isRegistered<MerchantController>()) {
      merchant =
          Get.find<MerchantController>().getMerchantById(invoice.merchantId!);
    }

    Customer? customer;
    if (invoice.customerId != null && Get.isRegistered<CustomerController>()) {
      customer =
          Get.find<CustomerController>().getCustomerById(invoice.customerId!);
    }

    final paid = invoice.isFullyPaid;
    final isPartiallyPaid = invoice.paidAmount > 0 && !paid;
    final statusColor = paid
        ? AppColors.got
        : (isPartiallyPaid ? AppColors.warning : AppColors.give);
    final currCode =
        invoice.currencyCode.isNotEmpty ? invoice.currencyCode : 'YER';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle('#${invoice.invoiceNumber}'),
        actions: [
          IconButton(
            tooltip: 'preview_report'.tr,
            icon: Icon(Icons.visibility_outlined, size: resp.iconSM),
            onPressed: () => ExportService.previewInvoice(
              invoice: invoice,
              customer: customer,
              merchant: merchant,
            ),
          ),
          IconButton(
            tooltip: 'export_pdf'.tr,
            icon: Icon(Icons.picture_as_pdf_rounded, size: resp.iconSM),
            onPressed: () =>
                _exportPDF(context, customer: customer, merchant: merchant),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: resp.iconSM),
            onPressed: () => Get.off(() => AddInvoiceView(
                  merchantId: invoice.merchantId,
                  customerId: invoice.customerId,
                  invoice: invoice,
                )),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.give, size: resp.iconSM),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: AppPageContainer(
        maxWidth: 640,
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: resp.spacingSM,
            vertical: resp.spacingMD,
          ),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Status badge hero card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: resp.spacingLG,
                  horizontal: resp.spacingMD,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor,
                      statusColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(resp.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(resp.spacingSM),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        paid
                            ? Icons.check_circle_rounded
                            : (isPartiallyPaid
                                ? Icons.timelapse_rounded
                                : Icons.hourglass_bottom_rounded),
                        color: Colors.white,
                        size: resp.iconLG + 4,
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),
                    Text(
                      paid
                          ? 'paid_full'.tr
                          : (isPartiallyPaid
                              ? 'partially_paid'.tr
                              : 'unpaid'.tr),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: resp.fontLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: resp.spacingSM),
                    // Progress bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: resp.spacingSM),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(resp.radiusSM),
                        child: LinearProgressIndicator(
                          value: invoice.paymentPercentage,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: resp.spacingXS),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: resp.spacingSM,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(resp.radiusSM),
                      ),
                      child: Text(
                        '${(invoice.paymentPercentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                          fontSize: resp.fontXS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: resp.spacingMD),

              // Amount summary cards (Responsive layout without overflowing Rows)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 360) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _AmountCard(
                                label: 'total_amount'.tr,
                                amount: invoice.totalAmount,
                                currencyCode: currCode,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: resp.spacingXS),
                            Expanded(
                              child: _AmountCard(
                                label: 'paid_amount'.tr,
                                amount: invoice.paidAmount,
                                currencyCode: currCode,
                                color: AppColors.got,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: resp.spacingXS),
                        SizedBox(
                          width: double.infinity,
                          child: _AmountCard(
                            label: 'remaining_amount'.tr,
                            amount: invoice.remainingAmount,
                            currencyCode: currCode,
                            color: AppColors.give,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _AmountCard(
                          label: 'total_amount'.tr,
                          amount: invoice.totalAmount,
                          currencyCode: currCode,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: resp.spacingXS),
                      Expanded(
                        child: _AmountCard(
                          label: 'paid_amount'.tr,
                          amount: invoice.paidAmount,
                          currencyCode: currCode,
                          color: AppColors.got,
                        ),
                      ),
                      SizedBox(width: resp.spacingXS),
                      Expanded(
                        child: _AmountCard(
                          label: 'remaining_amount'.tr,
                          amount: invoice.remainingAmount,
                          currencyCode: currCode,
                          color: AppColors.give,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: resp.spacingMD),

              // Line items card (Fully responsive - never overflows)
              if (invoice.items.isNotEmpty) ...[
                AppCard(
                  padding: EdgeInsets.all(resp.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 340;
                          final iconWidget = Container(
                            padding: EdgeInsets.all(resp.spacingXS),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(resp.radiusXS),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.primary,
                              size: resp.iconSM,
                            ),
                          );

                          final badgeWidget = Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: resp.spacingSM,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(resp.radiusSM),
                            ),
                            child: Text(
                              '${invoice.items.length} ${'items_count'.tr}',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontXS,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          );

                          if (isNarrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    iconWidget,
                                    SizedBox(width: resp.spacingSM),
                                    Expanded(
                                      child: Text(
                                        'invoice_items'.tr,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: resp.fontMD,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: resp.spacingXS),
                                badgeWidget,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              iconWidget,
                              SizedBox(width: resp.spacingSM),
                              Expanded(
                                child: Text(
                                  'invoice_items'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: resp.fontMD,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: resp.spacingXS),
                              badgeWidget,
                            ],
                          );
                        },
                      ),
                      SizedBox(height: resp.spacingSM),
                      const Divider(height: 1),
                      SizedBox(height: resp.spacingXS),
                      ...invoice.items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return Container(
                          padding:
                              EdgeInsets.symmetric(vertical: resp.spacingSM),
                          decoration: BoxDecoration(
                            border: i < invoice.items.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.grey.withValues(alpha: 0.1),
                                    ),
                                  )
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(resp.radiusXS),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: resp.fontXS - 1,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: resp.spacingXS + 2),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w700,
                                        fontSize: resp.fontMD,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: resp.spacingSM),
                                  Text(
                                    CurrencyFormatter.format(item.total,
                                        currencyCode: currCode),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w900,
                                      fontSize: resp.fontMD,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: resp.spacing2XS),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 22 + resp.spacingXS + 2,
                                ),
                                child: Text(
                                  '${item.quantity} × ${CurrencyFormatter.format(item.unitPrice, currencyCode: currCode)}',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: resp.fontXS,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: resp.spacingMD),
              ],

              // Details info card
              AppCard(
                padding: EdgeInsets.all(resp.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(resp.spacingXS),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(resp.radiusXS),
                          ),
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: resp.iconSM,
                          ),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Text(
                          'invoice_details'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: resp.fontMD,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: resp.spacingSM),
                    const Divider(height: 1),
                    SizedBox(height: resp.spacingXS),
                    _DetailRow(
                      label: 'invoice_number'.tr,
                      value: '#${invoice.invoiceNumber}',
                    ),
                    if (customer != null)
                      _DetailRow(
                        label: 'customer_name'.tr,
                        value: customer.name,
                      ),
                    if (merchant != null)
                      _DetailRow(
                        label: 'merchant_name'.tr,
                        value: merchant.name,
                      ),
                    if (customer != null && customer.phoneNumber.isNotEmpty)
                      _DetailRow(
                        label: 'phone'.tr,
                        value: customer.phoneNumber,
                      ),
                    if (merchant != null && merchant.phone.isNotEmpty)
                      _DetailRow(
                        label: 'phone'.tr,
                        value: merchant.phone,
                      ),
                    _DetailRow(
                      label: 'account_currency'.tr,
                      value: () {
                        final c = AppCurrency.fromCode(currCode);
                        final isAr = Get.locale?.languageCode == 'ar';
                        return '${c.flag} ${c.getName(isArabic: isAr)} (${c.getSymbol(isArabic: isAr)})';
                      }(),
                    ),
                    _DetailRow(
                      label: 'invoice_date'.tr,
                      value:
                          DateFormat('yyyy/MM/dd HH:mm').format(invoice.date),
                    ),
                    if (invoice.notes != null && invoice.notes!.isNotEmpty)
                      _DetailRow(
                        label: 'notes'.tr,
                        value: invoice.notes!,
                      ),
                  ],
                ),
              ),
              SizedBox(height: resp.spacingMD),

              // WhatsApp Delivery Section
              _buildWhatsAppDeliveryCard(context,
                  customer: customer, merchant: merchant),
              SizedBox(height: resp.spacingLG),

              // Action Buttons (PDF & Record Payment - Responsive layout)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 360 && !paid) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'record_give'.tr,
                            icon: Icons.payments_rounded,
                            variant: AppButtonVariant.got,
                            onPressed: () => _showPayDialog(context),
                          ),
                        ),
                        SizedBox(height: resp.spacingSM),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'export_pdf'.tr,
                            icon: Icons.picture_as_pdf_rounded,
                            variant: AppButtonVariant.outlined,
                            onPressed: () => _exportPDF(context,
                                customer: customer, merchant: merchant),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'export_pdf'.tr,
                          icon: Icons.picture_as_pdf_rounded,
                          variant: AppButtonVariant.outlined,
                          onPressed: () => _exportPDF(context,
                              customer: customer, merchant: merchant),
                        ),
                      ),
                      if (!paid) ...[
                        SizedBox(width: resp.spacingSM),
                        Expanded(
                          child: AppButton(
                            text: 'record_give'.tr,
                            icon: Icons.payments_rounded,
                            variant: AppButtonVariant.got,
                            onPressed: () => _showPayDialog(context),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              SizedBox(height: resp.pagePadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppDeliveryCard(BuildContext context,
      {Customer? customer, Merchant? merchant}) {
    final resp = AppResponsive.of(context);
    const waColor = Color(0xFF25D366);
    final status = invoice.whatsappStatus;
    final isSent = status == 'sent';
    final isSending = status == 'sending' || status == 'pending';
    final isFailed = status == 'failed';
    final autoDeliveryOn = customer?.autoSendInvoiceWhatsApp ?? false;

    final targetPhone =
        customer?.effectiveWhatsAppNumber ?? merchant?.phone ?? '';
    final formattedPhone = targetPhone.isNotEmpty
        ? PhoneNumberHelper.formatForDisplay(targetPhone)
        : 'no_whatsapp_number'.tr;

    Color badgeColor = Colors.grey;
    String statusTitle = 'لم يتم الإرسال بعد';
    IconData statusIcon = Icons.chat_bubble_outline_rounded;

    if (isSent) {
      badgeColor = waColor;
      statusTitle = 'whatsapp_sent_success'.tr;
      statusIcon = Icons.check_circle_rounded;
    } else if (isSending) {
      badgeColor = Colors.blue;
      statusTitle = 'whatsapp_sending'.tr;
      statusIcon = Icons.hourglass_top_rounded;
    } else if (isFailed) {
      badgeColor = AppColors.error;
      statusTitle = 'whatsapp_failed'.tr;
      statusIcon = Icons.error_outline_rounded;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(resp.spacingMD),
      border: Border.all(
        color: isSent
            ? waColor.withValues(alpha: 0.35)
            : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final iconWidget = Container(
                padding: EdgeInsets.all(resp.spacingXS),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(resp.radiusXS),
                ),
                child: Icon(statusIcon, color: badgeColor, size: resp.iconSM),
              );

              final badgeWidget = Container(
                padding: EdgeInsets.symmetric(
                  horizontal: resp.spacingSM,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: (autoDeliveryOn ? waColor : Colors.grey)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Text(
                  autoDeliveryOn
                      ? 'whatsapp_auto_delivery_on'.tr
                      : 'whatsapp_auto_delivery_off'.tr,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontXS,
                    fontWeight: FontWeight.bold,
                    color: autoDeliveryOn
                        ? waColor
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        iconWidget,
                        SizedBox(width: resp.spacingSM),
                        Expanded(
                          child: Text(
                            'whatsapp_delivery'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: resp.fontMD,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: resp.spacingXS),
                    badgeWidget,
                  ],
                );
              }

              return Row(
                children: [
                  iconWidget,
                  SizedBox(width: resp.spacingSM),
                  Expanded(
                    child: Text(
                      'whatsapp_delivery'.tr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: resp.fontMD,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: resp.spacingXS),
                  badgeWidget,
                ],
              );
            },
          ),
          SizedBox(height: resp.spacingSM),
          const Divider(height: 1),
          SizedBox(height: resp.spacingSM),

          // Status details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSent
                    ? Icons.done_all_rounded
                    : (isFailed
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded),
                size: resp.iconXS,
                color: badgeColor,
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: resp.fontSM,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${'phone'.tr}: $formattedPhone',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontXS,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (invoice.whatsappSentAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${'whatsapp_sent_at'.tr}: ${DateFormat('yyyy/MM/dd — hh:mm a').format(invoice.whatsappSentAt!)}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: resp.fontXS - 1,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                    if (isFailed && invoice.whatsappError != null) ...[
                      SizedBox(height: resp.spacingXS),
                      Container(
                        padding: EdgeInsets.all(resp.spacingXS),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(resp.radiusSM),
                        ),
                        child: Text(
                          '${'whatsapp_error'.tr}: ${invoice.whatsappError}',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontXS,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM),

          // Trigger / Resend Button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: isFailed
                  ? 'resend_via_whatsapp'.tr
                  : (isSent
                      ? 'resend_via_whatsapp'.tr
                      : 'send_via_whatsapp'.tr),
              icon: isFailed
                  ? Icons.refresh_rounded
                  : (isSent ? Icons.send_rounded : Icons.chat_bubble_rounded),
              isLoading: isSending,
              onPressed: isSending
                  ? null
                  : () async {
                      final ic = Get.find<InvoiceController>();
                      await ic.resendWhatsAppDelivery(
                        invoice: invoice,
                        customer: customer,
                        merchant: merchant,
                      );
                      Get.forceAppUpdate();
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context,
      {Customer? customer, Merchant? merchant}) async {
    try {
      Get.snackbar('exporting'.tr, 'please_wait'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1));
      await ExportService.exportInvoiceToPDF(
        invoice: invoice,
        customer: customer,
        merchant: merchant,
      );
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  void _showPayDialog(BuildContext context) {
    final remaining = invoice.remainingAmount;
    if (remaining <= 0) {
      Get.snackbar(
        'warning'.tr,
        'invoice_already_fully_paid'.tr,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final payCtrl = TextEditingController();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currCode =
        invoice.currencyCode.isNotEmpty ? invoice.currencyCode : 'YER';
    final formKey = GlobalKey<FormState>();

    StateSetter? dialogSetter;
    void onTextChanged() {
      dialogSetter?.call(() {});
    }

    payCtrl.addListener(onTextChanged);

    AppDialog.show(
      context: context,
      maxWidth: 420,
      child: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          dialogSetter = setDialogState;
          final enteredText = payCtrl.text.trim();
          final enteredAmount = double.tryParse(enteredText) ?? 0.0;
          final isExceeding = enteredAmount > remaining + 0.0001;

          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(resp.spacingXS),
                        decoration: BoxDecoration(
                          color: AppColors.got.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(resp.radiusSM),
                        ),
                        child: Icon(Icons.payments_rounded,
                            color: AppColors.got, size: resp.iconSM),
                      ),
                      SizedBox(width: resp.spacingSM),
                      Expanded(
                        child: Text(
                          'record_give'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: resp.fontLG,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: resp.spacingMD),

                  // Remaining amount display card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(resp.spacingSM),
                    decoration: BoxDecoration(
                      color: AppColors.give.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                      border: Border.all(
                        color: AppColors.give.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'remaining_amount'.tr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: resp.fontSM,
                              color: isDark ? AppColors.textSecondaryDark : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: resp.spacingSM),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              CurrencyFormatter.format(remaining,
                                  currencyCode: currCode),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontMD,
                                fontWeight: FontWeight.w900,
                                color: AppColors.give,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick fill full remaining chip/button
                  Padding(
                    padding: EdgeInsets.only(top: resp.spacingXS),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                      onTap: () {
                        final formatted = remaining.truncateToDouble() == remaining
                            ? remaining.toInt().toString()
                            : remaining.toStringAsFixed(2);
                        payCtrl.text = formatted;
                        setDialogState(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: resp.spacingXS,
                          horizontal: 4,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flash_on_rounded,
                                  size: resp.iconXS, color: AppColors.got),
                              const SizedBox(width: 4),
                              Text(
                                '${'pay_full_remaining'.tr} (${CurrencyFormatter.format(remaining, currencyCode: currCode)})',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: resp.fontXS,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.got,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: resp.spacingSM),

                  // Amount input field
                  AmountField(
                    controller: payCtrl,
                    label: 'amount'.tr,
                    hint: '0',
                    currencyCode: currCode,
                    autofocus: true,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'enter_amount'.tr;
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null || parsed <= 0) {
                        return 'invalid_amount'.tr;
                      }
                      if (parsed > remaining + 0.0001) {
                        return 'payment_exceeds_remaining_error'.trParams({
                          'max': CurrencyFormatter.format(remaining,
                              currencyCode: currCode),
                        });
                      }
                      return null;
                    },
                  ),

                  // Prominent notice banner if amount exceeds remaining
                  if (isExceeding) ...[
                    Container(
                      margin: EdgeInsets.only(top: resp.spacingSM),
                      padding: EdgeInsets.symmetric(
                        horizontal: resp.spacingSM,
                        vertical: resp.spacingXS + 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(resp.radiusSM),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: resp.iconSM,
                          ),
                          SizedBox(width: resp.spacingXS),
                          Expanded(
                            child: Text(
                              'payment_exceeds_remaining_notice'.trParams({
                                'max': CurrencyFormatter.format(remaining,
                                    currencyCode: currCode),
                              }),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: resp.fontXS,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFFF8A80)
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: resp.spacingLG),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'cancel'.tr,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      SizedBox(width: resp.spacingSM),
                      Expanded(
                        child: AppButton(
                          text: 'confirm'.tr,
                          icon: Icons.check_rounded,
                          variant: AppButtonVariant.got,
                          onPressed: () async {
                            final text = payCtrl.text.trim();
                            if (text.isEmpty) {
                              Get.snackbar(
                                'warning'.tr,
                                'enter_amount'.tr,
                                backgroundColor: AppColors.warning,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                            final amount = double.tryParse(text);
                            if (amount == null || amount <= 0) {
                              Get.snackbar(
                                'warning'.tr,
                                'invalid_amount'.tr,
                                backgroundColor: AppColors.warning,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                            if (amount > remaining + 0.0001) {
                              HapticFeedback.heavyImpact();
                              Get.snackbar(
                                'warning'.tr,
                                'payment_exceeds_remaining_error'.trParams({
                                  'max': CurrencyFormatter.format(remaining,
                                      currencyCode: currCode),
                                }),
                                backgroundColor: AppColors.error,
                                colorText: Colors.white,
                                icon: const Icon(Icons.error_outline_rounded,
                                    color: Colors.white),
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 4),
                              );
                              return;
                            }

                            HapticFeedback.mediumImpact();
                            invoice.paidAmount = (invoice.paidAmount + amount)
                                .clamp(0.0, invoice.totalAmount);
                            await Get.find<InvoiceController>()
                                .updateInvoice(invoice);
                            Get.back(); // close dialog
                            setState(() {}); // refresh InvoiceDetailView

                            Get.snackbar(
                              'success'.tr,
                              'payment_recorded_success'.tr,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                              icon: const Icon(Icons.check_circle_rounded,
                                  color: Colors.white),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) {
      payCtrl.removeListener(onTextChanged);
      payCtrl.dispose();
    });
  }

  void _confirmDelete(BuildContext context) {
    AppDialog.confirm(
      context: context,
      title: 'delete_invoice'.tr,
      message: 'delete_invoice_confirm'.tr,
      confirmLabel: 'delete'.tr,
      isDestructive: true,
      onConfirm: () {
        Get.find<InvoiceController>().deleteInvoice(invoice.id);
        Get.back();
      },
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currencyCode;
  final Color color;
  const _AmountCard({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: resp.spacingSM,
        vertical: resp.spacingSM,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(resp.cardRadius * 0.75),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: resp.fontXS,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.format(amount, currencyCode: currencyCode),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: resp.fontMD,
              ),
            ),
          ),
        ],
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
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: resp.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: resp.fontSM,
            ),
          ),
          SizedBox(width: resp.spacingSM),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: resp.fontSM,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
