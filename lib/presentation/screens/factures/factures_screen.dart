import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import '../../../core/widgets/app_toast.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../core/utils/formatters.dart';
import 'facture_detail_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../../../core/config/app_config.dart';
import '../../../data/services/api_client.dart';
import '../../../data/repositories/invoice_repository_impl.dart';

class FacturesScreen extends StatelessWidget {
  const FacturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InvoiceController>();
    ctrl.loadFacturesACorriger();
    ctrl.loadFacturesEnAttenteModification();
    ctrl.loadFacturesOcrAVerifier();
    ctrl.loadFacturesEcartASignaler();
    ctrl.loadFacturesEcartAValider();
    Get.find<AlertController>().markReadByType('facture');
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: t.navInvoices,
            actions: [
              _FilterDropdown(ctrl: ctrl),
              const SizedBox(width: 12),
              _TypeFilterDropdown(ctrl: ctrl),
              const SizedBox(width: 12),
              SynButton(label: t.dashboardRefresh, icon: Icons.refresh_rounded, onTap: ctrl.loadInvoices, outline: true),
              const SizedBox(width: 12),
              SynButton(label: t.invPageActionsNewInvoice, icon: Icons.add_rounded,
                onTap: () => ouvrirNouvelleFacture(context, ctrl)),
            ],
          ),

          const SizedBox(height: 20),
          Obx(() {
            if (ctrl.facturesEcartASignaler.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(t.invBannerMismatchCount(ctrl.facturesEcartASignaler.length),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView(shrinkWrap: true, children: ctrl.facturesEcartASignaler.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text('#${f.id} — ${f.supplierName}', style: const TextStyle(fontSize: 13))),
                      SynButton(label: t.invViewAndReport, icon: Icons.compare_arrows_rounded,
                        onTap: () => _showEcartASignalerDialog(context, ctrl, f)),
                    ]),
                  )).toList()),
                ),
              ]),
            );
          }),
          Obx(() {
            if (ctrl.facturesOcrAVerifier.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.fact_check_rounded, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(t.invBannerOcrCount(ctrl.facturesOcrAVerifier.length),
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView(shrinkWrap: true, children: ctrl.facturesOcrAVerifier.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text('#${f.id} — ${f.supplierName} — ${formatDA(f.amountTtc)}',
                        style: const TextStyle(fontSize: 13))),
                      SynButton(label: t.invVerifyButton, icon: Icons.visibility_rounded,
                        onTap: () => _showVerifierOcrDialog(context, ctrl, f)),
                    ]),
                  )).toList()),
                ),
              ]),
            );
          }),
          Obx(() {
            if (ctrl.facturesEnAttenteModification.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.lock_clock_rounded, color: AppColors.darkTextMuted, size: 18),
                  const SizedBox(width: 8),
                  Text(t.invBannerPendingModCount(ctrl.facturesEnAttenteModification.length),
                    style: const TextStyle(color: AppColors.darkTextMuted, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView(shrinkWrap: true, children: ctrl.facturesEnAttenteModification.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text('#${f.id} — ${f.supplierName} — ${formatDA(f.amountTtc)}',
                        style: const TextStyle(fontSize: 13, color: AppColors.darkTextMuted))),
                      const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.darkTextMuted),
                      const SizedBox(width: 6),
                      Text(t.invPendingAdmin, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
                    ]),
                  )).toList()),
                ),
              ]),
            );
          }),
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
                  Text(t.invBannerToCorrectCount(ctrl.facturesACorriger.length),
                    style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView(shrinkWrap: true, children: ctrl.facturesACorriger.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text('#${f.id} — ${f.supplierName} — ${formatDA(f.amountTtc)}',
                        style: const TextStyle(fontSize: 13))),
                      SynButton(label: t.invCorrectNow, icon: Icons.build_rounded,
                        onTap: () => _showCompleterModificationDialog(context, ctrl, f)),
                    ]),
                  )).toList()),
                ),
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
                        return Center(child: Text(AppLocalizations.of(context).invoicesEmpty, style: const TextStyle(color: AppColors.darkTextMuted)));
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
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        _TH(label: t.thInvoiceNumber, flex: 2),
        _TH(label: '', flex: 1),
        _TH(label: t.thSupplierUpper, flex: 3),
        _TH(label: t.thDateUpper, flex: 2),
        _TH(label: t.thAmountHtUpper, flex: 2),
        _TH(label: t.thAmountTtcUpper, flex: 2),
        _TH(label: t.thAuthentication, flex: 2),
        _TH(label: t.thStatus, flex: 2),
        _TH(label: t.thActions, flex: 2),
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
          tooltip: AppLocalizations.of(context).viewInvoiceButton,
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
                invoice.typeFacture == 'vente' ? AppLocalizations.of(context).histTypeSale : AppLocalizations.of(context).histTypePurchase,
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
          _AuthDot(detected: invoice.stampDetected, label: AppLocalizations.of(context).stampLabel),
          const SizedBox(width: 8),
          _AuthDot(detected: invoice.signatureDetected, label: AppLocalizations.of(context).signatureShortLabel),
        ])),
        Expanded(flex: 2, child: InvoiceChip(status: invoice.status, label: _statusLabel(AppLocalizations.of(context), invoice.status))),
        Expanded(flex: 2, child: Builder(builder: (_) {
          if (!Get.find<AuthController>().isManager) return const SizedBox.shrink();
          if (invoice.statusRaw != 'pending') return const SizedBox.shrink();
          return Row(children: [
            SynButton(label: AppLocalizations.of(context).invValidateButton, color: AppColors.success, onTap: () => ctrl.validateInvoice(invoice.id)),
            const SizedBox(width: 8),
            SynButton(label: AppLocalizations.of(context).rejectButton, outline: true, color: AppColors.danger,
              onTap: () => _showRejectDialogInline(context, ctrl, invoice)),
          ]);
        })),
      ]),
    );
  }

  String _statusLabel(AppLocalizations t, InvoiceStatus s) {
    switch (s) {
      case InvoiceStatus.validated: return t.pdfStatusValidated;
      case InvoiceStatus.rejected: return t.pdfStatusRejected;
      case InvoiceStatus.pending: return t.pdfStatusPending;
      case InvoiceStatus.annulee: return t.invoiceCancelled;
    }
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

void _showRejectDialogInline(BuildContext context, InvoiceController ctrl, Invoice invoice) {
  final t = AppLocalizations.of(context);
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
          final ok = await ctrl.rejectInvoice(invoice.id, motifCtrl.text.trim());
          await safeBack();
          if (ok) {
            AppToast.success(t.toastSuccess, t.invoiceRejectedToast);
          }
        },
        child: Text(t.confirmRejectButton),
      ),
    ],
  ));
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
        hint: Text(AppLocalizations.of(context).filterAllStatus, style: const TextStyle(fontSize: 12)),
        style: const TextStyle(fontSize: 12),
        dropdownColor: AppColors.darkCard,
        items: [
          DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context).filterAllStatus)),
          DropdownMenuItem(value: InvoiceStatus.pending, child: Text(AppLocalizations.of(context).pdfStatusPending)),
          DropdownMenuItem(value: InvoiceStatus.validated, child: Text(AppLocalizations.of(context).statusValidatedPlural)),
          DropdownMenuItem(value: InvoiceStatus.rejected, child: Text(AppLocalizations.of(context).statusRejectedPlural)),
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
        hint: Text(AppLocalizations.of(context).filterAllTypes, style: const TextStyle(fontSize: 12)),
        style: const TextStyle(fontSize: 12),
        dropdownColor: AppColors.darkCard,
        items: [
          DropdownMenuItem(value: null,      child: Text(AppLocalizations.of(context).filterAllTypes)),
          DropdownMenuItem(value: 'achat',   child: Text(AppLocalizations.of(context).typePurchases)),
          DropdownMenuItem(value: 'vente',   child: Text(AppLocalizations.of(context).typeSales)),
        ],
        onChanged: (v) => ctrl.typeFilter.value = v,
      ),
    ));
  }
}

