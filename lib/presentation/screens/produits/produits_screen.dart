import 'package:flutter/material.dart';
import '../qr/qr_a_imprimer_screen.dart';
import 'dart:typed_data';
import 'package:dartz/dartz.dart' hide State;
import '../../../data/repositories/stock_repository_impl.dart';
import 'package:get/get.dart';
import '../../../core/utils/get_safe_back.dart';
import '../../../core/widgets/app_toast.dart';

import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
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
    Get.find<AlertController>().markReadByType('stock');
    final t = AppLocalizations.of(context);
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _TypeFilterTabs(),
          PageHeader(
            title: t.homeProducts,
            actions: [
              SearchField(hint: t.searchProductHint, onChanged: (v) => stock.searchQuery.value = v),
              const SizedBox(width: 10),
              _FilterDropdown(stock: stock),
              const SizedBox(width: 10),
              _CategorieDropdown(stock: stock),
              const SizedBox(width: 10),
              Obx(() {
                final auth = Get.find<AuthController>();
                if (!auth.canEdit) return const SizedBox.shrink();
                return SynButton(label: t.addButton, icon: Icons.add_rounded, onTap: () => _showChoixAjout(stock));
              }),
              const SizedBox(width: 10),
              SynButton(label: t.dashboardRefresh, icon: Icons.refresh_rounded, onTap: stock.loadProducts, outline: true),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SynCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _TableHeader(),
                  Divider(height: 1, color: colors.border),
                  Expanded(
                    child: Obx(() {
                      if (stock.isLoading.value && stock.products.isEmpty) {
                        return Center(child: CircularProgressIndicator(color: AppPalette.primary));
                      }
                      final list = stock.filteredProducts;
                      if (list.isEmpty) {
                        return Center(child: Text(t.noProduct, style: TextStyle(color: colors.textMuted)));
                      }
                      return ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: colors.border),
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
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        const SizedBox(width: 16),
        _TH(label: t.tableProduct, flex: 3),
        _TH(label: t.thSku, flex: 2),
        _TH(label: t.thCategory, flex: 2),
        _TH(label: t.thStockAvailable, flex: 1),
        _TH(label: t.thValue, flex: 2),
        _TH(label: t.thStatus, flex: 1),
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
    final colors = context.colors;
    return Expanded(flex: flex, child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.textMuted, letterSpacing: 0.1)));
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  const _ProductRow({required this.product});

  Color get _dotColor {
    switch (product.status) {
      case StockStatus.normal: return AppPalette.success;
      case StockStatus.low: return AppPalette.warning;
      case StockStatus.critical: return AppPalette.danger;
    }
  }

  String _statusLabel(AppLocalizations t) {
    switch (product.status) {
      case StockStatus.normal: return t.statusNormal;
      case StockStatus.low: return t.statusLowShort;
      case StockStatus.critical: return t.statusCritical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = context.colors;
    return InkWell(
      onTap: () => _showDetail(product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(children: [
          Container(width: 5, height: 5, decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle), margin: const EdgeInsets.only(right: 10)),
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text)),
            Text(product.qrReference, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: colors.textMuted)),
          ])),
          Expanded(flex: 2, child: Text(product.sku, style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: colors.textMuted))),
          Expanded(flex: 2, child: Text(product.categorie ?? '—', style: TextStyle(fontSize: 12, color: colors.text))),
          Expanded(flex: 1, child: Text(
            '${product.stockDisponible}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: product.status == StockStatus.critical ? AppPalette.danger
                   : product.status == StockStatus.low ? AppPalette.warning : colors.text),
          )),
          Expanded(flex: 2, child: Text(
            formatDA(product.valeurStock),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text),
          )),
          Expanded(flex: 1, child: StatusChip(status: product.status, label: _statusLabel(t))),
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
    final t = AppLocalizations.of(context);
    final colors = context.colors;
    return Obx(() => DropdownButtonHideUnderline(
      child: DropdownButton<StockStatus?>(
        value: stock.statusFilter.value,
        hint: Text(t.filterAllStatus, style: TextStyle(fontSize: 12, color: colors.textMuted)),
        style: TextStyle(fontSize: 12, color: colors.text),
        dropdownColor: colors.card,
        items: [
          DropdownMenuItem(value: null, child: Text(t.filterAllStatus)),
          DropdownMenuItem(value: StockStatus.normal, child: Text(t.statusNormal)),
          DropdownMenuItem(value: StockStatus.low, child: Text(t.statusLow)),
          DropdownMenuItem(value: StockStatus.critical, child: Text(t.statusCritical)),
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
      final t = AppLocalizations.of(context);
      final colors = context.colors;
      return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: stock.categorieFilter.value.isEmpty ? null : stock.categorieFilter.value,
          hint: Text(t.filterCategoryHint, style: TextStyle(fontSize: 12, color: colors.textMuted)),
          style: TextStyle(fontSize: 12, color: colors.text),
          dropdownColor: colors.card,
          items: [
            DropdownMenuItem(value: null, child: Text(t.filterAllCategories)),
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
    final t = AppLocalizations.of(context);
    final colors = context.colors;
    final items = [
      (t.detailStockPhysical,    '${product.stockPhysique} ${product.uniteMesure}'),
      (t.detailStockAvailable,  '${product.stockDisponible} ${product.uniteMesure}'),
      (t.detailStockReserved,     '${product.stockReserve} ${product.uniteMesure}'),
      (t.detailCriticalThreshold,    '${product.alertThreshold}'),
      (t.detailPurchasePrice,        formatDA(product.prixAchat)),
      (t.detailSalePrice,        formatDA(product.prixVente)),
      (t.detailPmp,               formatDA(product.prixMoyenPondere)),
      (t.detailStockValue,      formatDA(product.valeurStock)),
      (t.detailTva,               '${product.tauxTva}%'),
      (t.formCategory,         product.categorie ?? '—'),
      (t.detailOriginCountry,      product.paysOrigine ?? '—'),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: items.map((item) => SizedBox(
        width: 210,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.$1, style: TextStyle(fontSize: 10, color: colors.textMuted,
            fontWeight: FontWeight.w600, letterSpacing: 0.08)),
          const SizedBox(height: 3),
          Text(item.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.text)),
        ]),
      )).toList(),
    );
  }
}

