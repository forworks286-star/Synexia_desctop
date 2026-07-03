import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/models.dart';
import '../../controllers/controllers.dart';
import '../../widgets/widgets.dart';

class IoTScreen extends StatelessWidget {
  const IoTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stock = Get.find<StockController>();

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: PageHeader(title: 'IoT — Tableau de bord')),
            SynButton(
              label: 'Actualiser',
              icon: Icons.refresh_rounded,
              outline: true,
              onTap: stock.loadIoT,
            ),
          ]),
          const SizedBox(height: 8),
          Obx(() {
            final alarms = stock.iotActiveAlarms.value;
            if (alarms == 0) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_rounded, color: AppColors.danger, size: 16),
                const SizedBox(width: 10),
                Text('$alarms alarme(s) active(s) en ce moment',
                  style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 13)),
              ]),
            );
          }),
          Expanded(
            child: Obx(() {
              final zones = stock.iotZones;
              if (zones.isEmpty) {
                return const Center(child: Text('Aucune donnée IoT reçue',
                  style: TextStyle(color: AppColors.darkTextMuted)));
              }
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.3),
                itemCount: zones.length,
                itemBuilder: (_, i) => _IoTZoneCard(zone: zones[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _IoTZoneCard extends StatelessWidget {
  final IoTZone zone;
  const _IoTZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    final hasAlarm = zone.hasAlarm;
    final borderColor = hasAlarm ? AppColors.danger : AppColors.darkBorder;
    final module = zone.module;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: hasAlarm ? 1.5 : 1),
          ),
          padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _moduleIcon(module),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(module, style: const TextStyle(fontFamily: 'Syne', fontSize: 13, fontWeight: FontWeight.w700)),
              Text(zone.zoneId, style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10)),
            ])),
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: hasAlarm ? AppColors.danger : AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(color: AppColors.darkBorder, height: 1),
          const SizedBox(height: 12),
          ..._buildValues(module, zone),
          if (hasAlarm) ...[
            const SizedBox(height: 8),
            ..._buildAlarms(zone.alarms),
          ],
        ],
      ),
    ),
    );
  }

  Widget _moduleIcon(String module) {
    IconData icon;
    Color color;
    switch (module) {
      case 'SmartLighting': icon = Icons.lightbulb_outline_rounded; color = AppColors.warning; break;
      case 'HVAC':          icon = Icons.air_rounded;               color = AppColors.primary;  break;
      case 'FireSystem':    icon = Icons.local_fire_department_rounded; color = AppColors.danger; break;
      case 'AccessControl': icon = Icons.lock_outline_rounded;      color = AppColors.success;  break;
      case 'Energy':        icon = Icons.bolt_rounded;              color = AppColors.secondary; break;
      default:              icon = Icons.settings_outlined;          color = AppColors.darkTextMuted;
    }
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: color),
    );
  }

  List<Widget> _buildValues(String module, IoTZone zone) {
    final widgets = <Widget>[];
    if (module == 'SmartLighting' && zone.lighting.isNotEmpty) {
      final dimming = zone.outputs['light_level'] ?? zone.lighting['dimming'];
      final lux = zone.inputs['lux'];
      final presence = zone.inputs['presence'];
      if (dimming != null) widgets.add(_Val(label: 'Éclairage', value: '$dimming%', icon: Icons.lightbulb_rounded));
      if (lux != null)     widgets.add(_Val(label: 'Luminosité', value: '$lux lux', icon: Icons.wb_sunny_outlined));
      if (presence != null) widgets.add(_Val(label: 'Présence', value: presence == true ? 'Oui' : 'Non', icon: Icons.person_outline_rounded));
    }
    if (module == 'HVAC' && zone.hvac.isNotEmpty) {
      final temp = zone.hvac['actual_temperature'];
      final humidity = zone.hvac['actual_humidity'];
      final co2 = zone.inputs['co2'];
      final state = zone.states['current_state'];
      if (temp != null)     widgets.add(_Val(label: 'Température', value: '${temp}°C', icon: Icons.thermostat_rounded, warn: (temp as num) > 27));
      if (humidity != null) widgets.add(_Val(label: 'Humidité', value: '${humidity}%', icon: Icons.water_drop_outlined));
      if (co2 != null)      widgets.add(_Val(label: 'CO₂', value: '$co2 ppm', icon: Icons.air_rounded));
      if (state != null)    widgets.add(_Val(label: 'Mode', value: '$state', icon: Icons.tune_rounded));
    }
    if (module == 'FireSystem') {
      final smoke = zone.inputs['smoke_detector'];
      final gas = zone.inputs['gas_detector'];
      widgets.add(_Val(label: 'Fumée', value: smoke == true ? 'DETECTE' : 'Normal', icon: Icons.smoke_free_rounded, alarm: smoke == true));
      widgets.add(_Val(label: 'Gaz', value: gas == true ? 'DETECTE' : 'Normal', icon: Icons.gas_meter_outlined, alarm: gas == true));
    }
    if (zone.energy.isNotEmpty) {
      final power = zone.energy['power_w'];
      final daily = zone.energy['daily_energy_kwh'];
      if (power != null) widgets.add(_Val(label: 'Puissance', value: '${power}W', icon: Icons.bolt_rounded));
      if (daily != null) widgets.add(_Val(label: 'Conso. jour', value: '${daily} kWh', icon: Icons.electric_meter_outlined));
    }
    if (widgets.isEmpty) {
      final state = zone.states['current_state'];
      if (state != null) widgets.add(_Val(label: 'État', value: '$state', icon: Icons.info_outline_rounded));
    }
    return widgets.take(4).toList();
  }

  List<Widget> _buildAlarms(Map<String, dynamic> alarms) {
    return alarms.entries
        .where((e) => e.value == true)
        .map((e) => Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded, size: 10, color: AppColors.danger),
                const SizedBox(width: 4),
                Text(e.key, style: const TextStyle(fontSize: 9, color: AppColors.danger, fontWeight: FontWeight.w600)),
              ]),
            ))
        .toList();
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 900,
          constraints: const BoxConstraints(maxHeight: 700),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Row(children: [
                _moduleIcon(zone.module),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${zone.module} — ${zone.zoneId}',
                    style: const TextStyle(fontFamily: 'Syne', fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Device: ${zone.deviceId} | ${_fmt(zone.timestamp)}',
                    style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 11)),
                ])),
                if (zone.hasAlarm)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: const Text('ALARME ACTIVE', style: TextStyle(
                      color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.darkTextMuted),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(color: AppColors.darkBorder, height: 1),
              const SizedBox(height: 16),
              // ── Content ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (zone.inputs.isNotEmpty)
                            Expanded(child: _Section(title: 'ENTRÉES', color: AppColors.primary,
                              items: zone.inputs.entries.map((e) => _Item(
                                label: e.key,
                                value: _fmtVal(e.value),
                                isAlarm: e.value == true && _isDangerInput(e.key),
                              )).toList())),
                          if (zone.inputs.isNotEmpty) const SizedBox(width: 12),
                          if (zone.outputs.isNotEmpty)
                            Expanded(child: _Section(title: 'SORTIES', color: AppColors.secondary,
                              items: zone.outputs.entries.map((e) => _Item(
                                label: e.key,
                                value: _fmtVal(e.value),
                                isAlarm: e.value == true && _isDangerOutput(e.key),
                              )).toList())),
                          if (zone.outputs.isNotEmpty) const SizedBox(width: 12),
                          if (zone.states.isNotEmpty)
                            Expanded(child: _Section(title: 'ÉTATS', color: AppColors.warning,
                              items: zone.states.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                              )).toList())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (zone.hvac.isNotEmpty)
                            Expanded(child: _Section(title: 'HVAC', color: AppColors.primary,
                              items: zone.hvac.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                                warn: e.key == 'actual_temperature' &&
                                  (double.tryParse(e.value.toString()) ?? 0) >
                                  (double.tryParse(zone.hvac['target_temperature']?.toString() ?? '0') ?? 0),
                              )).toList())),
                          if (zone.hvac.isNotEmpty) const SizedBox(width: 12),
                          if (zone.energy.isNotEmpty)
                            Expanded(child: _Section(title: 'ÉNERGIE', color: AppColors.success,
                              items: zone.energy.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                              )).toList())),
                          if (zone.energy.isNotEmpty) const SizedBox(width: 12),
                          if (zone.lighting.isNotEmpty)
                            Expanded(child: _Section(title: 'ÉCLAIRAGE', color: AppColors.warning,
                              items: zone.lighting.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                              )).toList())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 3
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (zone.diagnostic.isNotEmpty)
                            Expanded(child: _Section(title: 'DIAGNOSTIC', color: AppColors.secondary,
                              items: zone.diagnostic.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                                isAlarm: e.key == 'plc_status' && e.value != 'OK',
                              )).toList())),
                          if (zone.diagnostic.isNotEmpty) const SizedBox(width: 12),
                          if (zone.maintenance.isNotEmpty)
                            Expanded(child: _Section(title: 'MAINTENANCE', color: AppColors.warning,
                              items: zone.maintenance.entries.map((e) => _Item(
                                label: e.key, value: _fmtVal(e.value),
                                warn: e.key == 'maintenance_due' && e.value == true,
                              )).toList())),
                          if (zone.maintenance.isNotEmpty) const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (zone.alarms.isNotEmpty)
                                _Section(title: 'ALARMES', color: AppColors.danger,
                                  items: zone.alarms.entries.map((e) => _Item(
                                    label: e.key, value: _fmtVal(e.value),
                                    isAlarm: e.value == true,
                                  )).toList()),
                            ],
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDangerInput(String key) =>
    ['smoke_detector', 'fire_alarm', 'gas_detector', 'water_leak',
     'emergency_button', 'heat_detector'].contains(key);

  bool _isDangerOutput(String key) =>
    ['alarm_output', 'buzzer', 'warning_light', 'emergency_shutdown'].contains(key);

  String _fmtVal(dynamic v) {
    if (v == true)  return '✅ OUI';
    if (v == false) return '❌ NON';
    if (v == null)  return '—';
    return v.toString();
  }

  String _fmt(DateTime dt) =>
    '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} '
    '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

class _Val extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool warn;
  final bool alarm;
  const _Val({required this.label, required this.value, required this.icon, this.warn = false, this.alarm = false});

  @override
  Widget build(BuildContext context) {
    final color = alarm ? AppColors.danger : warn ? AppColors.warning : AppColors.darkTextMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: alarm || warn ? color : Colors.white)),
      ]),
    );
  }
}



class _Section extends StatelessWidget {
  final String title;
  final Color color;
  final List<_Item> items;
  const _Section({required this.title, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
            color: color, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlarm;
  final bool warn;
  const _Item({required this.label, required this.value, this.isAlarm = false, this.warn = false});

  @override
  Widget build(BuildContext context) {
    final valueColor = isAlarm ? AppColors.danger : warn ? AppColors.warning : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(child: Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.darkTextMuted),
          overflow: TextOverflow.ellipsis)),
        Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: valueColor)),
      ]),
    );
  }
}