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

class _UserShellState extends State<UserShell> with TickerProviderStateMixin {
  int index = 0;
  late final PageController _pageController;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // Use const pages where possible so state inside each tab is preserved
    pages = const [
      HomePage(),
      DashboardPage(),
      EmergencyPage(),
      ProfilePage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int newIndex) {
    if (newIndex != index) {
      setState(() => index = newIndex);
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to RoadX',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.button,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Use PageView with bubble transition effect
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) => setState(() => index = newIndex),
        children: pages,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: SemiCircularBottomNav(
        currentIndex: index,
        onTap: _onNavTap,
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

// Enhanced bottom navigation with smooth animations
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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(SemiCircularBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassBottomNav(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      animationController: _animationController,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.warning_outlined),
          selectedIcon: Icon(Icons.warning),
          label: 'Incident',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}


