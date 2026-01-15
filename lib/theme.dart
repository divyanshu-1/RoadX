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

/// Enhanced Glass Bottom Navigation with bubble effects
class GlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;
  final AnimationController? animationController;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
    this.animationController,
  });

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _bubbleControllers;
  late List<Animation<double>> _bubbleAnimations;

  @override
  void initState() {
    super.initState();
    // Create bubble animations for each nav item
    _bubbleControllers = List.generate(
      widget.destinations.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(),
    );
    _bubbleAnimations = _bubbleControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _bubbleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.75),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.primarySkyBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(widget.destinations.length, (index) {
                    final destination = widget.destinations[index];
                    final isSelected = index == widget.currentIndex;
                    
                    return Expanded(
                      child: _AnimatedNavItem(
                        icon: isSelected 
                            ? (destination.selectedIcon ?? destination.icon)
                            : destination.icon,
                        label: destination.label,
                        isSelected: isSelected,
                        onTap: () => widget.onTap(index),
                        animationController: widget.animationController,
                        bubbleAnimation: _bubbleAnimations[index],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated Navigation Item with bubble effects
class _AnimatedNavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController? animationController;
  final Animation<double>? bubbleAnimation;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.animationController,
    this.bubbleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.primarySkyBlue.withOpacity(0.2),
        highlightColor: AppColors.primarySkyBlue.withOpacity(0.1),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main content - Clean minimal selection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppColors.primarySkyBlue.withOpacity(0.1)
                    : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        // Minimal shadow for subtle elevation
                        BoxShadow(
                          color: AppColors.primarySkyBlue.withOpacity(0.15),
                          blurRadius: 3,
                          spreadRadius: 0,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primarySkyBlue.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          size: 24,
                          color: isSelected
                              ? AppColors.primarySkyBlue
                              : Colors.grey[600],
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: isSelected ? 11.5 : 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primarySkyBlue
                          : Colors.grey[600],
                      letterSpacing: isSelected ? 0.3 : 0,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              // blurRadius: 18,
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
