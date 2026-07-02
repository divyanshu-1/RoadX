import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _QuickActionCard(item: actions[index]),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final QuickActionItem item;

  const _QuickActionCard({required this.item});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: widget.item.color.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.item.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.item.icon, color: widget.item.color, size: 24),
              ),
              const Spacer(),
              Text(
                widget.item.title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
