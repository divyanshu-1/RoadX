import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

/// Line chart — revenue collected per month.
class MonthlyRevenueLineChart extends StatelessWidget {
  final List<MonthlyChartPoint> points;
  final bool isDark;

  const MonthlyRevenueLineChart({
    super.key,
    required this.points,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return _empty();

    final spots = List.generate(
      points.length,
      (i) => FlSpot(i.toDouble(), points[i].revenue.toDouble()),
    );
    final maxY = points.map((p) => p.revenue).reduce((a, b) => a > b ? a : b) +
        500;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY.toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black12,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${(v / 1000).toStringAsFixed(0)}k',
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
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  return Text(
                    points[i].label.split(' ').first,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No revenue data yet',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      );
}
