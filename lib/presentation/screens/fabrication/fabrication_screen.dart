import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../domain/models/models.dart';

class FabricationScreen extends StatefulWidget {
  const FabricationScreen({super.key});

  @override
  State<FabricationScreen> createState() => _FabricationScreenState();
}

class _FabricationScreenState extends State<FabricationScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ManufacturingController>();
    final stock = Get.find<StockController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: 'Fabrication (BOM & Ordres)', actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: ctrl.loadAll),
        ]),
        TabBar(
          controller: _tab, isScrollable: true, labelColor: AppColors.primary,
          tabs: const [Tab(text: 'Recettes (BOM)'), Tab(text: 'Ordres de fabrication')],
        ),
        const SizedBox(height: 16),
        Expanded(child: TabBarView(controller: _tab, children: [
          _BomTab(ctrl: ctrl, stock: stock),
          _OrdresTab(ctrl: ctrl),
        ])),
      ]),
    );
  }
}

class _BomTab extends StatelessWidget {
  final ManufacturingController ctrl;
  final StockController stock;
  const _BomTab({required this.ctrl, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(alignment: Alignment.centerRight, child: SynButton(
        label: 'Nouvelle recette', icon: Icons.add_rounded,
        onTap: () => _showCreerBom(context),
      )),
      const SizedBox(height: 12),
      Expanded(child: Obx(() {
        if (ctrl.boms.isEmpty) {
          return const Center(child: Text('Aucune recette definie', style: TextStyle(color: AppColors.darkTextMuted)));
        }
        return ListView.separated(
          itemCount: ctrl.boms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final b = ctrl.boms[i];
            return SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.produitFiniNom ?? 'Produit #${b.produitFiniId}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              ...b.lignes.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${l.quantiteNecessaire} ${l.composantUnite ?? ''} de ${l.composantNom} (par unite)',
                  style: const TextStyle(fontSize: 12)),
              )),
              const SizedBox(height: 8),
              SynButton(label: 'Produire à partir de cette recette', outline: true,
                onTap: () => _showCreerOF(context, b)),
            ]));
          },
        );
      })),
    ]);
  }

  void _showCreerBom(BuildContext context) {
    int? produitFiniId;
    final composants = <Map<String, dynamic>>[];
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text('Nouvelle recette (BOM)'),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Produit fini'),
            items: stock.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
            onChanged: (v) => produitFiniId = v,
          ),
          const SizedBox(height: 12),
          ...composants.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(flex: 2, child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Composant'),
                items: stock.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => e.value['composant_produit_id'] = v,
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                decoration: const InputDecoration(labelText: 'Quantité / unité'),
                keyboardType: TextInputType.number,
                onChanged: (v) => e.value['quantite_necessaire'] = double.tryParse(v) ?? 0,
              )),
            ]),
          )),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            icon: const Icon(Icons.add), label: const Text('Ajouter un composant'),
            onPressed: () => setState(() => composants.add({})),
          )),
        ])),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(onPressed: () {
            if (produitFiniId == null || composants.isEmpty) return;
            ctrl.creerBom(produitFiniId: produitFiniId!, lignes: composants);
            Get.back();
          }, child: const Text('Créer')),
        ],
      );
    }));
  }

  void _showCreerOF(BuildContext context, BomModel bom) {
    final qteCtrl = TextEditingController();
    final emplacementCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Produire : ${bom.produitFiniNom ?? ''}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: qteCtrl, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantité produite')),
        const SizedBox(height: 10),
        TextField(controller: emplacementCtrl,
          decoration: const InputDecoration(labelText: 'Emplacement (optionnel)')),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
        TextButton(onPressed: () async {
          final qte = double.tryParse(qteCtrl.text) ?? 0;
          if (qte <= 0) return;
          final r = await ctrl.creerOrdreFabrication(
            bomId: bom.id, quantiteProduite: qte,
            emplacement: emplacementCtrl.text.isEmpty ? null : emplacementCtrl.text,
          );
          Get.back();
          r.fold(
            (e) => Get.snackbar('Erreur', e, backgroundColor: AppColors.danger, colorText: Colors.white),
            (res) => Get.snackbar('Production enregistrée',
              'Lot ${res['numero_lot']} — coût unitaire ${res['cout_revient_unitaire']} DZD',
              backgroundColor: AppColors.success, colorText: Colors.white),
          );
        }, child: const Text('Confirmer la production')),
      ],
    ));
  }
}

class _OrdresTab extends StatelessWidget {
  final ManufacturingController ctrl;
  const _OrdresTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.ordres.isEmpty) {
        return const Center(child: Text('Aucun ordre de fabrication', style: TextStyle(color: AppColors.darkTextMuted)));
      }
      return ListView.separated(
        itemCount: ctrl.ordres.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final o = ctrl.ordres[i];
          return SynCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${o.numeroOf} — ${o.produitFiniNom ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Quantité : ${o.quantiteProduite} · Lot : ${o.numeroLot ?? '—'}', style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${o.coutRevientTotal?.toStringAsFixed(2) ?? '—'} DZD', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${o.coutRevientUnitaire?.toStringAsFixed(2) ?? '—'} DZD / unité', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
            ]),
          ]));
        },
      );
    });
  }
}