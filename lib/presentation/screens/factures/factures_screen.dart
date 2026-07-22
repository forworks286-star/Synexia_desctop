import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../core/utils/formatters.dart';
import 'facture_detail_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../../core/config/app_config.dart';
import '../../../data/services/api_client.dart';

class FacturesScreen extends StatelessWidget {
  const FacturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InvoiceController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Factures',
            actions: [
              _FilterDropdown(ctrl: ctrl),
              const SizedBox(width: 12),
              _TypeFilterDropdown(ctrl: ctrl),
              const SizedBox(width: 12),
              SynButton(label: 'Actualiser', icon: Icons.refresh_rounded, onTap: ctrl.loadInvoices, outline: true),
              const SizedBox(width: 12),
              SynButton(label: 'Nouvelle facture', icon: Icons.add_rounded,
                onTap: () => ouvrirNouvelleFacture(context, ctrl)),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (ctrl.facturesACorriger.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.edit_note_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Text('${ctrl.facturesACorriger.length} facture(s) à corriger — votre demande a été approuvée',
                    style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ...ctrl.facturesACorriger.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Expanded(child: Text('#${f.id} — ${f.supplierName} — ${Formatters.currency(f.amountTtc)}',
                      style: const TextStyle(fontSize: 13))),
                    SynButton(label: 'Corriger maintenant', icon: Icons.build_rounded,
                      onTap: () => _showCompleterModificationDialog(context, ctrl, f)),
                  ]),
                )),
              ]),
            );
          }),
          Expanded(
            child: SynCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _TableHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: Obx(() {
                      if (ctrl.isLoading.value && ctrl.invoices.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      final list = ctrl.filteredInvoices;
                      if (list.isEmpty) {
                        return const Center(child: Text('Aucune facture', style: TextStyle(color: AppColors.darkTextMuted)));
                      }
                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _InvoiceRow(invoice: list[i], ctrl: ctrl),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        _TH(label: 'N° FACTURE', flex: 2),
        _TH(label: '', flex: 1),
        _TH(label: 'FOURNISSEUR', flex: 3),
        _TH(label: 'DATE', flex: 2),
        _TH(label: 'MONTANT HT', flex: 2),
        _TH(label: 'MONTANT TTC', flex: 2),
        _TH(label: 'AUTHENTIFICATION', flex: 2),
        _TH(label: 'STATUT', flex: 2),
        _TH(label: 'ACTIONS', flex: 2),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final int flex;
  const _TH({required this.label, required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: flex, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextMuted, letterSpacing: 0.1)));
  }
}

class _InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  final InvoiceController ctrl;

  const _InvoiceRow({required this.invoice, required this.ctrl});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Expanded(flex: 2, child: Text(invoice.numeroFacture ?? '—',
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        Expanded(flex: 1, child: IconButton(
          icon: const Icon(Icons.info_outline_rounded, size: 18),
          tooltip: 'Voir la facture',
          onPressed: () => Get.to(() => FactureDetailScreen(factureId: invoice.id)),
        )),
        Expanded(flex: 3, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(invoice.supplierName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: invoice.typeFacture == 'vente' ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                invoice.typeFacture == 'vente' ? 'Vente' : 'Achat',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                  color: invoice.typeFacture == 'vente' ? AppColors.success : AppColors.primary),
              ),
            ),
          ],
        )),
        Expanded(flex: 2, child: Text(_fmt(invoice.date), style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted))),
        Expanded(flex: 2, child: Text(formatDA(invoice.amountHt), style: const TextStyle(fontSize: 12))),
        Expanded(flex: 2, child: Text(formatDA(invoice.amountTtc), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(flex: 2, child: Row(children: [
          _AuthDot(detected: invoice.stampDetected, label: 'Cachet'),
          const SizedBox(width: 8),
          _AuthDot(detected: invoice.signatureDetected, label: 'Sign.'),
        ])),
        Expanded(flex: 2, child: InvoiceChip(status: invoice.status, label: _statusLabel(invoice.status))),
        Expanded(flex: 2, child: Builder(builder: (_) {
          if (!Get.find<AuthController>().isManager) return const SizedBox.shrink();
          if (invoice.status != InvoiceStatus.pending) return const SizedBox.shrink();
          return Row(children: [
            SynButton(label: 'Valider', color: AppColors.success, onTap: () => ctrl.validateInvoice(invoice.id)),
            const SizedBox(width: 8),
            SynButton(label: 'Rejeter', outline: true, color: AppColors.danger,
              onTap: () => Get.to(() => FactureDetailScreen(factureId: invoice.id))),
          ]);
        })),
      ]),
    );
  }

  String _statusLabel(InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.validated: return 'Validée';
      case InvoiceStatus.rejected: return 'Rejetée';
      case InvoiceStatus.pending: return 'En attente';
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _AuthDot extends StatelessWidget {
  final bool detected;
  final String label;
  const _AuthDot({required this.detected, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = detected ? AppColors.success : AppColors.darkTextMuted;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(detected ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, size: 12, color: c),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: c)),
    ]);
  }
}

