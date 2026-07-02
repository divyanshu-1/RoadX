import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Doughnut chart — accepted vs pending challans.
class StatusDoughnutChart extends StatelessWidget {
  final Map<String, int> split;
  final bool isDark;

  const StatusDoughnutChart({
    super.key,
    required this.split,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final accepted = split['accepted'] ?? 0;
    final pending = split['pending'] ?? 0;
    final total = accepted + pending;

    if (total == 0) return _empty();

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 48,
                sections: [
                  _section(accepted, const Color(0xFF6366F1), total),
                  _section(pending, const Color(0xFFF59E0B), total),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend('Accepted', accepted, const Color(0xFF6366F1)),
                const SizedBox(height: 8),
                _legend('Pending', pending, const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(int value, Color color, int total) {
    final pct = total == 0 ? 0.0 : (value / total) * 100;
    return PieChartSectionData(
      value: value.toDouble(),
      title: '${pct.toStringAsFixed(0)}%',
      color: color,
      radius: 44,
      titleStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _legend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _empty() => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No status data',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      );
}
