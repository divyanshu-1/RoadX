import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/analytics_models.dart';

/// Weekly / monthly / yearly report summary block.
class ReportSummaryPanel extends StatelessWidget {
  final PeriodReport report;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const ReportSummaryPanel({
    super.key,
    required this.report,
    required this.isSelected,
    required this.onTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = report.summary;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final fg = isDark ? Colors.white : const Color(0xFF1F2937);
    final muted = isDark ? Colors.white60 : Colors.black54;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4FC3F7)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black12),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? const Color(0xFF4FC3F7).withValues(alpha: 0.12)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
              const SizedBox(height: 12),
              _line('Challans', '${s.totalGenerated}', fg, muted),
              _line('Paid', '${s.totalPaid}', fg, muted),
              _line('Unpaid', '${s.totalUnpaid}', fg, muted),
              _line('Revenue', currency.format(s.amountCollected), fg, muted),
              _line(
                'Pending',
                currency.format(s.amountPending),
                fg,
                muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, Color fg, Color muted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: muted)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
