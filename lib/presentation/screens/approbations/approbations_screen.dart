import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';
import '../factures/facture_detail_screen.dart';

class ApprobationsScreen extends StatelessWidget {
  const ApprobationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InvoiceController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Confirmation des changements', actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: ctrl.loadDemandes),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Obx(() {
          final demandes = ctrl.demandes;
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
    final ctrl = Get.find<InvoiceController>();

    return SynCard(
      borderLeft: AppColors.warning,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Facture #${demande.factureId} — ${demande.factureFournisseur ?? "—"}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          )),
          if (demande.factureMontantTtc != null)
            Text('${demande.factureMontantTtc!.toStringAsFixed(2)} DA',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning)),
        ]),
        const SizedBox(height: 4),
        Text('Demandé par ${demande.demandeurNom ?? "—"}',
          style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
        const SizedBox(height: 12),
        const SectionTitle(title: 'COMPTE-RENDU'),
        const SizedBox(height: 4),
        Text(demande.compteRendu, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 14),
        Row(children: [
          TextButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: const Text('Voir la facture'),
            onPressed: () => Get.to(() => FactureDetailScreen(factureId: demande.factureId)),
          ),
          const Spacer(),
          SynButton(
            label: 'Refuser', outline: true, color: AppColors.danger,
            onTap: () => _refuser(context, ctrl, demande.id),
          ),
          const SizedBox(width: 10),
          SynButton(
            label: 'Approuver', color: AppColors.success,
            onTap: () => ctrl.approuverDemande(demande.id),
          ),
        ]),
      ]),
    );
  }

  void _refuser(BuildContext context, InvoiceController ctrl, int id) {
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Motif du refus'),
      content: TextField(controller: motifCtrl, maxLines: 3,
        decoration: const InputDecoration(hintText: 'Pourquoi refuser cette demande ?')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            if (motifCtrl.text.trim().isEmpty) return;
            ctrl.refuserDemande(id, motifCtrl.text.trim());
            Get.back();
          },
          child: const Text('Confirmer le refus'),
        ),
      ],
    ));
  }
}