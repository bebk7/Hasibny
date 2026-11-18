import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';
import '../../core/core.dart';
import '../../widgets/amount_field.dart';
import '../add_customer/add_customer_view.dart';

class CustomerDetailsView extends StatefulWidget {
  final int customerId;

  const CustomerDetailsView({super.key, required this.customerId});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  String _transactionFilter = 'all'; // 'all', 'give', 'got'

  @override
  void initState() {
    super.initState();
    final tc = Get.find<TransactionController>();
    Future.microtask(() => tc.loadTransactionsForCustomer(widget.customerId));
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    final transactionController = Get.find<TransactionController>();
    final resp = AppResponsive.of(context);

    return Obx(() {
      final customer = customerController.getCustomerById(widget.customerId);
      if (customer == null) {
        return Scaffold(
          appBar: AppBar(title: Text('customer_details'.tr)),
          body: AppEmptyState(
            icon: Icons.person_off_rounded,
            title: 'customer_not_found'.tr,
          ),
        );
      }

      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            customer.name,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: resp.fontSize(18, min: 16, max: 21),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'edit'.tr,
              onPressed: () => Get.to(() => AddCustomerView(customer: customer)),
            ),
            IconButton(
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'preview_report'.tr,
              onPressed: () {
                final balance = transactionController.isLoading.value
                    ? customerController.getCustomerBalance(widget.customerId)
                    : transactionController.getCustomerBalance(widget.customerId);
                ExportService.previewCustomerReport(
                  customer: customer,
                  transactions: transactionController.transactions.toList(),
                  balance: balance,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'export_pdf'.tr,
              onPressed: () async {
                final balance = transactionController.isLoading.value
                    ? customerController.getCustomerBalance(widget.customerId)
                    : transactionController.getCustomerBalance(widget.customerId);
                await ExportService.exportCustomerToPDF(
                  customer: customer,
                  transactions: transactionController.transactions.toList(),
                  balance: balance,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'delete'.tr,
              onPressed: () => _confirmDelete(context, customerController),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: resp.maxContentWidth),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildCustomerHeader(
                    context,
                    customerController,
                    transactionController,
                    customer,
                    resp,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: resp.spacingMD)),
                SliverToBoxAdapter(
                  child: _buildWhatsAppInfoCard(context, customer, resp),
                ),
                SliverToBoxAdapter(child: SizedBox(height: resp.spacingMD)),
                SliverToBoxAdapter(
                  child: _buildTransactionSummary(
                    context,
                    transactionController,
                    customer.currencyCode,
                    resp,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: resp.spacingMD)),
                SliverToBoxAdapter(
                  child: _buildFilterBar(context, resp),
                ),
                SliverToBoxAdapter(child: SizedBox(height: resp.spacingSM)),
                _buildTransactionsListSliver(
                  context,
                  transactionController,
                  customer,
                  resp,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'customer_details_add_tx',
          onPressed: () => _showAddTransactionDialog(
            context,
            transactionController,
            customer,
            resp,
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'add_transaction_title'.tr,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCustomerHeader(
    BuildContext context,
    CustomerController controller,
    TransactionController transactionController,
    Customer customer,
    AppResponsive resp,
  ) {
    return Obx(() {
      final balance = transactionController.isLoading.value
          ? controller.getCustomerBalance(widget.customerId)
          : transactionController.getCustomerBalance(widget.customerId);
      final isDark = AppColors.isDark(context);
      final curr = AppCurrency.fromCode(customer.currencyCode);
      final isPositive = balance >= 0;
      final color = isPositive ? AppColors.gotColor : AppColors.giveColor;
      final avatarSize = resp.isSmall ? 64.0 : 74.0;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          resp.isSmall ? 16 : 20,
          8,
          resp.isSmall ? 16 : 20,
          resp.isSmall ? 18 : 22,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceColor : Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: AppSizes.borderThin,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'customer-${customer.id}',
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.35),
                    width: AppSizes.borderHighlight,
                  ),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: resp.fontSize(resp.isSmall ? 26 : 30),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: resp.spacingSM + 2),
            Text(
              customer.name,
              style: TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: resp.fontSize(resp.isSmall ? 18 : 20),
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (customer.phoneNumber.isNotEmpty)
              InkWell(
                onTap: () => launchUrl(Uri.parse('tel:${customer.phoneNumber}')),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        customer.phoneNumber,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: resp.fontSize(13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: resp.spacingSM + 4),

            // Balance highlight box
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: resp.isSmall ? 16 : 20,
                vertical: resp.isSmall ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.35 : 0.22),
                  width: AppSizes.borderMedium,
                ),
              ),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        isPositive ? 'they_owe_you'.tr : 'you_owe_them'.tr,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: resp.fontSize(12),
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      AppBadge(
                        label: '${curr.flag} ${curr.code}',
                        color: color,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.formatAbs(balance, currencyCode: customer.currencyCode),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: resp.fontSize(resp.isSmall ? 24 : 28),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWhatsAppInfoCard(BuildContext context, Customer customer, AppResponsive resp) {
    final hasWa = customer.whatsappNumber != null && customer.whatsappNumber!.isNotEmpty;
    final isDark = AppColors.isDark(context);
    const waColor = Color(0xFF25D366);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: resp.isSmall ? 12 : 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: customer.autoSendInvoiceWhatsApp
                ? waColor.withValues(alpha: 0.35)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: AppSizes.borderThin,
          ),
          boxShadow: AppShadows.subtle(isDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: waColor.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: waColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'whatsapp_auto_send'.tr,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: resp.fontSize(12),
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    customer.autoSendInvoiceWhatsApp
                        ? (hasWa
                            ? '${'auto_send_enabled'.tr} (${customer.whatsappNumber})'
                            : 'auto_send_enabled_primary'.tr)
                        : 'auto_send_disabled'.tr,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: resp.fontSize(10),
                      color: customer.autoSendInvoiceWhatsApp
                          ? waColor
                          : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasWa)
              IconButton(
                icon: const Icon(Icons.send_rounded, color: waColor, size: 18),
                tooltip: 'open_whatsapp'.tr,
                onPressed: () {
                  final phone = PhoneNumberHelper.sanitize(customer.whatsappNumber!);
                  launchUrl(
                    Uri.parse('https://wa.me/$phone'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary(
    BuildContext context,
    TransactionController tc,
    String currencyCode,
    AppResponsive resp,
  ) {
    return Obx(() {
      final totalGive = tc.totalGiveForCustomer;
      final totalGot = tc.totalGotForCustomer;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: resp.isSmall ? 12 : 16),
        child: Row(
          children: [
            _SummaryItem(
              label: 'total_to_give'.tr,
              amount: totalGive,
              currencyCode: currencyCode,
              color: AppColors.giveColor,
              icon: Icons.arrow_upward_rounded,
              resp: resp,
            ),
            SizedBox(width: resp.spacingSM),
            _SummaryItem(
              label: 'total_to_get'.tr,
              amount: totalGot,
              currencyCode: currencyCode,
              color: AppColors.gotColor,
              icon: Icons.arrow_downward_rounded,
              resp: resp,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterBar(BuildContext context, AppResponsive resp) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: resp.isSmall ? 12 : 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterChip('all', 'all_filter'.tr, resp),
          SizedBox(width: resp.spacingSM),
          _buildFilterChip(
            'give',
            'give_filter'.tr,
            resp,
            color: AppColors.give,
          ),
          SizedBox(width: resp.spacingSM),
          _buildFilterChip(
            'got',
            'got_filter'.tr,
            resp,
            color: AppColors.got,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String filter,
    String label,
    AppResponsive resp, {
    Color? color,
  }) {
    final isSelected = _transactionFilter == filter;
    return AppFilterChip(
      label: label,
      isSelected: isSelected,
      color: color,
      onTap: () => setState(() => _transactionFilter = filter),
    );
  }

  Widget _buildTransactionsListSliver(
    BuildContext context,
    TransactionController tc,
    Customer customer,
    AppResponsive resp,
  ) {
    return Obx(() {
      if (tc.isLoading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: AppLoading(),
          ),
        );
      }

      var list = tc.transactions.toList();
      if (_transactionFilter == 'give') {
        list = list.where((t) => t.type == TransactionType.give).toList();
      } else if (_transactionFilter == 'got') {
        list = list.where((t) => t.type == TransactionType.got).toList();
      }

      if (list.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: AppEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'no_transactions'.tr,
              subtitle: 'add_first_transaction'.tr,
              isCompact: true,
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          resp.isSmall ? 12 : 16,
          4,
          resp.isSmall ? 12 : 16,
          resp.isSmall ? 80 : 96,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final tx = list[index];
              return _TransactionTile(
                transaction: tx,
                currencyCode: customer.currencyCode,
                resp: resp,
                onDelete: () => tc.deleteTransaction(tx.id, customer.id),
                onShare: () => _shareInvoice(tx, customer),
                onPreview: () => ExportService.previewTransaction(
                  transaction: tx,
                  customer: customer,
                ),
              );
            },
            childCount: list.length,
          ),
        ),
      );
    });
  }

  void _showAddTransactionDialog(
    BuildContext context,
    TransactionController controller,
    Customer customer,
    AppResponsive resp,
  ) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    var selectedType = TransactionType.give;
    var selectedDateTime = DateTime.now();
    final curr = AppCurrency.fromCode(customer.currencyCode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isDark = AppColors.isDark(context);
          final isAr = Get.locale?.languageCode == 'ar';
          final hour24 = selectedDateTime.hour;
          final minute = selectedDateTime.minute.toString().padLeft(2, '0');
          final isPm = hour24 >= 12;
          final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
          final period = isAr ? (isPm ? 'م' : 'ص') : (isPm ? 'PM' : 'AM');
          final timeStr = '${hour12.toString().padLeft(2, '0')}:$minute $period';
          final dateStr =
              '${selectedDateTime.year}/${selectedDateTime.month.toString().padLeft(2, '0')}/${selectedDateTime.day.toString().padLeft(2, '0')}';

          final viewInsets = MediaQuery.viewInsetsOf(context);
          final viewPadding = MediaQuery.viewPaddingOf(context);

          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: resp.maxContentWidth,
                  maxHeight: resp.screenHeight * 0.85,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceColor : Colors.white,
                  borderRadius: AppRadius.bottomSheetRadius(context),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: resp.isExtraCompact ? 14 : 20,
                      right: resp.isExtraCompact ? 14 : 20,
                      top: 14,
                      bottom: viewPadding.bottom + 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'add_transaction_title'.tr,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: resp.fontSize(18),
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppBadge(label: '${curr.flag} ${curr.code}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _TypeButton(
                        label: 'you_got_btn'.tr,
                        isSelected: selectedType == TransactionType.got,
                        color: AppColors.gotColor,
                        icon: Icons.arrow_downward_rounded,
                        resp: resp,
                        onTap: () => setState(() => selectedType = TransactionType.got),
                      ),
                      SizedBox(width: resp.spacingSM),
                      _TypeButton(
                        label: 'you_gave_btn'.tr,
                        isSelected: selectedType == TransactionType.give,
                        color: AppColors.giveColor,
                        icon: Icons.arrow_upward_rounded,
                        resp: resp,
                        onTap: () => setState(() => selectedType = TransactionType.give),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AmountField(
                    controller: amountController,
                    label: 'amount'.tr,
                    hint: '0',
                    currencyCode: customer.currencyCode,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'description'.tr,
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Transaction Date & Time Selector
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            selectedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardColor : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 20,
                            color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'transaction_time'.tr,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: resp.fontSize(11),
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$dateStr  -  $timeStr',
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    fontSize: resp.fontSize(13),
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    text: 'confirm'.tr,
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text.trim());
                      if (amount == null || amount <= 0) {
                        Get.snackbar(
                          'error'.tr,
                          'valid_amount'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.errorColor,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      Navigator.pop(context);
                      await controller.addTransaction(
                        customerId: customer.id,
                        amount: amount,
                        type: selectedType,
                        description: descriptionController.text.trim(),
                        currencyCode: customer.currencyCode,
                        createdAt: selectedDateTime,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
),
);
  }

  Future<void> _shareInvoice(TransactionModel transaction, Customer customer) async {
    await ExportService.shareTransactionAsPDF(
      transaction: transaction,
      customer: customer,
    );
  }

  void _confirmDelete(BuildContext context, CustomerController controller) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'delete_customer'.tr,
      message: 'delete_customer_confirm'.tr,
      confirmLabel: 'delete'.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      await controller.deleteCustomer(widget.customerId);
      Get.back();
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final String currencyCode;
  final Color color;
  final IconData icon;
  final AppResponsive resp;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.color,
    required this.icon,
    required this.resp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.28 : 0.16),
            width: AppSizes.borderThin,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: resp.fontSize(11),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(amount, currencyCode: currencyCode),
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: resp.fontSize(17, min: 14, max: 20),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final AppResponsive resp;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.resp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDark
                    ? color.withValues(alpha: 0.12)
                    : color.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.2),
              width: AppSizes.borderMedium,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w800,
                    fontSize: resp.fontSize(14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String currencyCode;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback? onPreview;
  final AppResponsive resp;

  const _TransactionTile({
    required this.transaction,
    required this.currencyCode,
    required this.onDelete,
    required this.onShare,
    this.onPreview,
    required this.resp,
  });

  @override
  Widget build(BuildContext context) {
    final isGive = transaction.type == TransactionType.give;
    final color = isGive ? AppColors.giveColor : AppColors.gotColor;
    final isDark = AppColors.isDark(context);

    return Dismissible(
      key: Key(transaction.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await AppDialog.confirm(
          context: context,
          title: 'delete_transaction'.tr,
          message: 'delete_transaction_confirm'.tr,
          confirmLabel: 'delete'.tr,
          isDestructive: true,
        );
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.giveColor,
          borderRadius: BorderRadius.circular(resp.cardRadius),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(resp.cardRadius),
          onTap: onPreview,
          child: Container(
            margin: EdgeInsets.only(bottom: resp.listSpacing),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(resp.cardRadius),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: AppSizes.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: color.withValues(alpha: 0.25), width: AppSizes.borderThin),
                    ),
                    child: Center(
                      child: Icon(
                        isGive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: resp.spacingSM + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description.isNotEmpty
                              ? transaction.description
                              : (isGive ? 'give'.tr : 'got'.tr),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: resp.fontSize(13),
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.formattedDate,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: resp.fontSize(11),
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: resp.spacingSM),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (resp.availableWidth * 0.40).clamp(90.0, 180.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, currencyCode: currencyCode)}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: color,
                                fontWeight: FontWeight.w900,
                                fontSize: resp.fontSize(14),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              size: 15,
                              color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onShare();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
