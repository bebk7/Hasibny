import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../models/transaction.dart';
import '../core/core.dart';
import '../views/add_transaction/add_transaction_view.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final size = resp.fabSize;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: AppShadows.primaryGlow(0.35),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showQuickTransactionModal(context);
          },
          customBorder: const CircleBorder(),
          splashColor: Colors.white24,
          highlightColor: Colors.white12,
          child: Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: resp.isSmall ? 28 : 32,
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickTransactionModal(BuildContext context) {
    final resp = AppResponsive.of(context);

    AppBottomSheet.show(
      context: context,
      title: 'add_transaction'.tr,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            // Give Card
            Expanded(
              child: _TransactionTypeCard(
                title: 'give_debit'.tr,
                subtitle: 'money_gave'.tr,
                icon: Icons.arrow_upward_rounded,
                color: AppColors.giveColor,
                gradient: AppColors.giveGradient,
                onTap: () async {
                  Get.back();
                  await Get.to(
                    () => const AddTransactionView(
                      initialType: TransactionType.give,
                    ),
                    transition: Transition.downToUp,
                  );
                  if (Get.isRegistered<CustomerController>()) {
                    Get.find<CustomerController>().loadCustomerBalances();
                  }
                },
              ),
            ),
            SizedBox(width: resp.isSmall ? 10 : 14),
            // Got Card
            Expanded(
              child: _TransactionTypeCard(
                title: 'got_credit'.tr,
                subtitle: 'money_received'.tr,
                icon: Icons.arrow_downward_rounded,
                color: AppColors.gotColor,
                gradient: AppColors.gotGradient,
                onTap: () async {
                  Get.back();
                  await Get.to(
                    () => const AddTransactionView(
                      initialType: TransactionType.got,
                    ),
                    transition: Transition.downToUp,
                  );
                  if (Get.isRegistered<CustomerController>()) {
                    Get.find<CustomerController>().loadCustomerBalances();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  const _TransactionTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: resp.isSmall ? 16 : 20,
              horizontal: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: resp.isSmall ? 48 : 54,
                  height: resp.isSmall ? 48 : 54,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: resp.isSmall ? 24 : 28,
                    ),
                  ),
                ),
                SizedBox(height: resp.isSmall ? 10 : 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(resp.isSmall ? 14 : 15),
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: resp.fontSize(resp.isSmall ? 11 : 12),
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
