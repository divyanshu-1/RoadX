import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pie chart — paid vs unpaid challans.
class PaidUnpaidPieChart extends StatelessWidget {
  final Map<String, int> split;
  final bool isDark;

  const PaidUnpaidPieChart({
    super.key,
    required this.split,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final paid = split['paid'] ?? 0;
    final unpaid = split['unpaid'] ?? 0;
    final total = paid + unpaid;

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
                centerSpaceRadius: 36,
                sections: [
                  _section('Paid', paid, const Color(0xFF10B981), total),
                  _section('Unpaid', unpaid, const Color(0xFFEF4444), total),
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
                _legend('Paid', paid, const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _legend('Unpaid', unpaid, const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(
    String title,
    int value,
    Color color,
    int total,
  ) {
    final pct = total == 0 ? 0.0 : (value / total) * 100;
    return PieChartSectionData(
      value: value.toDouble(),
      title: '${pct.toStringAsFixed(0)}%',
      color: color,
      radius: 52,
      titleStyle: GoogleFonts.poppins(
        fontSize: 12,
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
            'No payment data',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      );
}
