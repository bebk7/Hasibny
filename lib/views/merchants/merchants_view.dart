import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller.dart';
import '../../core/core.dart';
import 'add_merchant_view.dart';
import 'merchant_invoices_view.dart';
import 'product_search_view.dart';

class MerchantsView extends StatefulWidget {
  const MerchantsView({super.key});

  @override
  State<MerchantsView> createState() => _MerchantsViewState();
}

class _MerchantsViewState extends State<MerchantsView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MerchantController>();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'merchants'.tr,
          style: AppTypography.pageTitle(context),
        ),
        actions: [
          IconButton(
            tooltip: 'product_search'.tr,
            icon: Container(
              padding: EdgeInsets.all(resp.spacingXS),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.manage_search_rounded,
                size: resp.iconSM,
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => const ProductSearchView());
            },
          ),
          SizedBox(width: resp.spacingXS),
        ],
      ),
      body: AppPageContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: resp.pagePadding,
                vertical: resp.spacingSM,
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => mc.searchQuery.value = v,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: resp.fontMD,
                ),
                decoration: InputDecoration(
                  hintText: 'search_merchants'.tr,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    size: resp.iconSM,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCtrl,
                    builder: (context, val, _) {
                      if (val.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(Icons.clear_rounded, size: resp.iconSM - 2),
                        onPressed: () {
                          _searchCtrl.clear();
                          mc.searchQuery.value = '';
                        },
                      );
                    },
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: resp.spacingMD,
                    vertical: resp.spacingSM,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (mc.isLoading.value) {
                  return const Center(child: AppLoading());
                }
                if (mc.filteredMerchants.isEmpty) {
                  final hasSearch = mc.searchQuery.value.isNotEmpty;
                  return Center(
                    child: AppEmptyState(
                      icon: hasSearch ? Icons.search_off_rounded : Icons.storefront_rounded,
                      title: hasSearch ? 'no_results_found'.tr : 'no_merchants'.tr,
                      subtitle: hasSearch ? null : 'add_first_merchant'.tr,
                      actionLabel: hasSearch ? null : 'add_merchant_title'.tr,
                      actionIcon: Icons.add_business_rounded,
                      onAction: () => Get.to(() => const AddMerchantView()),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    HapticFeedback.lightImpact();
                    await mc.loadMerchants();
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      resp.pagePadding,
                      resp.spacing2XS,
                      resp.pagePadding,
                      resp.pagePadding + resp.bottomInset,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: mc.filteredMerchants.length,
                    itemBuilder: (ctx, i) =>
                        _MerchantCard(merchant: mc.filteredMerchants[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_merchant_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          Get.to(() => const AddMerchantView());
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final dynamic merchant;
  const _MerchantCard({required this.merchant});

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final mc = Get.find<MerchantController>();
    final owed = mc.getMerchantOwed(merchant.id);
    final hasDebt = owed > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = hasDebt ? AppColors.give : AppColors.got;
    final avatarSize = resp.isSmall ? 40.0 : 44.0;

    return Container(
      margin: EdgeInsets.only(bottom: resp.spacingSM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.22 : 0.14),
          width: 1.2,
        ),
        boxShadow: AppShadows.subtle(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(resp.cardRadius),
          onTap: () {
            HapticFeedback.lightImpact();
            Get.to(
              () => MerchantInvoicesView(merchantId: merchant.id),
              transition: Transition.cupertino,
            );
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showOptions(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: resp.spacingSM + 2,
              vertical: resp.spacingSM,
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'merchant-${merchant.id}',
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.store_rounded,
                        color: statusColor,
                        size: resp.iconSM,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: resp.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        merchant.name,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w800,
                          fontSize: resp.fontMD,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (merchant.phone.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: resp.iconXS - 2,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                            SizedBox(width: resp.spacing2XS),
                            Flexible(
                              child: Text(
                                merchant.phone,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontSize: resp.fontXS,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (merchant.address.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: resp.iconXS - 2,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                            SizedBox(width: resp.spacing2XS),
                            Flexible(
                              child: Text(
                                merchant.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontSize: resp.fontXS - 1,
                                ),
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
                    maxWidth: resp.isTablet ? 150 : 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          CurrencyFormatter.format(owed),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w900,
                            fontSize: resp.fontMD,
                            color: statusColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: resp.spacingXS,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(resp.radiusXS),
                        ),
                        child: Text(
                          hasDebt ? 'remaining'.tr : 'settled_label'.tr,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: statusColor,
                            fontSize: resp.fontXS - 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: resp.spacing2XS),
                Icon(
                  resp.forwardIcon,
                  color: isDark ? AppColors.textMutedDark : Colors.grey[400],
                  size: resp.iconSM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final mc = Get.find<MerchantController>();

    AppBottomSheet.show(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(
              'edit_merchant'.tr,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            onTap: () {
              Get.back();
              Get.to(() => AddMerchantView(merchant: merchant));
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            ),
            title: Text(
              'delete_merchant'.tr,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Get.back();
              _confirmDelete(context, mc);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantController mc) {
    AppDialog.confirm(
      context: context,
      title: 'delete_merchant'.tr,
      message: 'delete_merchant_confirm'.tr,
      confirmLabel: 'delete'.tr,
      isDestructive: true,
      onConfirm: () => mc.deleteMerchant(merchant.id),
    );
  }
}