class _FilterDropdown extends StatelessWidget {
  final InvoiceController ctrl;
  const _FilterDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonHideUnderline(
      child: DropdownButton<InvoiceStatus?>(
        value: ctrl.statusFilter.value,
        hint: const Text('Tous les statuts', style: TextStyle(fontSize: 12)),
        style: const TextStyle(fontSize: 12),
        dropdownColor: AppColors.darkCard,
        items: const [
          DropdownMenuItem(value: null, child: Text('Tous les statuts')),
          DropdownMenuItem(value: InvoiceStatus.pending, child: Text('En attente')),
          DropdownMenuItem(value: InvoiceStatus.validated, child: Text('Validées')),
          DropdownMenuItem(value: InvoiceStatus.rejected, child: Text('Rejetées')),
        ],
        onChanged: (v) => ctrl.statusFilter.value = v,
      ),
    ));
  }
}


class _TypeFilterDropdown extends StatelessWidget {
  final InvoiceController ctrl;
  const _TypeFilterDropdown({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: ctrl.typeFilter.value,
        hint: const Text('Tous les types', style: TextStyle(fontSize: 12)),
        style: const TextStyle(fontSize: 12),
        dropdownColor: AppColors.darkCard,
        items: const [
          DropdownMenuItem(value: null,      child: Text('Tous les types')),
          DropdownMenuItem(value: 'achat',   child: Text('Achats')),
          DropdownMenuItem(value: 'vente',   child: Text('Ventes')),
        ],
        onChanged: (v) => ctrl.typeFilter.value = v,
      ),
    ));
  }
}

Map<String, dynamic> _ligneVide() => {
  'produit_id': null,
  'designation': '', 'quantite': '', 'prix_unitaire': '', 'prix_vente': '',
  'date_fabrication': null, 'date_expiration': null, 'numero_lot_fournisseur': '',
  'nouveau_categorie': '', 'nouveau_code_barre': '', 'nouveau_unite_mesure': '',
  'nouveau_seuil_critique': '', 'nouveau_emplacement': '',
};

