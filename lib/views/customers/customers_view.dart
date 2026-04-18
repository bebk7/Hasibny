import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import '../customer_details/customer_details_view.dart';
import '../add_customer/add_customer_view.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();

    return Scaffold(
      // السماح لـ Flutter بالتعامل مع لوحة المفاتيح تلقائياً لتجنب الـ Overflow
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('nav_customers'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => Get.to(() => const AddCustomerView()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        // إغلاق الكيبورد عند الضغط على أي مكان فارغ في الشاشة
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (customerController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // حقل البحث
              Padding(
                padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 16),
                child: TextField(
                  onChanged: (value) =>
                      customerController.searchQuery.value = value,
                  decoration: InputDecoration(
                    hintText: 'search_customers'.tr,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                      filled: true,
                   fillColor: Theme.of(context).brightness == Brightness.dark
                   ? Colors.white.withValues(alpha: 0.05)
                   : AppTheme.primaryColor.withValues(alpha: 0.05),
                   contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                   focusedBorder: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide(
                   color: AppTheme.primaryColor.withValues(alpha: 0.3),
                   width: 1.5,),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                   hintStyle: TextStyle(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : Colors.grey,
    fontWeight: FontWeight.w500,
  ),
                  ),
                ),
              ),

              // قائمة العملاء
              Expanded(
                child: Obx(() {
                  final customers = customerController.filteredCustomers;

                  if (customers.isEmpty) return _buildEmptyState(context);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final balance =
                          customerController.getCustomerBalance(customer.id);
                      final isPositive = balance >= 0;
                      final color =
                          isPositive ? AppTheme.gotColor : AppTheme.giveColor;

                      return _buildCustomerItem(
                          context, customer, balance, color, isPositive);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCustomerItem(BuildContext context, dynamic customer,
      double balance, Color color, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: ListTile(
        onTap: () {
          FocusScope.of(context).unfocus();
          Get.to(() => CustomerDetailsView(customerId: customer.id),
              transition: Transition.cupertino);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Hero(
          tag: 'customer-${customer.id}',
          child: CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          customer.phoneNumber,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isPositive ? 'they_owe_you'.tr : 'you_owe_them'.tr,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Obx(() {
              Get.find<SettingsController>().currencySymbol;
              return Text(
                CurrencyFormatter.formatAbs(balance),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w900, fontSize: 16),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Icon(Icons.person_search_rounded,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'no_customers_found'.tr,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(() => const AddCustomerView()),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('add_first_customer'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
