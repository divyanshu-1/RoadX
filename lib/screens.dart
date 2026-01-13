import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/home.dart';
import 'pages/dashboard.dart';
import 'pages/emergency_screen.dart';
import 'pages/profile.dart';

// Route names
class AppRoutes {
  static const String login = '/';
  static const String userShell = '/user';
  static const String admin = '/admin';
  static const String emergency = '/emergency';
}

// GlassCard lives in theme.dart. Login/Admin pages live under pages/.

// User Shell with Bottom Navigation
class UserShell extends StatefulWidget {
  const UserShell({super.key});
  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int index = 0;
  final List<Widget> pages = [
    const HomePage(),
    const DashboardPage(),
    const EmergencyPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('RoadX'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.button,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: pages[index],
      bottomNavigationBar: SemiCircularBottomNav(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

// Home page lives in pages/home.dart

// Car details page lives in pages/car_details.dart

// Owner details page lives in pages/owner_details.dart

// Members page lives in pages/authorized_members.dart

// Emergency page wrapper
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmergencyScreen();
  }
}

// Semi-circular bottom navigation with center button
class SemiCircularBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SemiCircularBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<SemiCircularBottomNav> createState() => _SemiCircularBottomNavState();
}

class _SemiCircularBottomNavState extends State<SemiCircularBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Semi-circular notch
          Positioned(
            top: -20,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Navigation items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  flex: 1,
                  child: _NavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    currentIndex: widget.currentIndex,
                    onTap: () => widget.onTap(0),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: _NavItem(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'Dashboard',
                    index: 1,
                    currentIndex: widget.currentIndex,
                    onTap: () => widget.onTap(1),
                  ),
                ),
                // Center Emergency button - fixed width
                SizedBox(
                  width: 60,
                  child: GestureDetector(
                    onTapDown: (_) {
                      _controller.forward();
                    },
                    onTapUp: (_) {
                      _controller.reverse();
                      widget.onTap(2);
                    },
                    onTapCancel: () => _controller.reverse(),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          gradient: AppGradients.button,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primarySkyBlue.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: _NavItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    index: 3,
                    currentIndex: widget.currentIndex,
                    onTap: () => widget.onTap(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? AppColors.primarySkyBlue : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.primarySkyBlue : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