void _showFactureManuelleDialog(BuildContext context, InvoiceController ctrl, {String? typeStockInitial}) {
  final fournisseurCtrl = TextEditingController();
  DateTime factureDate = DateTime.now();
  final htCtrl = TextEditingController();
  final tvaCtrl = TextEditingController();
  final ttcCtrl = TextEditingController();
  final motifCtrl = TextEditingController();
  final nifCtrl = TextEditingController();
  final nisCtrl = TextEditingController();
  final rcCtrl = TextEditingController();
  final compteRenduDemandeCtrl = TextEditingController();
  String typeFacture = 'achat';
  String typeStock = typeStockInitial ?? 'marchandise';
  final lignes = <Map<String, dynamic>>[_ligneVide()];

  Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: const Text('Nouvelle facture manuelle'),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(child: Text('Une facture créée manuellement reste en attente jusqu\'à vérification par un administrateur.',
            style: TextStyle(fontSize: 11, color: AppColors.warning))),
        ]),
      ),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          value: typeFacture,
          decoration: const InputDecoration(labelText: 'Type'),
          items: const [
            DropdownMenuItem(value: 'achat', child: Text('Achat')),
            DropdownMenuItem(value: 'vente', child: Text('Vente')),
          ],
          onChanged: (v) => setState(() => typeFacture = v ?? 'achat'),
        )),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(
          value: typeStock,
          decoration: const InputDecoration(labelText: 'Catégorie'),
          items: const [
            DropdownMenuItem(value: 'marchandise', child: Text('Marchandise')),
            DropdownMenuItem(value: 'matiere_premiere', child: Text('Matière première')),
            DropdownMenuItem(value: 'produit_fini', child: Text('Produit fini')),
            DropdownMenuItem(value: 'consommable', child: Text('Consommable')),
          ],
          onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
        )),
      ]),
      const SizedBox(height: 10),
      TextField(controller: fournisseurCtrl, decoration: const InputDecoration(labelText: 'Fournisseur / Client')),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: nifCtrl, decoration: const InputDecoration(labelText: 'NIF (optionnel)'))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: nisCtrl, decoration: const InputDecoration(labelText: 'NIS (optionnel)'))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: rcCtrl, decoration: const InputDecoration(labelText: 'RC (optionnel)'))),
      ]),
      const SizedBox(height: 10),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context, initialDate: factureDate,
            firstDate: DateTime(2020), lastDate: DateTime(2100),
          );
          if (picked != null) setState(() => factureDate = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date de la facture'),
          child: Text('${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}'),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: htCtrl, decoration: const InputDecoration(labelText: 'Montant HT'), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: tvaCtrl, decoration: const InputDecoration(labelText: 'TVA'), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: ttcCtrl, decoration: const InputDecoration(labelText: 'TTC'), keyboardType: TextInputType.number)),
      ]),
      const SizedBox(height: 10),
      TextField(controller: motifCtrl, maxLines: 2,
        decoration: const InputDecoration(labelText: 'Motif (obligatoire)', hintText: 'Pourquoi une saisie manuelle ?')),
      const Divider(height: 28),
      const SectionTitle(title: 'ARTICLES'),
      const SizedBox(height: 8),
      ...lignes.asMap().entries.map((entry) => _LigneManuelleRow(
        data: entry.value,
        onRemove: lignes.length > 1 ? () => setState(() => lignes.removeAt(entry.key)) : null,
        onChanged: () => setState(() {}),
      )),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        icon: const Icon(Icons.add), label: const Text('Ajouter un article'),
        onPressed: () => setState(() => lignes.add(_ligneVide())),
      )),
      const Divider(height: 28),
      TextField(controller: compteRenduDemandeCtrl, maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Problème constaté (optionnel)',
          hintText: 'Laissez les champs concernés vides, et expliquez ici précisément ce qui manque ou est incorrect.',
        )),
    ]))),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
      TextButton(
        onPressed: () async {
          if (compteRenduDemandeCtrl.text.trim().isEmpty) {
            Get.snackbar('Compte-rendu requis', 'Expliquez le problème avant d\'envoyer une demande de modification',
              backgroundColor: AppColors.warning.withOpacity(0.1), colorText: AppColors.warning);
            return;
          }
          if (motifCtrl.text.trim().isEmpty || fournisseurCtrl.text.trim().isEmpty) return;
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            Get.snackbar('Quantité manquante', 'Chaque article doit avoir une quantité supérieure à 0',
              backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger);
            return;
          }
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_vente': (l['prix_vente'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_vente'] as String) : null,
            'date_fabrication': l['date_fabrication'],
            'date_expiration': l['date_expiration'],
            'numero_lot_fournisseur': (l['numero_lot_fournisseur'] as String?)?.isEmpty == true
                ? null : l['numero_lot_fournisseur'],
            'nouveau_categorie': (l['nouveau_categorie'] as String?)?.isEmpty == true ? null : l['nouveau_categorie'],
            'nouveau_code_barre': (l['nouveau_code_barre'] as String?)?.isEmpty == true ? null : l['nouveau_code_barre'],
            'nouveau_unite_mesure': (l['nouveau_unite_mesure'] as String?)?.isEmpty == true ? null : l['nouveau_unite_mesure'],
            'nouveau_seuil_critique': (l['nouveau_seuil_critique'] as String?)?.isNotEmpty == true
                ? int.tryParse(l['nouveau_seuil_critique'] as String) : null,
            'nouveau_emplacement': (l['nouveau_emplacement'] as String?)?.isEmpty == true ? null : l['nouveau_emplacement'],
          }).toList();
          final ok = await ctrl.creerFactureManuelle(
            fournisseurNom: fournisseurCtrl.text.trim(),
            date: '${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}',
            typeFacture: typeFacture, typeStock: typeStock,
            montantHt: double.tryParse(htCtrl.text) ?? 0,
            montantTva: double.tryParse(tvaCtrl.text) ?? 0,
            montantTtc: double.tryParse(ttcCtrl.text) ?? 0,
            fournisseurNif: nifCtrl.text.trim().isEmpty ? null : nifCtrl.text.trim(),
            fournisseurNis: nisCtrl.text.trim().isEmpty ? null : nisCtrl.text.trim(),
            fournisseurRc: rcCtrl.text.trim().isEmpty ? null : rcCtrl.text.trim(),
            motifCreationManuelle: motifCtrl.text.trim(),
            lignes: lignesPourEnvoi,
            compteRenduDemande: compteRenduDemandeCtrl.text.trim(),
          );
          Get.back();
          if (ok) {
            Get.snackbar('Facture envoyée', 'En confirmation de changement — un administrateur doit valider votre demande',
              backgroundColor: AppColors.warning.withOpacity(0.1), colorText: AppColors.warning);
          }
        },
        child: const Text('Envoyer + demande de modification'),
      ),
      ElevatedButton(
        onPressed: () async {
          if (motifCtrl.text.trim().isEmpty || fournisseurCtrl.text.trim().isEmpty) return;
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            Get.snackbar('Quantité manquante', 'Chaque article doit avoir une quantité supérieure à 0',
              backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger);
            return;
          }
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_vente': (l['prix_vente'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_vente'] as String) : null,
            'date_fabrication': l['date_fabrication'],
            'date_expiration': l['date_expiration'],
            'numero_lot_fournisseur': (l['numero_lot_fournisseur'] as String?)?.isEmpty == true
                ? null : l['numero_lot_fournisseur'],
            'nouveau_categorie': (l['nouveau_categorie'] as String?)?.isEmpty == true ? null : l['nouveau_categorie'],
            'nouveau_code_barre': (l['nouveau_code_barre'] as String?)?.isEmpty == true ? null : l['nouveau_code_barre'],
            'nouveau_unite_mesure': (l['nouveau_unite_mesure'] as String?)?.isEmpty == true ? null : l['nouveau_unite_mesure'],
            'nouveau_seuil_critique': (l['nouveau_seuil_critique'] as String?)?.isNotEmpty == true
                ? int.tryParse(l['nouveau_seuil_critique'] as String) : null,
            'nouveau_emplacement': (l['nouveau_emplacement'] as String?)?.isEmpty == true ? null : l['nouveau_emplacement'],
          }).toList();
          final ok = await ctrl.creerFactureManuelle(
            fournisseurNom: fournisseurCtrl.text.trim(),
            date: '${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}',
            typeFacture: typeFacture, typeStock: typeStock,
            montantHt: double.tryParse(htCtrl.text) ?? 0,
            montantTva: double.tryParse(tvaCtrl.text) ?? 0,
            montantTtc: double.tryParse(ttcCtrl.text) ?? 0,
            fournisseurNif: nifCtrl.text.trim().isEmpty ? null : nifCtrl.text.trim(),
            fournisseurNis: nisCtrl.text.trim().isEmpty ? null : nisCtrl.text.trim(),
            fournisseurRc: rcCtrl.text.trim().isEmpty ? null : rcCtrl.text.trim(),
            motifCreationManuelle: motifCtrl.text.trim(),
            lignes: lignesPourEnvoi,
          );
          Get.back();
          if (ok) {
            Get.snackbar('Facture créée', 'En attente de vérification par un administrateur',
              backgroundColor: AppColors.warning.withOpacity(0.1), colorText: AppColors.warning);
          }
        },
        child: const Text('Envoyer'),
      ),
    ],
  )));
}

