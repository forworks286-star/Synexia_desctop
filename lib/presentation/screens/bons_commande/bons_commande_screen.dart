import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import '../../../core/widgets/app_toast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; 
import 'package:printing/printing.dart';
import '../../controllers/controllers.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../widgets/widgets.dart';

class BonsCommandeScreen extends StatelessWidget {
  const BonsCommandeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BonCommandeController>();
    ctrl.loadBonsOuverts();
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t.navPurchaseOrders, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SynButton(label: t.poNew, icon: Icons.add_rounded,
            onTap: () => _showCreerBC(context, ctrl)),
        ]),
        const SizedBox(height: 20),
        Expanded(child: Obx(() => ListView.builder(
          itemCount: ctrl.bonsCommandeOuverts.length,
          itemBuilder: (context, i) {
            final bc = ctrl.bonsCommandeOuverts[i];
            return Card(
              color: context.colors.card,
              child: ListTile(
                title: Text('${bc.numeroBc} — ${bc.fournisseurNom ?? t.poNoSupplier}'),
                subtitle: Text('${bc.typeStock} — ${bc.lignes.length} ${t.poArticlesSuffix}'),
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
    final t = AppLocalizations(Get.locale ?? const Locale('fr'));
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('${t.poCreatedPrefix} ${bc.numeroBc}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('${t.poSupplierColon} ${bc.fournisseurNom ?? "—"}'),
        pw.Text('${t.pdfStockTypeLabel} ${bc.typeStock}'),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: [t.poDesignation, t.poQuantity, t.poPriceEstimate, t.pdfHeaderTotal],
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
  final t = AppLocalizations.of(context);
  Get.dialog(AlertDialog(
    backgroundColor: context.colors.card,
    title: Text(bc.numeroBc),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${t.poSupplierColon} ${bc.fournisseurNom ?? "—"}'),
      Text('${t.poTypeColon} ${bc.typeStock}'),
      Text('${t.poStatusColon} ${bc.statut}'),
      const Divider(height: 24),
      ...bc.lignes.map((l) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('• ${l.designation} — ${t.poQuantityShort} ${l.quantite} — ${t.poPriceEstimateShort} ${l.prixUnitaireEstime}',
          style: const TextStyle(fontSize: 13)),
      )),
    ]))),
    actions: [
      TextButton(onPressed: () => safeBack(), child: Text(t.close)),
      ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf_rounded), label: const Text('PDF'),
        onPressed: () => _exporterPdf(bc),
      ),
    ],
  ));
}

  void _showCreerBC(BuildContext context, BonCommandeController ctrl) {
    final t = AppLocalizations.of(context);
    final fournisseurCtrl = TextEditingController();
    String typeStock = 'marchandise';
    final lignes = <Map<String, dynamic>>[{'designation': '', 'quantite': 0.0, 'prix_unitaire_estime': 0.0}];

    Get.dialog(StatefulBuilder(builder: (context, setState) => AlertDialog(
      backgroundColor: context.colors.card,
      title: Text(t.poNew),
      content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          value: typeStock,
          items: ['marchandise', 'matiere_premiere', 'produit_fini', 'consommable']
              .map((ts) => DropdownMenuItem(value: ts, child: Text(ts))).toList(),
          onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
          decoration: InputDecoration(labelText: t.formStockType),
        ),
        const SizedBox(height: 10),
        TextField(controller: fournisseurCtrl, decoration: InputDecoration(labelText: t.poSupplierOptional)),
        const SizedBox(height: 16),
        ...lignes.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(flex: 2, child: TextField(
              decoration: InputDecoration(labelText: t.poDesignation),
              onChanged: (v) => entry.value['designation'] = v,
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              decoration: InputDecoration(labelText: t.poQuantity),
              keyboardType: TextInputType.number,
              onChanged: (v) => entry.value['quantite'] = double.tryParse(v) ?? 0,
            )),
            const SizedBox(width: 8),
            Expanded(child: TextField(
              decoration: InputDecoration(labelText: t.poPriceEstimate),
              keyboardType: TextInputType.number,
              onChanged: (v) => entry.value['prix_unitaire_estime'] = double.tryParse(v) ?? 0,
            )),
          ]),
        )),
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(
          icon: const Icon(Icons.add), label: Text(t.poAddLine),
          onPressed: () => setState(() => lignes.add({'designation': '', 'quantite': 0.0, 'prix_unitaire_estime': 0.0})),
        )),
      ]))),
      actions: [
        TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
        ElevatedButton(onPressed: () async {
          final r = await ctrl.creerBonCommande(
            typeStock: typeStock,
            fournisseurNom: fournisseurCtrl.text.isEmpty ? null : fournisseurCtrl.text,
            lignes: lignes,
          );
          await safeBack();
          r.fold(
            (e) => AppToast.error(t.errorTitle, e),
            (bc) => AppToast.success(t.poCreatedTitle, '${t.poCreatedPrefix} ${bc.numeroBc} ${t.poCreatedSuffix}'),
          );
        }, child: Text(t.create)),
      ],
    )));
  }
}