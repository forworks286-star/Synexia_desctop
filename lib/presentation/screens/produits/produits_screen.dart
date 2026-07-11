import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../../data/services/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/formatters.dart';
import '../factures/facture_detail_screen.dart';
import '../historique/historique_produit_screen.dart';

class ProduitsScreen extends StatelessWidget {
  const ProduitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Produits',
            actions: [
              SearchField(hint: 'SKU, nom, référence...', onChanged: (v) => stock.searchQuery.value = v),
              const SizedBox(width: 10),
              _FilterDropdown(stock: stock),
              const SizedBox(width: 10),
              _CategorieDropdown(stock: stock),
              const SizedBox(width: 10),
              Obx(() {
                final auth = Get.find<AuthController>();
                if (!auth.canEdit) return const SizedBox.shrink();
                return SynButton(label: 'Ajouter', icon: Icons.add_rounded, onTap: () => _showChoixAjout(stock));
              }),
              const SizedBox(width: 10),
              SynButton(label: 'Actualiser', icon: Icons.refresh_rounded, onTap: stock.loadProducts, outline: true),
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
                      if (stock.isLoading.value && stock.products.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      final list = stock.filteredProducts;
                      if (list.isEmpty) {
                        return const Center(child: Text('Aucun produit', style: TextStyle(color: AppColors.darkTextMuted)));
                      }
                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _ProductRow(product: list[i]),
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
        const SizedBox(width: 16),
        _TH(label: 'PRODUIT', flex: 3),
        _TH(label: 'SKU', flex: 2),
        _TH(label: 'CATÉGORIE', flex: 2),
        _TH(label: 'STOCK DISPO', flex: 1),
        _TH(label: 'VALEUR', flex: 2),
        _TH(label: 'FOURNISSEUR', flex: 2),
        _TH(label: 'STATUT', flex: 1),
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

class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  Color get _dotColor {
    switch (product.status) {
      case StockStatus.normal: return AppColors.success;
      case StockStatus.low: return AppColors.warning;
      case StockStatus.critical: return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (product.status) {
      case StockStatus.normal: return 'Normal';
      case StockStatus.low: return 'Bas';
      case StockStatus.critical: return 'Critique';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle), margin: const EdgeInsets.only(right: 10)),
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(product.qrReference, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.darkTextMuted)),
          ])),
          Expanded(flex: 2, child: Text(product.sku, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.darkTextMuted))),
          Expanded(flex: 2, child: Text(product.categorie ?? '—', style: const TextStyle(fontSize: 12))),
          Expanded(flex: 1, child: Text(
            '${product.stockDisponible}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: product.status == StockStatus.critical ? AppColors.danger
                   : product.status == StockStatus.low ? AppColors.warning : null),
          )),
          Expanded(flex: 2, child: Text(
            formatDA(product.valeurStock),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          )),
          Expanded(flex: 2, child: Text(product.supplierName ?? '—', style: const TextStyle(fontSize: 12))),
          Expanded(flex: 1, child: StatusChip(status: product.status, label: _statusLabel)),
        ]),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final StockController stock;
  const _FilterDropdown({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonHideUnderline(
      child: DropdownButton<StockStatus?>(
        value: stock.statusFilter.value,
        hint: const Text('Tous les statuts', style: TextStyle(fontSize: 12)),
        style: const TextStyle(fontSize: 12),
        dropdownColor: AppColors.darkCard,
        items: const [
          DropdownMenuItem(value: null, child: Text('Tous les statuts')),
          DropdownMenuItem(value: StockStatus.normal, child: Text('Normal')),
          DropdownMenuItem(value: StockStatus.low, child: Text('Stock bas')),
          DropdownMenuItem(value: StockStatus.critical, child: Text('Critique')),
        ],
        onChanged: (v) => stock.statusFilter.value = v,
      ),
    ));
  }
}


class _CategorieDropdown extends StatelessWidget {
  final StockController stock;
  const _CategorieDropdown({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cats = stock.categories;
      if (cats.isEmpty) return const SizedBox.shrink();
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: stock.categorieFilter.value.isEmpty ? null : stock.categorieFilter.value,
          hint: const Text('Catégorie', style: TextStyle(fontSize: 12)),
          style: const TextStyle(fontSize: 12),
          dropdownColor: AppColors.darkCard,
          items: [
            const DropdownMenuItem(value: null, child: Text('Toutes catégories')),
            ...cats.map((c) => DropdownMenuItem(value: c, child: Text(c))),
          ],
          onChanged: (v) => stock.categorieFilter.value = v ?? '',
        ),
      );
    });
  }
}


