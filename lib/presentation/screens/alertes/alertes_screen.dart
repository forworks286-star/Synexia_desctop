import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/design/colors.dart';
import '../../../core/design/theme_extension.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AlertController>();
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => PageHeader(
            title: t.homeAlerts,
            actions: [
              if (ctrl.unreadCount.value > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppPalette.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text('${ctrl.unreadCount.value} ${t.kpiUnread}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppPalette.danger)),
                ),
                const SizedBox(width: 10),
                if (Get.find<AuthController>().isAdmin)
                  SynButton(label: t.markAllRead, icon: Icons.done_all_rounded, onTap: ctrl.markAllRead, outline: true),
              ],
              const SizedBox(width: 10),
              SynButton(label: t.dashboardRefresh, icon: Icons.refresh_rounded, onTap: ctrl.loadAlerts, outline: true),
            ],
          )),
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
                      if (ctrl.alerts.isEmpty) {
                        return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.notifications_none_rounded, size: 40, color: context.colors.textMuted),
                            const SizedBox(height: 10),
                            Text(t.noAlerts, style: TextStyle(color: context.colors.textMuted)),
                          ]),
                        );
                      }
                      return ListView.separated(
                        itemCount: ctrl.alerts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _AlertRow(alert: ctrl.alerts[i], onTap: () => ctrl.markRead(ctrl.alerts[i].id)),
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
        const SizedBox(width: 20),
        _TH(label: t.thTitle, flex: 3),
        _TH(label: t.thMessage, flex: 5),
        _TH(label: t.thLevel, flex: 1),
        _TH(label: t.thTime, flex: 2),
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
    return Expanded(flex: flex, child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.textMuted, letterSpacing: 0.1)));
  }
}

class _AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertRow({required this.alert, required this.onTap});

  Color get _levelColor {
    switch (alert.level) {
      case AlertLevel.danger: return AppPalette.danger;
      case AlertLevel.warning: return AppPalette.warning;
      case AlertLevel.success: return AppPalette.success;
      case AlertLevel.info: return AppPalette.secondary;
    }
  }

  String _levelLabel(AppLocalizations t) {
    switch (alert.level) {
      case AlertLevel.danger: return t.statusCritical;
      case AlertLevel.warning: return t.alertLevelWarning;
      case AlertLevel.success: return t.toastSuccess;
      case AlertLevel.info: return t.alertLevelInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: alert.isRead ? Colors.transparent : _levelColor.withOpacity(0.04),
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: alert.isRead ? context.colors.textMuted.withOpacity(0.3) : _levelColor,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 14),
          ),
          Expanded(flex: 3, child: Text(alert.title, style: TextStyle(fontSize: 13, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w700))),
          Expanded(flex: 5, child: Text(alert.message, style: TextStyle(fontSize: 12, color: context.colors.textMuted), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: _levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(_levelLabel(t), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _levelColor)),
          )),
          Expanded(flex: 2, child: Text(_timeAgo(t, alert.createdAt), style: TextStyle(fontSize: 11, color: context.colors.textMuted))),
          Expanded(flex: 1, child: alert.isRead
              ? Text(t.readLabel, style: TextStyle(fontSize: 10, color: context.colors.textMuted))
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppPalette.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(t.newLabel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppPalette.primary)),
                )),
        ]),
      ),
    );
  }

  String _timeAgo(AppLocalizations t, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return t.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return t.hoursAgo(diff.inHours);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}