Map<String, dynamic> _ligneVide() => {
  'produit_id': null,
  'designation': '', 'quantite': '', 'prix_unitaire': '', 'prix_total_ligne': '', 'prix_vente': '',
  'date_fabrication': null, 'date_expiration': null, 'numero_lot_fournisseur': '',
  'nouveau_categorie': '', 'nouveau_code_barre': '', 'nouveau_unite_mesure': '',
  'nouveau_seuil_critique': '', 'nouveau_emplacement': '',
};

void _showFactureManuelleDialog(BuildContext context, InvoiceController ctrl, {String? typeStockInitial}) {
  final t = AppLocalizations.of(context);
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
  int? bonCommandeId;
  bool isSubmitting = false;
  Get.find<BonCommandeController>().loadBonsOuverts(typeStock: typeStock);

  Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(t.newManualInvoiceTitle),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(t.manualInvoiceNotice,
            style: const TextStyle(fontSize: 11, color: AppColors.warning))),
        ]),
      ),
      Row(children: [
        Expanded(child: DropdownButtonFormField<String>(
          value: typeFacture,
          decoration: InputDecoration(labelText: t.typeLabel),
          items: [
            DropdownMenuItem(value: 'achat', child: Text(t.histTypePurchase)),
            DropdownMenuItem(value: 'vente', child: Text(t.histTypeSale)),
          ],
          onChanged: (v) => setState(() => typeFacture = v ?? 'achat'),
        )),
        const SizedBox(width: 10),
        Expanded(child: DropdownButtonFormField<String>(
          value: typeStock,
          decoration: InputDecoration(labelText: t.categoryLabel),
          items: [
            DropdownMenuItem(value: 'marchandise', child: Text(t.filterTypeMerchandise)),
            DropdownMenuItem(value: 'matiere_premiere', child: Text(t.filterTypeRawMaterial)),
            DropdownMenuItem(value: 'produit_fini', child: Text(t.filterTypeFinishedProduct)),
            DropdownMenuItem(value: 'consommable', child: Text(t.filterTypeConsumable)),
          ],
          onChanged: (v) {
            setState(() => typeStock = v ?? 'marchandise');
            Get.find<BonCommandeController>().loadBonsOuverts(typeStock: typeStock);
          },
        )),
      ]),
      const SizedBox(height: 10),
      Obx(() {
        final bonsDisponibles = Get.find<BonCommandeController>().bonsCommandeOuverts;
        final items = <DropdownMenuItem<int?>>[
          DropdownMenuItem<int?>(value: null, child: Text(t.poNone)),
          ...bonsDisponibles.map((bc) => DropdownMenuItem<int?>(
            value: bc.id, child: Text('${bc.numeroBc} — ${bc.fournisseurNom ?? ""}'))),
        ];
        if (bonCommandeId != null && !items.any((i) => i.value == bonCommandeId)) {
          items.add(DropdownMenuItem<int?>(
            value: bonCommandeId, child: Text('${t.poReservedByYouPrefix}$bonCommandeId ${t.poReservedByYouSuffix}')));
        }
        return DropdownButtonFormField<int?>(
          value: bonCommandeId,
          decoration: InputDecoration(labelText: t.poOptionalLabel),
          items: items,
          onChanged: (v) async {
            final ancien = bonCommandeId;
            if (v != null) {
              final ok = await Get.find<BonCommandeController>().reserver(v);
              if (!ok) {
                AppToast.warning(t.poUnavailableTitle, t.poUnavailableMsg);
                return;
              }
            }
            if (ancien != null) Get.find<BonCommandeController>().liberer(ancien);
            setState(() => bonCommandeId = v);
          },
        );
      }),
      const SizedBox(height: 10),
      TextField(controller: fournisseurCtrl, decoration: InputDecoration(labelText: t.supplierClientLabel)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: nifCtrl, decoration: InputDecoration(labelText: t.nifOptionalLabel))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: nisCtrl, decoration: InputDecoration(labelText: t.nisOptionalLabel))),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: rcCtrl, decoration: InputDecoration(labelText: t.rcOptionalLabel))),
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
          decoration: InputDecoration(labelText: t.invoiceDateLabel),
          child: Text('${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}'),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: htCtrl, decoration: InputDecoration(labelText: t.amountHtLabel), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: tvaCtrl, decoration: InputDecoration(labelText: t.tvaLabel), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: ttcCtrl, decoration: InputDecoration(labelText: t.amountTtcLabel), keyboardType: TextInputType.number)),
      ]),
      const SizedBox(height: 10),
      TextField(controller: motifCtrl, maxLines: 2,
        decoration: InputDecoration(labelText: t.reasonRequiredLabel, hintText: t.reasonHint)),
      const Divider(height: 28),
      SectionTitle(title: t.articlesTitle),
      const SizedBox(height: 8),
      ...lignes.asMap().entries.map((entry) => _LigneManuelleRow(
        data: entry.value,
        onRemove: lignes.length > 1 ? () => setState(() => lignes.removeAt(entry.key)) : null,
        onChanged: () => setState(() {}),
      )),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        icon: const Icon(Icons.add), label: Text(t.addArticleButton),
        onPressed: () => setState(() => lignes.add(_ligneVide())),
      )),
      const Divider(height: 28),
      TextField(controller: compteRenduDemandeCtrl, maxLines: 3,
        decoration: InputDecoration(
          labelText: t.problemOptionalLabel,
          hintText: t.problemHint,
        )),
    ]))),
    actions: [
      TextButton(onPressed: () async {
        if (bonCommandeId != null) Get.find<BonCommandeController>().liberer(bonCommandeId!);
        await safeBack();
      }, child: Text(t.cancel)),
      TextButton(
        onPressed: isSubmitting ? null : () async {
          if (compteRenduDemandeCtrl.text.trim().isEmpty) {
            AppToast.warning(t.reportRequiredTitle, t.reportRequiredMsg);
            return;
          }
          if (motifCtrl.text.trim().isEmpty) {
            AppToast.warning(t.reasonRequiredTitle, t.reasonRequiredMsg);
            return;
          }
          if (fournisseurCtrl.text.trim().isEmpty) {
            AppToast.warning(t.supplierRequiredTitle, t.supplierRequiredMsg);
            return;
          }
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            AppToast.warning(t.qtyMissingTitle, t.qtyMissingMsg);
            return;
          }
          setState(() => isSubmitting = true);
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_total_ligne': (l['prix_total_ligne'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_total_ligne'] as String) : null,
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
            bonCommandeId: bonCommandeId,
          );
          if (ok) {
            await safeBack();
            AppToast.success(t.invoiceSentTitle, t.invoiceSentMsg);
          } else {
            setState(() => isSubmitting = false);
            AppToast.error(t.sendFailedTitle, t.sendFailedMsg);
          }
        },
        child: Text(t.sendModificationRequestButton),
      ),
      ElevatedButton(
        onPressed: isSubmitting ? null : () async {
          if (motifCtrl.text.trim().isEmpty) {
            AppToast.warning(t.reasonRequiredTitle, t.reasonRequiredMsg);
            return;
          }
          if (fournisseurCtrl.text.trim().isEmpty) {
            AppToast.warning(t.supplierRequiredTitle, t.supplierRequiredMsg);
            return;
          }
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            AppToast.warning(t.qtyMissingTitle, t.qtyMissingMsg);
            return;
          }
          setState(() => isSubmitting = true);
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_total_ligne': (l['prix_total_ligne'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_total_ligne'] as String) : null,
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
            bonCommandeId: bonCommandeId,
          );
          if (ok) {
            await safeBack();
            AppToast.success(t.invoiceCreatedTitle, t.invoiceCreatedMsg);
          } else {
            setState(() => isSubmitting = false);
            AppToast.error(t.sendFailedTitle, t.sendFailedMsg);
          }
        },
        child: Text(t.sendButton),
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
  late final _prixTotalCtrl = TextEditingController(text: widget.data['prix_total_ligne'] as String);
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
          title: Text(AppLocalizations.of(context).newProductSwitchLabel, style: const TextStyle(fontSize: 12)),
          value: _nouveauProduit,
          onChanged: (v) => setState(() {
            _nouveauProduit = v;
            if (v) widget.data['produit_id'] = null;
          }),

        ),
        if (!_nouveauProduit) ...[
          Autocomplete<Product>(
            displayStringForOption: (p) => p.name,
            optionsBuilder: (v) => v.text.isEmpty ? const Iterable<Product>.empty()
                : stock.products.where((p) => p.name.toLowerCase().contains(v.text.toLowerCase())),
            onSelected: (p) => setState(() {
              widget.data['produit_id'] = p.id;
              _designationCtrl.text = p.name;
              widget.data['designation'] = p.name;
              if (_emplacementCtrl.text.trim().isEmpty && p.lots.isNotEmpty) {
                final dernierLot = p.lots.reduce((a, b) => a.id > b.id ? a : b);
                _emplacementCtrl.text = dernierLot.emplacement ?? '';
                widget.data['nouveau_emplacement'] = _emplacementCtrl.text;
              }
            }),
            fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
              controller: controller, focusNode: focusNode,
              decoration: InputDecoration(hintText: AppLocalizations.of(context).searchExistingProductHint),
            ),
          ),
          const SizedBox(height: 6),
          TextField(controller: _emplacementCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).lotLocationPrefilledLabel),
            onChanged: (v) => widget.data['nouveau_emplacement'] = v),
        ] else ...[
          TextField(
            controller: _designationCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).newProductNameLabel),
            onChanged: (v) => widget.data['designation'] = v,
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _categorieCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).formCategory),
              onChanged: (v) => widget.data['nouveau_categorie'] = v)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _codeBarreCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).barcodeLabel),
              onChanged: (v) => widget.data['nouveau_code_barre'] = v)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: TextField(controller: _uniteMesureCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).unitLabel),
              onChanged: (v) => widget.data['nouveau_unite_mesure'] = v)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _seuilCritiqueCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).criticalThresholdLabel), keyboardType: TextInputType.number,
              onChanged: (v) => widget.data['nouveau_seuil_critique'] = v)),
          ]),
          const SizedBox(height: 6),
          TextField(controller: _emplacementCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).locationLabel),
            onChanged: (v) => widget.data['nouveau_emplacement'] = v),
        ],
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextField(
            controller: _designationCtrl,
            enabled: false,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).designationRetainedLabel),
          )),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: TextField(
            controller: _quantiteCtrl,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).qtyStarLabel,
              errorText: quantiteVide ? AppLocalizations.of(context).requiredLabel : null,
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
            controller: _prixTotalCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).lineTotalPriceLabel),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              widget.data['prix_total_ligne'] = v;
              final total = double.tryParse(v) ?? 0;
              final qte = double.tryParse(_quantiteCtrl.text) ?? 0;
              if (total > 0 && qte > 0) {
                setState(() => _prixAchatCtrl.text = (total / qte).toStringAsFixed(4));
                widget.data['prix_unitaire'] = _prixAchatCtrl.text;
              }
            },
          )),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            controller: _prixAchatCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context).unitPriceCalcLabel),
            keyboardType: TextInputType.number,
            onChanged: (v) => widget.data['prix_unitaire'] = v,
          )),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: _prixVenteCtrl,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).salePriceOptionalLabel), keyboardType: TextInputType.number,
          onChanged: (v) => widget.data['prix_vente'] = v,
        ),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: InkWell(
            onTap: () => _pickDate(context, 'date_fabrication'),
            child: InputDecorator(decoration: InputDecoration(labelText: AppLocalizations.of(context).manufacturingLabel),
              child: Text(widget.data['date_fabrication'] as String? ?? '—', style: const TextStyle(fontSize: 12))),
          )),
          const SizedBox(width: 8),
          Expanded(child: InkWell(
            onTap: () => _pickDate(context, 'date_expiration'),
            child: InputDecorator(decoration: InputDecoration(labelText: AppLocalizations.of(context).expirationLabel),
              child: Text(widget.data['date_expiration'] as String? ?? '—', style: const TextStyle(fontSize: 12))),
          )),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: _lotFournisseurCtrl,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).manufacturerLotLabel),
          onChanged: (v) => widget.data['numero_lot_fournisseur'] = v,
        ),
      ]),
    );
  }
}

