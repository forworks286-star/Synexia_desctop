import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class SecuriteScreen extends StatelessWidget {
  const SecuriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();
    final alerts = Get.find<AlertController>();
    final t = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: PageHeader(title: t.secPageTitle)),
            SynButton(label: t.dashboardRefresh, icon: Icons.refresh_rounded, outline: true,
              onTap: () { stock.loadIoT(); alerts.loadAlerts(); }),
          ]),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildFaceEvents(t, stock)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildSecurityAlerts(t, alerts)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceEvents(AppLocalizations t, StockController stock) {
    return SynCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SectionTitle(title: t.secAccessControlTitle),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(children: [
              Expanded(flex: 3, child: _TH(label: t.secThPerson)),
              Expanded(flex: 2, child: _TH(label: t.secThZone)),
              Expanded(flex: 1, child: _TH(label: t.secThConfidence)),
              Expanded(flex: 1, child: _TH(label: t.secThAccess)),
              Expanded(flex: 2, child: _TH(label: t.thTime)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          Expanded(
            child: Obx(() {
              final events = stock.faceEvents;
              if (events.isEmpty) {
                return Center(child: Text(t.secNoFaceEvent,
                  style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)));
              }
              return ListView.separated(
                itemCount: events.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                itemBuilder: (_, i) => _FaceRow(event: events[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAlerts(AppLocalizations t, AlertController alerts) {
    return SynCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: SectionTitle(title: t.secAlertsTitle),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          Expanded(
            child: Obx(() {
              final secAlerts = alerts.alerts
                  .where((a) => a.sourceModule == 'ia_vision' ||
                               a.sourceModule == 'ia_face_id' ||
                               a.sourceModule == 'automatique' ||
                               a.type == 'securite' || a.type == 'acces')
                  .toList();
              if (secAlerts.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.verified_user_rounded, size: 36, color: AppColors.success),
                  const SizedBox(height: 10),
                  Text(t.secNoSecurityAlert, style: TextStyle(color: AppColors.darkTextMuted, fontSize: 12)),
                ]));
              }
              return ListView.separated(
                itemCount: secAlerts.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.darkBorder),
                itemBuilder: (_, i) {
                  final a = secAlerts[i];
                  final color = a.level == AlertLevel.danger ? AppColors.danger : AppColors.warning;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: a.isRead ? Colors.transparent : color.withOpacity(0.04),
                    child: Row(children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a.title, style: TextStyle(fontSize: 12, fontWeight: a.isRead ? FontWeight.w400 : FontWeight.w700)),
                        Text(a.message, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ])),
                      const SizedBox(width: 8),
                      Text(_timeAgo(a.createdAt), style: const TextStyle(fontSize: 9, color: AppColors.darkTextMuted)),
                    ]),
                  );
                },
              );
            }),
          ),
        ],
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


class _FaceRow extends StatelessWidget {
  final FaceEvent event;
  const _FaceRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final autorise = event.autorise && event.reconnu;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Expanded(flex: 3, child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: (autorise ? AppColors.success : AppColors.danger).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(
              event.nom?.isNotEmpty == true ? event.nom![0].toUpperCase() : '?',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: autorise ? AppColors.success : AppColors.danger),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(event.nom ?? AppLocalizations.of(context).secUnknownPerson,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ])),
        Expanded(flex: 2, child: Text(event.zone ?? '—',
          style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted))),
        Expanded(flex: 1, child: Text(
          event.confiance != null ? '${(double.tryParse(event.confiance!) ?? 0 * 100).toStringAsFixed(0)}%' : '—',
          style: const TextStyle(fontSize: 11))),
        Expanded(flex: 1, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: (autorise ? AppColors.success : AppColors.danger).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(autorise ? AppLocalizations.of(context).secAccessOk : AppLocalizations.of(context).secAccessDenied,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: autorise ? AppColors.success : AppColors.danger)),
        )),
        Expanded(flex: 2, child: Text(
          '${event.timestamp.hour.toString().padLeft(2,'0')}:${event.timestamp.minute.toString().padLeft(2,'0')}',
          style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted))),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  const _TH({required this.label});
  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
      color: AppColors.darkTextMuted, letterSpacing: 0.1));
  }
}