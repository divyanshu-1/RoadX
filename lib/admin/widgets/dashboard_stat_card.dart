import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gradient glass stat card for admin dashboard.
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final int animationIndex;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.95), size: 28),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (80 * animationIndex).ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
