import 'package:flutter/material.dart';
import '../qr/qr_a_imprimer_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../data/repositories/invoice_repository_impl.dart';
import '../factures/facture_detail_screen.dart';

class HistoriqueProduitScreen extends StatefulWidget {
  final Product? initialProduct;
  const HistoriqueProduitScreen({super.key, this.initialProduct});

  @override
  State<HistoriqueProduitScreen> createState() => _HistoriqueProduitScreenState();
}

class _HistoriqueProduitScreenState extends State<HistoriqueProduitScreen> {
  final _repo = InvoiceRepositoryImpl();
  final _searchCtrl = TextEditingController();
  Product? _selectedProduct;
  HistoriquePrixProduit? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _searchCtrl.text = widget.initialProduct!.name;
      _load(widget.initialProduct!.id);
    }
  }

  Future<void> _load(int produitId) async {
    for (final p in Get.find<StockController>().products) {
      if (p.id == produitId) { _selectedProduct = p; break; }
    }
    setState(() { _loading = true; _error = null; });
    final r = await _repo.getHistoriquePrix(produitId);
    r.fold(
      (e) => setState(() { _error = e; _loading = false; }),
      (d) => setState(() { _data = d; _loading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Get.back()),
            Expanded(child: PageHeader(title: t.histPageTitle)),
          ]),
          const SizedBox(height: 20),
          SynCard(
            child: Autocomplete<Product>(
              displayStringForOption: (p) => p.name,
              optionsBuilder: (value) {
                if (value.text.isEmpty) return const Iterable<Product>.empty();
                return stock.products.where((p) =>
                    p.name.toLowerCase().contains(value.text.toLowerCase()) ||
                    p.sku.toLowerCase().contains(value.text.toLowerCase()));
              },
              onSelected: (p) => _load(p.id),
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                controller.text = _searchCtrl.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: t.histSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator(color: AppPalette.primary))),
          if (_error != null) Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppPalette.danger)))),
          if (!_loading && _error == null && _data != null) Expanded(child: _buildContent(t, _data!)),
          if (!_loading && _error == null && _data == null)
            Expanded(child: Center(child: Text(t.histSearchEmpty,
              style: TextStyle(color: context.colors.textMuted)))),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations t, HistoriquePrixProduit data) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _MarginCard(label: t.histAvgPurchasePrice, value: data.prixAchatMoyen),
          const SizedBox(width: 16),
          _MarginCard(label: t.histAvgSalePrice, value: data.prixVenteMoyen),
          const SizedBox(width: 16),
          _MarginCard(label: t.histMargin, value: data.margePercent, isPercent: true),
        ]),
        const SizedBox(height: 20),

        SynCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SectionTitle(title: t.histLotDistributionTitle),
            const SizedBox(height: 12),
            if (_selectedProduct == null || _selectedProduct!.lots.isEmpty)
              Text(t.histNoActiveLot, style: TextStyle(fontSize: 12, color: context.colors.textMuted))
            else
              for (final lot in _selectedProduct!.lots) Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(lot.numeroLot ?? '—', style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                  Expanded(child: Text('${lot.quantiteDisponible} ${t.histUnitsSuffix}', style: const TextStyle(fontSize: 12))),
                  Expanded(child: Text(lot.dateExpiration != null
                    ? '${t.histExpiresPrefix} ${lot.dateExpiration!.day}/${lot.dateExpiration!.month}/${lot.dateExpiration!.year}'
                    : '', style: TextStyle(fontSize: 11, color: context.colors.textMuted))),
                  Expanded(child: Row(children: [
                    Icon(Icons.place_outlined, size: 13, color: context.colors.textMuted),
                    const SizedBox(width: 3),
                    Expanded(child: Text(lot.emplacement ?? '—', style: TextStyle(fontSize: 11, color: context.colors.textMuted))),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: AppPalette.primary),
                    tooltip: t.printLotQrTooltip,
                    onPressed: () => showLotQrDialog(lot.id, lot.numeroLot ?? '#${lot.id}'),
                  ),
                  if (lot.numeroFacture != null && lot.factureId != null)
                    TextButton(
                      onPressed: () => Get.to(() => FactureDetailScreen(factureId: lot.factureId!)),
                      child: Text('${t.histInvoiceWord} ${lot.numeroFacture} →', style: const TextStyle(fontSize: 11)),
                    ),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 20),

        if (data.historique.isNotEmpty) ...[
          SynCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionTitle(title: t.histPriceEvolutionTitle),
              const SizedBox(height: 16),
              SizedBox(height: 220, child: _PriceChart(historique: data.historique)),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        SynCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SectionTitle(title: t.histAllInvoicesTitle),
            ),
            const Divider(height: 1),
            if (data.historique.isEmpty)
              Padding(padding: const EdgeInsets.all(20), child: Text(t.histNoInvoiceYet,
                style: TextStyle(fontSize: 12, color: context.colors.textMuted))),
            for (final l in data.historique) _HistoriqueRow(ligne: l),
          ]),
        ),
      ]),
    );
  }
}

