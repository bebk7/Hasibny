import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../themes/app_theme.dart';
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
      bottomNavigationBar: _buildBottomNavigationBar(dashboardController),
      floatingActionButton: const CustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(DashboardController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fabSpace = screenWidth * 0.12;
        final hPadding = screenWidth * 0.04;

        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: hPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildNavItem(
                            icon: Icons.dashboard_outlined,
                            activeIcon: Icons.dashboard,
                            label: 'nav_dashboard'.tr,
                            index: 0,
                            controller: controller,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            icon: Icons.people_outline,
                            activeIcon: Icons.people,
                            label: 'nav_customers'.tr,
                            index: 1,
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: fabSpace),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: hPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildNavItem(
                            icon: Icons.receipt_long_outlined,
                            activeIcon: Icons.receipt_long,
                            label: 'nav_transactions'.tr,
                            index: 2,
                            controller: controller,
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            icon: Icons.settings_outlined,
                            activeIcon: Icons.settings,
                            label: 'nav_settings'.tr,
                            index: 3,
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
  }) {
    return GestureDetector(
      onTap: () => controller.selectedIndex.value = index,
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
