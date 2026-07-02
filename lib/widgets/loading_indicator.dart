import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Loading animation with Lottie fallback to CircularProgressIndicator.
class AppLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.color = const Color(0xFF10B981),
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.network(
        'https://assets10.lottiefiles.com/packages/lf20_usmfxu8q.json',
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}
