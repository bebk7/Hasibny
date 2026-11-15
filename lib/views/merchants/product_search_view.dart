import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../services/database_service.dart';

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
    FocusScope.of(context).unfocus();
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
    final resp = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'product_search'.tr,
          style: AppTypography.pageTitle(context),
        ),
      ),
      body: AppPageContainer(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Search input bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: resp.pagePadding,
                vertical: resp.spacingSM,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onSubmitted: (_) => _search(),
                      textInputAction: TextInputAction.search,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontMD),
                      decoration: InputDecoration(
                        hintText: 'search_product_hint'.tr,
                        prefixIcon: Icon(Icons.search_rounded, size: resp.iconSM),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: resp.iconSM - 2),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _results.clear();
                                    _searched = false;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: resp.spacingSM),
                  SizedBox(
                    height: resp.buttonHeight,
                    child: AppButton(
                      text: 'search'.tr,
                      icon: Icons.search_rounded,
                      isLoading: _loading,
                      isFullWidth: false,
                      onPressed: _loading ? null : _search,
                    ),
                  ),
                ],
              ),
            ),

            // Results list or empty state
            Expanded(
              child: _loading
                  ? const Center(child: AppLoading())
                  : _results.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            resp.pagePadding,
                            resp.spacing2XS,
                            resp.pagePadding,
                            resp.pagePadding + resp.bottomInset,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _results.length,
                          itemBuilder: (ctx, i) =>
                              _ProductResultCard(result: _results[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    if (!_searched) {
      return AppEmptyState(
        icon: Icons.manage_search_rounded,
        title: 'product_search'.tr,
        subtitle: 'search_product_description'.tr,
      );
    }
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: 'no_results_found'.tr,
      subtitle: 'search_product_hint'.tr,
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ProductResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final date = result['invoiceDate'] as DateTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      margin: EdgeInsets.only(bottom: resp.spacingSM),
      padding: EdgeInsets.all(resp.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: resp.iconSM,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: resp.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['itemName'],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: resp.fontMD,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${result['quantity']} × ${CurrencyFormatter.format(result['unitPrice'])}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: resp.fontXS,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: resp.spacingSM),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    CurrencyFormatter.format(result['unitPrice']),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w900,
                      fontSize: resp.fontLG,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: resp.spacingSM),
          const Divider(height: 1),
          SizedBox(height: resp.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: resp.iconXS,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  SizedBox(width: resp.spacing2XS),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: (resp.screenWidth * 0.45).clamp(100.0, 220.0),
                    ),
                    child: Text(
                      result['merchantName'],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: resp.fontXS,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: resp.spacingXS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(resp.radiusXS),
                    ),
                    child: Text(
                      '#${result['invoiceNumber']}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: resp.fontXS - 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: resp.spacingSM),
                  Text(
                    DateFormat('yyyy/MM/dd').format(date),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: resp.fontXS - 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
