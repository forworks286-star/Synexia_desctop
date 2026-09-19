import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
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
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: t.approvalsPageTitle, actions: [
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
                Text(t.gapCount(ctrl.facturesEcartAValider.length),
                  style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              ...ctrl.facturesEcartAValider.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Text('#${f.id} — ${f.supplierName}', style: const TextStyle(fontSize: 13))),
                  SynButton(label: t.examineButton, icon: Icons.fact_check_rounded,
                    onTap: () => _showEcartAValiderDialog(context, ctrl, f)),
                ]),
              )),
            ]),
          );
        }),
        Expanded(child: Obx(() {
          final demandes = ctrl.demandes;
          if (demandes.isEmpty) {
            return Center(child: Text(t.approvalsNoPending,
              style: TextStyle(color: context.colors.textMuted)));
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

void _showEcartAValiderDialog(BuildContext context, InvoiceController ctrl, Invoice facture) {
  final t = AppLocalizations.of(context);
  Get.dialog(AlertDialog(
    backgroundColor: context.colors.card,
    title: Text('${t.gapTitlePrefix}${facture.id}'),
    content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle(title: t.gapDetectedTitle),
      const SizedBox(height: 6),
      Text(_formatEcarts(t, facture.ecartsBc ?? []), style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 16),
      SectionTitle(title: t.gapCommentTitle),
      const SizedBox(height: 6),
      Text(facture.ecartCompteRendu ?? '—', style: const TextStyle(fontSize: 13)),
    ]))),
    actions: [
      TextButton(
        onPressed: () async {
          final ok = await ctrl.rejeterEcart(facture.id);
          await safeBack();
          if (ok) {
            AppToast.error(t.rejectedTitle, t.rejectedMsg);
          }
        },
        child: Text(t.rejectButton, style: const TextStyle(color: AppPalette.danger)),
      ),
      ElevatedButton(
        onPressed: () async {
          final ok = await ctrl.approuverEcart(facture.id);
          await safeBack();
          if (ok) {
            AppToast.success(t.approvedTitle, t.approvedMsg);
          }
        },
        child: Text(t.approveButton),
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
    final t = AppLocalizations.of(context);
    final ecartLie = ctrl.facturesEcartASignaler.any((f) => f.id == demande.factureId)
        || ctrl.facturesEcartAValider.any((f) => f.id == demande.factureId);

    return SynCard(
      borderLeft: ecartLie ? context.colors.textMuted : AppPalette.warning,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.edit_note_rounded, size: 18, color: AppPalette.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(
            '${t.invoiceHashPrefix}${demande.factureId} — ${demande.factureFournisseur ?? "—"}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          )),
          if (demande.factureMontantTtc != null)
            Text('${demande.factureMontantTtc!.toStringAsFixed(2)} DA',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppPalette.warning)),
        ]),
        const SizedBox(height: 4),
        Text('${t.requestedByPrefix} ${demande.demandeurNom ?? "—"}',
          style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
        const SizedBox(height: 12),
        SectionTitle(title: t.gapCommentTitle),
        const SizedBox(height: 4),
        Text(demande.compteRendu, style: const TextStyle(fontSize: 13)),
        if (ecartLie) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(t.gapLockNotice,
              style: const TextStyle(fontSize: 12, color: Colors.purple)),
          ),
        ],
        const SizedBox(height: 14),
        Row(children: [
          TextButton.icon(
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: Text(t.viewInvoiceButton),
            onPressed: () => Get.to(() => FactureDetailScreen(factureId: demande.factureId)),
          ),
          const Spacer(),
          SynButton(
            label: t.refuseButton, outline: true, color: AppPalette.danger,
            onTap: ecartLie ? null : () => _refuser(context, ctrl, demande.id),
          ),
          const SizedBox(width: 10),
          SynButton(
            label: t.approveButton, color: AppPalette.success,
            onTap: ecartLie ? null : () => ctrl.approuverDemande(demande.id),
          ),
        ]),
      ]),
    );
  }

  void _refuser(BuildContext context, InvoiceController ctrl, int id) {
    final t = AppLocalizations.of(context);
    final motifCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: context.colors.card,
      title: Text(t.refuseReasonTitle),
      content: TextField(controller: motifCtrl, maxLines: 3,
        decoration: InputDecoration(hintText: t.refuseReasonHint)),
      actions: [
        TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
        TextButton(
          onPressed: () async {
            if (motifCtrl.text.trim().isEmpty) return;
            ctrl.refuserDemande(id, motifCtrl.text.trim());
            await safeBack();
          },
          child: Text(t.confirmRefuseButton),
        ),
      ],
    ));
  }
}