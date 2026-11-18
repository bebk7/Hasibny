import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/core.dart';

enum ReportFormat { pdf, excel, other }

class ReportPreviewView extends StatefulWidget {
  final String title;
  final String fileName;
  final ReportFormat format;
  final Future<Uint8List> Function() documentLoader;

  const ReportPreviewView({
    super.key,
    required this.title,
    required this.fileName,
    required this.format,
    required this.documentLoader,
  });

  @override
  State<ReportPreviewView> createState() => _ReportPreviewViewState();
}

class _ReportPreviewViewState extends State<ReportPreviewView>
    with SingleTickerProviderStateMixin {
  Uint8List? _loadedBytes;
  bool _isLoading = true;
  String? _errorMessage;
  File? _tempFile;

  // Excel state
  Excel? _excel;
  List<String> _sheetNames = [];
  TabController? _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadReport();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController?.dispose();
    _cleanupTempFile();
    super.dispose();
  }

  Future<void> _cleanupTempFile() async {
    try {
      if (_tempFile != null && await _tempFile!.exists()) {
        await _tempFile!.delete();
      }
    } catch (_) {}
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await widget.documentLoader();
      if (!mounted) return;

      if (widget.format == ReportFormat.excel) {
        final decoded = Excel.decodeBytes(bytes);
        final sheets = decoded.tables.keys.toList();
        _tabController?.dispose();
        _tabController = TabController(length: sheets.length, vsync: this);
        setState(() {
          _loadedBytes = bytes;
          _excel = decoded;
          _sheetNames = sheets;
          _isLoading = false;
        });
      } else {
        setState(() {
          _loadedBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      debugPrint('Report preview load error: $e\n$stack');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _shareReport() async {
    if (_loadedBytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.fileName}');
      await file.writeAsBytes(_loadedBytes!);
      _tempFile = file;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = AppResponsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: AppAppBarTitle(widget.title),
        actions: [
          if (!_isLoading && _loadedBytes != null && widget.format != ReportFormat.pdf)
            IconButton(
              icon: Icon(Icons.share_rounded, size: resp.iconSM),
              tooltip: 'share'.tr,
              onPressed: _shareReport,
            ),
        ],
        bottom: widget.format == ReportFormat.excel &&
                !_isLoading &&
                _sheetNames.length > 1 &&
                _tabController != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: _sheetNames.map((s) => Tab(text: s)).toList(),
              )
            : null,
      ),
      body: SafeArea(
        child: _buildBody(context, isDark, resp),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark, AppResponsive resp) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(),
            SizedBox(height: resp.spacingMD),
            Text(
              'preparing_report'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontMD,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(resp.spacingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'error_generating_report'.tr,
                subtitle: _errorMessage!,
              ),
              SizedBox(height: resp.spacingMD),
              AppButton(
                text: 'refresh'.tr,
                icon: Icons.refresh_rounded,
                onPressed: _loadReport,
              ),
            ],
          ),
        ),
      );
    }

    if (_loadedBytes == null || _loadedBytes!.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.description_outlined,
          title: 'no_data'.tr,
        ),
      );
    }

    switch (widget.format) {
      case ReportFormat.pdf:
        return _buildPdfPreview(context, isDark);
      case ReportFormat.excel:
        return _buildExcelPreview(context, isDark, resp);
      case ReportFormat.other:
        return _buildFallbackPreview(context, isDark, resp);
    }
  }

  Widget _buildPdfPreview(BuildContext context, bool isDark) {
    return PdfPreview(
      build: (format) async => _loadedBytes!,
      canChangePageFormat: false,
      canChangeOrientation: false,
      canDebug: false,
      allowPrinting: true,
      allowSharing: true,
      pdfFileName: widget.fileName,
      scrollViewDecoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFE5E9F0),
      ),
      loadingWidget: Center(
        child: Text(
          'preparing_report'.tr,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      onError: (context, error) => Center(
        child: AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'error_generating_report'.tr,
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Widget _buildExcelPreview(BuildContext context, bool isDark, AppResponsive resp) {
    if (_excel == null || _sheetNames.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.table_chart_outlined,
          title: 'no_data'.tr,
        ),
      );
    }

    if (_sheetNames.length == 1) {
      return _buildSheetTable(_sheetNames.first, isDark, resp);
    }

    return TabBarView(
      controller: _tabController,
      children: _sheetNames.map((s) => _buildSheetTable(s, isDark, resp)).toList(),
    );
  }

  Widget _buildSheetTable(String sheetName, bool isDark, AppResponsive resp) {
    final sheet = _excel!.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.table_rows_outlined,
          title: 'no_data_in_sheet'.tr,
        ),
      );
    }

    // Extract headers and data rows
    final rawHeaderRow = sheet.rows.first;
    final headers = rawHeaderRow
        .map((cell) => cell?.value?.toString() ?? '')
        .toList();

    var dataRows = sheet.rows.skip(1).toList();

    // Filter by search query if any
    if (_searchQuery.isNotEmpty) {
      dataRows = dataRows.where((row) {
        return row.any((cell) {
          final str = cell?.value?.toString().toLowerCase() ?? '';
          return str.contains(_searchQuery);
        });
      }).toList();
    }

    return Column(
      children: [
        // Search & stats bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: resp.spacingSM + 2,
            vertical: resp.spacingSM,
          ),
          color: isDark ? AppColors.darkCard : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: resp.fontSM),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    prefixIcon: Icon(Icons.search_rounded, size: resp.iconSM),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: resp.spacingSM),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(resp.radiusSM),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, size: resp.iconSM - 4),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: resp.spacingSM),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: resp.spacingSM,
                  vertical: resp.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(resp.radiusSM),
                ),
                child: Text(
                  '${'rows_count'.tr}: ${dataRows.length}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontXS,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scrollable Table (vertical and horizontal)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: resp.screenWidth,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.1),
                  ),
                  headingTextStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: resp.fontSM,
                    color: AppColors.primary,
                  ),
                  dataTextStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: resp.fontXS,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  columns: headers
                      .map((h) => DataColumn(
                            label: Text(h.isEmpty ? '-' : h),
                          ))
                      .toList(),
                  rows: List.generate(dataRows.length, (rowIndex) {
                    final row = dataRows[rowIndex];
                    final isEven = rowIndex % 2 == 0;
                    return DataRow(
                      color: WidgetStateProperty.all(
                        isEven
                            ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01))
                            : Colors.transparent,
                      ),
                      cells: List.generate(headers.length, (colIndex) {
                        final cellValue = colIndex < row.length
                            ? (row[colIndex]?.value?.toString() ?? '')
                            : '';
                        return DataCell(Text(cellValue));
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackPreview(BuildContext context, bool isDark, AppResponsive resp) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(resp.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(resp.spacingLG),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_present_rounded,
                size: resp.iconLG + 24,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: resp.spacingLG),
            Text(
              'unsupported_format_title'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontLG,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: resp.spacingSM),
            Text(
              'unsupported_format_desc'.tr,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: resp.fontSM,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: resp.spacingSM),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: resp.spacingSM + 2,
                vertical: resp.spacingSM,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(resp.radiusSM),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Text(
                widget.fileName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: resp.fontXS,
                ),
              ),
            ),
            SizedBox(height: resp.spacingLG),
            AppButton(
              text: 'export_file'.tr,
              icon: Icons.open_in_new_rounded,
              onPressed: _shareReport,
            ),
          ],
        ),
      ),
    );
  }
}
