import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/transaction.dart';
import '../../models/customer.dart';
import '../../services/export_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<TransactionController>();
    final cc = Get.find<CustomerController>();
    final sc = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('all_transactions'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => tc.loadAllTransactions(),
          ),
        ],
      ),
      body: Obx(() {
        if (tc.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildSummaryHeader(context, tc, sc),
            _buildFilterBar(context, tc),
            Expanded(
              child: Obx(() {
                final list = tc.filteredAllTransactions;
                if (list.isEmpty) return _buildEmptyState(context);

                final isTablet = Responsive.isLarge(context);

                if (isTablet) {
                  return GridView.builder(
                    padding: Responsive.pagePadding(context),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final transaction = list[index];
                      final customer =
                          cc.getCustomerById(transaction.customerId);
                      return _TransactionCard(
                        transaction: transaction,
                        customer: customer,
                        currencySymbol: sc.currencySymbol,
                        onShare: () => _shareInvoice(transaction, customer),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: Responsive.pagePadding(context),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final transaction = list[index];
                    final customer = cc.getCustomerById(transaction.customerId);
                    return _TransactionCard(
                      transaction: transaction,
                      customer: customer,
                      currencySymbol: sc.currencySymbol,
                      onShare: () => _shareInvoice(transaction, customer),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryHeader(
      BuildContext context, TransactionController tc, SettingsController sc) {
    final p = Responsive.isSmall(context) ? 10.0 : 16.0;
    return Container(
      padding: EdgeInsets.all(p),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(Responsive.cardRadius(context) * 2)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.arrow_upward_rounded,
              color: AppTheme.giveColor,
              label: 'total_given'.tr,
              amount: CurrencyFormatter.format(tc.totalGiveAll,
                  symbol: sc.currencySymbol),
            ),
          ),
          SizedBox(width: Responsive.isSmall(context) ? 8 : 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.arrow_downward_rounded,
              color: AppTheme.gotColor,
              label: 'total_got'.tr,
              amount: CurrencyFormatter.format(tc.totalGotAll,
                  symbol: sc.currencySymbol),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, TransactionController tc) {
    return SizedBox(
      height: Responsive.isSmall(context) ? 50 : 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.isSmall(context) ? 12 : 16, vertical: 10),
        children: [
          _FilterChip(
            label: 'all_transactions_filter'.tr,
            selected: tc.currentFilter.value == 'all',
            onTap: () => tc.setFilter('all'),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'only_give'.tr,
            selected: tc.currentFilter.value == 'give',
            color: AppTheme.giveColor,
            onTap: () => tc.setFilter('give'),
          ),
          const SizedBox(width: 10),
          _FilterChip(
            label: 'only_got'.tr,
            selected: tc.currentFilter.value == 'got',
            color: AppTheme.gotColor,
            onTap: () => tc.setFilter('got'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: Responsive.sp(context, 80), color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_transactions'.tr,
              style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.sp(context, 14))),
        ],
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

  const _SummaryCard(
      {required this.icon,
      required this.color,
      required this.label,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.isSmall(context) ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: Responsive.sp(context, 16)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: Responsive.sp(context, 11),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(amount,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: Responsive.sp(context, 18))),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label,
      required this.selected,
      this.color = AppTheme.primaryColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.isSmall(context) ? 12 : 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.sp(context, 13)),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Customer? customer;
  final String currencySymbol;
  final VoidCallback onShare;

  const _TransactionCard(
      {required this.transaction,
      required this.customer,
      required this.currencySymbol,
      required this.onShare});

  @override
  Widget build(BuildContext context) {
    final isGive = transaction.type == TransactionType.give;
    final color = isGive ? AppTheme.giveColor : AppTheme.gotColor;
    final isSmall = Responsive.isSmall(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 12, vertical: isSmall ? 8 : 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmall ? 18 : 22,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
                isGive ? Icons.upload_rounded : Icons.download_rounded,
                color: color,
                size: isSmall ? 16 : 20),
          ),
          SizedBox(width: isSmall ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(customer?.name ?? 'unknown_customer'.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.sp(context, 13))),
                Text(transaction.formattedDate,
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: Responsive.sp(context, 11))),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, symbol: currencySymbol)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: Responsive.sp(context, 14)),
              ),
            ),
          ),
          SizedBox(
            width: isSmall ? 32 : 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.ios_share_rounded,
                  size: isSmall ? 16 : 20, color: Colors.grey[400]),
              onPressed: onShare,
            ),
          ),
        ],
      ),
    );
  }
}
