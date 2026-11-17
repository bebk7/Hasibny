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
import '../models/app_currency.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/merchant.dart';
import '../models/transaction.dart';
import '../views/reports/report_preview_view.dart';

class ExportService {
  static pw.Font? _font;
  static pw.Font? _boldFont;

  // ───────────── Design tokens ─────────────
  static const _primary = PdfColor.fromInt(0xFF1565C0);
  static const _primaryDark = PdfColor.fromInt(0xFF0D47A1);
  static const _accent = PdfColor.fromInt(0xFF00897B);
  static const _danger = PdfColor.fromInt(0xFFD32F2F);
  static const _warning = PdfColor.fromInt(0xFFF57C00);
  static const _surface = PdfColor.fromInt(0xFFF8F9FA);
  static const _border = PdfColor.fromInt(0xFFE0E0E0);
  static const _textDark = PdfColor.fromInt(0xFF212121);
  static const _textMuted = PdfColor.fromInt(0xFF757575);
  static const _radiusSm = pw.BorderRadius.all(pw.Radius.circular(8));
  static const _radius = pw.BorderRadius.all(pw.Radius.circular(12));

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

  static String formatPdfAmount(double amount,
      {String? currencyCode, bool isAr = true}) {
    final absAmount = amount.abs();
    final defaultCode = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().currentCurrency.value
        : 'YER';
    final code = (currencyCode != null && currencyCode.trim().isNotEmpty)
        ? currencyCode
        : defaultCode;
    final curr = AppCurrency.fromCode(code);
    final dec = curr.decimalDigits;

    String v;
    if (dec == 0 || absAmount == absAmount.truncateToDouble()) {
      v = absAmount.toInt().toString();
    } else {
      final s = absAmount.toStringAsFixed(dec);
      if (s.endsWith('00')) {
        v = absAmount.toInt().toString();
      } else if (s.endsWith('0')) {
        v = s.substring(0, s.length - 1);
      } else {
        v = s;
      }
    }

    // thousand separators
    final parts = v.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final formattedNum = parts.length > 1 ? '$buf.${parts[1]}' : buf.toString();
    final sign = amount < 0 ? '- ' : '';

    final symbol = curr.getSymbol(isArabic: isAr);
    if (curr.code == 'USD') {
      return isAr ? '$sign$formattedNum \$' : '$sign\$$formattedNum';
    }
    return '$sign$formattedNum $symbol';
  }

  static String _fmtAmt(double amount,
          {String? currencyCode, bool isAr = true}) =>
      formatPdfAmount(amount, currencyCode: currencyCode, isAr: isAr);

