import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';
import 'add_merchant_view.dart';
import 'merchant_invoices_view.dart';
import 'product_search_view.dart';

class MerchantsView extends StatelessWidget {
  const MerchantsView({super.key});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MerchantController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('merchants'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search_rounded),
            tooltip: 'product_search'.tr,
            onPressed: () => Get.to(() => const ProductSearchView()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context, mc),
          Expanded(
            child: Obx(() {
              if (mc.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (mc.filteredMerchants.isEmpty) {
                return _buildEmpty(context);
              }
              return RefreshIndicator(
                onRefresh: mc.loadMerchants,
                child: ListView.builder(
                  padding: Responsive.pagePadding(context),
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  itemCount: mc.filteredMerchants.length,
                  itemBuilder: (ctx, i) =>
                      _MerchantCard(merchant: mc.filteredMerchants[i]),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_merchant_fab',
        onPressed: () => Get.to(() => const AddMerchantView()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, MerchantController mc) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.isLarge(context) ? 32 : 16, vertical: 8),
      child: TextField(
        onChanged: (v) => mc.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: 'search_merchants'.tr,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory_outlined,
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_merchants'.tr,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('add_first_merchant'.tr,
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final dynamic merchant;
  const _MerchantCard({required this.merchant});

  @override
  Widget build(BuildContext context) {
    final mc = Get.find<MerchantController>();
    final owed = mc.getMerchantOwed(merchant.id);
    final hasDebt = owed > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          onTap: () => Get.to(
            () => MerchantInvoicesView(merchantId: merchant.id),
            transition: Transition.rightToLeftWithFade,
          ),
          onLongPress: () => _showOptions(context),
          child: Padding(
            padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 16),
            child: Row(
              children: [
                Hero(
                  tag: 'merchant-${merchant.id}',
                  child: CircleAvatar(
                    radius: Responsive.avatarRadius(context) * 0.8,
                    backgroundColor: hasDebt
                        ? AppTheme.giveColor.withValues(alpha: 0.1)
                        : AppTheme.gotColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.store_rounded,
                      color: hasDebt ? AppTheme.giveColor : AppTheme.gotColor,
                      size: Responsive.iconSize(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(merchant.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.sp(context, 15))),
                      if (merchant.phone.isNotEmpty)
                        Text(merchant.phone,
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: Responsive.sp(context, 12))),
                      if (merchant.address.isNotEmpty)
                        Text(merchant.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: Responsive.sp(context, 11))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(owed),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: Responsive.sp(context, 15),
                        color: hasDebt ? AppTheme.giveColor : AppTheme.gotColor,
                      ),
                    ),
                    Text(
                      hasDebt ? 'remaining'.tr : 'settled_label'.tr,
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: Responsive.sp(context, 10)),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    color: Colors.grey[400],
                    size: Responsive.iconSize(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final mc = Get.find<MerchantController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
              title: Text('edit_merchant'.tr),
              onTap: () {
                Get.back();
                Get.to(() => AddMerchantView(merchant: merchant));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: Text('delete_merchant'.tr,
                  style: const TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Get.back();
                _confirmDelete(context, mc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MerchantController mc) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_merchant'.tr),
        content: Text('delete_merchant_confirm'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              mc.deleteMerchant(merchant.id);
              Get.back();
            },
            child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
