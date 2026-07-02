import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared dark glassmorphism styling for the admin panel.
class AdminTheme {
  AdminTheme._();

  static const Color bgTop = Color(0xFF0F172A);
  static const Color bgMid = Color(0xFF1E293B);
  static const Color bgBottom = Color(0xFF0F172A);
  static const Color accent = Color(0xFF4FC3F7);
  static const Color accentSoft = Color(0xFF38BDF8);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Gradient pageGradient = LinearGradient(
    colors: [bgTop, bgMid, bgBottom],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassDecoration({
    double radius = 16,
    double opacity = 0.08,
    Color borderColor = const Color(0xFF4FC3F7),
    double borderOpacity = 0.22,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withValues(alpha: borderOpacity),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

/// Frosted glass panel with optional backdrop blur.
class AdminGlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool blur;

  const AdminGlassBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin,
      padding: padding,
      decoration: AdminTheme.glassDecoration(radius: borderRadius),
      child: child,
    );

    if (!blur) return box;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: box,
      ),
    );
  }
}

class AdminGlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AdminGlassSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AdminGlassBox(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: AdminTheme.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AdminTheme.textMuted,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.accent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class AdminGlassListCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final List<String> subtitles;
  final Widget? trailing;

  const AdminGlassListCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitles = const [],
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AdminGlassBox(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AdminTheme.textPrimary,
                  ),
                ),
                ...subtitles.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      s,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AdminTheme.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AdminSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AdminTheme.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AdminEmptyState extends StatelessWidget {
  final String message;

  const AdminEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AdminGlassBox(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: AdminTheme.textMuted),
        ),
      ),
    );
  }
}

/// Glass bottom navigation for admin shell.
class AdminGlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdminGlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _labels = [
    'Analytics',
    'Users',
    'Vehicles',
    'Incidents',
    'Licenses',
  ];

  static const _icons = [
    (Icons.analytics_outlined, Icons.analytics_rounded),
    (Icons.people_outline, Icons.people_rounded),
    (Icons.directions_car_outlined, Icons.directions_car_rounded),
    (Icons.warning_amber_outlined, Icons.warning_amber_rounded),
    (Icons.badge_outlined, Icons.badge_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: AdminTheme.accent.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_labels.length, (i) {
                  final selected = i == selectedIndex;
                  final icons = _icons[i];
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onDestinationSelected(i),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: selected
                                ? AdminTheme.accent.withValues(alpha: 0.18)
                                : Colors.transparent,
                            border: selected
                                ? Border.all(
                                    color: AdminTheme.accent.withValues(alpha: 0.35),
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                selected ? icons.$2 : icons.$1,
                                size: 22,
                                color: selected
                                    ? AdminTheme.accent
                                    : AdminTheme.textMuted,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight:
                                      selected ? FontWeight.w600 : FontWeight.w500,
                                  color: selected
                                      ? AdminTheme.textPrimary
                                      : AdminTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
