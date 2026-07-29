import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart';
import '../../controllers/controllers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../widgets/widgets.dart';

class BonsCommandeScreen extends StatelessWidget {
  const BonsCommandeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BonCommandeController>();
    ctrl.loadBonsOuverts();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Bons de commande', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SynButton(label: 'Nouveau bon de commande', icon: Icons.add_rounded,
            onTap: () => _showCreerBC(context, ctrl)),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Obx(() => ListView.builder(
          itemCount: ctrl.bonsCommandeOuverts.length,
          itemBuilder: (context, i) {
            final bc = ctrl.bonsCommandeOuverts[i];
            return Card(
              color: AppColors.darkCard,
              child: ListTile(
                title: Text('${bc.numeroBc} — ${bc.fournisseurNom ?? "Sans fournisseur"}'),
                subtitle: Text('${bc.typeStock} — ${bc.lignes.length} article(s)'),
                onTap: () => _showDetailBC(context, bc),
                trailing: IconButton(
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  onPressed: () => _exporterPdf(bc),
                ),
              ),
            );
          },
        ))),
      ]),
    );
  }

  Future<void> _exporterPdf(BonCommande bc) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Bon de commande ${bc.numeroBc}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Fournisseur : ${bc.fournisseurNom ?? "—"}'),
        pw.Text('Type de stock : ${bc.typeStock}'),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: ['Désignation', 'Quantité', 'Prix estimé', 'Total'],
          data: bc.lignes.map((l) => [
            l.designation, l.quantite.toString(), l.prixUnitaireEstime.toStringAsFixed(2),
            (l.quantite * l.prixUnitaireEstime).toStringAsFixed(2),
          ]).toList(),
        ),
      ]),
    ));
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void _showDetailBC(BuildContext context, BonCommande bc) {
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: Text(bc.numeroBc),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fournisseur : ${bc.fournisseurNom ?? "—"}'),
      Text('Type : ${bc.typeStock}'),
      Text('Statut : ${bc.statut}'),
      const Divider(height: 24),
      ...bc.lignes.map((l) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('• ${l.designation} — Qté: ${l.quantite} — Prix estimé: ${l.prixUnitaireEstime}',
          style: const TextStyle(fontSize: 13)),
      )),
    ]))),
    actions: [
      TextButton(onPressed: () => Get.back(), child: const Text('Fermer')),
      ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF'),
        onPressed: () => _exporterPdf(bc),
      ),
    ],
  ));
}

  void _showCreerBC(BuildContext context, BonCommandeController ctrl) {
    final fournisseurCtrl = TextEditingController();
    String typeStock = 'marchandise';
    final lignes = <Map<String, dynamic>>[{'designation': '', 'quantite': 0.0, 'prix_unitaire_estime': 0.0}];

    Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Nouveau bon de commande'),
      content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          value: typeStock,
          items: ['marchandise', 'matiere_premiere', 'produit_fini', 'consommable']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
          decoration: const InputDecoration(labelText: 'Type de stock'),
        ),
        const SizedBox(height: 10),
        TextField(controller: fournisseurCtrl, decoration: const InputDecoration(labelText: 'Fournisseur (optionnel)')),
        const SizedBox(height: 16),
        ...lignes.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(flex: 2, child: TextField(
              decoration: const InputDecoration(labelText: 'Désignation'),
              onChanged: (v) => entry.value['designation'] = v,
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
              onChanged: (v) => entry.value['quantite'] = double.tryParse(v) ?? 0,
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              decoration: const InputDecoration(labelText: 'Prix estimé'),
              keyboardType: TextInputType.number,
              onChanged: (v) => entry.value['prix_unitaire_estime'] = double.tryParse(v) ?? 0,
            )),
          ]),
        )),
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(
          icon: const Icon(Icons.add), label: const Text('Ajouter une ligne'),
          onPressed: () => setState(() => lignes.add({'designation': '', 'quantite': 0.0, 'prix_unitaire_estime': 0.0})),
        )),
      ]))),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        ElevatedButton(onPressed: () async {
          final r = await ctrl.creerBonCommande(
            typeStock: typeStock,
            fournisseurNom: fournisseurCtrl.text.isEmpty ? null : fournisseurCtrl.text,
            lignes: lignes,
          );
          Get.back();
          r.fold(
            (e) => Get.snackbar('Erreur', e, backgroundColor: AppColors.danger, colorText: Colors.white),
            (bc) => Get.snackbar('Créé', 'Bon de commande ${bc.numeroBc} créé',
              backgroundColor: AppColors.success, colorText: Colors.white),
          );
        }, child: const Text('Créer')),
      ],
    )));
  }
}