void _showDetail(Product product) {
    final t = AppLocalizations(Get.locale ?? const Locale('fr'));
    final colors = Get.context!.colors;
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
                style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: colors.textMuted)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              _DetailGrid(product: product),
              const SizedBox(height: 12),
              SynButton(
                label: t.viewPriceHistory,
                icon: Icons.show_chart_rounded,
                outline: true,
                onTap: () async {
                  await safeBack();
                  Get.to(() => HistoriqueProduitScreen(initialProduct: product));
                },
              ),
              if (product.lots.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(t.lotsTitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: colors.textMuted, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                ...product.lots.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(l.numeroLot ?? 'N/A', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                    Text('${l.quantiteDisponible} ${t.lotAvailable}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    if (l.emplacement != null)
                      Text('📍 ${l.emplacement}', style: TextStyle(fontSize: 11, color: colors.textMuted)),
                    if (l.dateExpiration != null) ...[
                      const SizedBox(width: 16),
                      Text('${t.lotExpiry} ${_fmtDate(l.dateExpiration!)}',
                        style: TextStyle(fontSize: 11,
                          color: l.dateExpiration!.isBefore(DateTime.now().add(const Duration(days: 30)))
                            ? AppPalette.danger : colors.textMuted)),
                    ] else ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.event_busy_rounded, size: 13, color: AppPalette.warning),
                    ],
                    IconButton(
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: AppPalette.primary),
                      tooltip: t.printLotQrTooltip,
                      onPressed: () => showLotQrDialog(l.id, l.numeroLot ?? '#${l.id}'),
                    ),
                  ]),
                )).toList(),
              ],
              if (product.champsExtra.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(t.extraFieldsTitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: colors.textMuted, letterSpacing: 0.12)),
                const SizedBox(height: 8),
                ...product.champsExtra.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Text('${e.key}:', style: TextStyle(fontSize: 11, color: colors.textMuted)),
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
  final t = AppLocalizations(Get.locale ?? const Locale('fr'));
  final colors = Get.context!.colors;
  Get.dialog(AlertDialog(
    backgroundColor: colors.card,
    title: Text(t.addProductTitle),
    content: Text(t.addProductChooseMode, style: const TextStyle(fontSize: 13)),
    actions: [
      TextButton(
        onPressed: () async { await safeBack(); _showAddProduitSimple(stock); },
        child: Text(t.addProductSheetOnly, textAlign: TextAlign.center),
      ),
      ElevatedButton(
        onPressed: () async { await safeBack(); _showAddProduitComplet(stock); },
        child: Text(t.addProductWithStock, textAlign: TextAlign.center),
      ),
    ],
  ));
}

