import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/recent_transactions_widget.dart';
import '../../widgets/stats_card.dart';
import '../add_customer/add_customer_view.dart';
import '../merchants/merchants_view.dart';
import '../merchants/add_merchant_view.dart';
import '../merchants/merchant_shortages_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final customerController = Get.find<CustomerController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              dashboardController.refreshDashboard();
              customerController.loadCustomers();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (dashboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            dashboardController.refreshDashboard();
            customerController.loadCustomers();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const SizedBox(height: 24),
                _buildSectionTitle(context, 'quick_actions'.tr),
                const SizedBox(height: 16),
                _buildQuickActions(context, dashboardController),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'financial_overview'.tr),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: BalanceCard(
                        title: 'total_to_give'.tr,
                        amount: dashboardController.totalToGive.value,
                        color: AppTheme.giveColor,
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BalanceCard(
                        title: 'total_to_get'.tr,
                        amount: dashboardController.totalToGet.value,
                        color: AppTheme.gotColor,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                BalanceCard(
                  title: 'net_balance'.tr,
                  amount: dashboardController.netBalance,
                  color: dashboardController.netBalance >= 0
                      ? AppTheme.gotColor
                      : AppTheme.giveColor,
                  icon: dashboardController.netBalance >= 0
                      ? Icons.account_balance_wallet_rounded
                      : Icons.account_balance_wallet_outlined,
                  isNetBalance: true,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'statistics'.tr),
                const SizedBox(height: 12),
                _buildStatsGrid(dashboardController),
              
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(context, 'recent_transactions'.tr),
                  ],
                ),
                RecentTransactionsWidget(
                  transactions: dashboardController.recentTransactions,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildStatsGrid(DashboardController dc) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'total_customers'.tr,
                value: dc.totalCustomers.value.toString(),
                icon: Icons.people_alt_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'active_debtors'.tr,
                value: dc.activeDebtors.value.toString(),
                icon: Icons.trending_down_rounded,
                color: AppTheme.giveColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'active_creditors'.tr,
                value: dc.activeCreditors.value.toString(),
                icon: Icons.trending_up_rounded,
                color: AppTheme.gotColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'settled'.tr,
                value: (dc.totalCustomers.value -
                        dc.activeDebtors.value -
                        dc.activeCreditors.value)
                    .toString(),
                icon: Icons.verified_rounded,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, DashboardController dc) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'merchants'.tr,
                icon: Icons.store_rounded,
                color: const Color(0xFF7B1FA2),
                onTap: () => Get.to(() => const MerchantsView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'add_merchant_title'.tr,
                icon: Icons.person_add_alt_1_rounded,
                color: const Color(0xFF5D4037),
                onTap: () => Get.to(() => const AddMerchantView()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'shortages'.tr,
                icon: Icons.inventory_2_outlined,
                color: const Color(0xFF00695C),
                onTap: () => Get.to(() => const MerchantShortagesView()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'add_customer'.tr,
                icon: Icons.person_add_alt_1_rounded,
                color: AppTheme.primaryColor,
                onTap: () => Get.to(() => const AddCustomerView())
                    ?.then((_) => dc.refreshDashboard()),
              ),
            ),
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
    return Material(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  // تم تقليل الظل هنا بشكل كبير
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
