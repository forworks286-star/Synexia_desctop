import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class AlertesScreen extends StatelessWidget {
  const AlertesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AlertController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => PageHeader(
            title: 'Alertes',
            actions: [
              if (ctrl.unreadCount.value > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text('${ctrl.unreadCount.value} non lues', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ),
                const SizedBox(width: 10),
                SynButton(label: 'Tout marquer lu', icon: Icons.done_all_rounded, onTap: ctrl.markAllRead, outline: true),
              ],
              const SizedBox(width: 10),
              SynButton(label: 'Actualiser', icon: Icons.refresh_rounded, onTap: ctrl.loadAlerts, outline: true),
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
                        return const Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.notifications_none_rounded, size: 40, color: AppColors.darkTextMuted),
                            SizedBox(height: 10),
                            Text('Aucune alerte', style: TextStyle(color: AppColors.darkTextMuted)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: const [
        SizedBox(width: 20),
        _TH(label: 'TITRE', flex: 3),
        _TH(label: 'MESSAGE', flex: 5),
        _TH(label: 'NIVEAU', flex: 1),
        _TH(label: 'HEURE', flex: 2),
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

class _AlertRow extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;
  const _AlertRow({required this.alert, required this.onTap});

  Color get _levelColor {
    switch (alert.level) {
      case AlertLevel.danger: return AppColors.danger;
      case AlertLevel.warning: return AppColors.warning;
      case AlertLevel.success: return AppColors.success;
      case AlertLevel.info: return AppColors.secondary;
    }
  }

  String get _levelLabel {
    switch (alert.level) {
      case AlertLevel.danger: return 'Critique';
      case AlertLevel.warning: return 'Avertissement';
      case AlertLevel.success: return 'Succès';
      case AlertLevel.info: return 'Info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: alert.isRead ? Colors.transparent : _levelColor.withOpacity(0.04),
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: alert.isRead ? AppColors.darkTextMuted.withOpacity(0.3) : _levelColor,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 14),
          ),
          Expanded(flex: 3, child: Text(alert.title, style: TextStyle(fontSize: 13, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w700))),
          Expanded(flex: 5, child: Text(alert.message, style: const TextStyle(fontSize: 12, color: AppColors.darkTextMuted), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 1, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: _levelColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(_levelLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _levelColor)),
          )),
          Expanded(flex: 2, child: Text(_timeAgo(alert.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted))),
          Expanded(flex: 1, child: alert.isRead
              ? const Text('Lu', style: TextStyle(fontSize: 10, color: AppColors.darkTextMuted))
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Nouveau', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                )),
        ]),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
