import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
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

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Historique Produit'),
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
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un produit par nom ou SKU...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          if (_error != null) Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))),
          if (!_loading && _error == null && _data != null) Expanded(child: _buildContent(_data!)),
          if (!_loading && _error == null && _data == null)
            const Expanded(child: Center(child: Text('Recherchez un produit pour voir son historique',
              style: TextStyle(color: AppColors.darkTextMuted)))),
        ],
      ),
    );
  }

  Widget _buildContent(HistoriquePrixProduit data) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _MarginCard(label: 'Prix achat moyen', value: data.prixAchatMoyen),
          const SizedBox(width: 16),
          _MarginCard(label: 'Prix vente moyen', value: data.prixVenteMoyen),
          const SizedBox(width: 16),
          _MarginCard(label: 'Marge', value: data.margePercent, isPercent: true),
        ]),
        const SizedBox(height: 20),

        SynCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(title: 'RÉPARTITION DU STOCK PAR LOT'),
            const SizedBox(height: 12),
            if (_selectedProduct == null || _selectedProduct!.lots.isEmpty)
              const Text('Aucun lot actif', style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted))
            else
              for (final lot in _selectedProduct!.lots) Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(lot.numeroLot ?? '—', style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                  Expanded(child: Text('${lot.quantiteDisponible} unités', style: const TextStyle(fontSize: 12))),
                  Expanded(child: Text(lot.dateExpiration != null
                    ? 'Expire: ${lot.dateExpiration!.day}/${lot.dateExpiration!.month}/${lot.dateExpiration!.year}'
                    : '', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted))),
                  if (lot.numeroFacture != null && lot.factureId != null)
                    TextButton(
                      onPressed: () => Get.to(() => FactureDetailScreen(factureId: lot.factureId!)),
                      child: Text('Facture ${lot.numeroFacture} →', style: const TextStyle(fontSize: 11)),
                    ),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 20),

        if (data.historique.isNotEmpty) ...[
          SynCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle(title: 'ÉVOLUTION DU PRIX D\'ACHAT'),
              const SizedBox(height: 16),
              SizedBox(height: 220, child: _PriceChart(historique: data.historique)),
            ]),
          ),
          const SizedBox(height: 20),
        ],

        SynCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: SectionTitle(title: 'TOUTES LES FACTURES — CE PRODUIT'),
            ),
            const Divider(height: 1),
            if (data.historique.isEmpty)
              const Padding(padding: EdgeInsets.all(20), child: Text('Aucune facture pour ce produit pour le moment',
                style: TextStyle(fontSize: 12, color: AppColors.darkTextMuted))),
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
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(
        value == null ? '—' : (isPercent ? '${value!.toStringAsFixed(1)}%' : formatDA(value!)),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
          color: isPercent && value != null ? (value! >= 0 ? AppColors.success : AppColors.danger) : null),
      ),
    ])));
  }
}

class _PriceChart extends StatelessWidget {
  final List<LigneFacture> historique;
  const _PriceChart({required this.historique});

  @override
  Widget build(BuildContext context) {
    final achats = historique.where((l) => l.typeFacture != 'vente').toList().reversed.toList();
    if (achats.isEmpty) {
      return const Center(child: Text('Aucun achat enregistré pour ce produit',
        style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)));
    }
    final spots = <FlSpot>[
      for (int i = 0; i < achats.length; i++) FlSpot(i.toDouble(), achats[i].prixUnitaire),
    ];
    return LineChart(LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
          final i = v.toInt();
          if (i < 0 || i >= achats.length) return const SizedBox.shrink();
          final d = achats[i].factureDate;
          return Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted));
        })),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, meta) =>
          Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted)))),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: AppColors.primary, barWidth: 2,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.08)),
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
    final isVente = ligne.typeFacture == 'vente';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5))),
      child: Row(children: [
        Expanded(flex: 2, child: Text(
          '${ligne.factureDate.day.toString().padLeft(2, '0')}/${ligne.factureDate.month.toString().padLeft(2, '0')}/${ligne.factureDate.year}',
          style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (isVente ? AppColors.success : AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
          child: Text(isVente ? 'Vente' : 'Achat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
            color: isVente ? AppColors.success : AppColors.primary)),
        )),
        Expanded(flex: 3, child: Text(ligne.fournisseurNom, style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text('${ligne.quantite.toStringAsFixed(0)} u.', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(ligne.prixUnitaire), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(flex: 2, child: GestureDetector(
          onTap: () => Get.to(() => FactureDetailScreen(factureId: ligne.factureId)),
          child: Text(ligne.numeroFacture ?? '#${ligne.factureId}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.primary, decoration: TextDecoration.underline)),
        )),
      ]),
    );
  }
}