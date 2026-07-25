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
    ctrl.loadFacturesEcartAValider();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Confirmation des changements', actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () {
            ctrl.loadDemandes();
            ctrl.loadFacturesEcartAValider();
          }),
        ]),
        const SizedBox(height: 20),
        Obx(() {
          if (ctrl.facturesEcartAValider.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.rule_folder_rounded, color: Colors.purple, size: 18),
                const SizedBox(width: 8),
                Text('${ctrl.facturesEcartAValider.length} écart(s) bon de commande à valider',
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              ...ctrl.facturesEcartAValider.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Text('#${f.id} — ${f.supplierName}', style: const TextStyle(fontSize: 13))),
                  SynButton(label: 'Examiner', icon: Icons.fact_check_rounded,
                    onTap: () => _showEcartAValiderDialog(context, ctrl, f)),
                ]),
              )),
            ]),
          );
        }),
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

String _formatEcarts(List<dynamic> ecarts) {
  return ecarts.map((e) {
    final map = e as Map<String, dynamic>;
    if (map['type'] == 'fournisseur_different') {
      return '⚠ Fournisseur différent : commandé "${map['commande']}" → reçu "${map['recu']}"';
    } else if (map['type'] == 'produit_non_commande') {
      return '⚠ "${map['designation']}" reçu mais non commandé (qté: ${map['quantite_recue']})';
    } else if (map['type'] == 'produit_manquant') {
      return '⚠ "${map['designation']}" commandé (qté: ${map['quantite_commandee']}) mais non reçu';
    } else {
      final details = <String>[];
      if (map['quantite'] != null) {
        details.add('quantité commandée ${map['quantite']['commandee']} → reçue ${map['quantite']['recue']}');
      }
      if (map['prix_unitaire'] != null) {
        details.add('prix estimé ${map['prix_unitaire']['estime']} → reçu ${map['prix_unitaire']['recu']}');
      }
      return '⚠ "${map['designation']}" : ${details.join(', ')}';
    }
  }).join('\n');
}

void _showEcartAValiderDialog(BuildContext context, InvoiceController ctrl, Invoice facture) {
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text('Écart — Facture #${facture.id}'),
    content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionTitle(title: 'ÉCARTS DÉTECTÉS'),
      const SizedBox(height: 6),
      Text(_formatEcarts(facture.ecartsBc ?? []), style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 16),
      const SectionTitle(title: 'COMMENTAIRE'),
      const SizedBox(height: 6),
      Text(facture.ecartCompteRendu ?? '—', style: const TextStyle(fontSize: 13)),
    ]))),
    actions: [
      TextButton(
        onPressed: () async {
          final ok = await ctrl.rejeterEcart(facture.id);
          Get.back();
          if (ok) {
            Get.snackbar('Rejetée', 'La facture a été annulée',
              backgroundColor: AppColors.danger.withOpacity(0.1), colorText: AppColors.danger);
          }
        },
        child: const Text('Rejeter', style: TextStyle(color: AppColors.danger)),
      ),
      ElevatedButton(
        onPressed: () async {
          final ok = await ctrl.approuverEcart(facture.id);
          Get.back();
          if (ok) {
            Get.snackbar('Approuvé', 'La facture reprend son cours normal',
              backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
          }
        },
        child: const Text('Approuver'),
      ),
    ],
  ));
}

class _DemandeCard extends StatelessWidget {
  final DemandeModification demande;
  const _DemandeCard({required this.demande});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<InvoiceController>();
    final ecartLie = ctrl.facturesEcartASignaler.any((f) => f.id == demande.factureId)
        || ctrl.facturesEcartAValider.any((f) => f.id == demande.factureId);

    return SynCard(
      borderLeft: ecartLie ? AppColors.darkTextMuted : AppColors.warning,
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
        if (ecartLie) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: const Text('🔒 Réglez d\'abord l\'écart bon de commande de cette facture (voir ci-dessus)',
              style: TextStyle(fontSize: 12, color: Colors.purple)),
          ),
        ],
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
            onTap: ecartLie ? null : () => _refuser(context, ctrl, demande.id),
          ),
          const SizedBox(width: 10),
          SynButton(
            label: 'Approuver', color: AppColors.success,
            onTap: ecartLie ? null : () => ctrl.approuverDemande(demande.id),
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