import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/owner_auth_provider.dart';
import '../screens.dart';
import '../utils/app_constants.dart';
import '../widgets/premium_background.dart';
import 'user_drivers_tab.dart';
import 'user_home_tab.dart';
import 'user_profile_tab.dart';
import 'user_vehicles_tab.dart';

/// User dashboard — Home, Vehicles, Drivers, Profile.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _tabIndex = 0;

  String get _tabTitle {
    switch (_tabIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'My Vehicles';
      case 2:
        return 'Drivers';
      case 3:
        return 'Profile';
      default:
        return 'User Dashboard';
    }
  }

  Future<void> _logout() async {
    await context.read<OwnerAuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      child: PremiumBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              _tabTitle,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              UserHomeTab(
                onOpenVehicles: () => setState(() => _tabIndex = 1),
                onOpenDrivers: () => setState(() => _tabIndex = 2),
              ),
              const UserVehiclesTab(),
              const UserDriversTab(),
              const UserProfileTab(),
            ],
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  fontSize: 10,
                  color: states.contains(WidgetState.selected)
                      ? AppConstants.ownerAccent
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              backgroundColor: const Color(0xFF0F172A),
              indicatorColor: AppConstants.ownerAccent.withValues(alpha: 0.25),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.directions_car_outlined),
                  selectedIcon: Icon(Icons.directions_car_rounded),
                  label: 'Vehicles',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups_rounded),
                  label: 'Drivers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