class _LigneManuelleRow extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;
  const _LigneManuelleRow({required this.data, required this.onRemove, required this.onChanged});

  @override
  State<_LigneManuelleRow> createState() => _LigneManuelleRowState();
}

class _LigneManuelleRowState extends State<_LigneManuelleRow> {
  late final _designationCtrl = TextEditingController(text: widget.data['designation'] as String);
  late final _quantiteCtrl = TextEditingController(text: widget.data['quantite'] as String);
  late final _prixAchatCtrl = TextEditingController(text: widget.data['prix_unitaire'] as String);
  late final _prixVenteCtrl = TextEditingController(text: widget.data['prix_vente'] as String);
  late final _lotFournisseurCtrl = TextEditingController(text: widget.data['numero_lot_fournisseur'] as String);
  late final _categorieCtrl = TextEditingController(text: widget.data['nouveau_categorie'] as String);
  late final _codeBarreCtrl = TextEditingController(text: widget.data['nouveau_code_barre'] as String);
  late final _uniteMesureCtrl = TextEditingController(text: widget.data['nouveau_unite_mesure'] as String);
  late final _seuilCritiqueCtrl = TextEditingController(text: widget.data['nouveau_seuil_critique'] as String);
  late final _emplacementCtrl = TextEditingController(text: widget.data['nouveau_emplacement'] as String);
  late bool _nouveauProduit = widget.data['produit_id'] == null;