void _showCompleterModificationDialog(BuildContext context, InvoiceController ctrl, Invoice facture) async {
  final lignesResult = await InvoiceRepositoryImpl().getLignes(facture.id);
  final lignesExistantes = lignesResult.fold((_) => <LigneFacture>[], (l) => l);

  final fournisseurCtrl = TextEditingController(text: facture.supplierName);
  DateTime factureDate = facture.date;
  final htCtrl = TextEditingController(text: facture.amountHt.toString());
  final tvaCtrl = TextEditingController(text: facture.amountTva.toString());
  final ttcCtrl = TextEditingController(text: facture.amountTtc.toString());
  final lignes = lignesExistantes.isNotEmpty
      ? lignesExistantes.map((l) => <String, dynamic>{
          'produit_id': l.produitId,
          'designation': l.produitNom,
          'quantite': l.quantite.toString(),
          'prix_unitaire': l.prixUnitaire.toString(),
          'prix_vente': l.prixVente?.toString() ?? '',
          'date_fabrication': l.dateFabrication,
          'date_expiration': l.dateExpiration,
          'numero_lot_fournisseur': l.numeroLotFournisseur ?? '',
          'nouveau_categorie': l.nouveauCategorie ?? '',
          'nouveau_code_barre': l.nouveauCodeBarre ?? '',
          'nouveau_unite_mesure': l.nouveauUniteMesure ?? '',
          'nouveau_seuil_critique': l.nouveauSeuilCritique?.toString() ?? '',
          'nouveau_emplacement': l.nouveauEmplacement ?? '',
        }).toList()
      : <Map<String, dynamic>>[_ligneVide()];
  bool isSubmitting = false;

  final t = AppLocalizations.of(context);
  Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text('${t.correctInvoiceTitlePrefix}${facture.id}'),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: fournisseurCtrl, decoration: InputDecoration(labelText: t.supplierClientLabel)),
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
          decoration: InputDecoration(labelText: t.invoiceDateLabel),
          child: Text('${factureDate.year}-${factureDate.month.toString().padLeft(2, '0')}-${factureDate.day.toString().padLeft(2, '0')}'),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: TextField(controller: htCtrl, decoration: InputDecoration(labelText: t.amountHtLabel), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: tvaCtrl, decoration: InputDecoration(labelText: t.tvaLabel), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextField(controller: ttcCtrl, decoration: InputDecoration(labelText: t.amountTtcLabel), keyboardType: TextInputType.number)),
      ]),
      const Divider(height: 28),
      SectionTitle(title: t.correctedArticlesTitle),
      const SizedBox(height: 8),
      ...lignes.asMap().entries.map((entry) => _LigneManuelleRow(
        data: entry.value,
        onRemove: lignes.length > 1 ? () => setState(() => lignes.removeAt(entry.key)) : null,
        onChanged: () => setState(() {}),
      )),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        icon: const Icon(Icons.add), label: Text(t.addArticleButton),
        onPressed: () => setState(() => lignes.add(_ligneVide())),
      )),
    ]))),
    actions: [
      TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
      ElevatedButton(
        onPressed: isSubmitting ? null : () async {
          if (fournisseurCtrl.text.trim().isEmpty) {
            AppToast.warning(t.supplierRequiredTitle, t.supplierRequiredMsg);
            return;
          }
          if (lignes.any((l) => (double.tryParse(l['quantite'] as String? ?? '') ?? 0) <= 0)) {
            AppToast.warning(t.qtyMissingTitle, t.qtyMissingMsg);
            return;
          }
          setState(() => isSubmitting = true);
          final lignesPourEnvoi = lignes.map((l) => {
            'produit_id': l['produit_id'],
            'designation': l['designation'],
            'quantite': double.tryParse(l['quantite'] as String? ?? '') ?? 0,
            'prix_unitaire': double.tryParse(l['prix_unitaire'] as String? ?? '') ?? 0,
            'prix_total_ligne': (l['prix_total_ligne'] as String?)?.isNotEmpty == true
                ? double.tryParse(l['prix_total_ligne'] as String) : null,
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
          if (ok) {
            await safeBack();
            AppToast.success(t.invoiceCorrectedTitle, t.invoiceCorrectedMsg);
          } else {
            setState(() => isSubmitting = false);
            AppToast.error(t.correctionFailedTitle, t.correctionFailedMsg);
          }
        },
        child: Text(t.sendCorrectionButton),
      ),
    ],
  )));
}



