import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/app_currency.dart';
import '../../core/core.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/recent_transactions_widget.dart';
import '../../widgets/stats_card.dart';
import '../add_customer/add_customer_view.dart';
import '../merchants/merchants_view.dart';
import '../merchants/add_merchant_view.dart';
import '../merchants/merchant_shortages_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GuidedTourManager.instance.showIfFirstVisit(context, AppTours.buildDashboardTour());
      }
    });
  }

  @override
  void dispose() {
    GuidedTourManager.instance.cancelPendingTour(AppTours.dashboardTourId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dc = Get.find<DashboardController>();
    final cc = Get.find<CustomerController>();
    final sc = Get.isRegistered<SettingsController>() ? Get.find<SettingsController>() : null;
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: GuidedTourTarget(
          step: AppTours.buildDashboardTour().steps[0],
          child: Obx(() {
            final storeName = (sc?.storeName.value ?? '').trim();
            final titleText = storeName.isNotEmpty ? storeName : 'app_title'.tr;
            return AppAppBarTitle(titleText);
          }),
        ),
        actions: [
          IconButton(
            tooltip: 'refresh'.tr,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : AppColors.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 19,
                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              dc.refreshDashboard();
              cc.loadCustomers();
            },
          ),
          SizedBox(width: resp.spacingXS),
        ],
      ),
      body: Obx(() {
        if (dc.isLoading.value) {
          return const AppLoading();
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await dc.loadDashboardData();
            await cc.loadCustomers();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: resp.tabPadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: resp.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    AppSectionHeader(
                      title: 'quick_actions'.tr,
                      icon: Icons.bolt_rounded,
                    ),
                    SizedBox(height: resp.spacingSM),
                    GuidedTourTarget(
                      step: AppTours.buildDashboardTour().steps[1],
                      child: _buildQuickActions(context, dc, resp),
                    ),
                    SizedBox(height: resp.sectionSpacing),

                    // Multi-Currency Financial Overview Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppSectionHeader(
                            title: 'financial_overview'.tr,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        SizedBox(width: resp.spacingSM),
                        _buildCurrencyBadge(context, dc.selectedCurrency.value, resp),
                      ],
                    ),
                    SizedBox(height: resp.spacingSM),

                    // Currency Selector Tabs
                    GuidedTourTarget(
                      step: AppTours.buildDashboardTour().steps[2],
                      child: _buildCurrencyTabs(context, dc, resp),
                    ),
                    SizedBox(height: resp.spacingSM + 4),

                    // Active Currency Balance Cards
                    GuidedTourTarget(
                      step: AppTours.buildDashboardTour().steps[3],
                      child: Obx(() {
                        final curr = dc.selectedCurrency.value;
                        final toGive = dc.currentToGive;
                        final toGet = dc.currentToGet;
                        final net = dc.currentNetBalance;
                        final isLarge = resp.isLarge;
                        final spacing = resp.cardSpacing;

                        if (isLarge) {
                          return Row(
                            children: [
                              Expanded(
                                child: BalanceCard(
                                  title: 'total_to_give'.tr,
                                  amount: toGive,
                                  currencyCode: curr,
                                  color: AppColors.giveColor,
                                  icon: Icons.arrow_upward_rounded,
                                ),
                              ),
                              SizedBox(width: spacing),
                              Expanded(
                                child: BalanceCard(
                                  title: 'total_to_get'.tr,
                                  amount: toGet,
                                  currencyCode: curr,
                                  color: AppColors.gotColor,
                                  icon: Icons.arrow_downward_rounded,
                                ),
                              ),
                              SizedBox(width: spacing),
                              Expanded(
                                child: BalanceCard(
                                  title: 'net_balance'.tr,
                                  amount: net,
                                  currencyCode: curr,
                                  color: net >= 0 ? AppColors.gotColor : AppColors.giveColor,
                                  icon: net >= 0
                                      ? Icons.account_balance_wallet_rounded
                                      : Icons.account_balance_wallet_outlined,
                                  isNetBalance: true,
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: BalanceCard(
                                    title: 'total_to_give'.tr,
                                    amount: toGive,
                                    currencyCode: curr,
                                    color: AppColors.giveColor,
                                    icon: Icons.arrow_upward_rounded,
                                  ),
                                ),
                                SizedBox(width: spacing),
                                Expanded(
                                  child: BalanceCard(
                                    title: 'total_to_get'.tr,
                                    amount: toGet,
                                    currencyCode: curr,
                                    color: AppColors.gotColor,
                                    icon: Icons.arrow_downward_rounded,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: spacing),
                            BalanceCard(
                              title: 'net_balance'.tr,
                              amount: net,
                              currencyCode: curr,
                              color: net >= 0 ? AppColors.gotColor : AppColors.giveColor,
                              icon: net >= 0
                                  ? Icons.account_balance_wallet_rounded
                                  : Icons.account_balance_wallet_outlined,
                              isNetBalance: true,
                            ),
                          ],
                        );
                      }),
                    ),

                    SizedBox(height: resp.sectionSpacing),

                    // Multi-Currency Mini Overview (All Currencies Summary)
                    _buildAllCurrenciesSummary(context, dc, resp),

                    SizedBox(height: resp.sectionSpacing),

                    // Statistics Section
                    AppSectionHeader(
                      title: 'statistics'.tr,
                      icon: Icons.insights_rounded,
                    ),
                    SizedBox(height: resp.spacingSM),
                    _buildStatsGrid(context, dc, resp),

                    SizedBox(height: resp.sectionSpacing),

                    // Recent Transactions Section
                    AppSectionHeader(
                      title: 'recent_transactions'.tr,
                      icon: Icons.history_rounded,
                      actionText: 'all_transactions'.tr,
                      onTrailingTap: () {
                        dc.selectedIndex.value = 2; // Jump to transactions tab
                      },
                    ),
                    SizedBox(height: resp.spacingSM),
                    RecentTransactionsWidget(
                      transactions: dc.recentTransactions,
                    ),
                    SizedBox(height: resp.spacingLG),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrencyBadge(BuildContext context, String code, AppResponsive resp) {
    final curr = AppCurrency.fromCode(code);
    final isDark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(curr.flag, style: TextStyle(fontSize: resp.fontSize(13))),
          const SizedBox(width: 4),
          Text(
            curr.code,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: resp.fontSize(12),
              color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTabs(BuildContext context, DashboardController dc, AppResponsive resp) {
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: AppSizes.borderThin,
        ),
        boxShadow: AppShadows.subtle(isDark),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: AppCurrency.supportedCurrencies.map((curr) {
          return Obx(() {
            final isSelected = dc.selectedCurrency.value == curr.code;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  dc.setCurrency(curr.code);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(vertical: resp.isExtraCompact ? 7 : 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(curr.flag, style: TextStyle(fontSize: resp.isExtraCompact ? 12 : 14)),
                          const SizedBox(width: 5),
                          Text(
                            curr.code,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: resp.fontSize(resp.isExtraCompact ? 11 : 13),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildAllCurrenciesSummary(BuildContext context, DashboardController dc, AppResponsive resp) {
    final isDark = AppColors.isDark(context);

    return Container(
      padding: resp.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: AppSizes.borderThin,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'multi_currency_summary'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: resp.fontSize(14),
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM),
          const Divider(height: 1),
          const SizedBox(height: 6),
          ...AppCurrency.supportedCurrencies.map((curr) {
            final toGive = dc.currencyTotals[curr.code]?['toGive'] ?? 0.0;
            final toGet = dc.currencyTotals[curr.code]?['toGet'] ?? 0.0;
            final net = dc.currencyTotals[curr.code]?['net'] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Center(
                      child: Text(curr.flag, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curr.code,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: resp.fontSize(13),
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        curr.name.tr,
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          fontSize: resp.fontSize(10),
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            CurrencyFormatter.format(net, currencyCode: curr.code, showSign: true),
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w900,
                              fontSize: resp.fontSize(14),
                              color: net >= 0 ? AppColors.gotColor : AppColors.giveColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '${'total_to_give'.tr}: ${CurrencyFormatter.format(toGive, currencyCode: curr.code)}  •  ${'total_to_get'.tr}: ${CurrencyFormatter.format(toGet, currencyCode: curr.code)}',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontSize: resp.fontSize(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardController dc, AppResponsive resp) {
    final cards = [
      StatsCard(
        title: 'total_customers'.tr,
        value: dc.totalCustomers.value.toString(),
        icon: Icons.people_alt_rounded,
        color: AppColors.primaryColor,
      ),
      StatsCard(
        title: 'active_debtors'.tr,
        value: dc.activeDebtors.value.toString(),
        icon: Icons.trending_down_rounded,
        color: AppColors.giveColor,
      ),
      StatsCard(
        title: 'active_creditors'.tr,
        value: dc.activeCreditors.value.toString(),
        icon: Icons.trending_up_rounded,
        color: AppColors.gotColor,
      ),
      StatsCard(
        title: 'settled'.tr,
        value: (dc.totalCustomers.value -
                dc.activeDebtors.value -
                dc.activeCreditors.value)
            .clamp(0, 999999)
            .toString(),
        icon: Icons.verified_rounded,
        color: AppColors.successColor,
      ),
    ];

    if (resp.isLarge) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: resp.cardSpacing),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    final spacing = resp.cardSpacing;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: spacing),
            Expanded(child: cards[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: cards[2]),
            SizedBox(width: spacing),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardController dc, AppResponsive resp) {
    final actions = [
      _ActionButton(
        label: 'merchants'.tr,
        icon: Icons.store_rounded,
        color: const Color(0xFF7C3AED), // Purple Accent
        onTap: () => Get.to(() => const MerchantsView()),
      ),
      _ActionButton(
        label: 'add_merchant_title'.tr,
        icon: Icons.domain_add_rounded,
        color: const Color(0xFF0D9488), // Teal Accent
        onTap: () => Get.to(() => const AddMerchantView()),
      ),
      _ActionButton(
        label: 'shortages'.tr,
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFEA580C), // Orange Accent
        onTap: () => Get.to(() => const MerchantShortagesView()),
      ),
      _ActionButton(
        label: 'add_customer'.tr,
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.primaryColor,
        onTap: () => Get.to(() => const AddCustomerView())
            ?.then((_) => dc.refreshDashboard()),
      ),
    ];

    if (resp.isLarge) {
      return Row(
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: resp.cardSpacing),
            Expanded(child: actions[i]),
          ],
        ],
      );
    }

    final spacing = resp.cardSpacing;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: actions[0]),
            SizedBox(width: spacing),
            Expanded(child: actions[1]),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: actions[2]),
            SizedBox(width: spacing),
            Expanded(child: actions[3]),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          width: AppSizes.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(resp.cardRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: resp.isExtraCompact ? 12 : (resp.isSmall ? 14 : 16),
              horizontal: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: resp.isExtraCompact ? 36 : 42,
                  height: resp.isExtraCompact ? 36 : 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: AppSizes.borderThin,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: resp.isExtraCompact ? 18 : 22,
                      color: color,
                    ),
                  ),
                ),
                SizedBox(height: resp.isExtraCompact ? 6 : 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: resp.fontSize(resp.isExtraCompact ? 11 : (resp.isSmall ? 12 : 13)),
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
