import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../pages/login_selection_screen.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/premium_background.dart';
import 'rto_dashboard_screen.dart';
import 'rto_vehicle_list_screen.dart';
import 'rto_search_vehicle_screen.dart';
import 'rto_challan_tab.dart';
import 'rto_data_provider.dart';
import 'rto_issue_challan_screen.dart';

/// RTO shell with AppBar logout and shared realtime cache.
class RtoShellScreen extends StatelessWidget {
  final String officerId;
  final String officerName;

  const RtoShellScreen({
    super.key,
    required this.officerId,
    required this.officerName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RtoDataProvider()..startListening(),
      child: _RtoShellBody(officerId: officerId, officerName: officerName),
    );
  }
}

class _RtoShellBody extends StatefulWidget {
  final String officerId;
  final String officerName;

  const _RtoShellBody({
    required this.officerId,
    required this.officerName,
  });

  @override
  State<_RtoShellBody> createState() => _RtoShellBodyState();
}

class _RtoShellBodyState extends State<_RtoShellBody> {
  int _index = 0;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
      (_) => false,
    );
    CustomSnackBar.success(context, 'Logged out successfully');
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Dashboard',
      'Vehicles',
      'Search',
      'Challans',
      'Issue Challan',
    ];
    final pages = [
      RtoDashboardScreen(officerId: widget.officerId),
      const RtoVehicleListScreen(),
      RtoSearchVehicleScreen(officerName: widget.officerName),
      RtoChallanTab(
        officerName: widget.officerName,
        onIssueChallan: () => setState(() => _index = 4),
      ),
      RtoIssueChallanScreen(officerName: widget.officerName),
    ];

    return PremiumBackground(
      gradientColors: const [
        Color(0xFF0A0F1C),
        Color(0xFF1C1917),
        Color(0xFF0F172A),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            titles[_index],
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: AppConstants.rtoAccent.withValues(alpha: 0.25),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              selectedIcon: Icon(Icons.list_alt),
              label: 'Vehicles',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Challans',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_card_outlined),
              selectedIcon: Icon(Icons.add_card),
              label: 'Issue',
            ),
          ],
        ),
      ),
    );
  }
}
