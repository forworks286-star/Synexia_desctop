import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../data/repositories/invoice_repository_impl.dart';
import '../historique/historique_produit_screen.dart';

const typeStockOptions = [
  ('matiere_premiere', 'Matière première'),
  ('produit_fini', 'Produit fini'),
  ('marchandise', 'Marchandise'),
  ('consommable', 'Consommable'),
];

String typeStockLabel(String? v) =>
    typeStockOptions.firstWhere((e) => e.$1 == v, orElse: () => (v ?? '', v ?? '—')).$2;

class FactureDetailScreen extends StatefulWidget {
  final int factureId;
  const FactureDetailScreen({super.key, required this.factureId});

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  final _repo = InvoiceRepositoryImpl();
  Invoice? _invoice;
  List<LigneFacture> _lignes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r1 = await _repo.getInvoice(widget.factureId);
    final r2 = await _repo.getLignes(widget.factureId);
    r1.fold((e) => _error = e, (i) => _invoice = i);
    r2.fold((e) {}, (l) => _lignes = l);
    setState(() => _loading = false);
  }

  bool get _isPending => _invoice?.status == InvoiceStatus.pending;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null || _invoice == null) {
      return Center(child: Text(_error ?? 'Erreur', style: const TextStyle(color: AppColors.danger)));
    }
    final invoice = _invoice!;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Get.back()),
            Expanded(child: PageHeader(title: 'Facture ${invoice.numeroFacture ?? '#${invoice.id}'}')),
            InvoiceChip(status: invoice.status, label: _statusLabel(invoice.status)),
          ]),
          const SizedBox(height: 20),
          _buildHeaderCard(invoice),
          const SizedBox(height: 16),
          _buildFinancialCard(invoice),
          const SizedBox(height: 16),
          _buildLinesCard(invoice),
          if (invoice.motifRejet != null) ...[
            const SizedBox(height: 16),
            SynCard(
              borderLeft: AppColors.danger,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionTitle(title: 'MOTIF DE REJET'),
                const SizedBox(height: 8),
                Text(invoice.motifRejet!, style: const TextStyle(fontSize: 13)),
              ]),
            ),
          ],
          if (_isPending) ...[
            const SizedBox(height: 20),
            _buildActionButtons(invoice),
          ],
        ]),
      ),
    );
  }

  Widget _buildHeaderCard(Invoice invoice) {
    return SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(invoice.supplierName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(_fmtDate(invoice.date), style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (invoice.typeFacture == 'vente' ? AppColors.success : AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            invoice.typeFacture == 'vente' ? 'Vente' : (invoice.typeFacture == 'ajustement_manuel' ? 'Ajustement manuel' : 'Achat'),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: invoice.typeFacture == 'vente' ? AppColors.success : AppColors.primary),
          ),
        ),
        if (invoice.creeManuellement) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: const Text('Créée manuellement', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
          ),
        ],
      ]),
      const Divider(height: 24),
      Row(children: [
        Expanded(child: _infoLine('NIF fournisseur', invoice.fournisseurNif ?? '—')),
        Expanded(child: _infoLine('NIS fournisseur', invoice.fournisseurNis ?? '—')),
        Expanded(child: _infoLine('RC fournisseur', invoice.fournisseurRc ?? '—')),
      ]),
    ]));
  }

  Widget _buildFinancialCard(Invoice invoice) {
    return SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle(title: 'RÉSUMÉ FINANCIER'),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _infoLine('Montant HT', formatDA(invoice.amountHt))),
        Expanded(child: _infoLine('Taux TVA', '${invoice.tauxTva.toStringAsFixed(0)}%')),
        Expanded(child: _infoLine('Montant TVA', formatDA(invoice.amountTva))),
        Expanded(child: _infoLine('Montant TTC', formatDA(invoice.amountTtc))),
        if (invoice.ppa != null) Expanded(child: _infoLine('PPA', formatDA(invoice.ppa!))),
      ]),
      if (invoice.incoherenceDetectee) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
          child: const Row(children: [
            Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(child: Text('Incohérence détectée entre le montant HT et le total des lignes.',
              style: TextStyle(fontSize: 11, color: AppColors.warning))),
          ]),
        ),
      ],
    ]));
  }

  Widget _buildLinesCard(Invoice invoice) {
    return SynCard(padding: EdgeInsets.zero, child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: SectionTitle(
          title: 'PRODUITS (${_lignes.length})',
          action: _isPending ? SynButton(label: '+ Ajouter', outline: true, onTap: _showAddLigneDialog) : null,
        ),
      ),
      const Divider(height: 1),
      if (_lignes.isEmpty)
        const Padding(padding: EdgeInsets.all(24), child: Text('Aucun produit ajouté à cette facture',
          style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12))),
      for (final l in _lignes) _ligneRow(l),
    ]));
  }

  Widget _ligneRow(LigneFacture l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.darkBorder, width: 0.5))),
      child: Row(children: [
        Expanded(flex: 3, child: GestureDetector(
          onTap: l.produitId != null ? () => _goToProduct(l.produitId!) : null,
          child: Text(l.produitNom, style: TextStyle(fontSize: 13,
            decoration: l.produitId != null ? TextDecoration.underline : null,
            color: l.produitId != null ? AppColors.primary : null)),
        )),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (l.matched ? AppColors.success : AppColors.warning).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
          child: Text(l.matched ? '✅ Existant' : '🆕 ${typeStockLabel(l.typeStock)}',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: l.matched ? AppColors.success : AppColors.warning)),
        )),
        Expanded(flex: 1, child: Text('${l.quantite.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(l.prixUnitaire), style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(l.montantLigne), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        if (_isPending)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
            onPressed: () async {
              final r = await _repo.deleteLigne(l.id);
              r.fold((e) {}, (_) => _load());
            },
          )
        else
          const SizedBox(width: 40),
      ]),
    );
  }

  Widget _buildActionButtons(Invoice invoice) {
    return Row(children: [
      Expanded(child: SynButton(
        label: 'Valider',
        color: AppColors.success,
        onTap: () async {
          final r = await _repo.validateInvoice(invoice.id);
          r.fold(
            (e) => Get.snackbar('Erreur', e, backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger),
            (_) {
              _load();
              if (Get.isRegistered<StockController>()) Get.find<StockController>().loadProducts();
              Get.snackbar('Succès', 'Facture validée — stock mis à jour',
                backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
            },
          );
        },
      )),
      const SizedBox(width: 12),
      Expanded(child: SynButton(
        label: 'Rejeter', outline: true, color: AppColors.danger,
        onTap: () => _showRejectDialog(invoice),
      )),
    ]);
  }

  void _showRejectDialog(Invoice invoice) {
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Motif du rejet'),
      content: TextField(
        controller: motifCtrl, maxLines: 3,
        decoration: const InputDecoration(hintText: 'Expliquez pourquoi cette facture est rejetée...'),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            if (motifCtrl.text.trim().isEmpty) return;
            final r = await _repo.rejectInvoice(invoice.id, motifCtrl.text.trim());
            Get.back();
            r.fold(
              (e) => Get.snackbar('Erreur', e, backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger),
              (_) => _load(),
            );
          },
          child: const Text('Confirmer le rejet'),
        ),
      ],
    ));
  }

  void _showAddLigneDialog() {
    final stock = Get.find<StockController>();
    Product? selectedProduct;
    final designationCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final prixCtrl = TextEditingController();
    String? selectedTypeStock;
    bool nouveauProduit = false;

    Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Ajouter un produit à la facture'),
      content: SizedBox(width: 460, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(
          title: const Text('Produit inexistant (nouveau)', style: TextStyle(fontSize: 13)),
          value: nouveauProduit,
          onChanged: (v) => setState(() => nouveauProduit = v),
        ),
        if (!nouveauProduit)
          Autocomplete<Product>(
            displayStringForOption: (p) => p.name,
            optionsBuilder: (v) => v.text.isEmpty ? const Iterable<Product>.empty()
                : stock.products.where((p) => p.name.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (p) => selectedProduct = p,
            fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
              controller: controller, focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'Rechercher un produit existant...'),
            ),
          )
        else ...[
          TextField(controller: designationCtrl,
            decoration: const InputDecoration(labelText: 'Nom du nouveau produit')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedTypeStock,
            decoration: const InputDecoration(labelText: 'Type de stock'),
            items: typeStockOptions.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
            onChanged: (v) => setState(() => selectedTypeStock = v),
          ),
        ],
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: qtyCtrl,
            decoration: const InputDecoration(labelText: 'Quantité'), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixCtrl,
            decoration: const InputDecoration(labelText: 'Prix unitaire'), keyboardType: TextInputType.number)),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () async {
            final qty = double.tryParse(qtyCtrl.text) ?? 0;
            final prix = double.tryParse(prixCtrl.text) ?? 0;
            if (qty <= 0) return;
            final r = nouveauProduit
                ? await _repo.addLigne(widget.factureId,
                    designation: designationCtrl.text.trim(), typeStock: selectedTypeStock,
                    quantite: qty, prixUnitaire: prix)
                : (selectedProduct == null
                    ? null
                    : await _repo.addLigne(widget.factureId,
                        produitId: selectedProduct!.id, quantite: qty, prixUnitaire: prix));
            if (r == null) return;
            Get.back();
            r.fold((e) {}, (_) => _load());
          },
          child: const Text('Ajouter'),
        ),
      ],
    )));
  }

  void _goToProduct(int produitId) {
    final stock = Get.find<StockController>();
    Product? product;
    for (final p in stock.products) {
      if (p.id == produitId) { product = p; break; }
    }
    if (product != null) {
      Get.to(() => HistoriqueProduitScreen(initialProduct: product));
    }
  }

  Widget _infoLine(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _statusLabel(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.validated: return 'Validée';
      case InvoiceStatus.rejected: return 'Rejetée';
      case InvoiceStatus.pending: return 'En attente';
    }
  }
}