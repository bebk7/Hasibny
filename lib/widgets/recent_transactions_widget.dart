import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../models/transaction.dart';
import '../core/core.dart';
import '../views/customer_details/customer_details_view.dart';

class RecentTransactionsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const RecentTransactionsWidget({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    if (transactions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: AppSizes.borderThin,
          ),
        ),
        child: AppEmptyState(
          icon: Icons.receipt_long_rounded,
          title: 'no_transactions'.tr,
          subtitle: 'quick_actions'.tr,
          isCompact: true,
        ),
      );
    }

    final cc = Get.find<CustomerController>();

    return Column(
      children: transactions.map((transaction) {
        final isGive = transaction.type == TransactionType.give;
        final color = isGive ? AppColors.giveColor : AppColors.gotColor;
        final customer = cc.getCustomerById(transaction.customerId);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: customer != null
                  ? () => Get.to(() => CustomerDetailsView(customerId: customer.id))
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: resp.isExtraCompact ? 10 : (resp.isSmall ? 12 : 14),
                  vertical: resp.isSmall ? 10 : 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: resp.isSmall ? 38 : 42,
                      height: resp.isSmall ? 38 : 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                          width: AppSizes.borderThin,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isGive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: color,
                          size: resp.isSmall ? 20 : 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer?.name ??
                                (transaction.description.isNotEmpty
                                    ? transaction.description
                                    : 'unknown_customer'.tr),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: resp.fontSize(resp.isSmall ? 13 : 14),
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              if (transaction.description.isNotEmpty && customer != null) ...[
                                Text(
                                  transaction.description,
                                  style: TextStyle(
                                    fontFamily: AppTypography.fontFamily,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    fontSize: resp.fontSize(11),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.black26,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                              Text(
                                transaction.formattedDate,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                                  fontSize: resp.fontSize(11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: resp.isExtraCompact ? 95 : (resp.isSmall ? 110 : 130),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              '${isGive ? '-' : '+'}${CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode)}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: color,
                                fontWeight: FontWeight.w900,
                                fontSize: resp.fontSize(resp.isSmall ? 14 : 15),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isGive ? 'total_to_give'.tr : 'total_to_get'.tr,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: resp.fontSize(10),
                              fontWeight: FontWeight.w600,
                              color: color.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
