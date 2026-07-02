import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dark_glass_card.dart';

/// Dashboard statistic tile with icon and animated entrance.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final int animationIndex;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: animationIndex,
      duration: const Duration(milliseconds: 400),
      child: SlideAnimation(
        verticalOffset: 24,
        child: FadeInAnimation(
          child: DarkGlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: accentColor.withOpacity(0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(height: 12),
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
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
