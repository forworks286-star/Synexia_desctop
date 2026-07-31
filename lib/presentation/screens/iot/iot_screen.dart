import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class IoTScreen extends StatefulWidget {
  const IoTScreen({super.key});

  @override
  State<IoTScreen> createState() => _IoTScreenState();
}

class _IoTScreenState extends State<IoTScreen> {
  String? _zoneSelectionnee;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<IoTController>();
    ctrl.loadZones();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: PageHeader(title: 'IoT — Zones')),
          SynButton(label: 'Actualiser', icon: Icons.refresh_rounded, outline: true, onTap: ctrl.loadZones),
        ]),
        const SizedBox(height: 16),
        Obx(() {
          final zones = ctrl.zones;
          return DropdownButtonFormField<String?>(
            value: _zoneSelectionnee,
            decoration: const InputDecoration(labelText: 'Zone'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Toutes les zones')),
              ...zones.map((z) => DropdownMenuItem<String?>(value: z.zoneId, child: Text(z.nom))),
            ],
            onChanged: (v) => setState(() => _zoneSelectionnee = v),
          );
        }),
        const SizedBox(height: 20),
        Expanded(child: Obx(() {
          final toutes = ctrl.zones;
          final affichees = _zoneSelectionnee == null
              ? toutes
              : toutes.where((z) => z.zoneId == _zoneSelectionnee).toList();
          if (affichees.isEmpty) {
            return const Center(child: Text('Aucune donnée IoT reçue',
              style: TextStyle(color: AppColors.darkTextMuted)));
          }
          return ListView.separated(
            itemCount: affichees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ZoneCard(zone: affichees[i]),
          );
        })),
      ]),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final IoTZoneState zone;
  const _ZoneCard({required this.zone});

  Color get _couleur {
    switch (zone.niveau) {
      case 'critique': return AppColors.danger;
      case 'alerte': return AppColors.warning;
      case 'manuel': return Colors.blueGrey;
      default: return AppColors.success;
    }
  }

  String get _libelleNiveau {
    switch (zone.niveau) {
      case 'critique': return 'CRITIQUE';
      case 'alerte': return 'ALERTE';
      case 'manuel': return 'MANUEL';
      default: return 'NORMAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _couleur.withOpacity(0.4), width: zone.niveau == 'critique' ? 1.5 : 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _couleur.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: Text(_libelleNiveau, style: TextStyle(color: _couleur, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(zone.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
          if (zone.derniereMaj != null)
            Text('${zone.derniereMaj!.hour.toString().padLeft(2, '0')}:${zone.derniereMaj!.minute.toString().padLeft(2, '0')}:${zone.derniereMaj!.second.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted)),
        ]),
        const SizedBox(height: 8),
        Text(zone.libelle, style: TextStyle(fontSize: 13, color: _couleur, fontWeight: FontWeight.w600)),
        if (zone.resoluAuto == true)
          const Padding(padding: EdgeInsets.only(top: 4),
            child: Text('✓ Résolu automatiquement', style: TextStyle(fontSize: 12, color: AppColors.success))),
        if (zone.resoluAuto == false)
          const Padding(padding: EdgeInsets.only(top: 4),
            child: Text('⚠ Nécessite une intervention manuelle', style: TextStyle(fontSize: 12, color: AppColors.danger))),
        const Divider(height: 20),
        Wrap(spacing: 16, runSpacing: 6, children: zone.valeurs.entries.map((e) => SizedBox(
          width: 220,
          child: Row(children: [
            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 11, color: AppColors.darkTextMuted), overflow: TextOverflow.ellipsis)),
            Text(_fmt(e.value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        )).toList()),
      ]),
    );
  }

  String _fmt(dynamic v) {
    if (v == true) return '✅';
    if (v == false) return '❌';
    if (v == null) return '—';
    return v.toString();
  }
}