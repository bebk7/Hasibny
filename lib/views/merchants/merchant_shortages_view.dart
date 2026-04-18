import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_shortage_controller.dart';
import '../../models/merchant_shortage.dart';
import '../../utils/responsive.dart';

class MerchantShortagesView extends StatelessWidget {
  /// When null, shows ALL shortages regardless of merchant.
  final int? merchantId;
  const MerchantShortagesView({super.key, this.merchantId});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<MerchantShortageController>();
    Future.microtask(() {
      if (merchantId != null) {
        sc.loadForMerchant(merchantId!);
      } else {
        sc.loadAll();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('shortages'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _SummaryHeader(),
          Expanded(
            child: Obx(() {
              if (sc.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (sc.shortages.isEmpty) {
                return _Empty();
              }
              return ListView.builder(
                padding: Responsive.pagePadding(context),
                physics: const BouncingScrollPhysics(),
                itemCount: sc.shortages.length,
                itemBuilder: (ctx, i) => _ShortageCard(shortage: sc.shortages[i]),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_shortage_fab',
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final productCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('add_shortage'.tr),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productCtrl,
                decoration: InputDecoration(
                  labelText: 'product_name'.tr,
                  hintText: 'enter_product_name'.tr,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'quantity'.tr,
                  hintText: 'quantity_optional'.tr,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'notes'.tr,
                  hintText: 'note_optional'.tr,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
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
              ); // merchantId may be null (general shortage)
              Get.back();
              Get.find<MerchantShortageController>().addShortage(shortage);
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sc = Get.find<MerchantShortageController>();
    return Obx(() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            _SumItem(label: 'total'.tr, value: '${sc.totalCount}'),
            _Divider(),
            _SumItem(label: 'pending'.tr, value: '${sc.pendingCount}'),
            _Divider(),
            _SumItem(label: 'resolved'.tr, value: '${sc.resolvedCount}'),
          ],
        ),
      );
    });
  }
}

class _SumItem extends StatelessWidget {
  final String label;
  final String value;
  const _SumItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(label,
                style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: Responsive.sp(context, 10))),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: Responsive.sp(context, 14))),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_shortages'.tr,
              style:
                  const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
    final resolved = shortage.isResolved;

    final subtitleParts = <String>[];
    if (shortage.quantity != null) {
      final q = shortage.quantity!;
      final qStr = q == q.truncateToDouble() ? q.toInt().toString() : q.toString();
      subtitleParts.add('${'quantity'.tr}: $qStr');
    }
    if (shortage.note != null && shortage.note!.isNotEmpty) {
      subtitleParts.add(shortage.note!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        color: Theme.of(context).cardColor,
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.cardRadius(context))),
          leading: Checkbox(
            value: resolved,
            onChanged: (_) => sc.toggleResolved(shortage),
          ),
          title: Text(
            shortage.productName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              decoration:
                  resolved ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
          subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => sc.deleteShortage(shortage.id),
          ),
        ),
      ),
    );
  }
}