  Future<void> _pickDate(BuildContext context, String key) async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => widget.data[key] =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quantiteVide = (double.tryParse(_quantiteCtrl.text) ?? 0) <= 0;
    final stock = Get.find<StockController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('Produit inexistant (nouveau)', style: TextStyle(fontSize: 12)),
          value: _nouveauProduit,
          onChanged: (v) => setState(() {
            _nouveauProduit = v;
            if (v) widget.data['produit_id'] = null;
          }),

        ),
        if (!_nouveauProduit)
          Autocomplete<Product>(
            displayStringForOption: (p) => p.name,
            optionsBuilder: (v) => v.text.isEmpty ? const Iterable<Product>.empty()
                : stock.products.where((p) => p.name.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (p) => setState(() {
              widget.data['produit_id'] = p.id;
              _designationCtrl.text = p.name;
              widget.data['designation'] = p.name;
            }),
            fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
              controller: controller, focusNode: focusNode,
              decoration: const InputDecoration(hintText: 'Rechercher un produit existant...'),
            ),
          )
        else ...[
          TextField(
            controller: _designationCtrl,
            decoration: const InputDecoration(labelText: 'Nom du nouveau produit'),
            onChanged: (v) => widget.data['designation'] = v,
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _categorieCtrl,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              onChanged: (v) => widget.data['nouveau_categorie'] = v)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _codeBarreCtrl,
              decoration: const InputDecoration(labelText: 'Code-barres'),
              onChanged: (v) => widget.data['nouveau_code_barre'] = v)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _uniteMesureCtrl,
              decoration: const InputDecoration(labelText: 'Unité (kg, litre, pièce...)'),
              onChanged: (v) => widget.data['nouveau_unite_mesure'] = v)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _seuilCritiqueCtrl,
              decoration: const InputDecoration(labelText: 'Seuil critique'), keyboardType: TextInputType.number,
              onChanged: (v) => widget.data['nouveau_seuil_critique'] = v)),
          ]),
          const SizedBox(height: 6),
          TextField(controller: _emplacementCtrl,
            decoration: const InputDecoration(labelText: 'Emplacement'),
            onChanged: (v) => widget.data['nouveau_emplacement'] = v),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextField(
            controller: _designationCtrl,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Désignation retenue'),
          )),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextField(
            controller: _quantiteCtrl,
            decoration: InputDecoration(
              labelText: 'Qté *',
              errorText: quantiteVide ? 'Requis' : null,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => widget.data['quantite'] = v),
          )),
          if (widget.onRemove != null)
            IconButton(icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger), onPressed: widget.onRemove),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextField(
            controller: _prixAchatCtrl,
            decoration: const InputDecoration(labelText: 'Prix achat'),
            keyboardType: TextInputType.number,
            onChanged: (v) => widget.data['prix_unitaire'] = v,
          )),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _prixVenteCtrl,
            decoration: const InputDecoration(labelText: 'Prix vente (optionnel)'),
            keyboardType: TextInputType.number,
            onChanged: (v) => widget.data['prix_vente'] = v,
          )),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: InkWell(
            onTap: () => _pickDate(context, 'date_fabrication'),
            child: InputDecorator(decoration: const InputDecoration(labelText: 'Fabrication'),
              child: Text(widget.data['date_fabrication'] as String? ?? '—', style: const TextStyle(fontSize: 12))),
          )),
          const SizedBox(width: 8),
          Expanded(child: InkWell(
            onTap: () => _pickDate(context, 'date_expiration'),
            child: InputDecorator(decoration: const InputDecoration(labelText: 'Expiration'),
              child: Text(widget.data['date_expiration'] as String? ?? '—', style: const TextStyle(fontSize: 12))),
          )),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: _lotFournisseurCtrl,
          decoration: const InputDecoration(labelText: 'N° de lot fabricant (si imprimé sur le produit)'),
          onChanged: (v) => widget.data['numero_lot_fournisseur'] = v,
        ),
      ]),
    );
  }
}