void _showAddProduitSimple(StockController stock) {
  final t = AppLocalizations(Get.locale ?? const Locale('fr'));
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
          Expanded(child: Text(t.addProductSheetOnly.replaceAll('\n', ' '),
            style: TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, size: 18)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(controller: skuCtrl, decoration: InputDecoration(labelText: t.formSku))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: qrCtrl, decoration: InputDecoration(labelText: t.formQrCode))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: nomCtrl, decoration: InputDecoration(labelText: t.formProductName)),
        const SizedBox(height: 12),
        TextField(controller: categorieCtrl, decoration: InputDecoration(labelText: t.formCategory)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: typeStock,
          decoration: InputDecoration(labelText: t.formStockType),
          items: typeStockOptionsL10n(t).map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
          onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: prixAchatCtrl,
            decoration: InputDecoration(labelText: t.formPurchasePriceRef), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixVenteCtrl,
            decoration: InputDecoration(labelText: t.formSalePriceRef), keyboardType: TextInputType.number)),
        ]),
        if (errorMsg != null) ...[
          const SizedBox(height: 12),
          Text(errorMsg!, style: const TextStyle(color: AppPalette.danger, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: Get.back, child: Text(t.cancel)),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              if (skuCtrl.text.trim().isEmpty || nomCtrl.text.trim().isEmpty || qrCtrl.text.trim().isEmpty) {
                setState(() => errorMsg = t.errorSkuNameQrRequired);
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
                await safeBack();
                await stock.loadProducts();
                AppToast.success(t.toastSuccess, t.toastProductSheetCreated);
              } catch (e) {
                setState(() => errorMsg = t.errorSkuQrUsed);
              }
            },
            child: Text(t.create),
          ),
        ]),
      ]),
    ),
  )));
}