class _DetailGrid extends StatelessWidget {
  final Product product;
  const _DetailGrid({required this.product});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Stock physique',    '${product.stockPhysique} ${product.uniteMesure}'),
      ('Stock disponible',  '${product.stockDisponible} ${product.uniteMesure}'),
      ('Stock réservé',     '${product.stockReserve} ${product.uniteMesure}'),
      ('Seuil critique',    '${product.alertThreshold}'),
      ('Prix achat',        formatDA(product.prixAchat)),
      ('Prix vente',        formatDA(product.prixVente)),
      ('PMP',               formatDA(product.prixMoyenPondere)),
      ('Valeur stock',      formatDA(product.valeurStock)),
      ('TVA',               '${product.tauxTva}%'),
      ('Catégorie',         product.categorie ?? '—'),
      ('Pays origine',      product.paysOrigine ?? '—'),
      ('Fournisseur',       product.supplierName ?? '—'),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: items.map((item) => SizedBox(
        width: 210,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.$1, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted,
            fontWeight: FontWeight.w600, letterSpacing: 0.08)),
          const SizedBox(height: 3),
          Text(item.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
    );
  }
}

void _showDetail(Product product) {
    Get.dialog(
      Dialog(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(product.name,
                  style: const TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700))),
                StatusChip(status: product.status, label: product.statutProduit),
                const SizedBox(width: 8),
                IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, size: 18)),
              ]),
              const SizedBox(height: 4),
              Text('SKU: ${product.sku}  ·  QR: ${product.qrReference}',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.darkTextMuted)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _DetailGrid(product: product),
              const SizedBox(height: 12),
              SynButton(
                label: 'Voir historique des prix',
                icon: Icons.show_chart_rounded,
                outline: true,
                onTap: () {
                  Get.back();
                  Get.to(() => HistoriqueProduitScreen(initialProduct: product));
                },
              ),
              if (product.lots.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('LOTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.darkTextMuted, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                ...product.lots.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(l.numeroLot ?? 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Text('${l.quantiteDisponible} dispo', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    if (l.emplacement != null)
                      Text('📍 ${l.emplacement}', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    if (l.dateExpiration != null) ...[
                      const SizedBox(width: 16),
                      Text('Exp: ${_fmtDate(l.dateExpiration!)}',
                        style: TextStyle(fontSize: 11,
                          color: l.dateExpiration!.isBefore(DateTime.now().add(const Duration(days: 30)))
                            ? AppColors.danger : AppColors.darkTextMuted)),
                    ],
                  ]),
                )).toList(),
              ],
              if (product.champsExtra.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('CHAMPS EXTRA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.darkTextMuted, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                ...product.champsExtra.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Text('${e.key}:', style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
                    const SizedBox(width: 8),
                    Text('${e.value}', style: const TextStyle(fontSize: 11)),
                  ]),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  

void _showChoixAjout(StockController stock) {
  Get.dialog(AlertDialog(
    backgroundColor: AppColors.darkCard,
    title: const Text('Ajouter un produit'),
    content: const Text('Choisissez le mode d\'ajout :', style: TextStyle(fontSize: 13)),
    actions: [
      TextButton(
        onPressed: () { Get.back(); _showAddProduitSimple(stock); },
        child: const Text('Fiche produit seulement\n(sans stock)', textAlign: TextAlign.center),
      ),
      ElevatedButton(
        onPressed: () { Get.back(); _showAddProduitComplet(stock); },
        child: const Text('Avec stock initial\n(facture automatique)', textAlign: TextAlign.center),
      ),
    ],
  ));
}

