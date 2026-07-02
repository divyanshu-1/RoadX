import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../screens.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A), // Slate 900 (Dark Deep Blue)
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background blobs / shapes
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8).withOpacity(0.1), // Light Blue glow
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0EA5E9).withOpacity(0.08), // Primary Blue glow
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo & Title
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withOpacity(0.2),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.traffic_rounded,
                              size: 56,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'RoadX',
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF38BDF8).withOpacity(0.5),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SMART TRAFFIC & FLEET MANAGEMENT SYSTEM',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Welcome text
                        Text(
                          'Welcome to RoadX',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Select your portal to sign in',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Login selection grid
                        AnimationLimiter(
                          child: isDesktop
                              ? GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.6,
                                  children: _buildSelectionCards(context),
                                )
                              : ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: AnimationConfiguration.toStaggeredList(
                                    duration: const Duration(milliseconds: 375),
                                    childAnimationBuilder: (widget) => SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(child: widget),
                                    ),
                                    children: _buildSelectionCards(context),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),

                        // Footer / Version Info
                        Text(
                          'RoadX Security Protocol v1.4 • Encrypted Connection',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectionCards(BuildContext context) {
    final List<Map<String, dynamic>> cardData = [
      {
        'title': 'User Login',
        'subtitle': 'Primary user portal',
        'icon': Icons.person_rounded,
        'description':
            'Manage vehicles, drivers, challans, and your RoadX profile.',
        'route': AppRoutes.carOwnerLogin,
        'accentColor': const Color(0xFF10B981),
      },
      {
        'title': 'Admin Login',
        'subtitle': 'RoadX management/admin',
        'icon': Icons.admin_panel_settings_rounded,
        'description':
            'Supervise platform incidents, verify users, and adjust database settings.',
        'route': AppRoutes.adminLogin,
        'accentColor': const Color(0xFFF43F5E),
      },
      {
        'title': 'RTO Login',
        'subtitle': 'RTO officers/admin access',
        'icon': Icons.security_rounded,
        'description':
            'Verify vehicle status, inspect documents, and issue traffic challans.',
        'route': AppRoutes.rtoLogin,
        'accentColor': const Color(0xFFF59E0B),
      },
    ];

    return cardData.map((data) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: RoleSelectionCard(
          title: data['title'],
          subtitle: data['subtitle'],
          description: data['description'],
          icon: data['icon'],
          route: data['route'],
          accentColor: data['accentColor'],
        ),
      );
    }).toList();
  }
}

// Reusable animated Role Selection Card
class RoleSelectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;

  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
  });

  @override
  State<RoleSelectionCard> createState() => _RoleSelectionCardState();
}

class _RoleSelectionCardState extends State<RoleSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    Navigator.pushNamed(context, widget.route);
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowHoverHighlight: (value) {
        setState(() {
          _isHovered = value;
        });
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Glassmorphic background
              color: _isHovered
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.accentColor.withOpacity(0.12)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon wrapper with pulse glow on hover
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? widget.accentColor.withOpacity(0.2)
                        : widget.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.accentColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Tiny chevron indicating navigation
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isHovered ? widget.accentColor : const Color(0xFF475569),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
