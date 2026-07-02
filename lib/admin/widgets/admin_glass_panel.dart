import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Glassmorphism container for charts and tables.
class AdminGlassPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final bool isDark;

  const AdminGlassPanel({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : const Color(0xFF1F2937);
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.85);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: fg,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
