import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
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

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Rapports'),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ReportCard(
                title: 'Rapport de stock',
                description: 'État complet de l\'inventaire avec niveaux critiques et historique des mouvements.',
                icon: Icons.inventory_2_outlined,
                color: AppColors.primary,
                onGenerate: () => _generateStockPdf(stock),
              )),
              const SizedBox(width: 20),
              Expanded(child: _ReportCard(
                title: 'Rapport des factures',
                description: 'Synthèse des factures validées, rejetées et en attente sur la période sélectionnée.',
                icon: Icons.receipt_long_outlined,
                color: AppColors.success,
                onGenerate: () => _generateFacturesPdf(invoices),
              )),
              const SizedBox(width: 20),
              Expanded(child: _ReportCard(
                title: 'Rapport des alertes',
                description: 'Journal complet des alertes système, stocks critiques et anomalies détectées.',
                icon: Icons.notifications_outlined,
                color: AppColors.warning,
                onGenerate: () => _generateAlertesPdf(),
              )),
            ],
          ),
          const SizedBox(height: 24),
          SynCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'RÉSUMÉ GLOBAL'),
                const SizedBox(height: 20),
                Obx(() {
                  final s = stock.stats.value;
                  final pending = invoices.invoices.where((i) => i.status == InvoiceStatus.pending).length;
                  final validated = invoices.invoices.where((i) => i.status == InvoiceStatus.validated).length;
                  final critical = stock.products.where((p) => p.status == StockStatus.critical).length;
                  return Row(children: [
                    Expanded(child: _StatItem(label: 'Total produits', value: '${s?.totalProducts ?? 0}', color: AppColors.primary)),
                    _Divider(),
                    Expanded(child: _StatItem(label: 'Produits critiques', value: '$critical', color: AppColors.danger)),
                    _Divider(),
                    Expanded(child: _StatItem(label: 'Factures validées', value: '$validated', color: AppColors.success)),
                    _Divider(),
                    Expanded(child: _StatItem(label: 'Factures en attente', value: '$pending', color: AppColors.warning)),
                    _Divider(),
                    Expanded(child: _StatItem(label: 'Disponibilité système', value: '${s?.availability.toStringAsFixed(1) ?? 0}%', color: AppColors.secondary)),
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
          Text(description, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted, height: 1.5)),
          const SizedBox(height: 20),
          SynButton(label: 'Générer PDF', icon: Icons.picture_as_pdf_outlined, color: color, onTap: onGenerate),
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
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted), textAlign: TextAlign.center),
    ]);
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 60, color: AppColors.darkBorder, margin: const EdgeInsets.symmetric(horizontal: 20));
  }
}

Future<void> _generateStockPdf(StockController stock) async {
  final pdf = pw.Document();
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => [
      pw.Header(level: 0, child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SYNEXIA — Rapport de Stock',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Généré le $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: ['Produit', 'SKU', 'Catégorie', 'Stock dispo', 'Valeur (DZD)', 'Statut'],
        data: stock.products.map((p) => [
          p.name,
          p.sku,
          p.categorie ?? '—',
          '${p.stockDisponible}',
          p.valeurStock.toStringAsFixed(0),
          p.status == StockStatus.critical ? 'Critique'
              : p.status == StockStatus.low ? 'Bas' : 'Normal',
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
        'Total valeur stock: ${stock.products.fold<double>(0, (s, p) => s + p.valeurStock).toStringAsFixed(0)} DZD',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      ),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<void> _generateFacturesPdf(InvoiceController invoices) async {
  final pdf = pw.Document();
  final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => [
      pw.Header(level: 0, child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SYNEXIA — Rapport des Factures',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Généré le $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: ['Fournisseur', 'Date', 'Montant HT', 'Montant TTC', 'Statut'],
        data: invoices.invoices.map((f) => [
          f.supplierName,
          DateFormat('dd/MM/yyyy').format(f.date),
          '${f.amountHt.toStringAsFixed(0)} DA',
          '${f.amountTtc.toStringAsFixed(0)} DA',
          f.status == InvoiceStatus.validated ? 'Validée'
              : f.status == InvoiceStatus.rejected ? 'Rejetée' : 'En attente',
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      ),
      pw.SizedBox(height: 20),
      pw.Row(children: [
        pw.Expanded(child: pw.Text(
          'Validées: ${invoices.invoices.where((f) => f.status == InvoiceStatus.validated).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
        pw.Expanded(child: pw.Text(
          'En attente: ${invoices.invoices.where((f) => f.status == InvoiceStatus.pending).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
        pw.Expanded(child: pw.Text(
          'Rejetées: ${invoices.invoices.where((f) => f.status == InvoiceStatus.rejected).length}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        )),
      ]),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<void> _generateAlertesPdf() async {
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
          pw.Text('SYNEXIA — Rapport des Alertes',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('Généré le $now', style: const pw.TextStyle(fontSize: 10)),
        ],
      )),
      pw.SizedBox(height: 20),
      pw.Table.fromTextArray(
        headers: ['Titre', 'Message', 'Niveau', 'Date', 'Statut'],
        data: alerts.map((a) => [
          a.title,
          a.message,
          a.level == AlertLevel.danger ? 'Critique'
              : a.level == AlertLevel.warning ? 'Avertissement'
              : a.level == AlertLevel.success ? 'Succès' : 'Info',
          DateFormat('dd/MM/yyyy HH:mm').format(a.createdAt),
          a.isRead ? 'Lu' : 'Non lu',
        ]).toList(),
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      ),
    ],
  ));

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
