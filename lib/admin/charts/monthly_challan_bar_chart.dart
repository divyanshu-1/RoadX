import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

/// Bar chart — challans generated per month.
class MonthlyChallanBarChart extends StatelessWidget {
  final List<MonthlyChartPoint> points;
  final bool isDark;

  const MonthlyChallanBarChart({
    super.key,
    required this.points,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _empty();

    final maxY = points
            .map((p) => p.challanCount)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      points[i].label.split(' ').first,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(points.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].challanCount.toDouble(),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _empty() => SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No monthly data yet',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      );
}
