import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams, XFile;
import 'package:excel/excel.dart';
import '../controllers/settings_controller.dart';
import '../models/customer.dart';
import '../models/transaction.dart';

class ExportService {
  static pw.Font? _font;
  static pw.Font? _boldFont;

  // ───────────── Design tokens ─────────────
  static const _primary = PdfColor.fromInt(0xFF1565C0);
  static const _primaryDark = PdfColor.fromInt(0xFF0D47A1);
  static const _accent = PdfColor.fromInt(0xFF00897B);
  static const _danger = PdfColor.fromInt(0xFFD32F2F);
  static const _surface = PdfColor.fromInt(0xFFF8F9FA);
  static const _border = PdfColor.fromInt(0xFFE0E0E0);
  static const _textDark = PdfColor.fromInt(0xFF212121);
  static const _textMuted = PdfColor.fromInt(0xFF757575);
  static const _radius = pw.BorderRadius.all(pw.Radius.circular(12));
  static const _radiusSm = pw.BorderRadius.all(pw.Radius.circular(8));

  // ───────────── Fonts ─────────────
  static Future<pw.Font> _getFont() async {
    _font ??=
        pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
    return _font!;
  }

  static Future<pw.Font> _getBoldFont() async {
    _boldFont ??=
        pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    return _boldFont!;
  }

  // ───────────── Utilities ─────────────

  static String _formatDate(DateTime dt) =>
      DateFormat('yyyy/MM/dd  HH:mm').format(dt);

  static String _fmtAmt(double amount) {
    String v;
    if (amount == amount.truncateToDouble()) {
      v = amount.toInt().toString();
    } else {
      final s = amount.toStringAsFixed(2);
      if (s.endsWith('00')) {
        v = amount.toInt().toString();
      } else if (s.endsWith('0')) {
        v = s.substring(0, s.length - 1);
      } else {
        v = s;
      }
    }
    // thousand separators
    final parts = v.split('.');
    final intPart = parts[0];
    final isNeg = intPart.startsWith('-');
    final digits = isNeg ? intPart.substring(1) : intPart;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final formatted = (isNeg ? '-' : '') + buf.toString();
    return parts.length > 1 ? '$formatted.${parts[1]}' : formatted;
  }

  static String _currencyLabel(bool isAr) =>
      isAr ? 'ريال يمني' : 'YER';

