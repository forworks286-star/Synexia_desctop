import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/design/theme_extension.dart';
import '../../../core/design/radii.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';
import '../../widgets/design_system/area_chart.dart';
import '../../widgets/design_system/donut_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final alerts = Get.find<AlertController>();
    final invoices = Get.find<InvoiceController>();
    final auth = Get.find<AuthController>();
    final settings = Get.find<AppSettingsController>();
    final t = AppLocalizations.of(context);
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, t, stock, auth),
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
                    Expanded(flex: 2, child: _buildCategoryBreakdown(context, t, stock)),
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
          ),
        ),
        Container(width: 1, color: colors.border),
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickActions(context, t, auth, settings),
                const SizedBox(height: 20),
                _buildAlertsPanel(context, t, alerts, settings),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations t, StockController stock, AuthController auth) {
    final colors = context.colors;
    final today = DateFormat('d MMMM yyyy').format(DateTime.now());

    return Obx(() {
      final name = auth.user.value?.fullName.split(' ').first ?? '';
      final hasCritical = stock.products.any((p) => p.status == StockStatus.critical);
      final statusColor = hasCritical ? colors.warning : colors.success;
      final statusLabel = hasCritical ? t.stockStatusAlert : t.stockStatusOk;

      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${t.homeGreeting} $name 👋',
                    style: TextStyle(
                        fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w800, color: colors.text, letterSpacing: -0.4)),
                const SizedBox(height: 4),
                Text(t.dashboardSubtitle, style: TextStyle(fontSize: 13, color: colors.textMuted)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: colors.card, borderRadius: AppRadii.rMd, border: Border.all(color: colors.border)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: colors.textMuted),
              const SizedBox(width: 8),
              Text('${t.todayLabel}, $today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: AppRadii.rMd),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
            ]),
          ),
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
        ],
      );
    });
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

    final cards = <Widget>[
      KpiCard(value: s != null ? '${s.totalProducts}' : '--', label: t.homeProducts, icon: Icons.inventory_2_outlined),
      KpiCard(
          value: s != null ? '${s.todayEntries}' : '--',
          label: t.kpiEntriesToday,
          icon: Icons.arrow_downward_rounded,
          valueColor: colors.success),
      KpiCard(
          value: s != null ? '${s.todayExits}' : '--',
          label: t.kpiExitsToday,
          icon: Icons.arrow_upward_rounded,
          valueColor: colors.danger),
      KpiCard(
          value: '$alertCount',
          label: t.kpiActiveAlerts,
          icon: Icons.notifications_outlined,
          valueColor: alertCount > 0 ? colors.warning : null,
          trend: alertCount > 0 ? t.kpiUnread : null,
          trendUp: false),
      KpiCard(
          value: '$pendingInvoices',
          label: t.kpiPendingInvoices,
          icon: Icons.receipt_long_outlined,
          valueColor: pendingInvoices > 0 ? colors.warning : null),
      KpiCard(value: '$valeur DZD', label: t.kpiTotalStockValue, icon: Icons.account_balance_wallet_outlined, valueColor: colors.info),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - 14 * (cards.length - 1)) / cards.length;
      if (cardWidth >= 150) {
        return Row(children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: cards[i]),
          ],
        ]);
      }
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: cards.map((c) => SizedBox(width: 200, child: c)).toList(),
      );
    });
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
                AreaChartSeries(
                    label: t.homeEntries, color: colors.primary, values: points.map((p) => p.entrees.toDouble()).toList()),
                AreaChartSeries(
                    label: t.homeExits, color: colors.success, values: points.map((p) => p.sorties.toDouble()).toList()),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryBreakdown(BuildContext context, AppLocalizations t, StockController stock) {
    final colors = context.colors;
    final palette = [
      colors.primary,
      colors.info,
      colors.secondary,
      colors.warning,
      colors.success,
      colors.danger,
      colors.accent,
      colors.textMuted,
    ];

    return Obx(() {
      final products = stock.products;
      final total = products.length;

      final counts = <String, int>{};
      for (final p in products) {
        final cat = (p.categorie == null || p.categorie!.trim().isEmpty) ? t.categoryOther : p.categorie!;
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

      final data = <DonutChartData>[
        for (int i = 0; i < sorted.length; i++)
          DonutChartData(label: sorted[i].key, value: sorted[i].value.toDouble(), color: palette[i % palette.length]),
      ];

      return SynCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: t.categoryBreakdownTitle),
            const SizedBox(height: 18),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(t.chartNoData, style: TextStyle(color: colors.textMuted, fontSize: 12))),
              )
            else ...[
              Center(child: SynDonutChart(data: data, centerValue: '$total', centerLabel: t.homeProducts)),
              const SizedBox(height: 18),
              ...data.take(6).map(
                    (d) => DonutLegendRow(item: d, valueLabel: '${(d.value / total * 100).toStringAsFixed(0)}%'),
                  ),
            ],
          ],
        ),
      );
    });
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
            if (critical.isEmpty) {
              return Center(child: Text(t.allNormal, style: TextStyle(color: colors.success, fontSize: 12)));
            }
            return Column(
              children: critical
                  .map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: p.status == StockStatus.critical ? colors.danger : colors.warning,
                                shape: BoxShape.circle,
                              ),
                              margin: const EdgeInsets.only(right: 10),
                            ),
                            Expanded(child: Text(p.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text))),
                            Text('${p.stockQuantity}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: p.status == StockStatus.critical ? colors.danger : colors.warning)),
                          ],
                        ),
                      ))
                  .toList(),
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
            if (stock.movements.isEmpty) {
              return Center(child: Text(t.noMovements, style: TextStyle(color: colors.textMuted, fontSize: 12)));
            }
            return Column(
              children: [
                Row(children: [
                  Expanded(
                      child: Text(t.tableProduct,
                          style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(
                      width: 80,
                      child: Text(t.tableQty,
                          style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                  SizedBox(
                      width: 100,
                      child: Text(t.tableType,
                          style: TextStyle(fontSize: 10, color: colors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.08))),
                ]),
                const SizedBox(height: 8),
                ...stock.movements.take(6).map((m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Expanded(child: Text(m.productName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colors.text))),
                          SizedBox(
                            width: 80,
                            child: Text(
                              m.type == MovementType.entry ? '+${m.quantity}' : '-${m.quantity}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: m.type == MovementType.entry ? colors.success : colors.danger),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (m.type == MovementType.entry ? colors.success : colors.danger).withOpacity(0.1),
                                borderRadius: AppRadii.rXs,
                              ),
                              child: Text(
                                m.type == MovementType.entry ? t.movementEntry : t.movementExit,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: m.type == MovementType.entry ? colors.success : colors.danger),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations t, AuthController auth, AppSettingsController settings) {
    final role = auth.user.value?.role;
    final actions = <_QuickAction>[
      _QuickAction(icon: Icons.add_box_outlined, label: t.actionAddProduct, onTap: () => settings.setNav(1)),
      _QuickAction(icon: Icons.description_outlined, label: t.actionNewPurchaseOrder, onTap: () => settings.setNav(11)),
      _QuickAction(icon: Icons.receipt_long_outlined, label: t.actionViewInvoices, onTap: () => settings.setNav(2)),
      _QuickAction(icon: Icons.notifications_outlined, label: t.actionViewAlerts, onTap: () => settings.setNav(3)),
      if (role == UserRole.admin || role == UserRole.manager)
        _QuickAction(icon: Icons.bar_chart_rounded, label: t.actionViewReports, onTap: () => settings.setNav(4)),
    ];

    return SynCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SectionTitle(title: t.quickActionsTitle),
          ),
          const SizedBox(height: 6),
          ...actions.map((a) => _QuickActionRow(action: a)),
        ],
      ),
    );
  }

  Widget _buildAlertsPanel(BuildContext context, AppLocalizations t, AlertController alerts, AppSettingsController settings) {
    final colors = context.colors;
    return SynCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: t.recentAlertsTitle,
            action: GestureDetector(
              onTap: () => settings.setNav(3),
              child: Text(t.viewAllLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.primary)),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            if (alerts.alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text(t.noAlerts, style: TextStyle(color: colors.textMuted, fontSize: 12))),
              );
            }
            return Column(
              children: alerts.alerts.take(6).map((a) => _AlertRow(alert: a, onTap: () => alerts.markRead(a.id))).toList(),
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
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: AppRadii.rXs)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: colors.textMuted)),
    ]);
  }
}

class _AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertRow({required this.alert, required this.onTap});

  Color _color(AppColorsExt colors) {
    switch (alert.level) {
      case AlertLevel.danger:
        return colors.danger;
      case AlertLevel.warning:
        return colors.warning;
      case AlertLevel.success:
        return colors.success;
      case AlertLevel.info:
        return colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = _color(colors);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: alert.isRead ? Colors.transparent : c.withOpacity(0.06),
          borderRadius: AppRadii.rMd,
          border: Border.all(color: alert.isRead ? colors.border.withOpacity(0.6) : c.withOpacity(0.25)),
        ),
        child: Row(children: [
          AlertDot(level: alert.level),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(alert.title,
                  style: TextStyle(fontSize: 11, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w700, color: colors.text)),
              Text(alert.message,
                  style: TextStyle(fontSize: 10, color: colors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
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

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
}

class _QuickActionRow extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: action.onTap,
      hoverColor: colors.hover,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: colors.primary.withOpacity(0.1), borderRadius: AppRadii.rSm),
            child: Icon(action.icon, size: 15, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: colors.text))),
          Icon(Icons.chevron_right_rounded, size: 16, color: colors.textMuted),
        ]),
      ),
    );
  }
}