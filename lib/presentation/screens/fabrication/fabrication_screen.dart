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
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: t.fabPageTitle, actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: ctrl.loadAll),
        ]),
        TabBar(
          controller: _tab, isScrollable: true, labelColor: AppPalette.primary,
          tabs: [Tab(text: t.fabTabRecipes), Tab(text: t.fabTabOrders)],
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
    final t = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(alignment: Alignment.centerRight, child: SynButton(
        label: t.fabNewRecipe, icon: Icons.add_rounded,
        onTap: () => _showCreerBom(context),
      )),
      const SizedBox(height: 12),
      Expanded(child: Obx(() {
        if (ctrl.boms.isEmpty) {
          return Center(child: Text(t.fabNoRecipe, style: TextStyle(color: context.colors.textMuted)));
        }
        return ListView.separated(
          itemCount: ctrl.boms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final b = ctrl.boms[i];
            return SynCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.produitFiniNom ?? '${t.fabProductHashPrefix}${b.produitFiniId}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              ...b.lignes.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• ${l.quantiteNecessaire} ${l.composantUnite ?? ''} ${l.composantNom} ${t.fabPerUnitSuffix}'
                  '${l.tauxPerte > 0 ? ' ${t.fabLossSuffix} ${l.tauxPerte}%' : ''}',
                  style: const TextStyle(fontSize: 12)),
              )),
              const SizedBox(height: 8),
              SynButton(label: t.fabProduceFromRecipe, outline: true,
                onTap: () => _showCreerOF(context, b)),
            ]));
          },
        );
      })),
    ]);
  }

  void _showCreerBom(BuildContext context) {
    final t = AppLocalizations.of(context);
    int? produitFiniId;
    final composants = <Map<String, dynamic>>[];
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(t.fabNewRecipeDialogTitle),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            decoration: InputDecoration(labelText: t.fabFinishedProductLabel),
            items: stock.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
            onChanged: (v) => produitFiniId = v,
          ),
          const SizedBox(height: 12),
          ...composants.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(flex: 2, child: DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: t.fabComponentLabel),
                items: stock.products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => e.value['composant_produit_id'] = v,
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                decoration: InputDecoration(labelText: t.fabQtyPerUnitLabel),
                keyboardType: TextInputType.number,
                onChanged: (v) => e.value['quantite_necessaire'] = double.tryParse(v) ?? 0,
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                decoration: InputDecoration(labelText: t.fabLossPercentLabel),
                keyboardType: TextInputType.number,
                onChanged: (v) => e.value['taux_perte'] = double.tryParse(v) ?? 0,
              )),
            ]),
          )),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            icon: const Icon(Icons.add), label: Text(t.fabAddComponent),
            onPressed: () => setState(() => composants.add({})),
          )),
        ])),
        actions: [
          TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
          TextButton(onPressed: () async {
            if (produitFiniId == null || composants.isEmpty) return;
            ctrl.creerBom(produitFiniId: produitFiniId!, lignes: composants);
            await safeBack();
          }, child: Text(t.create)),
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

    final t = AppLocalizations.of(context);
    showDialog(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: Text('${t.fabProduceDialogTitlePrefix} ${bom.produitFiniNom ?? ''}'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (maxRealisable != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${t.fabMaxRealisablePrefix} $maxRealisable'
                '${goulot != null ? ' (${t.fabLimitedByPrefix} $goulot)' : ''}',
                style: const TextStyle(fontSize: 12, color: AppPalette.warning, fontWeight: FontWeight.w600),
              ),
            ),
          TextField(controller: qteCtrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: t.fabQtyProducedLabel)),
          const SizedBox(height: 10),
          TextField(controller: emplacementCtrl,
            decoration: InputDecoration(labelText: t.fabLocationOptionalLabel)),
          const SizedBox(height: 10),
          TextField(controller: numeroLotCtrl,
            decoration: InputDecoration(labelText: t.fabLotNumberOptionalLabel)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: dialogContext,
                initialDate: dateFabrication ?? DateTime.now(),
                firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => dateFabrication = picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(labelText: t.fabFabricationDateLabel),
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
              decoration: InputDecoration(labelText: t.fabExpirationDateLabel),
              child: Text(dateExpiration != null
                ? '${dateExpiration!.year}-${dateExpiration!.month.toString().padLeft(2, '0')}-${dateExpiration!.day.toString().padLeft(2, '0')}'
                : t.fabNotDefinedPick),
            ),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => safeBack(), child: Text(t.cancel)),
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
            await safeBack();
            r.fold(
              (e) => AppToast.error(t.errorTitle, e),
              (res) => AppToast.success(t.fabProductionRecordedTitle,
                '${t.fabLotWord} ${res['numero_lot']} ${t.fabUnitCostSuffix} ${res['cout_revient_unitaire']} DZD'),
            );
          }, child: Text(t.fabConfirmProduction)),
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
    final t = AppLocalizations.of(context);
    return Obx(() {
      if (ctrl.ordres.isEmpty) {
        return Center(child: Text(t.fabNoOrders, style: TextStyle(color: context.colors.textMuted)));
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
              Text('${t.fabQuantityColon} ${o.quantiteProduite} · ${t.fabLotColon} ${o.numeroLot ?? '—'}', style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${o.coutRevientTotal?.toStringAsFixed(2) ?? '—'} DZD', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('${o.coutRevientUnitaire?.toStringAsFixed(2) ?? '—'} ${t.fabPerUnitDzdSuffix}', style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
            ]),
          ]));
        },
      );
    });
  }
}