  static Future<void> _saveAndShare(pw.Document pdf, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  // ───────────── Shared PDF Widgets ─────────────

  static pw.Widget _buildHeader({
    required String title,
    required String subtitle,
    required pw.Font boldFont,
    required pw.Font font,
    String storeName = '',
    String storePhone = '',
    String storeAddress = '',
    String storeEmail = '',
    String storeTaxNumber = '',
    pw.MemoryImage? logoImage,
  }) {
    final hasStore = storeName.isNotEmpty;
    final storeInitial = hasStore ? storeName.trim()[0].toUpperCase() : 'H';
    final hasLogo = logoImage != null;

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      margin: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (hasStore) ...
                  [
                    pw.Text(storeName,
                        style: pw.TextStyle(
                            font: boldFont, fontSize: 18, color: _primaryDark)),
                    pw.SizedBox(height: 2),
                    if (storePhone.isNotEmpty)
                      pw.Text(storePhone,
                          style: pw.TextStyle(
                              font: font, fontSize: 9, color: _textMuted)),
                    if (storeAddress.isNotEmpty)
                      pw.Text(storeAddress,
                          style: pw.TextStyle(
                              font: font, fontSize: 9, color: _textMuted)),
                    if (storeEmail.isNotEmpty)
                      pw.Text(storeEmail,
                          style: pw.TextStyle(
                              font: font, fontSize: 9, color: _textMuted)),
                    if (storeTaxNumber.isNotEmpty)
                      pw.Text(storeTaxNumber,
                          style: pw.TextStyle(
                              font: font, fontSize: 9, color: _textMuted)),
                    pw.SizedBox(height: 8),
                  ],
                pw.Text(title,
                    style: pw.TextStyle(
                        font: boldFont, fontSize: hasStore ? 14 : 22, color: _primaryDark)),
                pw.SizedBox(height: 2),
                pw.Text(subtitle,
                    style: pw.TextStyle(
                        font: font, fontSize: 10, color: _textMuted)),
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          hasLogo
              ? pw.Container(
                  height: 56,
                  width: 56,
                  decoration: pw.BoxDecoration(
                    borderRadius: _radiusSm,
                    border: pw.Border.all(color: _border),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(logoImage, fit: pw.BoxFit.cover),
                  ),
                )
              : pw.Container(
                  height: 44,
                  width: 44,
                  decoration: const pw.BoxDecoration(
                      color: _primaryDark, borderRadius: _radiusSm),
                  child: pw.Center(
                    child: pw.Text(storeInitial,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            font: boldFont)),
                  ),
                ),
        ],
      ),
    );
  }

  static Future<pw.MemoryImage?> _loadStoreLogo(String? path) async {
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final bytes = await file.readAsBytes();
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildFooter(
      pw.Context ctx, pw.Font font, bool isAr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Hasibny App',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: _textMuted)),
          pw.Text(
              isAr
                  ? 'صفحة ${ctx.pageNumber} من ${ctx.pagesCount}'
                  : 'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: _textMuted)),
        ],
      ),
    );
  }

  static pw.Widget _infoCard({
    required String label,
    required String value,
    required pw.Font font,
    required pw.Font boldFont,
    PdfColor valueColor = _textDark,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: _surface,
          borderRadius: _radiusSm,
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    font: font, fontSize: 9, color: _textMuted)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    font: boldFont, fontSize: 15, color: valueColor)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _sectionTitle(String text, pw.Font boldFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10, top: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: _radiusSm,
      ),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: boldFont, fontSize: 12, color: PdfColors.white)),
    );
  }

  static pw.Widget _totalBar({
    required String label,
    required String value,
    required pw.Font font,
    required pw.Font boldFont,
    PdfColor color = _primaryDark,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: _radiusSm,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 12, color: PdfColors.white)),
          pw.Text(value,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 14, color: PdfColors.white)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Customer Statement (Multi-Page) ──────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> exportCustomerToPDF({
    required Customer customer,
    required List<TransactionModel> transactions,
    required double balance,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final font = await _getFont();
    final boldFont = await _getBoldFont();
    final logoImage = await _loadStoreLogo(sc.storeLogoPath.value);
    final pdf = pw.Document();
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final cur = _currencyLabel(isAr);

    final customerTx = transactions
        .where((t) => t.customerId == customer.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    double totalGive = 0, totalGot = 0;
    for (final t in customerTx) {
      if (t.type == TransactionType.give) {
        totalGive += t.amount;
      } else {
        totalGot += t.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: isAr ? 'كشف حساب عميل' : 'Customer Statement',
          subtitle: _formatDate(DateTime.now()),
          boldFont: boldFont,
          font: font,
          storeName: sc.storeName.value,
          storePhone: sc.storePhone.value,
          storeAddress: sc.storeAddress.value,
          storeEmail: sc.storeEmail.value,
          storeTaxNumber: sc.storeTaxNumber.value,
          logoImage: logoImage,
        ),
        footer: (ctx) => _buildFooter(ctx, font, isAr),
        build: (ctx) => [
          // Customer info cards row
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'اسم العميل' : 'Customer',
              value: customer.name,
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'رقم الهاتف' : 'Phone',
              value: customer.phoneNumber,
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'الرصيد الحالي' : 'Balance',
              value: '${_fmtAmt(balance)} $cur',
              font: font,
              boldFont: boldFont,
              valueColor: balance >= 0 ? _accent : _danger,
            ),
          ]),
          pw.SizedBox(height: 20),

          // Summary row
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'إجمالي الدفع (عليه)' : 'Total Give',
              value: '${_fmtAmt(totalGive)} $cur',
              font: font,
              boldFont: boldFont,
              valueColor: _danger,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'إجمالي الاستلام (له)' : 'Total Got',
              value: '${_fmtAmt(totalGot)} $cur',
              font: font,
              boldFont: boldFont,
              valueColor: _accent,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'عدد العمليات' : 'Transactions',
              value: '${customerTx.length}',
              font: font,
              boldFont: boldFont,
            ),
          ]),
          pw.SizedBox(height: 20),

          _sectionTitle(
              isAr ? 'سجل العمليات' : 'Transaction Log', boldFont),
          pw.SizedBox(height: 4),

          // Transactions table
          pw.TableHelper.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(
                font: boldFont, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
                color: _primaryDark,
                borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(8),
                  topRight: pw.Radius.circular(8),
                )),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom:
                        pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'التاريخ', 'الوصف', 'النوع', 'المبلغ']
                : ['#', 'Date', 'Description', 'Type', 'Amount'],
            data: List.generate(customerTx.length, (i) {
              final t = customerTx[i];
              final isGive = t.type == TransactionType.give;
              return [
                '${i + 1}',
                _formatDate(t.createdAt),
                t.description.isEmpty ? '-' : t.description,
                isGive
                    ? (isAr ? 'دفع' : 'Give')
                    : (isAr ? 'استلام' : 'Got'),
                '${_fmtAmt(t.amount)} $cur',
              ];
            }),
          ),

          // Total bar
          _totalBar(
            label: isAr ? 'صافي الرصيد' : 'Net Balance',
            value: '${_fmtAmt(balance)} $cur',
            font: font,
            boldFont: boldFont,
            color: balance >= 0 ? _accent : _danger,
          ),
        ],
      ),
    );
    await _saveAndShare(pdf, 'statement_${customer.name}.pdf');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Single Transaction Receipt (Multi-Page) ──────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> shareTransactionAsPDF({
    required TransactionModel transaction,
    required Customer customer,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final font = await _getFont();
    final boldFont = await _getBoldFont();
    final logoImage = await _loadStoreLogo(sc.storeLogoPath.value);
    final pdf = pw.Document();
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final cur = _currencyLabel(isAr);
    final isGive = transaction.type == TransactionType.give;
    final typeColor = isGive ? _danger : _accent;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: isAr ? 'إيصال معاملة' : 'Transaction Receipt',
          subtitle: '#${transaction.id}  •  ${_formatDate(transaction.createdAt)}',
          boldFont: boldFont,
          font: font,
          storeName: sc.storeName.value,
          storePhone: sc.storePhone.value,
          storeAddress: sc.storeAddress.value,
          storeEmail: sc.storeEmail.value,
          storeTaxNumber: sc.storeTaxNumber.value,
          logoImage: logoImage,
        ),
        footer: (ctx) => _buildFooter(ctx, font, isAr),
        build: (ctx) => [
          pw.SizedBox(height: 10),

          // Big amount card
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 28),
            decoration: pw.BoxDecoration(
              color: _surface,
              borderRadius: _radius,
              border: pw.Border.all(color: typeColor, width: 1.5),
            ),
            child: pw.Column(
              children: [
                pw.Text(isAr ? 'المبلغ' : 'Amount',
                    style: pw.TextStyle(
                        font: font, fontSize: 11, color: _textMuted)),
                pw.SizedBox(height: 6),
                pw.Text('${_fmtAmt(transaction.amount)} $cur',
                    style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 34,
                        color: typeColor)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Details table
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: pw.BoxDecoration(
              color: _surface,
              borderRadius: _radius,
              border: pw.Border.all(color: _border),
            ),
            child: pw.Column(
              children: [
                _detailRow(
                    isAr ? 'العميل' : 'Customer',
                    customer.name,
                    font,
                    boldFont),
                _divider(),
                _detailRow(
                    isAr ? 'الهاتف' : 'Phone',
                    customer.phoneNumber,
                    font,
                    boldFont),
                _divider(),
                _detailRow(
                    isAr ? 'نوع العملية' : 'Type',
                    isGive
                        ? (isAr ? 'دفع (عليه)' : 'Give')
                        : (isAr ? 'استلام (له)' : 'Got'),
                    font,
                    boldFont,
                    valueColor: typeColor),
                _divider(),
                _detailRow(
                    isAr ? 'التاريخ' : 'Date',
                    _formatDate(transaction.createdAt),
                    font,
                    boldFont),
                if (transaction.description.isNotEmpty) ...[
                  _divider(),
                  _detailRow(
                      isAr ? 'الوصف' : 'Description',
                      transaction.description,
                      font,
                      boldFont),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    await _saveAndShare(pdf, 'receipt_${transaction.id}.pdf');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Full Report (Multi-Page) ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> exportAllToPDF({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final font = await _getFont();
    final boldFont = await _getBoldFont();
    final logoImage = await _loadStoreLogo(sc.storeLogoPath.value);
    final pdf = pw.Document();
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final cur = _currencyLabel(isAr);

    double totalGive = 0, totalGot = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.give) {
        totalGive += t.amount;
      } else {
        totalGot += t.amount;
      }
    }
    final netBalance = totalGot - totalGive;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: isAr ? 'التقرير الشامل' : 'Full Report',
          subtitle: _formatDate(DateTime.now()),
          boldFont: boldFont,
          font: font,
          storeName: sc.storeName.value,
          storePhone: sc.storePhone.value,
          storeAddress: sc.storeAddress.value,
          storeEmail: sc.storeEmail.value,
          storeTaxNumber: sc.storeTaxNumber.value,
          logoImage: logoImage,
        ),
        footer: (ctx) => _buildFooter(ctx, font, isAr),
        build: (ctx) => [
          // Summary cards
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'عدد العملاء' : 'Customers',
              value: '${customers.length}',
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 10),
            _infoCard(
              label: isAr ? 'عدد العمليات' : 'Transactions',
              value: '${transactions.length}',
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 10),
            _infoCard(
              label: isAr ? 'إجمالي الدفع' : 'Total Give',
              value: '${_fmtAmt(totalGive)} $cur',
              font: font,
              boldFont: boldFont,
              valueColor: _danger,
            ),
            pw.SizedBox(width: 10),
            _infoCard(
              label: isAr ? 'إجمالي الاستلام' : 'Total Got',
              value: '${_fmtAmt(totalGot)} $cur',
              font: font,
              boldFont: boldFont,
              valueColor: _accent,
            ),
          ]),
          pw.SizedBox(height: 20),

          // Customers section
          _sectionTitle(
              isAr ? 'العملاء والأرصدة' : 'Customers & Balances',
              boldFont),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(
                font: boldFont, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
                color: _primaryDark,
                borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(8),
                  topRight: pw.Radius.circular(8),
                )),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom:
                        pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'العميل', 'الهاتف', 'الرصيد']
                : ['#', 'Customer', 'Phone', 'Balance'],
            data: List.generate(customers.length, (i) {
              final c = customers[i];
              final bal = balances[c.id] ?? 0;
              return [
                '${i + 1}',
                c.name,
                c.phoneNumber,
                '${_fmtAmt(bal)} $cur',
              ];
            }),
          ),
          pw.SizedBox(height: 24),

          // Transactions section
          _sectionTitle(
              isAr ? 'سجل جميع العمليات' : 'All Transactions',
              boldFont),
          pw.SizedBox(height: 4),
          pw.TableHelper.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(
                font: boldFont, color: PdfColors.white, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
                color: _primaryDark,
                borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(8),
                  topRight: pw.Radius.circular(8),
                )),
            cellStyle: pw.TextStyle(font: font, fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom:
                        pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'التاريخ', 'العميل', 'الوصف', 'النوع', 'المبلغ']
                : ['#', 'Date', 'Customer', 'Desc', 'Type', 'Amount'],
            data: List.generate(transactions.length, (i) {
              final t = transactions[i];
              final cust = customers
                  .firstWhereOrNull((c) => c.id == t.customerId);
              return [
                '${i + 1}',
                _formatDate(t.createdAt),
                cust?.name ?? '-',
                t.description.isEmpty ? '-' : t.description,
                t.type == TransactionType.give
                    ? (isAr ? 'دفع' : 'Give')
                    : (isAr ? 'استلام' : 'Got'),
                '${_fmtAmt(t.amount)} $cur',
              ];
            }),
          ),

          // Net total
          _totalBar(
            label: isAr ? 'صافي الإجمالي' : 'Net Total',
            value: '${_fmtAmt(netBalance)} $cur',
            font: font,
            boldFont: boldFont,
            color: netBalance >= 0 ? _accent : _danger,
          ),
        ],
      ),
    );
    await _saveAndShare(pdf, 'full_report.pdf');
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Excel Export ─────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> exportAllToExcel({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final excel = Excel.createExcel();

    final custSheet = excel['Customers'];
    custSheet.appendRow([
      TextCellValue(isAr ? 'الاسم' : 'Name'),
      TextCellValue(isAr ? 'الهاتف' : 'Phone'),
      TextCellValue(isAr ? 'الرصيد' : 'Balance'),
    ]);
    for (final c in customers) {
      custSheet.appendRow([
        TextCellValue(c.name),
        TextCellValue(c.phoneNumber),
        DoubleCellValue(balances[c.id] ?? 0),
      ]);
    }

    final txSheet = excel['Transactions'];
    txSheet.appendRow([
      TextCellValue(isAr ? 'التاريخ' : 'Date'),
      TextCellValue(isAr ? 'العميل' : 'Customer'),
      TextCellValue(isAr ? 'الوصف' : 'Description'),
      TextCellValue(isAr ? 'النوع' : 'Type'),
      TextCellValue(isAr ? 'المبلغ' : 'Amount'),
    ]);
    for (final t in transactions) {
      final cust =
          customers.firstWhereOrNull((c) => c.id == t.customerId);
      txSheet.appendRow([
        TextCellValue(_formatDate(t.createdAt)),
        TextCellValue(cust?.name ?? '-'),
        TextCellValue(t.description),
        TextCellValue(t.type == TransactionType.give
            ? (isAr ? 'دفع' : 'Give')
            : (isAr ? 'استلام' : 'Got')),
        DoubleCellValue(t.amount),
      ]);
    }

    excel.delete('Sheet1');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/account_book_export.xlsx');
    await file.writeAsBytes(excel.encode()!);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Helper Widgets ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static pw.Widget _detailRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont, {
    PdfColor valueColor = _textDark,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: font, fontSize: 11, color: _textMuted)),
          pw.Text(value,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 11, color: valueColor)),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Divider(color: _border, thickness: 0.5);
  }
}