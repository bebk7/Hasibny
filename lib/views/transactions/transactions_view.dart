import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../core/core.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../services/export_service.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GuidedTourManager.instance.showIfFirstVisit(context, AppTours.buildTransactionsTour());
      }
    });
  }

  @override
  void dispose() {
    GuidedTourManager.instance.cancelPendingTour(AppTours.transactionsTourId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<TransactionController>();
    final cc = Get.find<CustomerController>();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: AppAppBarTitle('all_transactions'.tr),
        actions: [
          GuidedTourTarget(
            step: AppTours.buildTransactionsTour().steps[2],
            child: IconButton(
              tooltip: 'preview_report'.tr,
              icon: Container(
                padding: EdgeInsets.all(resp.spacingXS),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.visibility_rounded,
                  size: resp.iconSM,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ExportService.previewAllReportPDF(
                  customers: cc.customers.toList(),
                  balances: Map<int, double>.from(cc.customerBalances),
                  transactions: tc.allTransactions.toList(),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'refresh'.tr,
            icon: Container(
              padding: EdgeInsets.all(resp.spacingXS),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: resp.iconSM,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              tc.loadAllTransactions();
            },
          ),
          SizedBox(width: resp.spacingXS),
        ],
      ),
      body: Obx(() {
        if (tc.isLoading.value) {
          return const Center(child: AppLoading());
        }

        return AppPageContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              GuidedTourTarget(
                step: AppTours.buildTransactionsTour().steps[0],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCurrencyFilterBar(context, tc, resp),
                    _buildTypeFilterBar(context, tc, resp),
                    _buildSummaryHeader(context, tc, resp),
                  ],
                ),
              ),
              Expanded(
                child: GuidedTourTarget(
                  step: AppTours.buildTransactionsTour().steps[1],
                  child: Obx(() {
                    final list = tc.filteredAllTransactions;
                    if (list.isEmpty) return _buildEmptyState(context);

                    final isTablet = resp.isTablet;

                    if (isTablet) {
                      final cardExtent = resp.textScaleFactor > 1.2 ? 104.0 : 92.0;
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          resp.pagePadding,
                          resp.spacingSM,
                          resp.pagePadding,
                          resp.pagePadding + resp.bottomInset,
                        ),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 480,
                          mainAxisExtent: cardExtent,
                          crossAxisSpacing: resp.spacingMD,
                          mainAxisSpacing: resp.spacingSM,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final transaction = list[index];
                          final customer = cc.getCustomerById(transaction.customerId);
                          return _TransactionCard(
                            transaction: transaction,
                            customer: customer,
                            onShare: () => _shareInvoice(transaction, customer),
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        resp.pagePadding,
                        resp.spacingSM,
                        resp.pagePadding,
                        resp.pagePadding + resp.bottomInset,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final transaction = list[index];
                        final customer = cc.getCustomerById(transaction.customerId);
                        return _TransactionCard(
                          transaction: transaction,
                          customer: customer,
                          onShare: () => _shareInvoice(transaction, customer),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrencyFilterBar(
      BuildContext context, TransactionController tc, AppResponsive resp) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        resp.pagePadding,
        resp.spacingSM,
        resp.pagePadding,
        resp.spacing2XS,
      ),
      child: Row(
        children: [
          AppFilterChip(
            label: 'all_currencies'.tr,
            isSelected: tc.selectedCurrencyFilter.value == 'all',
            onTap: () => tc.setCurrencyFilter('all'),
          ),
          SizedBox(width: resp.spacingSM),
          ...AppCurrency.supportedCurrencies.map((c) {
            return Padding(
              padding: EdgeInsetsDirectional.only(end: resp.spacingSM),
              child: AppFilterChip(
                label: '${c.flag} ${c.code}',
                isSelected: tc.selectedCurrencyFilter.value == c.code,
                onTap: () => tc.setCurrencyFilter(c.code),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeFilterBar(
      BuildContext context, TransactionController tc, AppResponsive resp) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        resp.pagePadding,
        resp.spacing2XS,
        resp.pagePadding,
        resp.spacingSM,
      ),
      child: Row(
        children: [
          AppFilterChip(
            label: 'all_transactions_filter'.tr,
            isSelected: tc.currentFilter.value == 'all',
            onTap: () => tc.setFilter('all'),
          ),
          SizedBox(width: resp.spacingSM),
          AppFilterChip(
            label: 'only_give'.tr,
            isSelected: tc.currentFilter.value == 'give',
            color: AppColors.give,
            onTap: () => tc.setFilter('give'),
          ),
          SizedBox(width: resp.spacingSM),
          AppFilterChip(
            label: 'only_got'.tr,
            isSelected: tc.currentFilter.value == 'got',
            color: AppColors.got,
            onTap: () => tc.setFilter('got'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(
      BuildContext context, TransactionController tc, AppResponsive resp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCurrency = tc.selectedCurrencyFilter.value == 'all'
        ? 'YER'
        : tc.selectedCurrencyFilter.value;

    final totalGive = tc.getTotalGive(activeCurrency);
    final totalGot = tc.getTotalGot(activeCurrency);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: resp.pagePadding,
        vertical: resp.spacing2XS,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: resp.spacingMD,
        vertical: resp.spacingSM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.arrow_upward_rounded,
              color: AppColors.give,
              label: 'total_given'.tr,
              amount: CurrencyFormatter.format(totalGive, currencyCode: activeCurrency),
            ),
          ),
          SizedBox(width: resp.spacingSM),
          Expanded(
            child: _SummaryCard(
              icon: Icons.arrow_downward_rounded,
              color: AppColors.got,
              label: 'total_got'.tr,
              amount: CurrencyFormatter.format(totalGot, currencyCode: activeCurrency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'no_transactions'.tr,
        subtitle: 'quick_actions'.tr,
      ),
    );
  }

  Future<void> _shareInvoice(
      TransactionModel transaction, Customer? customer) async {
    if (customer == null) return;
    await ExportService.shareTransactionAsPDF(
      transaction: transaction,
      customer: customer,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String amount;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: resp.spacingSM,
        vertical: resp.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(resp.cardRadius * 0.75),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: resp.iconXS),
              SizedBox(width: resp.spacing2XS),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacing2XS),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: resp.fontLG,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Customer? customer;
  final VoidCallback onShare;

  const _TransactionCard({
    required this.transaction,
    required this.customer,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isGive = transaction.type == TransactionType.give;
    final color = isGive ? AppColors.give : AppColors.got;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final curr = AppCurrency.fromCode(transaction.currencyCode);
    final avatarSize = resp.isSmall ? 36.0 : 40.0;

    return InkWell(
      borderRadius: BorderRadius.circular(resp.cardRadius),
      onTap: customer != null
          ? () {
              HapticFeedback.lightImpact();
              ExportService.previewTransactionReceipt(
                transaction: transaction,
                customer: customer!,
              );
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: resp.spacingSM),
        padding: EdgeInsets.symmetric(
          horizontal: resp.spacingSM + 2,
          vertical: resp.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: AppShadows.subtle(isDark),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(resp.radiusSM),
                border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
              ),
              child: Center(
                child: Icon(
                  isGive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: color,
                  size: resp.iconSM,
                ),
              ),
            ),
            SizedBox(width: resp.spacingSM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: resp.spacing2XS + 2,
                    children: [
                      Text(
                        customer?.name ??
                            (transaction.description.isNotEmpty
                                ? transaction.description
                                : 'unknown_customer'.tr),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: resp.fontMD,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      AppBadge(
                        label: '${curr.flag} ${curr.code}',
                        fontSize: 9.5,
                        padding: EdgeInsets.symmetric(
                          horizontal: resp.spacingXS - 1,
                          vertical: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: resp.spacing2XS),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: resp.spacing2XS,
                    children: [
                      if (transaction.description.isNotEmpty && customer != null) ...[
                        Text(
                          transaction.description,
                          style: AppTypography.caption(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black26,
                            fontSize: 10,
                          ),
                        ),
                      ],
                      Text(
                        transaction.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          fontSize: resp.fontXS,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: resp.spacingSM),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode)}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: resp.fontMD,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onShare();
                  },
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.share_rounded,
                      size: resp.iconXS + 2,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
