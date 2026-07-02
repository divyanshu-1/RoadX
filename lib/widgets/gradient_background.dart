import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

/// Full-screen dark gradient background wrapper.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const GradientBackground({
    super.key,
    required this.child,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppConstants.darkBackground),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: child,
      ),
    );
  }
}