void _showAddProduitSimple(StockController stock) {
  final skuCtrl = TextEditingController();
  final nomCtrl = TextEditingController();
  final qrCtrl = TextEditingController();
  final categorieCtrl = TextEditingController();
  final prixAchatCtrl = TextEditingController(text: '0');
  final prixVenteCtrl = TextEditingController(text: '0');
  String typeStock = 'marchandise';
  String? errorMsg;

  Get.dialog(StatefulBuilder(builder: (context, setState) => Dialog(
    child: Container(
      width: 480,
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Fiche produit (sans stock)',
            style: TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, size: 18)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU *'))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: qrCtrl, decoration: const InputDecoration(labelText: 'QR Code *'))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom du produit *')),
        const SizedBox(height: 12),
        TextField(controller: categorieCtrl, decoration: const InputDecoration(labelText: 'Catégorie')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: typeStock,
          decoration: const InputDecoration(labelText: 'Type de stock'),
          items: typeStockOptions.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
          onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: prixAchatCtrl,
            decoration: const InputDecoration(labelText: 'Prix achat référence'), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixVenteCtrl,
            decoration: const InputDecoration(labelText: 'Prix vente référence'), keyboardType: TextInputType.number)),
        ]),
        if (errorMsg != null) ...[
          const SizedBox(height: 12),
          Text(errorMsg!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: Get.back, child: const Text('Annuler')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              if (skuCtrl.text.trim().isEmpty || nomCtrl.text.trim().isEmpty || qrCtrl.text.trim().isEmpty) {
                setState(() => errorMsg = 'SKU, Nom et QR Code sont obligatoires');
                return;
              }
              try {
                final dio = ApiClient.instance.dio;
                await dio.post(AppConfig.stockProduitsCreate, data: {
                  'sku': skuCtrl.text.trim(), 'nom': nomCtrl.text.trim(),
                  'qr_code': qrCtrl.text.trim(),
                  'categorie': categorieCtrl.text.trim().isEmpty ? null : categorieCtrl.text.trim(),
                  'type_stock': typeStock,
                  'prix_achat': double.tryParse(prixAchatCtrl.text) ?? 0,
                  'prix_vente': double.tryParse(prixVenteCtrl.text) ?? 0,
                  'unite_mesure': 'piece', 'devise': 'DZD', 'taux_tva': 19.0,
                });
                Get.back();
                await stock.loadProducts();
                Get.snackbar('Succès', 'Fiche produit créée (stock à 0, en attente de facture)',
                  backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
              } catch (e) {
                setState(() => errorMsg = 'Erreur — SKU ou QR Code déjà utilisé');
              }
            },
            child: const Text('Créer'),
          ),
        ]),
      ]),
    ),
  )));
}

void _showAddProduitComplet(StockController stock) {
  final skuCtrl = TextEditingController();
  final nomCtrl = TextEditingController();
  final qrCtrl = TextEditingController();
  final categorieCtrl = TextEditingController();
  final prixAchatCtrl = TextEditingController(text: '0');
  final prixVenteCtrl = TextEditingController(text: '0');
  final seuilCtrl = TextEditingController(text: '10');
  final stockInitialCtrl = TextEditingController(text: '0');
  String typeStock = 'marchandise';
  String? errorMsg;

  Get.dialog(StatefulBuilder(builder: (context, setState) => Dialog(
    child: Container(
      width: 520,
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Produit avec stock initial',
            style: TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, size: 18)),
        ]),
        const SizedBox(height: 8),
        const Text('Une facture d\'ajustement sera créée automatiquement pour tracer cette entrée.',
          style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU *'))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: qrCtrl, decoration: const InputDecoration(labelText: 'QR Code *'))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: nomCtrl, decoration: const InputDecoration(labelText: 'Nom du produit *')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: categorieCtrl, decoration: const InputDecoration(labelText: 'Catégorie'))),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(
            value: typeStock,
            decoration: const InputDecoration(labelText: 'Type de stock'),
            items: typeStockOptions.map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
            onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: prixAchatCtrl,
            decoration: const InputDecoration(labelText: 'Prix achat'), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixVenteCtrl,
            decoration: const InputDecoration(labelText: 'Prix vente'), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: seuilCtrl,
            decoration: const InputDecoration(labelText: 'Seuil critique'), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        TextField(controller: stockInitialCtrl,
          decoration: const InputDecoration(labelText: 'Quantité initiale *'), keyboardType: TextInputType.number),
        if (errorMsg != null) ...[
          const SizedBox(height: 12),
          Text(errorMsg!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: Get.back, child: const Text('Annuler')),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              if (skuCtrl.text.trim().isEmpty || nomCtrl.text.trim().isEmpty || qrCtrl.text.trim().isEmpty) {
                setState(() => errorMsg = 'SKU, Nom et QR Code sont obligatoires');
                return;
              }
              final r = await stock.ajoutManuelComplet({
                'sku': skuCtrl.text.trim(), 'nom': nomCtrl.text.trim(),
                'qr_code': qrCtrl.text.trim(),
                'categorie': categorieCtrl.text.trim().isEmpty ? null : categorieCtrl.text.trim(),
                'type_stock': typeStock,
                'prix_achat': double.tryParse(prixAchatCtrl.text) ?? 0,
                'prix_vente': double.tryParse(prixVenteCtrl.text) ?? 0,
                'seuil_critique': int.tryParse(seuilCtrl.text) ?? 10,
                'quantite_initiale': int.tryParse(stockInitialCtrl.text) ?? 0,
              });
              r.fold(
                (e) => setState(() => errorMsg = e),
                (_) async {
                  Get.back();
                  await stock.loadProducts();
                  Get.snackbar('Succès', 'Produit + facture d\'ajustement créés',
                    backgroundColor: AppColors.success.withOpacity(0.1), colorText: AppColors.success);
                },
              );
            },
            child: const Text('Créer'),
          ),
        ]),
      ]),
    ),
  )));
}