void _showVerifierOcrDialog(BuildContext context, InvoiceController ctrl, Invoice facture) async {
  final lignesResult = await InvoiceRepositoryImpl().getLignes(facture.id);
  final lignes = lignesResult.fold((_) => <LigneFacture>[], (l) => l);
  final stockCtrl = Get.find<StockController>();

  String _dernierEmplacement(int? produitId) {
    if (produitId == null) return '';
    final produit = stockCtrl.products.firstWhereOrNull((p) => p.id == produitId);
    if (produit == null || produit.lots.isEmpty) return '';
    final dernierLot = produit.lots.reduce((a, b) => a.id > b.id ? a : b);
    return dernierLot.emplacement ?? '';
  }

  final emplacementCtrls = {
    for (var l in lignes)
      l.id: TextEditingController(text: l.nouveauEmplacement ?? _dernierEmplacement(l.produitId)),
  };

  final t = AppLocalizations.of(context);
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text('${t.verifyOcrTitlePrefix}${facture.id}'),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _champLectureSeule(t.pdfHeaderSupplier, facture.supplierName),
      _champLectureSeule(t.pdfHeaderDate, '${facture.date.year}-${facture.date.month.toString().padLeft(2, '0')}-${facture.date.day.toString().padLeft(2, '0')}'),
      _champLectureSeule(t.invoiceAmountTtc, formatDA(facture.amountTtc)),
      const Divider(height: 24),
      SectionTitle(title: t.ocrDetectedArticlesTitle),
      const SizedBox(height: 8),
      ...lignes.map((l) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.produitNom, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${t.poQuantityShort} ${l.quantite}${t.puLabel} ${formatDA(l.prixUnitaire)}${l.dateExpiration != null ? '${t.expInlineLabel} ${l.dateExpiration}' : ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: emplacementCtrls[l.id],
            decoration: InputDecoration(
              labelText: l.produitId == null
                  ? t.newProductLocationHint
                  : t.lotLocationPrefilledLabel,
              isDense: true,
            ),
          ),
        ]),
      )),
    ]))),
    actions: [
      TextButton(
        onPressed: () async {
          final payload = lignes.map((l) => {
            'id': l.id,
            'emplacement': emplacementCtrls[l.id]?.text.trim().isEmpty == true ? null : emplacementCtrls[l.id]?.text.trim(),
          }).toList();
          await ctrl.enregistrerEmplacementsOcr(facture.id, payload);
          await safeBack();
          _showSignalerErreurDialog(context, ctrl, facture);
        },
        child: Text(t.reportErrorButton, style: const TextStyle(color: AppColors.danger)),
      ),
      TextButton(
        onPressed: () async {
          final payload = lignes.map((l) => {
            'id': l.id,
            'emplacement': emplacementCtrls[l.id]?.text.trim().isEmpty == true ? null : emplacementCtrls[l.id]?.text.trim(),
          }).toList();
          final ok = await ctrl.enregistrerEmplacementsOcr(facture.id, payload);
          if (ok) {
            AppToast.success(t.locationsSavedTitle, t.locationsSavedMsg);
          }
        },
        child: Text(t.saveLocationsButton),
      ),
      ElevatedButton(
        onPressed: () async {
          final payload = lignes.map((l) => {
            'id': l.id,
            'emplacement': emplacementCtrls[l.id]?.text.trim().isEmpty == true ? null : emplacementCtrls[l.id]?.text.trim(),
          }).toList();
          final ok = await ctrl.confirmerOcr(facture.id, payload);
          await safeBack();
          if (ok) {
            AppToast.success(t.invoiceConfirmedTitle, t.invoiceConfirmedMsg);
          }
        },
        child: Text(t.confirmButtonWord),
      ),
    ],
  ));
}


