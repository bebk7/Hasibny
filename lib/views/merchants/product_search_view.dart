import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/responsive.dart';

class ProductSearchView extends StatefulWidget {
  const ProductSearchView({super.key});

  @override
  State<ProductSearchView> createState() => _ProductSearchViewState();
}

class _ProductSearchViewState extends State<ProductSearchView> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
    });
    final res = await DatabaseService.searchProductAcrossInvoices(q);
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('product_search'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.isLarge(context) ? 32 : 16,
                vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'search_product_hint'.tr,
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('search'.tr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: Responsive.pagePadding(context),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _results.length,
                        itemBuilder: (ctx, i) =>
                            _ProductResultCard(result: _results[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    if (!_searched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded,
                size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('search_product_description'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('no_results_found'.tr,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ProductResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final date = result['invoiceDate'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    AppTheme.primaryColor.withValues(alpha: 0.08),
                child: const Icon(Icons.inventory_2_rounded,
                    size: 20, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result['itemName'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${result['quantity']} × ${CurrencyFormatter.format(result['unitPrice'])}',
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(result['unitPrice']),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.primaryColor),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(Icons.store_rounded,
                  size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(result['merchantName'],
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.receipt_outlined,
                  size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text('#${result['invoiceNumber']}',
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 11)),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(DateFormat('yyyy/MM/dd').format(date),
                  style: TextStyle(
                      color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