class _MarginCard extends StatelessWidget {
  final String label;
  final double? value;
  final bool isPercent;
  const _MarginCard({required this.label, required this.value, this.isPercent = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: context.colors.textMuted, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(
        value == null ? '—' : (isPercent ? '${value!.toStringAsFixed(1)}%' : formatDA(value!)),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
          color: isPercent && value != null ? (value! >= 0 ? AppPalette.success : AppPalette.danger) : null),
      ),
    ])));
  }
}

class _PriceChart extends StatelessWidget {
  final List<LigneFacture> historique;
  const _PriceChart({required this.historique});

  @override
  Widget build(BuildContext context) {
    // بس Achat/Ajustement مؤكدة (validated) — نفس منطق المتوسطات بالسيرفر.
    // historique يوصل من السيرفر مرتب: الأحدث أول (بالتاريخ ثم بالـid) — نعكسو
    // بالكامل هنا مرة وحدة، فيولي ترتيب زمني تصاعدي حقيقي (الأقدم أول).
    final achats = historique
        .where((l) => l.typeFacture != 'vente' && l.factureStatus == 'validated')
        .toList()
        .reversed
        .toList();

    final t = AppLocalizations(Get.locale ?? const Locale('fr'));
    if (achats.isEmpty) {
      return Center(child: Text(t.histNoValidatedPurchase,
        style: TextStyle(color: context.colors.textMuted, fontSize: 12)));
    }
    if (achats.length < 2) {
      return Center(child: Text(
        '${t.histSinglePurchasePrefix} (${formatDA(achats.first.prixUnitaire)})\n${t.histChartAppearsNote}',
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colors.textMuted, fontSize: 12)));
    }

    final spots = <FlSpot>[
      for (int i = 0; i < achats.length; i++) FlSpot(i.toDouble(), achats[i].prixUnitaire),
    ];

    return LineChart(LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, getTitlesWidget: (v, meta) {
          final i = v.toInt();
          if (i < 0 || i >= achats.length) return const SizedBox.shrink();
          final d = achats[i].factureDate;
          // نتفادى تكرار نفس التاريخ جنب بعضو مباشرة (يصير فعليًا لو عدة فواتير بنفس اليوم)
          if (i > 0) {
            final prev = achats[i - 1].factureDate;
            if (prev.day == d.day && prev.month == d.month && prev.year == d.year) {
              return const SizedBox.shrink();
            }
          }
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${(d.year % 100).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 9, color: context.colors.textMuted)),
          );
        })),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 55, getTitlesWidget: (v, meta) =>
          Text(formatDA(v), style: TextStyle(fontSize: 8, color: context.colors.textMuted)))),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) {
            final l = achats[s.x.toInt()];
            return LineTooltipItem(
              '${formatDA(l.prixUnitaire)}\n${l.fournisseurNom}',
              const TextStyle(color: Colors.white, fontSize: 11),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: false, color: AppPalette.primary, barWidth: 2,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: AppPalette.primary.withOpacity(0.08)),
        ),
      ],
    ));
  }
}

class _HistoriqueRow extends StatelessWidget {
  final LigneFacture ligne;
  const _HistoriqueRow({required this.ligne});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isVente = ligne.typeFacture == 'vente';
    final statusColor = ligne.factureStatus == 'validated' ? AppPalette.success
                       : ligne.factureStatus == 'rejected' ? AppPalette.danger
                       : AppPalette.warning;
    final statusLabel = ligne.factureStatus == 'validated' ? t.histStatusAccepted
                       : ligne.factureStatus == 'rejected' ? t.pdfStatusRejected
                       : t.pdfStatusPending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.colors.border, width: 0.5))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(
          '${ligne.factureDate.day.toString().padLeft(2, '0')}/${ligne.factureDate.month.toString().padLeft(2, '0')}/${ligne.factureDate.year}',
          style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (isVente ? AppPalette.success : AppPalette.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
          child: Text(isVente ? t.histTypeSale : t.histTypePurchase, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
            color: isVente ? AppPalette.success : AppPalette.primary)),
        )),
        Expanded(flex: 2, child: Text(ligne.fournisseurNom, style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: Text('${ligne.quantite.toStringAsFixed(0)} u.', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(ligne.prixUnitaire), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(flex: 2, child: GestureDetector(
          onTap: () => Get.to(() => FactureDetailScreen(factureId: ligne.factureId)),
          child: Text(ligne.numeroFacture ?? '#${ligne.factureId}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppPalette.primary, decoration: TextDecoration.underline)),
        )),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor)),
        )),
      ]),
    );
  }
}