void _showCompleterModificationDialog(BuildContext context, InvoiceController ctrl, Invoice facture) {
  final fournisseurCtrl = TextEditingController(text: facture.supplierName);
  DateTime factureDate = facture.date;
  final htCtrl = TextEditingController(text: facture.amountHt.toString());
  final tvaCtrl = TextEditingController(text: facture.amountTva.toString());
  final ttcCtrl = TextEditingController(text: facture.amountTtc.toString());
  final lignes = <Map<String, dynamic>>[_ligneVide()];

  Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text('Corriger la facture #${facture.id}'),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: fournisseurCtrl, decoration: const InputDecoration(labelText: 'Fournisseur / Client')),
      const SizedBox(height: 10),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context, initialDate: factureDate,
            firstDate: DateTime(2020), lastDate: DateTime(2100),
          );
          if (picked != null) setState(() => factureDate = picked);
        },
        child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Date de la facture'),
          child: Text('${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}'),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: htCtrl, decoration: const InputDecoration(labelText: 'Montant HT'), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: tvaCtrl, decoration: const InputDecoration(labelText: 'TVA'), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: ttcCtrl, decoration: const InputDecoration(labelText: 'TTC'), keyboardType: TextInputType.number)),
      ]),
      const Divider(height: 28),
      const SectionTitle(title: 'ARTICLES CORRIGÉS'),
      const SizedBox(height: 8),
      ...lignes.asMap().entries.map((entry) => _LigneManuelleRow(
        data: entry.value,
        onRemove: lignes.length > 1 ? () => setState(() => lignes.removeAt(entry.key)) : null,
        onChanged: () => setState(() {}),
      )),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        icon: const Icon(Icons.add), label: const Text('Ajouter un article'),
        onPressed: () => setState(() => lignes.add(_ligneVide())),
      )),
    ]))),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
      ElevatedButton(
        onPressed: () async {
          if (fournisseurCtrl.text.trim().isEmpty) return;
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            Get.snackbar('Quantité manquante', 'Chaque article doit avoir une quantité supérieure à 0',
              backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger);
            return;
          }
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_vente': (l['prix_vente'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_vente'] as String) : null,
            'date_fabrication': l['date_fabrication'],
            'date_expiration': l['date_expiration'],
            'numero_lot_fournisseur': (l['numero_lot_fournisseur'] as String?)?.isEmpty == true
                ? null : l['numero_lot_fournisseur'],
          }).toList();
          final ok = await ctrl.completerModification(
            factureId: facture.id,
            fournisseurNom: fournisseurCtrl.text.trim(),
            date: '${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}',
            montantHt: double.tryParse(htCtrl.text) ?? 0,
            montantTva: double.tryParse(tvaCtrl.text) ?? 0,
            montantTtc: double.tryParse(ttcCtrl.text) ?? 0,
            lignes: lignesPourEnvoi,
          );
          Get.back();
          if (ok) {
            Get.snackbar('Facture corrigée', 'La facture est de nouveau en attente de vérification',
              backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
          }
        },
        child: const Text('Envoyer la correction'),
      ),
    ],
  )));
}

