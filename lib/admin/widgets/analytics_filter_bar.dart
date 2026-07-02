import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analytics_models.dart';

/// Time filter chips: Today / Week / Month / Year.
class AnalyticsFilterBar extends StatelessWidget {
  final AnalyticsTimeFilter selected;
  final ValueChanged<AnalyticsTimeFilter> onChanged;
  final bool isDark;

  const AnalyticsFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    const filters = AnalyticsTimeFilter.values;
    const labels = ['Today', 'This Week', 'This Month', 'This Year'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(filters.length, (i) {
        final f = filters[i];
        final active = f == selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(f),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: active
                    ? const Color(0xFF4FC3F7)
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
                border: Border.all(
                  color: active
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF64748B),
                ),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? const Color(0xFF0F172A)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
