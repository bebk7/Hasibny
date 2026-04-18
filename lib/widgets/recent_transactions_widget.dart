import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/transaction.dart';
import '../themes/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/responsive.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'no_transactions'.tr,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...transactions
            .map((transaction) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.isSmall(context) ? 12 : 16,
                      vertical: Responsive.isSmall(context) ? 4 : 8,
                    ),
                    leading: Container(
                      width: Responsive.isSmall(context) ? 34 : 40,
                      height: Responsive.isSmall(context) ? 34 : 40,
                      decoration: BoxDecoration(
                        color: transaction.type == TransactionType.got
                            ? AppTheme.gotColor.withValues(alpha: 0.2)
                            : AppTheme.giveColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(
                            Responsive.isSmall(context) ? 17 : 20),
                      ),
                      child: Icon(
                        transaction.type == TransactionType.got
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: transaction.type == TransactionType.got
                            ? AppTheme.gotColor
                            : AppTheme.giveColor,
                        size: Responsive.isSmall(context) ? 16 : 20,
                      ),
                    ),
                    title: Text(
                      Get.find<CustomerController>()
                              .getCustomerById(transaction.customerId)
                              ?.name ??
                          transaction.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (transaction.description.isNotEmpty)
                          Text(
                            transaction.description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        Text(
                          transaction.formattedDate,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                    trailing: Obx(() {
                      Get.find<SettingsController>().currencySymbol;
                      final isGive = transaction.type == TransactionType.give;
                      return Text(
                        '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isGive
                                  ? AppTheme.giveColor
                                  : AppTheme.gotColor,
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    }),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
