import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// App Colors
class AppColors {
  static const Color primarySkyBlue = Color(0xFF4FC3F7); // Sky Blue primary
  static const Color accentLightBlue = Color(0xFF81D4FA); // Light Blue accent
  static const Color charcoal = Color(0xFF111827); // headings
  static const Color text = Color(0xFF1F2937); // body
  static const Color subtle = Color(0xFF6B7280); // secondary text
}

/// App Gradients
class AppGradients {
  static const Gradient background = LinearGradient(
    colors: [Color(0xFFF3F4F6), Color(0xFFE3F2FD)], // light grey to light blue tint
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient button = LinearGradient(
    colors: [AppColors.primarySkyBlue, AppColors.accentLightBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// Main App Theme
ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primarySkyBlue,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: scheme,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.charcoal,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.75),
      hintStyle: TextStyle(color: AppColors.subtle),
      labelStyle: const TextStyle(color: AppColors.text),
      prefixIconColor: AppColors.subtle,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primarySkyBlue),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    iconTheme: const IconThemeData(color: AppColors.charcoal),
  );
}

/// Gradient Scaffold
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

/// Gradient Button
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.child,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppGradients.button,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySkyBlue.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            child,
          ],
        ),
      ),
    );

    return InkWell(borderRadius: BorderRadius.circular(16), onTap: onPressed, child: button);
  }
}

/// Glass Bottom Navigation
class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.primarySkyBlue.withOpacity(0.12),
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}

/// Glass Card Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
