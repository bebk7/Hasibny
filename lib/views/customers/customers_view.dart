import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/customer_controller.dart';
import '../../models/app_currency.dart';
import '../../models/customer.dart';
import '../../core/core.dart';
import '../customer_details/customer_details_view.dart';
import '../add_customer/add_customer_view.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        GuidedTourManager.instance.showIfFirstVisit(context, AppTours.buildCustomersTour());
      }
    });
  }

  @override
  void dispose() {
    GuidedTourManager.instance.cancelPendingTour(AppTours.customersTourId);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Get.find<CustomerController>();
    final resp = AppResponsive.of(context);
    final isDark = AppColors.isDark(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: AppAppBarTitle('nav_customers'.tr),
        actions: [
          GuidedTourTarget(
            step: AppTours.buildCustomersTour().steps[2],
            child: IconButton(
              tooltip: 'add_customer'.tr,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                ),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await Get.to(() => const AddCustomerView());
                customerController.loadCustomers();
              },
            ),
          ),
          SizedBox(width: resp.spacingSM),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() {
          if (customerController.isLoading.value) {
            return const AppLoading();
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: resp.maxContentWidth),
              child: Column(
                children: [
                  // Search & Currency Filter Target
                  GuidedTourTarget(
                    step: AppTours.buildCustomersTour().steps[0],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search input
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            resp.isSmall ? 12 : 16,
                            8,
                            resp.isSmall ? 12 : 16,
                            6,
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (value) =>
                                customerController.searchQuery.value = value,
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              fontSize: resp.fontSize(14),
                            ),
                            decoration: InputDecoration(
                              hintText: 'search_customers'.tr,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
                              ),
                              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _searchCtrl,
                                builder: (context, value, _) {
                                  if (value.text.isEmpty) return const SizedBox.shrink();
                                  return IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      customerController.searchQuery.value = '';
                                    },
                                  );
                                },
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: resp.isSmall ? 10 : 12,
                              ),
                            ),
                          ),
                        ),

                        // Currency filter bar
                        _buildCurrencyFilterBar(context, customerController, resp),
                      ],
                    ),
                  ),

                  // Customers List Target
                  Expanded(
                    child: GuidedTourTarget(
                      step: AppTours.buildCustomersTour().steps[1],
                      child: Obx(() {
                        // Explicitly track customerBalances so list updates reactively
                        final _ = customerController.customerBalances.values;
                        final customers = customerController.filteredCustomers;

                        if (customers.isEmpty) {
                          return _buildEmptyState(context, customerController);
                        }

                      return RefreshIndicator(
                        onRefresh: () async {
                          HapticFeedback.lightImpact();
                          await customerController.loadCustomers();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            resp.isSmall ? 12 : 16,
                            4,
                            resp.isSmall ? 12 : 16,
                            resp.isSmall ? 72 : 84,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return Obx(() {
                              final balance =
                                  customerController.getCustomerBalance(customer.id);
                              final isPositive = balance >= 0;
                              final color =
                                  isPositive ? AppColors.gotColor : AppColors.giveColor;

                              return _buildCustomerItem(
                                context,
                                customer,
                                balance,
                                color,
                                isPositive,
                                customerController,
                                resp,
                              );
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrencyFilterBar(
    BuildContext context,
    CustomerController controller,
    AppResponsive resp,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          AppFilterChip(
            label: 'all_currencies'.tr,
            isSelected: controller.selectedCurrencyFilter.value == 'all',
            onTap: () => controller.setCurrencyFilter('all'),
          ),
          SizedBox(width: resp.spacingSM),
          ...AppCurrency.supportedCurrencies.map((c) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: AppFilterChip(
                label: '${c.flag} ${c.code}',
                isSelected: controller.selectedCurrencyFilter.value == c.code,
                onTap: () => controller.setCurrencyFilter(c.code),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomerItem(
    BuildContext context,
    Customer customer,
    double balance,
    Color color,
    bool isPositive,
    CustomerController controller,
    AppResponsive resp,
  ) {
    final curr = AppCurrency.fromCode(customer.currencyCode);
    final isDark = AppColors.isDark(context);
    final avatarSize = resp.isExtraCompact ? 40.0 : (resp.isSmall ? 44.0 : 48.0);

    return Container(
      margin: EdgeInsets.only(bottom: resp.listSpacing),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.22 : 0.14),
          width: AppSizes.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus();
            HapticFeedback.lightImpact();
            await Get.to(
              () => CustomerDetailsView(customerId: customer.id),
              transition: Transition.cupertino,
            );
            controller.loadCustomerBalances();
          },
          borderRadius: BorderRadius.circular(resp.cardRadius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: resp.isExtraCompact ? 10 : 14,
              vertical: resp.isSmall ? 10 : 12,
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'customer-${customer.id}',
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: AppSizes.borderMedium,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontFamily: AppTypography.fontFamily,
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: resp.fontSize(resp.isExtraCompact ? 16 : 18),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: resp.spacingSM + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontWeight: FontWeight.w800,
                                fontSize: resp.fontSize(resp.isSmall ? 14 : 15),
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppBadge(
                            label: '${curr.flag} ${curr.code}',
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (customer.phoneNumber.isNotEmpty) ...[
                            Icon(
                              Icons.phone_rounded,
                              size: 12,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                PhoneNumberHelper.bidiSafe(customer.phoneNumber),
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  fontFamily: AppTypography.fontFamily,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontSize: resp.fontSize(11),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            Text(
                              'no_phone'.tr,
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                fontSize: resp.fontSize(11),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: resp.isExtraCompact ? 90 : (resp.isSmall ? 115 : 140),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          isPositive ? 'they_owe_you'.tr : 'you_owe_them'.tr,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          CurrencyFormatter.formatAbs(balance, currencyCode: customer.currencyCode),
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: resp.fontSize(resp.isSmall ? 14 : 15),
                            letterSpacing: -0.3,
                          ),
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
  }

  Widget _buildEmptyState(BuildContext context, CustomerController controller) {
    final hasSearch = controller.searchQuery.value.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: AppEmptyState(
        icon: hasSearch ? Icons.search_off_rounded : Icons.person_search_rounded,
        title: hasSearch ? 'no_results_found'.tr : 'no_customers_found'.tr,
        subtitle: hasSearch ? null : 'add_first_customer'.tr,
        actionLabel: hasSearch ? null : 'add_customer'.tr,
        actionIcon: Icons.person_add_alt_1_rounded,
        onAction: () async {
          await Get.to(() => const AddCustomerView());
          controller.loadCustomers();
        },
      ),
    );
  }
}
