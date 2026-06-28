import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final alerts = Get.find<AlertController>();
    final invoices = Get.find<InvoiceController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: PageHeader(title: 'Dashboard')),
            SynButton(
              label: 'Actualiser',
              icon: Icons.refresh_rounded,
              outline: true,
              onTap: () {
                Get.find<StockController>().loadAll();
                Get.find<InvoiceController>().loadInvoices();
                Get.find<AlertController>().loadAlerts();
              },
            ),
          ]),
          const SizedBox(height: 24),
          Obx(() => _buildKpis(stock.stats.value, alerts.unreadCount.value, invoices.invoices.where((i) => i.status == InvoiceStatus.pending).length)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildMovementsChart(stock)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildAlertsPanel(alerts)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildCriticalStock(stock)),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildRecentMovements(stock)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpis(DashboardStats? s, int alertCount, int pendingInvoices) {
    final valeur = s != null
        ? (s.valeurStockTotal >= 1000000
            ? '${(s.valeurStockTotal / 1000000).toStringAsFixed(1)}M'
            : s.valeurStockTotal >= 1000
                ? '${(s.valeurStockTotal / 1000).toStringAsFixed(0)}K'
                : s.valeurStockTotal.toStringAsFixed(0))
        : '--';
    return Row(children: [
      Expanded(child: KpiCard(value: s != null ? '${s.totalProducts}' : '--', label: 'Produits', icon: Icons.inventory_2_outlined)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: s != null ? '${s.todayEntries}' : '--', label: 'Entrées / auj.', icon: Icons.arrow_downward_rounded, valueColor: AppColors.success)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: s != null ? '${s.todayExits}' : '--', label: 'Sorties / auj.', icon: Icons.arrow_upward_rounded, valueColor: AppColors.danger)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$alertCount', label: 'Alertes actives', icon: Icons.notifications_outlined, valueColor: alertCount > 0 ? AppColors.warning : null, trend: alertCount > 0 ? 'non lues' : null, trendUp: false)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$pendingInvoices', label: 'Factures en attente', icon: Icons.receipt_long_outlined, valueColor: pendingInvoices > 0 ? AppColors.warning : null)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$valeur DZD', label: 'Valeur stock total', icon: Icons.account_balance_wallet_outlined, valueColor: AppColors.info)),
    ]);
  }

  Widget _buildMovementsChart(StockController stock) {
    return Obx(() {
      final points = stock.chartPoints;
      final barGroups = List.generate(points.length, (i) {
        final p = points[i];
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: p.entrees.toDouble(), color: AppColors.primary.withOpacity(0.8), width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          BarChartRodData(toY: p.sorties.toDouble(), color: AppColors.success.withOpacity(0.7), width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
        ]);
      });

      final labels = points.map((p) {
        final parts = p.date.split('-');
        return parts.length == 3 ? '${parts[2]}/${parts[1]}' : p.date;
      }).toList();

      

    return SynCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const SectionTitle(title: 'MOUVEMENTS — 7 DERNIERS JOURS'),
              const SizedBox(width: 20),
              _Legend(color: AppColors.primary, label: 'Entrées'),
              const SizedBox(width: 12),
              _Legend(color: AppColors.success, label: 'Sorties'),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: points.isEmpty
                  ? const Center(child: Text('Aucune donnée', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)))
                  : BarChart(BarChartData(
                      barGroups: barGroups,
                      gridData: FlGridData(
                        show: true, drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(color: AppColors.darkBorder.withOpacity(0.4), strokeWidth: 0.5),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(labels[i], style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted)),
                            );
                          },
                        )),
                        leftTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true, reservedSize: 28,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}',
                            style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted)),
                        )),
                        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppColors.darkCard,
                          getTooltipItem: (group, _, rod, rodIndex) => BarTooltipItem(
                            '${rodIndex == 0 ? "Entrées" : "Sorties"}: ${rod.toY.toInt()}',
                            const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    )),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAlertsPanel(AlertController alerts) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'ALERTES RÉCENTES',
            action: Obx(() => alerts.unreadCount.value > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${alerts.unreadCount.value}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.danger)),
                  )
                : const SizedBox.shrink()),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (alerts.alerts.isEmpty) {
              return const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('Aucune alerte', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12))));
            }
            return Column(
              children: alerts.alerts.take(6).map((a) => _AlertRow(alert: a, onTap: () => alerts.markRead(a.id))).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCriticalStock(StockController stock) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'STOCK CRITIQUE'),
          const SizedBox(height: 14),
          Obx(() {
            final critical = stock.products.where((p) => p.status != StockStatus.normal).take(5).toList();
            if (critical.isEmpty) return const Center(child: Text('Tout est normal', style: TextStyle(color: AppColors.success, fontSize: 12)));
            return Column(
              children: critical.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: p.status == StockStatus.critical ? AppColors.danger : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    Expanded(child: Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                    Text('${p.stockQuantity}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.status == StockStatus.critical ? AppColors.danger : AppColors.warning)),
                  ],
                ),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentMovements(StockController stock) {
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'DERNIERS MOUVEMENTS'),
          const SizedBox(height: 14),
          Obx(() {
            if (stock.movements.isEmpty) return const Center(child: Text('Aucun mouvement', style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)));
            return Column(
              children: [
                Row(children: [
                  Expanded(child: Text('PRODUIT', style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(width: 80, child: Text('QTÉ', style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(width: 100, child: Text('TYPE', style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                ]),
                const SizedBox(height: 8),
                ...stock.movements.take(6).map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(child: Text(m.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                      SizedBox(width: 80, child: Text(
                        m.type == MovementType.entry ? '+${m.quantity}' : '-${m.quantity}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: m.type == MovementType.entry ? AppColors.success : AppColors.danger),
                      )),
                      SizedBox(width: 100, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (m.type == MovementType.entry ? AppColors.success : AppColors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(m.type == MovementType.entry ? 'Entrée' : 'Sortie', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: m.type == MovementType.entry ? AppColors.success : AppColors.danger)),
                      )),
                    ],
                  ),
                )).toList(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
    ]);
  }
}

class _AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertRow({required this.alert, required this.onTap});

  Color get _color {
    switch (alert.level) {
      case AlertLevel.danger: return AppColors.danger;
      case AlertLevel.warning: return AppColors.warning;
      case AlertLevel.success: return AppColors.success;
      case AlertLevel.info: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: alert.isRead ? Colors.transparent : _color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: alert.isRead ? AppColors.darkBorder.withOpacity(0.3) : _color.withOpacity(0.2)),
        ),
        child: Row(children: [
          AlertDot(level: alert.level),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert.title, style: TextStyle(fontSize: 11, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w700)),
            Text(alert.message, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          Text(_timeAgo(alert.createdAt), style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted)),
        ]),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dt.day}/${dt.month}';
  }
}
