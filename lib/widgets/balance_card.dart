import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/core.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String currencyCode;
  final bool isNetBalance;
  final VoidCallback? onTap;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.currencyCode = 'YER',
    this.isNetBalance = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final cardPadding = resp.isExtraCompact
        ? resp.spacingSM
        : (resp.isSmall ? resp.spacingSM + 2 : resp.spacingMD);
    final radius = resp.cardRadius * 1.25;

    final isProfit = amount >= 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.18),
          width: AppSizes.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.1 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: isDark ? 0.12 : 0.08),
                    color.withValues(alpha: isDark ? 0.03 : 0.01),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(resp.isExtraCompact ? 6 : 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.2 : 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withValues(alpha: 0.3),
                            width: AppSizes.borderThin,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: resp.isExtraCompact ? 16 : (resp.isSmall ? 18 : 20),
                        ),
                      ),
                      const Spacer(),
                      if (isNetBalance)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: AppSizes.borderThin,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isProfit
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 13,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isProfit ? 'profit'.tr : 'loss'.tr,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  color: color,
                                  fontSize: resp.isExtraCompact ? 10 : 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: resp.isExtraCompact ? 8 : 12),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: resp.fontSize(resp.isExtraCompact ? 11 : (resp.isSmall ? 12 : 13)),
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      CurrencyFormatter.format(
                        amount,
                        currencyCode: currencyCode,
                        showSign: isNetBalance,
                      ),
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: resp.fontSize(
                          resp.isExtraCompact ? 16 : (resp.isSmall ? 19 : 23),
                          min: 14,
                          max: 26,
                        ),
                        letterSpacing: -0.5,
                      ),
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
