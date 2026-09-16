import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/design/theme_extension.dart';

class DonutChartData {
  final String label;
  final double value;
  final Color color;

  const DonutChartData({required this.label, required this.value, required this.color});
}

class SynDonutChart extends StatelessWidget {
  final List<DonutChartData> data;
  final String centerValue;
  final String centerLabel;
  final double size;

  const SynDonutChart({
    super.key,
    required this.data,
    required this.centerValue,
    required this.centerLabel,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.32,
              sections: data.map((d) => PieChartSectionData(
                value: d.value,
                color: d.color,
                radius: size * 0.18,
                showTitle: false,
              )).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue, style: TextStyle(fontFamily: 'Syne', fontSize: 18, fontWeight: FontWeight.w800, color: colors.text)),
              Text(centerLabel, style: TextStyle(fontSize: 10, color: colors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutLegendRow extends StatelessWidget {
  final DonutChartData item;
  final String valueLabel;

  const DonutLegendRow({super.key, required this.item, required this.valueLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(item.label, style: TextStyle(fontSize: 12, color: colors.text))),
          Text(valueLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        ],
      ),
    );
  }
}