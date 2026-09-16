import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../widgets/design_system/area_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final alerts = Get.find<AlertController>();
    final invoices = Get.find<InvoiceController>();
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: PageHeader(title: t.navDashboard)),
            SynButton(
              label: t.dashboardRefresh,
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
          Obx(() => _buildKpis(
                context,
                t,
                stock.stats.value,
                alerts.unreadCount.value,
                invoices.invoices.where((i) => i.status == InvoiceStatus.pending).length,
              )),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildMovementsChart(context, t, stock)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildAlertsPanel(context, t, alerts)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildCriticalStock(context, t, stock)),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildRecentMovements(context, t, stock)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpis(
    BuildContext context,
    AppLocalizations t,
    DashboardStats? s,
    int alertCount,
    int pendingInvoices,
  ) {
    final colors = context.colors;
    final valeur = s != null
        ? (s.valeurStockTotal >= 1000000
            ? '${(s.valeurStockTotal / 1000000).toStringAsFixed(1)}M'
            : s.valeurStockTotal >= 1000
                ? '${(s.valeurStockTotal / 1000).toStringAsFixed(0)}K'
                : s.valeurStockTotal.toStringAsFixed(0))
        : '--';
    return Row(children: [
      Expanded(child: KpiCard(value: s != null ? '${s.totalProducts}' : '--', label: t.homeProducts, icon: Icons.inventory_2_outlined)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: s != null ? '${s.todayEntries}' : '--', label: t.kpiEntriesToday, icon: Icons.arrow_downward_rounded, valueColor: colors.success)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: s != null ? '${s.todayExits}' : '--', label: t.kpiExitsToday, icon: Icons.arrow_upward_rounded, valueColor: colors.danger)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$alertCount', label: t.kpiActiveAlerts, icon: Icons.notifications_outlined, valueColor: alertCount > 0 ? colors.warning : null, trend: alertCount > 0 ? t.kpiUnread : null, trendUp: false)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$pendingInvoices', label: t.kpiPendingInvoices, icon: Icons.receipt_long_outlined, valueColor: pendingInvoices > 0 ? colors.warning : null)),
      const SizedBox(width: 14),
      Expanded(child: KpiCard(value: '$valeur DZD', label: t.kpiTotalStockValue, icon: Icons.account_balance_wallet_outlined, valueColor: colors.info)),
    ]);
  }

  Widget _buildMovementsChart(BuildContext context, AppLocalizations t, StockController stock) {
    final colors = context.colors;
    return Obx(() {
      final points = stock.chartPoints;
      final labels = points.map((p) {
        final parts = p.date.split('-');
        return parts.length == 3 ? '${parts[2]}/${parts[1]}' : p.date;
      }).toList();

      return SynCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SectionTitle(title: t.chartMovementsTitle),
              const SizedBox(width: 20),
              _Legend(color: colors.primary, label: t.homeEntries),
              const SizedBox(width: 12),
              _Legend(color: colors.success, label: t.homeExits),
            ]),
            const SizedBox(height: 20),
            SynAreaChart(
              xLabels: labels,
              series: [
                AreaChartSeries(label: t.homeEntries, color: colors.primary, values: points.map((p) => p.entrees.toDouble()).toList()),
                AreaChartSeries(label: t.homeExits, color: colors.success, values: points.map((p) => p.sorties.toDouble()).toList()),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAlertsPanel(BuildContext context, AppLocalizations t, AlertController alerts) {
    final colors = context.colors;
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: t.recentAlertsTitle,
            action: Obx(() => alerts.unreadCount.value > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: colors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text('${alerts.unreadCount.value}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.danger)),
                  )
                : const SizedBox.shrink()),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (alerts.alerts.isEmpty) {
              return Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(t.noAlerts, style: TextStyle(color: colors.textMuted, fontSize: 12))));
            }
            return Column(
              children: alerts.alerts.take(6).map((a) => _AlertRow(alert: a, onTap: () => alerts.markRead(a.id))).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCriticalStock(BuildContext context, AppLocalizations t, StockController stock) {
    final colors = context.colors;
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: t.criticalStockTitle),
          const SizedBox(height: 14),
          Obx(() {
            final critical = stock.products.where((p) => p.status != StockStatus.normal).take(5).toList();
            if (critical.isEmpty) return Center(child: Text(t.allNormal, style: TextStyle(color: colors.success, fontSize: 12)));
            return Column(
              children: critical.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: p.status == StockStatus.critical ? colors.danger : colors.warning,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    Expanded(child: Text(p.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text))),
                    Text('${p.stockQuantity}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.status == StockStatus.critical ? colors.danger : colors.warning)),
                  ],
                ),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentMovements(BuildContext context, AppLocalizations t, StockController stock) {
    final colors = context.colors;
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: t.recentMovementsTitle),
          const SizedBox(height: 14),
          Obx(() {
            if (stock.movements.isEmpty) return Center(child: Text(t.noMovements, style: TextStyle(color: colors.textMuted, fontSize: 12)));
            return Column(
              children: [
                Row(children: [
                  Expanded(child: Text(t.tableProduct, style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(width: 80, child: Text(t.tableQty, style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(width: 100, child: Text(t.tableType, style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                ]),
                const SizedBox(height: 8),
                ...stock.movements.take(6).map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(child: Text(m.productName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text))),
                      SizedBox(width: 80, child: Text(
                        m.type == MovementType.entry ? '+${m.quantity}' : '-${m.quantity}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: m.type == MovementType.entry ? colors.success : colors.danger),
                      )),
                      SizedBox(width: 100, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (m.type == MovementType.entry ? colors.success : colors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(m.type == MovementType.entry ? t.movementEntry : t.movementExit, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: m.type == MovementType.entry ? colors.success : colors.danger)),
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
    final colors = context.colors;
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: colors.textMuted)),
    ]);
  }
}

class _AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertRow({required this.alert, required this.onTap});

  Color _color(BuildContext context) {
    final colors = context.colors;
    switch (alert.level) {
      case AlertLevel.danger: return colors.danger;
      case AlertLevel.warning: return colors.warning;
      case AlertLevel.success: return colors.success;
      case AlertLevel.info: return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = _color(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: alert.isRead ? Colors.transparent : c.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: alert.isRead ? colors.border.withOpacity(0.6) : c.withOpacity(0.25)),
        ),
        child: Row(children: [
          AlertDot(level: alert.level),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert.title, style: TextStyle(fontSize: 11, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w700, color: colors.text)),
            Text(alert.message, style: TextStyle(fontSize: 10, color: colors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          Text(_timeAgo(alert.createdAt), style: TextStyle(fontSize: 9, color: colors.textMuted)),
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