void ouvrirNouvelleFacture(BuildContext context, InvoiceController ctrl) {
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: const Text('Nouvelle facture'),
    content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _ChoixCard(
        icon: Icons.qr_code_scanner_rounded, title: 'Depuis un téléphone (OCR)',
        subtitle: 'Nécessite l\'application mobile',
        onTap: () { Get.back(); _choisirType(context, ctrl, viaOcr: true); },
      ),
      const SizedBox(height: 10),
      _ChoixCard(
        icon: Icons.edit_note_rounded, title: 'Saisie manuelle',
        subtitle: 'Remplir la facture directement ici',
        onTap: () { Get.back(); _choisirType(context, ctrl, viaOcr: false); },
      ),
    ])),
  ));
}

void _choisirType(BuildContext context, InvoiceController ctrl, {required bool viaOcr}) {
  const types = {
    'marchandise': 'Marchandise', 'matiere_premiere': 'Matière première',
    'produit_fini': 'Produit fini', 'consommable': 'Consommable',
  };
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: const Text('Catégorie de la facture'),
    content: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min,
      children: types.entries.map((e) => _ChoixCard(
        icon: Icons.category_outlined, title: e.value, subtitle: '',
        onTap: () {
          Get.back();
          if (viaOcr) {
            Get.dialog(_AttenteAppairageDialog(typeStock: e.key), barrierDismissible: false);
          } else {
            _showFactureManuelleDialog(context, ctrl, typeStockInitial: e.key);
          }
        },
      )).toList(),
    )),
  ));
}

class _ChoixCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ChoixCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextMuted),
        ]),
      ),
    );
  }
}

class _AttenteAppairageDialog extends StatefulWidget {
  final String typeStock;
  const _AttenteAppairageDialog({required this.typeStock});

  @override
  State<_AttenteAppairageDialog> createState() => _AttenteAppairageDialogState();
}

class _AttenteAppairageDialogState extends State<_AttenteAppairageDialog> {
  String? _code;
  String _statut = 'attente';
  int _secondesRestantes = 180;
  Timer? _timer;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _genererCode();
  }

  Future<void> _genererCode() async {
    setState(() { _statut = 'attente'; _code = null; });
    try {
      final response = await ApiClient.instance.dio.post(AppConfig.appairageGenerer, data: {
        'type_stock': widget.typeStock, 'type_facture': 'achat',
      });
      setState(() {
        _code = response.data['code'] as String;
        _secondesRestantes = response.data['expire_dans_secondes'] as int;
      });
      _demarrerCompteARebours();
      _ecouterAppairage();
    } catch (_) {
      setState(() => _statut = 'erreur');
    }
  }

  void _demarrerCompteARebours() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondesRestantes <= 1) {
        t.cancel();
        setState(() => _statut = 'expire');
      } else {
        setState(() => _secondesRestantes--);
      }
    });
  }

  void _ecouterAppairage() {
    final alertCtrl = Get.find<AlertController>();
    _wsSub = alertCtrl.appairageStream.listen((data) {
      if (data['code'] != _code) return;
      final statut = data['statut'] as String?;
      if (statut == 'scanne') {
        setState(() => _statut = 'scanne');
      } else if (statut == 'complete') {
        _timer?.cancel();
        Get.back();
        final factureId = data['facture_id'] as int?;
        if (factureId != null) {
          Get.to(() => FactureDetailScreen(factureId: factureId));
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Recevoir depuis un téléphone'),
      content: SizedBox(width: 340, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_statut == 'expire') ...[
          const Icon(Icons.timer_off_rounded, size: 48, color: AppColors.warning),
          const SizedBox(height: 12),
          const Text('Code expiré', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SynButton(label: 'Générer un nouveau code', onTap: _genererCode),
        ] else if (_statut == 'erreur') ...[
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          const Text('Erreur de connexion au serveur'),
          const SizedBox(height: 12),
          SynButton(label: 'Réessayer', onTap: _genererCode),
        ] else if (_code == null) ...[
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: QrImageView(data: _code!, size: 180),
          ),
          const SizedBox(height: 14),
          Text(_code!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 4)),
          const SizedBox(height: 10),
          Text('Expire dans ${_secondesRestantes}s', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
          const SizedBox(height: 14),
          if (_statut == 'attente')
            const Text('Depuis l\'application mobile : entrez ce code ou scannez le QR.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          if (_statut == 'scanne') ...[
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 28),
            const SizedBox(height: 6),
            const Text('Téléphone connecté — en attente de la photo...',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.success)),
          ],
        ],
      ])),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Annuler'))],
    );
  }
}