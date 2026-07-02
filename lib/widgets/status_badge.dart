import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Green Active / Red Unauthorized status pill.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  bool get _isActive => status.toLowerCase() == 'active';

  @override
  Widget build(BuildContext context) {
    final color = _isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
