import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/design/theme_extension.dart';

class AreaChartSeries {
  final String label;
  final Color color;
  final List<double> values;

  const AreaChartSeries({required this.label, required this.color, required this.values});
}

class SynAreaChart extends StatelessWidget {
  final List<String> xLabels;
  final List<AreaChartSeries> series;
  final double height;

  const SynAreaChart({
    super.key,
    required this.xLabels,
    required this.series,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (series.isEmpty || xLabels.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('Aucune donnée', style: TextStyle(color: colors.textMuted, fontSize: 12))),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: colors.border.withOpacity(0.5), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= xLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(xLabels[i], style: TextStyle(fontSize: 9, color: colors.textMuted)),
                );
              },
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(fontSize: 9, color: colors.textMuted)),
            )),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.cardAlt,
              getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                s.y.toStringAsFixed(0),
                TextStyle(color: colors.text, fontSize: 11, fontWeight: FontWeight.w600),
              )).toList(),
            ),
          ),
          lineBarsData: series.map((s) {
            return LineChartBarData(
              spots: List.generate(s.values.length, (i) => FlSpot(i.toDouble(), s.values[i])),
              isCurved: true,
              curveSmoothness: 0.3,
              color: s.color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [s.color.withOpacity(0.28), s.color.withOpacity(0.0)],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}