String _formatEcarts(AppLocalizations t, List<dynamic> ecarts) {
  return ecarts.map((e) {
    final map = e as Map<String, dynamic>;
    if (map['type'] == 'fournisseur_different') {
      return t.ecartFournisseurDifferent('${map['commande']}', '${map['recu']}');
    } else if (map['type'] == 'produit_non_commande') {
      return t.ecartProduitNonCommande('${map['designation']}', '${map['quantite_recue']}');
    } else if (map['type'] == 'produit_manquant') {
      return t.ecartProduitManquant('${map['designation']}', '${map['quantite_commandee']}');
    } else {
      final details = <String>[];
      if (map['quantite'] != null) {
        details.add(t.ecartQuantiteDetail('${map['quantite']['commandee']}', '${map['quantite']['recue']}'));
      }
      if (map['prix_unitaire'] != null) {
        details.add(t.ecartPrixDetail('${map['prix_unitaire']['estime']}', '${map['prix_unitaire']['recu']}'));
      }
      return t.ecartGenericPrefix('${map['designation']}', details.join(', '));
    }
  }).join('\n');
}

void _showEcartASignalerDialog(BuildContext context, InvoiceController ctrl, Invoice facture) {
  final t = AppLocalizations.of(context);
  final compteRenduCtrl = TextEditingController();
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text('${t.gapsDetectedTitlePrefix}${facture.id}'),
    content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_formatEcarts(t, facture.ecartsBc ?? []), style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 16),
      TextField(controller: compteRenduCtrl, maxLines: 4,
        decoration: InputDecoration(labelText: t.yourCommentLabel)),
    ]))),
    actions: [
      TextButton(onPressed: () => safeBack(), child: Text(t.close)),
      ElevatedButton(
        onPressed: () async {
          if (compteRenduCtrl.text.trim().isEmpty) return;
          final ok = await ctrl.envoyerEcart(facture.id, compteRenduCtrl.text.trim());
          await safeBack();
          if (ok) {
            AppToast.warning(t.sentTitle, t.sentAwaitingAdminMsg);
          }
        },
        child: Text(t.sendToAdminButton),
      ),
    ],
  ));
}

