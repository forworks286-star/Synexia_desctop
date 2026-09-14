import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import '../../../core/widgets/app_toast.dart';
import '../../controllers/controllers.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../data/repositories/invoice_repository_impl.dart';
import '../historique/historique_produit_screen.dart';

List<(String, String)> typeStockOptionsL10n(AppLocalizations t) => [
  ('matiere_premiere', t.filterTypeRawMaterial),
  ('produit_fini', t.filterTypeFinishedProduct),
  ('marchandise', t.filterTypeMerchandise),
  ('consommable', t.filterTypeConsumable),
];

String typeStockLabelL10n(AppLocalizations t, String? v) =>
    typeStockOptionsL10n(t).firstWhere((e) => e.$1 == v, orElse: () => (v ?? '', v ?? '—')).$2;

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

  bool get _isPending => _invoice?.statusRaw == 'pending';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final t = AppLocalizations.of(context);
    if (_error != null || _invoice == null) {
      return Center(child: Text(_error ?? t.errorTitle, style: const TextStyle(color: AppColors.danger)));
    }
    final invoice = _invoice!;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => safeBack()),
            Expanded(child: PageHeader(title: '${t.histInvoiceWord} ${invoice.numeroFacture ?? '#${invoice.id}'}')),
            InvoiceChip(status: invoice.status, label: _statusLabel(t, invoice.status)),
          ]),
          const SizedBox(height: 20),
          _buildHeaderCard(t, invoice),
          const SizedBox(height: 16),
          _buildFinancialCard(t, invoice),
          const SizedBox(height: 16),
          _buildLinesCard(t, invoice),
          if (invoice.motifRejet != null) ...[
            const SizedBox(height: 16),
            SynCard(
              borderLeft: AppColors.danger,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionTitle(title: t.rejectionReasonTitle),
                const SizedBox(height: 8),
                Text(invoice.motifRejet!, style: const TextStyle(fontSize: 13)),
              ]),
            ),
          ],
          if (_isPending && Get.find<AuthController>().isManager) ...[
            const SizedBox(height: 20),
            _buildActionButtons(t, invoice),
          ],
        ]),
      ),
    );
  }

  Widget _buildHeaderCard(AppLocalizations t, Invoice invoice) {
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
            invoice.typeFacture == 'vente' ? t.saleWord : (invoice.typeFacture == 'ajustement_manuel' ? t.manualAdjustmentWord : t.histTypePurchase),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              color: invoice.typeFacture == 'vente' ? AppColors.success : AppColors.primary),
          ),
        ),
        if (invoice.creeManuellement) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(t.createdManuallyLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning)),
          ),
        ],
      ]),
      const Divider(height: 24),
      Row(children: [
        Expanded(child: _infoLine(t.formSupplierNif, invoice.fournisseurNif ?? '—')),
        Expanded(child: _infoLine(t.formSupplierNis, invoice.fournisseurNis ?? '—')),
        Expanded(child: _infoLine(t.formSupplierRc, invoice.fournisseurRc ?? '—')),
      ]),
      if (invoice.motifCreationManuelle != null) ...[
        const SizedBox(height: 8),
        _infoLine(t.manualCreationReasonLabel, invoice.motifCreationManuelle!),
      ],
    ]));
  }

  Widget _buildFinancialCard(AppLocalizations t, Invoice invoice) {
    return SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title: t.financialSummaryTitle),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _infoLine(t.amountHtLabel, formatDA(invoice.amountHt))),
        Expanded(child: _infoLine(t.tvaLabel, '${invoice.tauxTva.toStringAsFixed(0)}%')),
        Expanded(child: _infoLine(t.invoiceAmountTva, formatDA(invoice.amountTva))),
        Expanded(child: _infoLine(t.amountTtcLabel, formatDA(invoice.amountTtc))),
        if (invoice.ppa != null) Expanded(child: _infoLine(t.ppaLabel, formatDA(invoice.ppa!))),
      ]),
      if (invoice.incoherenceDetectee) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(t.incoherenceDetectedMsg,
              style: const TextStyle(fontSize: 11, color: AppColors.warning))),
          ]),
        ),
      ],
    ]));
  }

  Widget _buildLinesCard(AppLocalizations t, Invoice invoice) {
    return SynCard(padding: EdgeInsets.zero, child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: SectionTitle(
          title: '${t.productsCountTitle} (${_lignes.length})',
          action: _isPending ? SynButton(label: t.addShortButton, outline: true, onTap: _showAddLigneDialog) : null,
        ),
      ),
      const Divider(height: 1),
      if (_lignes.isEmpty)
        Padding(padding: const EdgeInsets.all(24), child: Text(t.noProductInInvoice,
          style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12))),
      for (final l in _lignes) _ligneRow(t, l),
    ]));
  }

  Widget _ligneRow(AppLocalizations t, LigneFacture l) {
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
          child: Text(l.matched ? t.existingTag : '🆕 ${typeStockLabelL10n(t, l.typeStock)}',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: l.matched ? AppColors.success : AppColors.warning)),
        )),
        Expanded(flex: 1, child: Text('${l.quantite.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(l.prixUnitaire), style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(l.montantLigne), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        if (l.dateExpiration != null)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text('${t.histExpiresPrefix.replaceAll(':', '')}: ${l.dateExpiration}', style: TextStyle(fontSize: 10,
              color: l.dateExpirationManquante ? AppColors.warning : AppColors.darkTextMuted)),
          )
        else if (l.dateExpirationManquante)
          const Padding(
            padding: EdgeInsets.only(right: 6),
            child: Icon(Icons.event_busy_rounded, size: 14, color: AppColors.warning),
          ),
        if (_isPending)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
            onPressed: () async {
              final r = await _repo.deleteLigne(l.id);
              r.fold((e) {}, (_) => _load());
            },
          ),
      ]),
    );
  }

  Widget _buildActionButtons(AppLocalizations t, Invoice invoice) {
    return Row(children: [
      Expanded(child: SynButton(
        label: t.invValidateButton,
        color: AppColors.success,
        onTap: () async {
          final r = await _repo.validateInvoice(invoice.id);
          r.fold(
            (e) => AppToast.error(t.errorTitle, e),
            (_) {
              _load();
              if (Get.isRegistered<StockController>()) Get.find<StockController>().loadProducts();
              AppToast.success(t.toastSuccess, t.invoiceValidatedSuccessMsg);
            },
          );
        },
      )),
      const SizedBox(width: 12),
      Expanded(child: SynButton(
        label: t.rejectButton, outline: true, color: AppColors.danger,
        onTap: () => _showRejectDialog(t, invoice),
      )),
    ]);
  }

  void _showRejectDialog(AppLocalizations t, Invoice invoice) {
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: Text(t.motifRejetTitle),
      content: TextField(
        controller: motifCtrl, maxLines: 3,
        decoration: InputDecoration(hintText: t.motifRejetHint),
      ),
      actions: [
        TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
        ElevatedButton(
          onPressed: () async {
            if (motifCtrl.text.trim().isEmpty) return;
            final r = await _repo.rejectInvoice(invoice.id, motifCtrl.text.trim());
            await safeBack();
            r.fold(
              (e) => AppToast.error(t.errorTitle, e),
              (_) => _load(),
            );
          },
          child: Text(t.confirmRejectButton),
        ),
      ],
    ));
  }

  void _showAddLigneDialog() {
    final t = AppLocalizations.of(context);
    final stock = Get.find<StockController>();
    Product? selectedProduct;
    final designationCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final prixCtrl = TextEditingController();
    final prixTotalCtrl = TextEditingController();
    final prixVenteCtrl = TextEditingController();
    final dateFabCtrl = TextEditingController();
    final dateExpCtrl = TextEditingController();
    String? selectedTypeStock;
    bool nouveauProduit = false;

    Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: Text(t.addProductToInvoiceTitle),
      content: SizedBox(width: 460, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SwitchListTile(
          title: Text(t.newProductSwitchLabel, style: const TextStyle(fontSize: 13)),
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
              decoration: InputDecoration(hintText: t.searchExistingProductHint),
            ),
          )
        else ...[
          TextField(controller: designationCtrl,
            decoration: InputDecoration(labelText: t.newProductNameLabel)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedTypeStock,
            decoration: InputDecoration(labelText: t.formStockType),
            items: typeStockOptionsL10n(t).map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
            onChanged: (v) => setState(() => selectedTypeStock = v),
          ),
        ],
        const SizedBox(height: 12),
        TextField(controller: qtyCtrl,
          decoration: InputDecoration(labelText: t.quantityWord), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: prixTotalCtrl,
            decoration: InputDecoration(labelText: t.lineTotalInvoiceLabel), keyboardType: TextInputType.number,
            onChanged: (v) {
              final total = double.tryParse(v) ?? 0;
              final qte = double.tryParse(qtyCtrl.text) ?? 0;
              if (total > 0 && qte > 0) prixCtrl.text = (total / qte).toStringAsFixed(4);
            })),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixCtrl,
            decoration: InputDecoration(labelText: t.unitPriceCalcLabel), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        TextField(controller: prixVenteCtrl,
          decoration: InputDecoration(labelText: t.salePriceOptionalLabel2), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: dateFabCtrl,
            decoration: InputDecoration(labelText: t.manufacturingDateYmdLabel))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: dateExpCtrl,
            decoration: InputDecoration(labelText: t.expirationDateYmdLabel))),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
        ElevatedButton(
          onPressed: () async {
            final qty = double.tryParse(qtyCtrl.text) ?? 0;
            final prix = double.tryParse(prixCtrl.text) ?? 0;
            final prixVente = double.tryParse(prixVenteCtrl.text);
            if (qty <= 0) return;
            final r = nouveauProduit
                ? await _repo.addLigne(widget.factureId,
                    designation: designationCtrl.text.trim(), typeStock: selectedTypeStock,
                    quantite: qty, prixUnitaire: prix,
                    prixTotalLigne: double.tryParse(prixTotalCtrl.text),
                    prixVente: prixVente,
                    dateFabrication: dateFabCtrl.text.trim().isEmpty ? null : dateFabCtrl.text.trim(),
                    dateExpiration: dateExpCtrl.text.trim().isEmpty ? null : dateExpCtrl.text.trim())
                : (selectedProduct == null
                    ? null
                    : await _repo.addLigne(widget.factureId,
                        produitId: selectedProduct!.id, quantite: qty, prixUnitaire: prix,
                    prixTotalLigne: double.tryParse(prixTotalCtrl.text),
                    prixVente: prixVente,
                        dateFabrication: dateFabCtrl.text.trim().isEmpty ? null : dateFabCtrl.text.trim(),
                        dateExpiration: dateExpCtrl.text.trim().isEmpty ? null : dateExpCtrl.text.trim()));
            if (r == null) return;
            await safeBack();
            r.fold((e) {}, (_) => _load());
          },
          child: Text(t.addButton),
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

  String _statusLabel(AppLocalizations t, InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.validated: return t.pdfStatusValidated;
      case InvoiceStatus.rejected: return t.pdfStatusRejected;
      case InvoiceStatus.pending: return t.pdfStatusPending;
      case InvoiceStatus.annulee: return t.invoiceCancelled;
    }
  }
}

