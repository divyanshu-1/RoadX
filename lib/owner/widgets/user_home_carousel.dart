import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

/// Glassmorphism auto-sliding carousel for the user home tab.
class UserHomeCarousel extends StatefulWidget {
  const UserHomeCarousel({super.key});

  @override
  State<UserHomeCarousel> createState() => _UserHomeCarouselState();
}

class _UserHomeCarouselState extends State<UserHomeCarousel> {
  static const _banners = [
    _BannerData(
      title: 'Drive Safe, Stay Protected',
      subtitle: 'Smart alerts & digital compliance on the road',
      icon: Icons.shield_moon_outlined,
      accent: Color(0xFF10B981),
    ),
    _BannerData(
      title: 'Check Your Challans Instantly',
      subtitle: 'Track fines, status & outstanding amount',
      icon: Icons.receipt_long_outlined,
      accent: Color(0xFF8B5CF6),
    ),
    _BannerData(
      title: 'Digital Vehicle Management',
      subtitle: 'Register, monitor & manage every vehicle',
      icon: Icons.directions_car_filled_outlined,
      accent: Color(0xFF38BDF8),
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
  }

  void _nextPage() {
    if (!_controller.hasClients) return;
    final next = (_page + 1) % _banners.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final b = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _GlassBannerCard(banner: b),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: active
                    ? LinearGradient(
                        colors: [
                          AppConstants.ownerAccent,
                          AppConstants.ownerAccent.withValues(alpha: 0.6),
                        ],
                      )
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.2),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppConstants.ownerAccent.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _GlassBannerCard extends StatelessWidget {
  final _BannerData banner;

  const _GlassBannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.14),
                banner.accent.withValues(alpha: 0.18),
                const Color(0xFF0F172A).withValues(alpha: 0.55),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: banner.accent.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -24,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: banner.accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                left: -16,
                bottom: -20,
                child: Icon(
                  banner.icon,
                  size: 110,
                  color: banner.accent.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [
                            banner.accent.withValues(alpha: 0.35),
                            banner.accent.withValues(alpha: 0.12),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: banner.accent.withValues(alpha: 0.25),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(banner.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner.title,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.25,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
