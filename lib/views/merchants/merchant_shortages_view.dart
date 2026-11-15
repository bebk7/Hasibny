import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_shortage_controller.dart';
import '../../core/core.dart';
import '../../models/merchant_shortage.dart';

class MerchantShortagesView extends StatelessWidget {
  /// When null, shows ALL shortages regardless of merchant.
  final int? merchantId;
  const MerchantShortagesView({super.key, this.merchantId});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<MerchantShortageController>();
    final resp = AppResponsive.of(context);

    Future.microtask(() {
      if (merchantId != null) {
        sc.loadForMerchant(merchantId!);
      } else {
        sc.loadAll();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'shortages'.tr,
          style: AppTypography.pageTitle(context),
        ),
      ),
      body: AppPageContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _SummaryHeader(),
            Expanded(
              child: Obx(() {
                if (sc.isLoading.value) {
                  return const Center(child: AppLoading());
                }
                if (sc.shortages.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      icon: Icons.inventory_2_rounded,
                      title: 'no_shortages'.tr,
                      actionLabel: 'add_shortage'.tr,
                      actionIcon: Icons.add_rounded,
                      onAction: () => _showAddDialog(context),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    resp.pagePadding,
                    resp.spacing2XS,
                    resp.pagePadding,
                    resp.pagePadding + resp.bottomInset,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: sc.shortages.length,
                  itemBuilder: (ctx, i) => _ShortageCard(shortage: sc.shortages[i]),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_shortage_fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          _showAddDialog(context);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final productCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppBottomSheet.show(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'add_shortage'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontLG,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: resp.spacingMD),
            TextField(
              controller: productCtrl,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
              decoration: InputDecoration(
                labelText: 'product_name'.tr,
                hintText: 'enter_product_name'.tr,
                prefixIcon: Icon(Icons.inventory_2_rounded, size: resp.iconSM),
              ),
            ),
            SizedBox(height: resp.spacingSM),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: const [
                DigitsOnlyInputFormatter(),
              ],
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
              decoration: InputDecoration(
                labelText: 'quantity'.tr,
                hintText: 'quantity_optional'.tr,
                prefixIcon: Icon(Icons.numbers_rounded, size: resp.iconSM),
              ),
            ),
            SizedBox(height: resp.spacingSM),
            TextField(
              controller: noteCtrl,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: resp.fontMD),
              decoration: InputDecoration(
                labelText: 'notes'.tr,
                hintText: 'note_optional'.tr,
                prefixIcon: Icon(Icons.notes_rounded, size: resp.iconSM),
              ),
            ),
            SizedBox(height: resp.spacingLG),
            AppButton(
              text: 'add'.tr,
              icon: Icons.add_rounded,
              onPressed: () {
                final name = productCtrl.text.trim();
                if (name.isEmpty) return;

                final qtyStr = qtyCtrl.text.trim();
                final qty = qtyStr.isEmpty
                    ? null
                    : double.tryParse(qtyStr.replaceAll(',', ''));

                final note = noteCtrl.text.trim().isEmpty
                    ? null
                    : noteCtrl.text.trim();

                final shortage = MerchantShortage(
                  merchantId: merchantId,
                  productName: name,
                  quantity: qty,
                  note: note,
                );
                Get.back();
                Get.find<MerchantShortageController>().addShortage(shortage);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sc = Get.find<MerchantShortageController>();
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: resp.pagePadding,
          vertical: resp.spacingXS,
        ),
        padding: EdgeInsets.all(resp.spacingSM + 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(resp.cardRadius),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: AppShadows.subtle(isDark),
        ),
        child: Row(
          children: [
            _SumItem(
              label: 'total'.tr,
              value: '${sc.totalCount}',
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            _divider(isDark, resp),
            _SumItem(
              label: 'pending'.tr,
              value: '${sc.pendingCount}',
              color: AppColors.warning,
            ),
            _divider(isDark, resp),
            _SumItem(
              label: 'resolved'.tr,
              value: '${sc.resolvedCount}',
              color: AppColors.success,
            ),
          ],
        ),
      );
    });
  }

  Widget _divider(bool isDark, AppResponsive resp) => Container(
        width: 1,
        height: 32,
        margin: EdgeInsets.symmetric(horizontal: resp.spacing2XS),
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      );
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SumItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: resp.fontXS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: resp.fontLG,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortageCard extends StatelessWidget {
  final MerchantShortage shortage;
  const _ShortageCard({required this.shortage});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<MerchantShortageController>();
    final resp = AppResponsive.of(context);
    final resolved = shortage.isResolved;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtitleParts = <String>[];
    if (shortage.quantity != null) {
      final q = shortage.quantity!;
      final qStr = q == q.truncateToDouble() ? q.toInt().toString() : q.toString();
      subtitleParts.add('${'quantity'.tr}: $qStr');
    }
    if (shortage.note != null && shortage.note!.isNotEmpty) {
      subtitleParts.add(shortage.note!);
    }

    return Container(
      margin: EdgeInsets.only(bottom: resp.spacingSM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(resp.cardRadius),
        border: Border.all(
          color: resolved
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : AppColors.warning.withValues(alpha: isDark ? 0.28 : 0.18),
          width: 1.2,
        ),
        boxShadow: AppShadows.subtle(isDark),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: resp.spacingSM,
          vertical: resp.spacingXS,
        ),
        child: Row(
          children: [
            Checkbox(
              value: resolved,
              activeColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(resp.radiusXS)),
              onChanged: (_) {
                HapticFeedback.selectionClick();
                sc.toggleResolved(shortage);
              },
            ),
            SizedBox(width: resp.spacingXS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortage.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: resp.fontMD,
                      color: resolved
                          ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      decoration: resolved ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitleParts.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: resp.fontXS,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? Colors.redAccent : AppColors.error,
                size: resp.iconSM,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                sc.deleteShortage(shortage.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