void _showSignalerErreurDialog(BuildContext context, InvoiceController ctrl, Invoice facture) {
  final t = AppLocalizations.of(context);
  final compteRenduCtrl = TextEditingController();
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(t.reportErrorTitle),
    content: SizedBox(width: 420, child: TextField(
      controller: compteRenduCtrl, maxLines: 4,
      decoration: InputDecoration(labelText: t.describeErrorLabel),
    )),
    actions: [
      TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
      ElevatedButton(
        onPressed: () async {
          if (compteRenduCtrl.text.trim().isEmpty) return;
          final ok = await ctrl.signalerErreurOcr(facture.id, compteRenduCtrl.text.trim());
          await safeBack();
          if (ok) {
            AppToast.warning(t.requestSentTitle, t.requestSentMsg);
          }
        },
        child: Text(t.sendRequestButton),
      ),
    ],
  ));
}

Widget _champLectureSeule(String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Row(children: [
    SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12))),
    Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
  ]),
);

void ouvrirNouvelleFacture(BuildContext context, InvoiceController ctrl) {
  final t = AppLocalizations.of(context);
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(t.newInvoiceTitle),
    content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _ChoixCard(
        icon: Icons.qr_code_scanner_rounded, title: t.fromPhoneOcrTitle,
        subtitle: t.fromPhoneOcrSubtitle,
        onTap: () async { await safeBack(); _choisirType(context, ctrl, viaOcr: true); },
      ),
      const SizedBox(height: 10),
      _ChoixCard(
        icon: Icons.edit_note_rounded, title: t.manualEntryTitle,
        subtitle: t.manualEntrySubtitle,
        onTap: () async { await safeBack(); _choisirType(context, ctrl, viaOcr: false); },
      ),
    ])),
  ));
}