void _showAddProduitComplet(StockController stock) {
  final t = AppLocalizations(Get.locale ?? const Locale('fr'));
  final colors = Get.context!.colors;
  final fournisseurCtrl = TextEditingController();
  final paysOrigineCtrl = TextEditingController();
  final nifCtrl = TextEditingController();
  final nisCtrl = TextEditingController();
  final rcCtrl = TextEditingController();
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
          Expanded(child: Text(t.productFullTitle,
            style: const TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700))),
          IconButton(onPressed: Get.back, icon: const Icon(Icons.close_rounded, size: 18)),
        ]),
        const SizedBox(height: 8),
        Text(t.productFullSubtitle,
          style: TextStyle(fontSize: 11, color: colors.textMuted)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(controller: skuCtrl, decoration: InputDecoration(labelText: t.formSku))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: qrCtrl, decoration: InputDecoration(labelText: t.formQrCode))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: nomCtrl, decoration: InputDecoration(labelText: t.formProductName)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: categorieCtrl, decoration: InputDecoration(labelText: t.formCategory))),
          const SizedBox(width: 12),
          Expanded(child: DropdownButtonFormField<String>(
            value: typeStock,
            decoration: InputDecoration(labelText: t.formStockType),
            items: typeStockOptionsL10n(t).map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2))).toList(),
            onChanged: (v) => setState(() => typeStock = v ?? 'marchandise'),
          )),
        ]),

        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: fournisseurCtrl,
            decoration: InputDecoration(labelText: t.formSupplier))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: paysOrigineCtrl,
            decoration: InputDecoration(labelText: t.formOriginCountry))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: nifCtrl,
            decoration: InputDecoration(labelText: t.formSupplierNif))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: nisCtrl,
            decoration: InputDecoration(labelText: t.formSupplierNis))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: rcCtrl,
            decoration: InputDecoration(labelText: t.formSupplierRc))),
        ]),
        
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextField(controller: prixAchatCtrl,
            decoration: InputDecoration(labelText: t.detailPurchasePrice), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: prixVenteCtrl,
            decoration: InputDecoration(labelText: t.detailSalePrice), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: seuilCtrl,
            decoration: InputDecoration(labelText: t.detailCriticalThreshold), keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        TextField(controller: stockInitialCtrl,
          decoration: InputDecoration(labelText: t.formInitialQty), keyboardType: TextInputType.number),
        if (errorMsg != null) ...[
          const SizedBox(height: 12),
          Text(errorMsg!, style: const TextStyle(color: AppPalette.danger, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: Get.back, child: Text(t.cancel)),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () async {
              if (skuCtrl.text.trim().isEmpty || nomCtrl.text.trim().isEmpty || qrCtrl.text.trim().isEmpty) {
                setState(() => errorMsg = t.errorSkuNameQrRequired);
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
                'fournisseur_nom': fournisseurCtrl.text.trim().isEmpty ? null : fournisseurCtrl.text.trim(),
                'pays_origine': paysOrigineCtrl.text.trim().isEmpty ? null : paysOrigineCtrl.text.trim(),
                'fournisseur_nif': nifCtrl.text.trim().isEmpty ? null : nifCtrl.text.trim(),
                'fournisseur_nis': nisCtrl.text.trim().isEmpty ? null : nisCtrl.text.trim(),
                'fournisseur_rc': rcCtrl.text.trim().isEmpty ? null : rcCtrl.text.trim(),
              });
              r.fold(
                (e) => setState(() => errorMsg = e),
                (_) async {
                  await safeBack();
                  await stock.loadProducts();
                  AppToast.success(t.toastSuccess, t.toastProductInvoiceCreated);
                },
              );
            },
            child: Text(t.create),
          ),
        ]),
      ]),
    ),
  )));
}

void _showLotQr(int lotId, String numeroLot) async {
    final t = AppLocalizations(Get.locale ?? const Locale('fr'));
    final colors = Get.context!.colors;
    Get.dialog(FutureBuilder<Either<String, Uint8List>>(
      future: StockRepositoryImpl().getLotQr(lotId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AlertDialog(content: SizedBox(height: 120,
            child: Center(child: CircularProgressIndicator())));
        }
        return snapshot.data!.fold(
          (e) => AlertDialog(title: Text(t.errorTitle), content: Text(e)),
          (bytes) => AlertDialog(
            title: Text('${t.qrLotTitle} $numeroLot'),
            content: SizedBox(width: 260, height: 300, child: Column(children: [
              Image.memory(bytes, width: 220, height: 220),
              const SizedBox(height: 10),
              Text(t.qrPrintInstruction,
                style: TextStyle(fontSize: 11, color: colors.textMuted), textAlign: TextAlign.center),
            ])),
            actions: [TextButton(onPressed: () => safeBack(), child: Text(t.close))],
          ),
        );
      },
    ));
  }



  class _TypeFilterTabs extends StatefulWidget {
  @override
  State<_TypeFilterTabs> createState() => _TypeFilterTabsState();
}

class _TypeFilterTabsState extends State<_TypeFilterTabs> {
  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final t = AppLocalizations.of(context);
    final options = {
      null: t.filterTypeAll, 'marchandise': t.filterTypeMerchandise, 'matiere_premiere': t.filterTypeRawMaterial,
      'produit_fini': t.filterTypeFinishedProduct, 'consommable': t.filterTypeConsumable,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => Wrap(spacing: 8, children: options.entries.map((e) {
        final selected = stock.typeStockFilter.value == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: selected,
          onSelected: (_) => stock.typeStockFilter.value = e.key,
        );
      }).toList())),
    );
  }
}