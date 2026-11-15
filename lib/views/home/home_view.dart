import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/core.dart';
import '../dashboard/dashboard_view.dart';
import '../customers/customers_view.dart';
import '../transactions/transactions_view.dart';
import '../settings/settings_view.dart';
import '../../widgets/custom_fab.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();

    return Scaffold(
      body: Obx(() {
        return IndexedStack(
          index: dashboardController.selectedIndex.value,
          children: const [
            DashboardView(),
            CustomersView(),
            TransactionsView(),
            SettingsView(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(context, dashboardController),
      floatingActionButton: const CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, DashboardController controller) {
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);
    final fabSpace = resp.isExtraCompact ? 44.0 : (resp.isSmall ? 52.0 : 60.0);
    final sidePadding = resp.isExtraCompact ? 4.0 : (resp.isSmall ? 8.0 : 12.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceColor : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: AppSizes.borderThin,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: resp.isSmall ? 6 : 8,
            padding: EdgeInsets.zero,
            child: SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: resp.isSmall ? 56 : 62,
                ),
                padding: EdgeInsetsDirectional.symmetric(horizontal: sidePadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildNavItem(
                              icon: Icons.dashboard_outlined,
                              activeIcon: Icons.dashboard_rounded,
                              label: 'nav_dashboard'.tr,
                              index: 0,
                              controller: controller,
                              resp: resp,
                              isDark: isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              icon: Icons.people_outline_rounded,
                              activeIcon: Icons.people_rounded,
                              label: 'nav_customers'.tr,
                              index: 1,
                              controller: controller,
                              resp: resp,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: fabSpace),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildNavItem(
                              icon: Icons.receipt_long_outlined,
                              activeIcon: Icons.receipt_long_rounded,
                              label: 'nav_transactions'.tr,
                              index: 2,
                              controller: controller,
                              resp: resp,
                              isDark: isDark,
                            ),
                          ),
                          Expanded(
                            child: _buildNavItem(
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings_rounded,
                              label: 'nav_settings'.tr,
                              index: 3,
                              controller: controller,
                              resp: resp,
                              isDark: isDark,
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
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required DashboardController controller,
    required AppResponsive resp,
    required bool isDark,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      final activeColor = isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor;
      final inactiveColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.selectedIndex.value = index;
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 12 : 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: resp.isSmall ? 20 : 22,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: resp.fontSize(resp.isSmall ? 10 : 11),
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
