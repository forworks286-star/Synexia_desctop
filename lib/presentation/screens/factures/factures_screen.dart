import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../core/utils/formatters.dart';
import 'facture_detail_screen.dart';

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
              SynButton(label: 'Facture manuelle', icon: Icons.edit_note_rounded,
                onTap: () => _showFactureManuelleDialog(context, ctrl)),
            ],
          ),
          const SizedBox(height: 20),
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

void _showFactureManuelleDialog(BuildContext context, InvoiceController ctrl) {
  final fournisseurCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
  final htCtrl = TextEditingController();
  final tvaCtrl = TextEditingController();
  final ttcCtrl = TextEditingController();
  final motifCtrl = TextEditingController();
  String typeFacture = 'achat';

  Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: const Text('Nouvelle facture manuelle'),
    content: SizedBox(width: 440, child: Column(mainAxisSize: MainAxisSize.min, children: [
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
      DropdownButtonFormField<String>(
        value: typeFacture,
        decoration: const InputDecoration(labelText: 'Type'),
        items: const [
          DropdownMenuItem(value: 'achat', child: Text('Achat')),
          DropdownMenuItem(value: 'vente', child: Text('Vente')),
        ],
        onChanged: (v) => setState(() => typeFacture = v ?? 'achat'),
      ),
      const SizedBox(height: 10),
      TextField(controller: fournisseurCtrl, decoration: const InputDecoration(labelText: 'Fournisseur / Client')),
      const SizedBox(height: 10),
      TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)')),
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
    ])),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
      ElevatedButton(
        onPressed: () async {
          if (motifCtrl.text.trim().isEmpty || fournisseurCtrl.text.trim().isEmpty) return;
          final ok = await ctrl.creerFactureManuelle(
            fournisseurNom: fournisseurCtrl.text.trim(), date: dateCtrl.text.trim(),
            typeFacture: typeFacture,
            montantHt: double.tryParse(htCtrl.text) ?? 0,
            montantTva: double.tryParse(tvaCtrl.text) ?? 0,
            montantTtc: double.tryParse(ttcCtrl.text) ?? 0,
            motifCreationManuelle: motifCtrl.text.trim(),
          );
          Get.back();
          if (ok) {
            Get.snackbar('Facture créée', 'En attente de vérification par un administrateur',
              backgroundColor: AppColors.warning.withOpacity(0.1), colorText: AppColors.warning);
          }
        },
        child: const Text('Créer'),
      ),
    ],
  )));
}