void _choisirType(BuildContext context, InvoiceController ctrl, {required bool viaOcr}) {
  final t = AppLocalizations.of(context);
  final types = {
    'marchandise': t.filterTypeMerchandise, 'matiere_premiere': t.filterTypeRawMaterial,
    'produit_fini': t.filterTypeFinishedProduct, 'consommable': t.filterTypeConsumable,
  };
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(t.invoiceCategoryTitle),
    content: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min,
      children: types.entries.map((e) => _ChoixCard(
        icon: Icons.category_outlined, title: e.value, subtitle: '',
        onTap: () async {
          await safeBack();
          if (viaOcr) {
            _choisirBonCommandePourOcr(context, ctrl, e.key);
          } else {
            _showFactureManuelleDialog(context, ctrl, typeStockInitial: e.key);
          }
        },
      )).toList(),
    )),
  ));
}


void _choisirBonCommandePourOcr(BuildContext context, InvoiceController ctrl, String typeStock) {
  final t = AppLocalizations.of(context);
  final bcCtrl = Get.find<BonCommandeController>();
  bcCtrl.loadBonsOuverts(typeStock: typeStock);
  Get.dialog(Obx(() => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(t.poChoiceTitle),
    content: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _ChoixCard(icon: Icons.close_rounded, title: t.noneWord, subtitle: '',
        onTap: () async {
          await safeBack();
          Get.dialog(_AttenteAppairageDialog(typeStock: typeStock), barrierDismissible: false);
        }),
      ...bcCtrl.bonsCommandeOuverts.map((bc) => _ChoixCard(
        icon: Icons.description_outlined, title: bc.numeroBc, subtitle: bc.fournisseurNom ?? '',
        onTap: () async {
          final ok = await bcCtrl.reserver(bc.id);
          if (!ok) {
            AppToast.warning(t.poUnavailableTitle, t.poUnavailableMsg);
            return;
          }
          await safeBack();
          Get.dialog(_AttenteAppairageDialog(typeStock: typeStock, bonCommandeId: bc.id), barrierDismissible: false);
        },
      )),
    ])),
  )));
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
  final int? bonCommandeId;
  const _AttenteAppairageDialog({required this.typeStock, this.bonCommandeId});

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
        'bon_commande_id': widget.bonCommandeId,
      });
      setState(() {
        _code = response.data['code'] as String;
        _secondesRestantes = response.data['expire_dans_secondes'] as int;
      });
      _demarrerCompteARebours();
      _ecouterAppairage();
      _sondagePeriodique();
    } catch (_) {
      setState(() => _statut = 'erreur');
    }
  }

  int? _factureRecueId;
  Timer? _sondage;
  void _sondagePeriodique() {
    _sondage?.cancel();
    _sondage = Timer.periodic(const Duration(seconds: 2), (t) async {
      if (!mounted || _code == null || _statut == 'complete') { t.cancel(); return; }
      try {
        final r = await ApiClient.instance.dio.get(
          AppConfig.appairageGenerer.replaceAll('generer', '$_code/statut'));
        final statut = r.data['statut'] as String?;
        if (statut == 'scanne' && _statut == 'attente') {
          _timer?.cancel();
          setState(() => _statut = 'scanne');
        } else if (statut == 'complete' && _statut != 'complete') {
          t.cancel();
          _timer?.cancel();
          _factureRecueId = r.data['facture_id'] as int?;
          setState(() => _statut = 'complete');
        }
      } catch (_) {}
    });
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
        _timer?.cancel();
        setState(() => _statut = 'scanne');
      } else if (statut == 'complete' && _statut != 'complete') {
        _timer?.cancel();
        _factureRecueId = data['facture_id'] as int?;
        setState(() => _statut = 'complete');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sondage?.cancel();
    _wsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: Text(t.receiveFromPhoneTitle),
      content: SizedBox(width: 340, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_statut == 'expire') ...[
          const Icon(Icons.timer_off_rounded, size: 48, color: AppColors.warning),
          const SizedBox(height: 12),
          Text(t.codeExpiredTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SynButton(label: t.generateNewCodeButton, onTap: _genererCode),
        ] else if (_statut == 'erreur') ...[
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(t.serverConnectionError),
          const SizedBox(height: 12),
          SynButton(label: t.retry, onTap: _genererCode),
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
          if (_statut == 'attente')
            Text('${t.expiresInPrefix} ${_secondesRestantes}s', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
          const SizedBox(height: 14),
          if (_statut == 'attente')
            Text(t.mobileInstructions,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          if (_statut == 'scanne') ...[
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 28),
            const SizedBox(height: 6),
            Text(t.phoneConnectedMsg,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.success)),
          ],
          if (_statut == 'complete') ...[
            const Icon(Icons.task_alt_rounded, color: AppColors.success, size: 40),
            const SizedBox(height: 8),
            Text(t.invoiceReceivedMsg, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
          ],
        ],
      ])),
      actions: _statut == 'complete'
          ? [
              TextButton(onPressed: () => safeBack(), child: Text(t.laterButton)),
              ElevatedButton(
                onPressed: () async {
                  await safeBack();
                  final result = await InvoiceRepositoryImpl().getInvoice(_factureRecueId!);
                  result.fold((_) {}, (invoice) => _showVerifierOcrDialog(context, Get.find<InvoiceController>(), invoice));
                },
                child: Text(t.verifyInvoiceButton),
              ),
            ]
          : [TextButton(onPressed: () async {
              if (widget.bonCommandeId != null) Get.find<BonCommandeController>().liberer(widget.bonCommandeId!);
              await safeBack();
            }, child: Text(t.cancel))],
    );
  }
}