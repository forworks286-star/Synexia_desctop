import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

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
              SearchField(hint: 'Rechercher un produit...', onChanged: (v) => stock.searchQuery.value = v),
              const SizedBox(width: 12),
              _FilterDropdown(stock: stock),
              const SizedBox(width: 12),
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
        _TH(label: 'PRODUIT', flex: 4),
        _TH(label: 'RÉFÉRENCE QR', flex: 3),
        _TH(label: 'STOCK', flex: 1),
        _TH(label: 'SEUIL', flex: 1),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle), margin: const EdgeInsets.only(right: 10)),
        Expanded(flex: 4, child: Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(flex: 3, child: Text(product.qrReference, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.darkTextMuted))),
        Expanded(flex: 1, child: Text(
          '${product.stockQuantity}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: product.status == StockStatus.critical ? AppColors.danger : product.status == StockStatus.low ? AppColors.warning : null),
        )),
        Expanded(flex: 1, child: Text('${product.alertThreshold}', style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted))),
        Expanded(flex: 2, child: Text(product.supplierName ?? '—', style: const TextStyle(fontSize: 12))),
        Expanded(flex: 1, child: StatusChip(status: product.status, label: _statusLabel)),
      ]),
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
