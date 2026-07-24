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
                child: Text('• ${l.quantiteNecessaire} ${l.composantUnite ?? ''} de ${l.composantNom} (par unite)'
                  '${l.tauxPerte > 0 ? ' — perte ${l.tauxPerte}%' : ''}',
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
              const SizedBox(width: 8),
              Expanded(child: TextField(
                decoration: const InputDecoration(labelText: '% perte'),
                keyboardType: TextInputType.number,
                onChanged: (v) => e.value['taux_perte'] = double.tryParse(v) ?? 0,
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

  void _showCreerOF(BuildContext context, BomModel bom) async {
    final qteCtrl = TextEditingController();
    final emplacementCtrl = TextEditingController();
    final numeroLotCtrl = TextEditingController();
    DateTime? dateFabrication = DateTime.now();
    DateTime? dateExpiration;
    int? maxRealisable;
    String? goulot;

    final maxResult = await ctrl.getMaxRealisable(bom.id);
    maxResult.fold((_) {}, (data) {
      maxRealisable = data['quantite_maximale'] as int?;
      goulot = data['goulot_etranglement'] as String?;
    });

    showDialog(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text('Produire : ${bom.produitFiniNom ?? ''}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (maxRealisable != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Quantité maximale réalisable avec le stock actuel : $maxRealisable'
                '${goulot != null ? ' (limité par : $goulot)' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ),
          TextField(controller: qteCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité produite')),
          const SizedBox(height: 10),
          TextField(controller: emplacementCtrl,
            decoration: const InputDecoration(labelText: 'Emplacement (optionnel)')),
          const SizedBox(height: 10),
          TextField(controller: numeroLotCtrl,
            decoration: const InputDecoration(labelText: 'Numéro de lot (optionnel)')),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: dialogContext,
                initialDate: dateFabrication ?? DateTime.now(),
                firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => dateFabrication = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date de fabrication'),
              child: Text(dateFabrication != null
                ? '${dateFabrication!.year}-${dateFabrication!.month.toString().padLeft(2, '0')}-${dateFabrication!.day.toString().padLeft(2, '0')}'
                : '—'),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: dialogContext,
                initialDate: DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => dateExpiration = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date de péremption (recommandé)'),
              child: Text(dateExpiration != null
                ? '${dateExpiration!.year}-${dateExpiration!.month.toString().padLeft(2, '0')}-${dateExpiration!.day.toString().padLeft(2, '0')}'
                : 'Non définie — appuyez pour choisir'),
            ),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          TextButton(onPressed: () async {
            final qte = double.tryParse(qteCtrl.text) ?? 0;
            if (qte <= 0) return;
            String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
            final r = await ctrl.creerOrdreFabrication(
              bomId: bom.id, quantiteProduite: qte,
              emplacement: emplacementCtrl.text.isEmpty ? null : emplacementCtrl.text,
              dateFabrication: dateFabrication != null ? fmt(dateFabrication!) : null,
              dateExpiration: dateExpiration != null ? fmt(dateExpiration!) : null,
              numeroLot: numeroLotCtrl.text.isEmpty ? null : numeroLotCtrl.text,
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
      ),
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