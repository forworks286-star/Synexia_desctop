import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';


class RapportsScreen extends StatelessWidget {
  const RapportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final invoices = Get.find<InvoiceController>();
    final t = AppLocalizations.of(context);
    final tGlobal = AppLocalizations(Get.locale ?? const Locale('fr'));

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: t.navReports),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ReportCard(
                title: t.reportStockTitle,
                description: t.reportStockDesc,
                icon: Icons.inventory_2_outlined,
                color: AppPalette.primary,
                onGenerate: () => _generateStockPdf(tGlobal, stock),
              )),
              const SizedBox(width: 20),
              Expanded(child: _ReportCard(
                title: t.reportInvoicesTitle,
                description: t.reportInvoicesDesc,
                icon: Icons.receipt_long_outlined,
                color: AppPalette.success,
                onGenerate: () => _generateFacturesPdf(tGlobal, invoices),
              )),
              const SizedBox(width: 20),
              Expanded(child: _ReportCard(
                title: t.reportAlertsTitle,
                description: t.reportAlertsDesc,
                icon: Icons.notifications_outlined,
                color: AppPalette.warning,
                onGenerate: () => _generateAlertesPdf(tGlobal),
              )),
            ],
          ),
          const SizedBox(height: 24),
          SynCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title: t.globalSummaryTitle),
                const SizedBox(height: 20),
                Obx(() {
                  final s = stock.stats.value;
                  final pending = invoices.invoices.where((i) => i.status == InvoiceStatus.pending).length;
                  final validated = invoices.invoices.where((i) => i.status == InvoiceStatus.validated).length;
                  final critical = stock.products.where((p) => p.status == StockStatus.critical).length;
                  return Row(children: [
                    Expanded(child: _StatItem(label: t.statTotalProducts, value: '${s?.totalProducts ?? 0}', color: AppPalette.primary)),
                    _Divider(),
                    Expanded(child: _StatItem(label: t.statCriticalProducts, value: '$critical', color: AppPalette.danger)),
                    _Divider(),
                    Expanded(child: _StatItem(label: t.statValidatedInvoices, value: '$validated', color: AppPalette.success)),
                    _Divider(),
                    Expanded(child: _StatItem(label: t.kpiPendingInvoices, value: '$pending', color: AppPalette.warning)),
                    _Divider(),
                    Expanded(child: _StatItem(label: t.statSystemAvailability, value: '${s?.availability.toStringAsFixed(1) ?? 0}%', color: AppPalette.secondary)),
                  ]);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onGenerate;

  const _ReportCard({required this.title, required this.description, required this.icon, required this.color, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return SynCard(
      borderLeft: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Syne')),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 12, color: context.colors.textMuted, height: 1.5)),
          const SizedBox(height: 20),
          SynButton(label: AppLocalizations.of(context).generatePdfButton, icon: Icons.picture_as_pdf_outlined, color: color, onTap: onGenerate),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(fontFamily: 'Syne', fontSize: 28, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 11, color: context.colors.textMuted), textAlign: TextAlign.center),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 60, color: context.colors.border, margin: const EdgeInsets.symmetric(horizontal: 20));
  }
}

Future<void> _generateStockPdf(AppLocalizations t, StockController stock) async {
  final pdf = pw.Document();
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => [
      pw.Header(level: 0, child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(t.pdfStockReportTitle,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('${t.pdfGeneratedOnPrefix} $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: [t.pdfHeaderProduct, t.thSku, t.thCategory, t.pdfHeaderStockAvailable, t.pdfHeaderValueDzd, t.thStatus],
        data: stock.products.map((p) => [
          p.name,
          p.sku,
          p.categorie ?? '—',
          '${p.stockDisponible}',
          p.valeurStock.toStringAsFixed(0),
          p.status == StockStatus.critical ? t.statusCritical
              : p.status == StockStatus.low ? t.statusLowShort : t.statusNormal,
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
        cellAlignments: {
          3: pw.Alignment.center,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.center,
        },
      ),
      pw.SizedBox(height: 20),
      pw.Text(
        '${t.pdfTotalStockValuePrefix} ${stock.products.fold<double>(0, (s, p) => s + p.valeurStock).toStringAsFixed(0)} DZD',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<void> _generateFacturesPdf(AppLocalizations t, InvoiceController invoices) async {
  final pdf = pw.Document();
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => [
      pw.Header(level: 0, child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(t.pdfInvoicesReportTitle,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('${t.pdfGeneratedOnPrefix} $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: [t.pdfHeaderSupplier, t.pdfHeaderDate, t.invoiceAmountHt, t.invoiceAmountTtc, t.thStatus],
        data: invoices.invoices.map((f) => [
          f.supplierName,
          DateFormat('dd/MM/yyyy').format(f.date),
          '${f.amountHt.toStringAsFixed(0)} DA',
          '${f.amountTtc.toStringAsFixed(0)} DA',
          f.status == InvoiceStatus.validated ? t.pdfStatusValidated
              : f.status == InvoiceStatus.rejected ? t.pdfStatusRejected : t.pdfStatusPending,
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      ),
      pw.SizedBox(height: 20),
      pw.Row(children: [
        pw.Expanded(child: pw.Text(
          '${t.pdfValidatedCountPrefix} ${invoices.invoices.where((f) => f.status == InvoiceStatus.validated).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
        pw.Expanded(child: pw.Text(
          '${t.pdfPendingCountPrefix} ${invoices.invoices.where((f) => f.status == InvoiceStatus.pending).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
        pw.Expanded(child: pw.Text(
          '${t.pdfRejectedCountPrefix} ${invoices.invoices.where((f) => f.status == InvoiceStatus.rejected).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
      ]),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<void> _generateAlertesPdf(AppLocalizations t) async {
  final alerts = Get.find<AlertController>().alerts;
  final pdf = pw.Document();
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => [
      pw.Header(level: 0, child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(t.pdfAlertsReportTitle,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('${t.pdfGeneratedOnPrefix} $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: [t.thTitle, t.thMessage, t.thLevel, t.pdfHeaderDate, t.thStatus],
        data: alerts.map((a) => [
          a.title,
          a.message,
          a.level == AlertLevel.danger ? t.statusCritical
              : a.level == AlertLevel.warning ? t.alertLevelWarning
              : a.level == AlertLevel.success ? t.toastSuccess : t.alertLevelInfo,
          DateFormat('dd/MM/yyyy HH:mm').format(a.createdAt),
          a.isRead ? t.readLabel : t.pdfUnreadLabel,
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      ),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
