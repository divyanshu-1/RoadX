import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/challan_model.dart';

/// Scrollable recent challans data table.
class RecentChallansTable extends StatelessWidget {
  final List<ChallanModel> challans;
  final bool isDark;

  const RecentChallansTable({
    super.key,
    required this.challans,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    if (challans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No challans in this period.',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
      );
    }

    final dateFmt = DateFormat('dd MMM yyyy');
    final headerColor = isDark ? Colors.white70 : Colors.black54;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: headerColor,
        ),
        dataTextStyle: GoogleFonts.poppins(fontSize: 13, color: textColor),
        columns: const [
          DataColumn(label: Text('Vehicle')),
          DataColumn(label: Text('Owner')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Payment')),
          DataColumn(label: Text('Date')),
        ],
        rows: challans.map((c) {
          return DataRow(
            cells: [
              DataCell(Text(c.vehicleNumber)),
              DataCell(Text(c.ownerName.isEmpty ? '—' : c.ownerName)),
              DataCell(Text('₹${c.fineAmount}')),
              DataCell(_badge(c.status, _statusColor(c.status))),
              DataCell(_badge(c.paymentStatus, _paymentColor(c.paymentStatus))),
              DataCell(Text(dateFmt.format(c.effectiveDate))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'paid':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Color _paymentColor(String payment) {
    return payment.toLowerCase() == 'paid' ? Colors.teal : Colors.redAccent;
  }
}