  static Future<void> _saveAndShareBytes(
      Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
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
        border: pw.Border(bottom: pw.BorderSide(color: _primary, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (hasStore) ...[
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
                    pw.Text(
                        '${Get.locale?.languageCode == 'ar' ? 'الرقم الضريبي:' : 'Tax No:'} $storeTaxNumber',
                        style: pw.TextStyle(
                            font: font, fontSize: 9, color: _textMuted)),
                  pw.SizedBox(height: 8),
                ],
                pw.Text(title,
                    style: pw.TextStyle(
                        font: boldFont,
                        fontSize: hasStore ? 14 : 22,
                        color: _primaryDark)),
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

  static pw.Widget _buildFooter(pw.Context ctx, pw.Font font, bool isAr) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(' حاسبني •  Hasibny ',
              style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
          pw.Text(
              isAr
                  ? 'صفحة ${ctx.pageNumber} من ${ctx.pagesCount}'
                  : 'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 8, color: _textMuted)),
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
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _surface,
          borderRadius: _radiusSm,
          border: pw.Border.all(color: _border),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style:
                    pw.TextStyle(font: font, fontSize: 9, color: _textMuted)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    font: boldFont, fontSize: 13, color: valueColor)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _sectionTitle(String text, pw.Font boldFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10, top: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const pw.BoxDecoration(
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
  // ─── Official Invoice PDF (Multi-Page) ────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════
  // ─── Official Invoice PDF (Multi-Page) ────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateInvoicePdfBytes({
    required Invoice invoice,
    Customer? customer,
    Merchant? merchant,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final font = await _getFont();
    final boldFont = await _getBoldFont();
    final logoImage = await _loadStoreLogo(sc.storeLogoPath.value);
    final pdf = pw.Document();
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final paid = invoice.isFullyPaid;
    final statusColor =
        paid ? _accent : (invoice.paidAmount > 0 ? _warning : _danger);
    final statusText = paid
        ? (isAr ? 'مدفوعة بالكامل' : 'Fully Paid')
        : (invoice.paidAmount > 0
            ? (isAr ? 'مدفوعة جزئياً' : 'Partially Paid')
            : (isAr ? 'غير مدفوعة' : 'Unpaid'));

    final recipientName = customer?.name ?? merchant?.name ?? '-';
    final recipientLabel = customer != null
        ? (isAr ? 'العميل' : 'Customer')
        : (isAr ? 'المورد / التاجر' : 'Merchant');

    final invoiceTitle = customer != null
        ? (isAr ? 'فاتورة مبيعات' : 'Sales Invoice')
        : (isAr ? 'فاتورة توريد بضاعة' : 'Supply Invoice');

    final currCode =
        invoice.currencyCode.isNotEmpty ? invoice.currencyCode : 'YER';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: invoiceTitle,
          subtitle:
              '#${invoice.invoiceNumber}  •  ${_formatDate(invoice.date)}',
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
          // Invoice Info Cards Row
          pw.Row(children: [
            _infoCard(
              label: recipientLabel,
              value: recipientName,
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'رقم الفاتورة' : 'Invoice No',
              value: '#${invoice.invoiceNumber}',
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'حالة السداد' : 'Payment Status',
              value: statusText,
              font: font,
              boldFont: boldFont,
              valueColor: statusColor,
            ),
          ]),
          pw.SizedBox(height: 16),

          // Items Table
          _sectionTitle(
              isAr ? 'بنود وأصناف الفاتورة' : 'Invoice Items', boldFont),
          pw.SizedBox(height: 4),

          if (invoice.items.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: _radiusSm,
                border: pw.Border.all(color: _border),
              ),
              child: pw.Text(
                isAr ? 'لا توجد أصناف مسجلة' : 'No items recorded',
                style:
                    pw.TextStyle(font: font, fontSize: 10, color: _textMuted),
              ),
            )
          else
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
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: _border, width: 0.5))),
              cellAlignment: pw.Alignment.center,
              headers: isAr
                  ? ['#', 'اسم الصنف', 'الكمية', 'سعر الوحدة', 'الإجمالي']
                  : ['#', 'Item Name', 'Qty', 'Unit Price', 'Total'],
              data: List.generate(invoice.items.length, (i) {
                final itm = invoice.items[i];
                return [
                  '${i + 1}',
                  itm.name,
                  '${itm.quantity}',
                  _fmtAmt(itm.unitPrice, currencyCode: currCode, isAr: isAr),
                  _fmtAmt(itm.total, currencyCode: currCode, isAr: isAr),
                ];
              }),
            ),

          pw.SizedBox(height: 16),

          // Financial Summary Cards
          pw.Row(
            children: [
              _infoCard(
                label: isAr ? 'المبلغ الإجمالي' : 'Total Amount',
                value: _fmtAmt(invoice.totalAmount,
                    currencyCode: currCode, isAr: isAr),
                font: font,
                boldFont: boldFont,
                valueColor: _primaryDark,
              ),
              pw.SizedBox(width: 12),
              _infoCard(
                label: isAr ? 'المبلغ المدفوع' : 'Paid Amount',
                value: _fmtAmt(invoice.paidAmount,
                    currencyCode: currCode, isAr: isAr),
                font: font,
                boldFont: boldFont,
                valueColor: _accent,
              ),
              pw.SizedBox(width: 12),
              _infoCard(
                label: isAr ? 'المتبقي للسداد' : 'Remaining Balance',
                value: _fmtAmt(invoice.remainingAmount,
                    currencyCode: currCode, isAr: isAr),
                font: font,
                boldFont: boldFont,
                valueColor: invoice.remainingAmount > 0 ? _danger : _accent,
              ),
            ],
          ),

          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: _radiusSm,
                border: pw.Border.all(color: _border),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(isAr ? 'ملاحظات وشروط الفاتورة:' : 'Notes & Terms:',
                      style: pw.TextStyle(
                          font: boldFont, fontSize: 10, color: _primaryDark)),
                  pw.SizedBox(height: 4),
                  pw.Text(invoice.notes!,
                      style: pw.TextStyle(font: font, fontSize: 9)),
                ],
              ),
            ),
          ],

          pw.SizedBox(height: 32),

          // Signatures Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(isAr ? 'توقيع المستلم' : 'Receiver Signature',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.SizedBox(height: 36),
                  pw.Container(width: 140, height: 1, color: _border),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                      isAr
                          ? 'الختم والتوقيع المعتمد'
                          : 'Authorized Stamp & Signature',
                      style: pw.TextStyle(font: boldFont, fontSize: 10)),
                  pw.SizedBox(height: 36),
                  pw.Container(width: 140, height: 1, color: _border),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return await pdf.save();
  }

  static Future<void> exportInvoiceToPDF({
    required Invoice invoice,
    Customer? customer,
    Merchant? merchant,
  }) async {
    final bytes = await generateInvoicePdfBytes(
      invoice: invoice,
      customer: customer,
      merchant: merchant,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  static void previewInvoice({
    required Invoice invoice,
    Customer? customer,
    Merchant? merchant,
  }) {
    final title =
        '${Get.locale?.languageCode == 'ar' ? 'معاينة الفاتورة' : 'Invoice Preview'} #${invoice.invoiceNumber}';
    Get.to(() => ReportPreviewView(
          title: title,
          fileName: 'invoice_${invoice.invoiceNumber}.pdf',
          format: ReportFormat.pdf,
          documentLoader: () => generateInvoicePdfBytes(
            invoice: invoice,
            customer: customer,
            merchant: merchant,
          ),
        ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Merchant Statement PDF (Multi-Page) ──────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<void> exportMerchantInvoicesToPDF({
    required Merchant merchant,
    required List<Invoice> invoices,
  }) =>
      exportMerchantToPDF(merchant: merchant, invoices: invoices);

  static Future<Uint8List> generateMerchantPdfBytes({
    required Merchant merchant,
    required List<Invoice> invoices,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    final font = await _getFont();
    final boldFont = await _getBoldFont();
    final logoImage = await _loadStoreLogo(sc.storeLogoPath.value);
    final pdf = pw.Document();
    final textDir = isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    double totalAmount = 0, totalPaid = 0;
    for (final inv in invoices) {
      totalAmount += inv.totalAmount;
      totalPaid += inv.paidAmount;
    }
    final totalRemaining = totalAmount - totalPaid;
    final defaultCurr = invoices.isNotEmpty
        ? invoices.first.currencyCode
        : (Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>().currentCurrency.value
            : 'YER');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: isAr ? 'كشف حساب مورد' : 'Supplier Statement',
          subtitle: '${merchant.name}  •  ${_formatDate(DateTime.now())}',
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
          // Supplier Info Row
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'اسم المورد' : 'Supplier',
              value: merchant.name,
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'الهاتف' : 'Phone',
              value: merchant.phone.isNotEmpty ? merchant.phone : '-',
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'المتبقي للمورد' : 'Remaining Due',
              value: _fmtAmt(totalRemaining,
                  currencyCode: defaultCurr, isAr: isAr),
              font: font,
              boldFont: boldFont,
              valueColor: totalRemaining > 0 ? _danger : _accent,
            ),
          ]),
          pw.SizedBox(height: 16),

          // Summary Cards
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'إجمالي الفواتير' : 'Total Invoiced',
              value:
                  _fmtAmt(totalAmount, currencyCode: defaultCurr, isAr: isAr),
              font: font,
              boldFont: boldFont,
              valueColor: _primaryDark,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'إجمالي المدفوع' : 'Total Paid',
              value: _fmtAmt(totalPaid, currencyCode: defaultCurr, isAr: isAr),
              font: font,
              boldFont: boldFont,
              valueColor: _accent,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'عدد الفواتير' : 'Invoices Count',
              value: '${invoices.length}',
              font: font,
              boldFont: boldFont,
            ),
          ]),
          pw.SizedBox(height: 20),

          // Invoices Table
          _sectionTitle(
              isAr ? 'سجل فواتير التوريد' : 'Supply Invoices Log', boldFont),
          pw.SizedBox(height: 4),

          if (invoices.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: _surface,
                borderRadius: _radiusSm,
                border: pw.Border.all(color: _border),
              ),
              child: pw.Text(
                isAr
                    ? 'لا توجد فواتير مسجلة لهذا المورد'
                    : 'No invoices for this supplier',
                style:
                    pw.TextStyle(font: font, fontSize: 10, color: _textMuted),
              ),
            )
          else
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
                      bottom: pw.BorderSide(color: _border, width: 0.5))),
              cellAlignment: pw.Alignment.center,
              headers: isAr
                  ? [
                      '#',
                      'رقم الفاتورة',
                      'التاريخ',
                      'الأصناف',
                      'الإجمالي',
                      'المدفوع',
                      'المتبقي',
                      'الحالة'
                    ]
                  : [
                      '#',
                      'Inv No',
                      'Date',
                      'Items',
                      'Total',
                      'Paid',
                      'Remaining',
                      'Status'
                    ],
              data: List.generate(invoices.length, (i) {
                final inv = invoices[i];
                final paid = inv.isFullyPaid;
                final invCurr = inv.currencyCode.isNotEmpty
                    ? inv.currencyCode
                    : defaultCurr;
                return [
                  '${i + 1}',
                  '#${inv.invoiceNumber}',
                  DateFormat('yyyy/MM/dd').format(inv.date),
                  '${inv.items.length}',
                  formatPdfAmount(inv.totalAmount,
                      currencyCode: invCurr, isAr: isAr),
                  formatPdfAmount(inv.paidAmount,
                      currencyCode: invCurr, isAr: isAr),
                  formatPdfAmount(inv.remainingAmount,
                      currencyCode: invCurr, isAr: isAr),
                  paid ? (isAr ? 'مدفوعة' : 'Paid') : (isAr ? 'متبقي' : 'Due'),
                ];
              }),
            ),

          _totalBar(
            label: isAr ? 'إجمالي المتبقي للمورد' : 'Total Remaining Balance',
            value: formatPdfAmount(totalRemaining,
                currencyCode: defaultCurr, isAr: isAr),
            font: font,
            boldFont: boldFont,
            color: totalRemaining > 0 ? _danger : _accent,
          ),
        ],
      ),
    );
    return await pdf.save();
  }

  static Future<void> exportMerchantToPDF({
    required Merchant merchant,
    required List<Invoice> invoices,
  }) async {
    final bytes =
        await generateMerchantPdfBytes(merchant: merchant, invoices: invoices);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/supplier_statement_${merchant.name}.pdf');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  static void previewMerchantReport({
    required Merchant merchant,
    required List<Invoice> invoices,
  }) {
    final title =
        '${Get.locale?.languageCode == 'ar' ? 'كشف حساب مورد' : 'Supplier Statement'}: ${merchant.name}';
    Get.to(() => ReportPreviewView(
          title: title,
          fileName: 'supplier_statement_${merchant.name}.pdf',
          format: ReportFormat.pdf,
          documentLoader: () =>
              generateMerchantPdfBytes(merchant: merchant, invoices: invoices),
        ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Customer Statement (Multi-Page) ──────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateCustomerPdfBytes({
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
    final curr = AppCurrency.fromCode(customer.currencyCode);

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
          subtitle:
              '${curr.getName(isArabic: isAr)} (${curr.code})  •  ${_formatDate(DateTime.now())}',
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
              label: isAr ? 'العملة' : 'Currency',
              value: '${curr.getName(isArabic: isAr)} (${curr.code})',
              font: font,
              boldFont: boldFont,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'الرصيد الحالي' : 'Balance',
              value: _fmtAmt(balance,
                  currencyCode: customer.currencyCode, isAr: isAr),
              font: font,
              boldFont: boldFont,
              valueColor: balance >= 0 ? _accent : _danger,
            ),
          ]),
          pw.SizedBox(height: 16),

          // Summary row
          pw.Row(children: [
            _infoCard(
              label: isAr ? 'إجمالي الدفع (عليه)' : 'Total Give',
              value: _fmtAmt(totalGive,
                  currencyCode: customer.currencyCode, isAr: isAr),
              font: font,
              boldFont: boldFont,
              valueColor: _danger,
            ),
            pw.SizedBox(width: 12),
            _infoCard(
              label: isAr ? 'إجمالي الاستلام (له)' : 'Total Got',
              value: _fmtAmt(totalGot,
                  currencyCode: customer.currencyCode, isAr: isAr),
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

          _sectionTitle(isAr ? 'سجل العمليات' : 'Transaction Log', boldFont),
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
                    bottom: pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'التاريخ والوقت', 'الوصف', 'النوع', 'المبلغ']
                : ['#', 'Date & Time', 'Description', 'Type', 'Amount'],
            data: List.generate(customerTx.length, (i) {
              final t = customerTx[i];
              final isGive = t.type == TransactionType.give;
              return [
                '${i + 1}',
                _formatDate(t.createdAt),
                t.description.isEmpty ? '-' : t.description,
                isGive ? (isAr ? 'دفع' : 'Give') : (isAr ? 'استلام' : 'Got'),
                _fmtAmt(t.amount,
                    currencyCode: customer.currencyCode, isAr: isAr),
              ];
            }),
          ),

          // Total bar
          _totalBar(
            label: isAr ? 'صافي الرصيد' : 'Net Balance',
            value: _fmtAmt(balance,
                currencyCode: customer.currencyCode, isAr: isAr),
            font: font,
            boldFont: boldFont,
            color: balance >= 0 ? _accent : _danger,
          ),
        ],
      ),
    );
    return await pdf.save();
  }

  static Future<void> exportCustomerToPDF({
    required Customer customer,
    required List<TransactionModel> transactions,
    required double balance,
  }) async {
    final bytes = await generateCustomerPdfBytes(
      customer: customer,
      transactions: transactions,
      balance: balance,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/statement_${customer.name}.pdf');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  static void previewCustomerReport({
    required Customer customer,
    required List<TransactionModel> transactions,
    required double balance,
  }) {
    final title =
        '${Get.locale?.languageCode == 'ar' ? 'كشف حساب عميل' : 'Customer Statement'}: ${customer.name}';
    Get.to(() => ReportPreviewView(
          title: title,
          fileName: 'statement_${customer.name}.pdf',
          format: ReportFormat.pdf,
          documentLoader: () => generateCustomerPdfBytes(
            customer: customer,
            transactions: transactions,
            balance: balance,
          ),
        ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Single Transaction Receipt (Multi-Page) ──────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateTransactionPdfBytes({
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
          subtitle:
              '#${transaction.id}  •  ${_formatDate(transaction.createdAt)}',
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
                pw.Text(
                    _fmtAmt(transaction.amount,
                        currencyCode: transaction.currencyCode, isAr: isAr),
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 32, color: typeColor)),
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
                _detailRow(isAr ? 'العميل' : 'Customer', customer.name, font,
                    boldFont),
                _divider(),
                _detailRow(isAr ? 'الهاتف' : 'Phone', customer.phoneNumber,
                    font, boldFont),
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
                    isAr ? 'العملة' : 'Currency',
                    AppCurrency.fromCode(transaction.currencyCode)
                        .getName(isArabic: isAr),
                    font,
                    boldFont),
                _divider(),
                _detailRow(isAr ? 'تاريخ ووقت الإدخال' : 'Entry Date & Time',
                    _formatDate(transaction.createdAt), font, boldFont),
                if (transaction.description.isNotEmpty) ...[
                  _divider(),
                  _detailRow(isAr ? 'الوصف / البيان' : 'Description',
                      transaction.description, font, boldFont),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    return await pdf.save();
  }

  static Future<void> shareTransactionAsPDF({
    required TransactionModel transaction,
    required Customer customer,
  }) async {
    final bytes = await generateTransactionPdfBytes(
      transaction: transaction,
      customer: customer,
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${transaction.id}.pdf');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  static void previewTransactionReceipt({
    required TransactionModel transaction,
    required Customer customer,
  }) {
    final title =
        '${Get.locale?.languageCode == 'ar' ? 'إيصال معاملة' : 'Transaction Receipt'} #${transaction.id}';
    Get.to(() => ReportPreviewView(
          title: title,
          fileName: 'receipt_${transaction.id}.pdf',
          format: ReportFormat.pdf,
          documentLoader: () => generateTransactionPdfBytes(
            transaction: transaction,
            customer: customer,
          ),
        ));
  }

  /// Alias for previewTransactionReceipt
  static void previewTransaction({
    required TransactionModel transaction,
    required Customer customer,
  }) =>
      previewTransactionReceipt(transaction: transaction, customer: customer);

  // ═══════════════════════════════════════════════════════════════════
  // ─── Full Report (Multi-Page) ─────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateAllReportPdfBytes({
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

    // Calculate totals per currency
    final Map<String, double> giveByCurr = {};
    final Map<String, double> gotByCurr = {};
    for (final t in transactions) {
      final code = t.currencyCode.isNotEmpty ? t.currencyCode : 'YER';
      if (t.type == TransactionType.give) {
        giveByCurr[code] = (giveByCurr[code] ?? 0) + t.amount;
      } else {
        gotByCurr[code] = (gotByCurr[code] ?? 0) + t.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        textDirection: textDir,
        header: (ctx) => _buildHeader(
          title: isAr ? 'التقرير المالي الشامل' : 'Full Financial Report',
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
          // Currency Breakdown Section
          _sectionTitle(isAr ? 'ملخص العملات' : 'Currency Breakdown', boldFont),
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
                    bottom: pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? [
                    'العملة',
                    'إجمالي الدفع (لك)',
                    'إجمالي الاستلام (عليك)',
                    'صافي الرصيد'
                  ]
                : ['Currency', 'Total Give', 'Total Got', 'Net Balance'],
            data: AppCurrency.supportedCurrencies.map((c) {
              final give = giveByCurr[c.code] ?? 0;
              final got = gotByCurr[c.code] ?? 0;
              final net = got - give;
              return [
                '${c.getName(isArabic: isAr)} (${c.code})',
                _fmtAmt(give, currencyCode: c.code, isAr: isAr),
                _fmtAmt(got, currencyCode: c.code, isAr: isAr),
                _fmtAmt(net, currencyCode: c.code, isAr: isAr),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // Customers section
          _sectionTitle(
              isAr ? 'العملاء والأرصدة' : 'Customers & Balances', boldFont),
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
                    bottom: pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'العميل', 'الهاتف', 'العملة', 'الرصيد']
                : ['#', 'Customer', 'Phone', 'Currency', 'Balance'],
            data: List.generate(customers.length, (i) {
              final c = customers[i];
              final bal = balances[c.id] ?? 0;
              return [
                '${i + 1}',
                c.name,
                c.phoneNumber,
                c.currencyCode,
                _fmtAmt(bal, currencyCode: c.currencyCode, isAr: isAr),
              ];
            }),
          ),
          pw.SizedBox(height: 20),

          // Transactions section
          _sectionTitle(
              isAr ? 'سجل جميع العمليات' : 'All Transactions Log', boldFont),
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
                    bottom: pw.BorderSide(color: _border, width: 0.5))),
            cellAlignment: pw.Alignment.center,
            headers: isAr
                ? ['#', 'التاريخ والوقت', 'العميل', 'الوصف', 'النوع', 'المبلغ']
                : ['#', 'Date & Time', 'Customer', 'Desc', 'Type', 'Amount'],
            data: List.generate(transactions.length, (i) {
              final t = transactions[i];
              final cust =
                  customers.firstWhereOrNull((c) => c.id == t.customerId);
              return [
                '${i + 1}',
                _formatDate(t.createdAt),
                cust?.name ?? '-',
                t.description.isEmpty ? '-' : t.description,
                t.type == TransactionType.give
                    ? (isAr ? 'دفع' : 'Give')
                    : (isAr ? 'استلام' : 'Got'),
                _fmtAmt(t.amount, currencyCode: t.currencyCode, isAr: isAr),
              ];
            }),
          ),
        ],
      ),
    );
    return await pdf.save();
  }

  static Future<void> exportAllToPDF({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final bytes = await generateAllReportPdfBytes(
      customers: customers,
      balances: balances,
      transactions: transactions,
    );
    await _saveAndShareBytes(bytes, 'full_report.pdf');
  }

  static Future<void> previewAllReportPDF({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    Get.to(() => ReportPreviewView(
          title: isAr
              ? 'معاينة التقرير المالي الشامل'
              : 'Full Financial Report Preview',
          fileName: 'full_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
          format: ReportFormat.pdf,
          documentLoader: () => generateAllReportPdfBytes(
            customers: customers,
            balances: balances,
            transactions: transactions,
          ),
        ));
  }

  // ═══════════════════════════════════════════════════════════════════
  // ─── Excel Export ─────────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════════════

  static Future<Uint8List> generateAllReportExcelBytes({
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
      TextCellValue(isAr ? 'العملة' : 'Currency'),
      TextCellValue(isAr ? 'الرصيد' : 'Balance'),
    ]);
    for (final c in customers) {
      custSheet.appendRow([
        TextCellValue(c.name),
        TextCellValue(c.phoneNumber),
        TextCellValue(c.currencyCode),
        DoubleCellValue(balances[c.id] ?? 0),
      ]);
    }

    final txSheet = excel['Transactions'];
    txSheet.appendRow([
      TextCellValue(isAr ? 'التاريخ والوقت' : 'Date & Time'),
      TextCellValue(isAr ? 'العميل' : 'Customer'),
      TextCellValue(isAr ? 'الوصف' : 'Description'),
      TextCellValue(isAr ? 'النوع' : 'Type'),
      TextCellValue(isAr ? 'العملة' : 'Currency'),
      TextCellValue(isAr ? 'المبلغ' : 'Amount'),
    ]);
    for (final t in transactions) {
      final cust = customers.firstWhereOrNull((c) => c.id == t.customerId);
      txSheet.appendRow([
        TextCellValue(_formatDate(t.createdAt)),
        TextCellValue(cust?.name ?? '-'),
        TextCellValue(t.description),
        TextCellValue(t.type == TransactionType.give
            ? (isAr ? 'دفع' : 'Give')
            : (isAr ? 'استلام' : 'Got')),
        TextCellValue(t.currencyCode),
        DoubleCellValue(t.amount),
      ]);
    }

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }

  static Future<void> exportAllToExcel({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final bytes = await generateAllReportExcelBytes(
      customers: customers,
      balances: balances,
      transactions: transactions,
    );
    await _saveAndShareBytes(bytes, 'account_book_export.xlsx');
  }

  static Future<void> previewAllReportExcel({
    required List<Customer> customers,
    required Map<int, double> balances,
    required List<TransactionModel> transactions,
  }) async {
    final sc = Get.find<SettingsController>();
    final isAr = sc.isArabic;
    Get.to(() => ReportPreviewView(
          title: isAr ? 'معاينة ملف إكسل' : 'Full Excel Report Preview',
          fileName:
              'account_book_export_${DateTime.now().millisecondsSinceEpoch}.xlsx',
          format: ReportFormat.excel,
          documentLoader: () => generateAllReportExcelBytes(
            customers: customers,
            balances: balances,
            transactions: transactions,
          ),
        ));
  }

  static pw.Widget _detailRow(
    String label,
    String value,
    pw.Font font,
    pw.Font boldFont, {
    PdfColor valueColor = _textDark,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(font: font, fontSize: 10, color: _textMuted)),
          pw.Text(value,
              style: pw.TextStyle(
                  font: boldFont, fontSize: 11, color: valueColor)),
        ],
      ),
    );
  }

  static pw.Widget _divider() {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      height: 0.5,
      color: _border,
    );
  }
}
