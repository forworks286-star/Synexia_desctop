import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class ApprobationsScreen extends StatelessWidget {
  const ApprobationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceCtrl = Get.find<InvoiceController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Centre d\'approbations', actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: invoiceCtrl.loadDemandes),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Obx(() {
          final demandes = invoiceCtrl.demandes;
          if (demandes.isEmpty) {
            return const Center(child: Text('Aucune demande en attente',
              style: TextStyle(color: AppColors.darkTextMuted)));
          }
          return ListView.separated(
            itemCount: demandes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _DemandeCard(demande: demandes[i]),
          );
        })),
      ]),
    );
  }
}

class _DemandeCard extends StatelessWidget {
  final DemandeModification demande;
  const _DemandeCard({required this.demande});

  @override
  Widget build(BuildContext context) {
    final invoiceCtrl = Get.find<InvoiceController>();
    final estDateExpiration = demande.champConcerne.endsWith(':date_expiration');

    return SynCard(
      borderLeft: estDateExpiration ? AppColors.info : AppColors.warning,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(estDateExpiration ? Icons.event_busy_rounded : Icons.edit_note_rounded,
            size: 18, color: estDateExpiration ? AppColors.info : AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text('Facture #${demande.factureId} — ${demande.champConcerne}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          if (estDateExpiration)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: const Text('Lot déjà utilisable', style: TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _ValeurBox(label: 'Valeur actuelle', value: demande.valeurActuelle ?? '—')),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.darkTextMuted),
          const SizedBox(width: 10),
          Expanded(child: _ValeurBox(label: 'Valeur proposée', value: demande.valeurProposee ?? '—', highlight: true)),
        ]),
        const SizedBox(height: 10),
        const SectionTitle(title: 'COMPTE-RENDU'),
        const SizedBox(height: 4),
        Text(demande.compteRendu, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: SynButton(
            label: 'Refuser', outline: true, color: AppColors.danger,
            onTap: () => _refuser(context, invoiceCtrl, demande.id),
          )),
          const SizedBox(width: 10),
          Expanded(child: SynButton(
            label: 'Approuver', color: AppColors.success,
            onTap: () => invoiceCtrl.approuverDemande(demande.id),
          )),
        ]),
      ]),
    );
  }

  void _refuser(BuildContext context, InvoiceController ctrl, int id) {
    final motifCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Motif du refus'),
      content: TextField(controller: motifCtrl, maxLines: 3,
        decoration: const InputDecoration(hintText: 'Pourquoi refuser cette demande ?')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        TextButton(onPressed: () { ctrl.refuserDemande(id, motifCtrl.text); Get.back(); },
          child: const Text('Confirmer le refus')),
      ],
    ));
  }
}

class _ValeurBox extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _ValeurBox({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary.withOpacity(0.08) : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}