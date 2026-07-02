import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated neon gradient background for premium dark UI.
class PremiumBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const PremiumBackground({
    super.key,
    required this.child,
    this.gradientColors,
  });

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors ??
        const [
          Color(0xFF0A0E1A),
          Color(0xFF111827),
          Color(0xFF0F172A),
          Color(0xFF1E1B4B),
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_controller.value * 2 * math.pi),
                math.sin(_controller.value * 2 * math.pi),
              ),
              end: Alignment(
                -math.cos(_controller.value * 2 * math.pi),
                -math.sin(_controller.value * 2 * math.pi),
              ),
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.1, 1.1),
                      duration: 4.seconds,
                    ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.06),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
