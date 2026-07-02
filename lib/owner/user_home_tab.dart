import 'package:flutter/material.dart';
import 'user_challan_history_screen.dart';
import 'user_incident_history_screen.dart';
import 'user_register_vehicle_screen.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/user_home_carousel.dart';
import 'widgets/user_shared_widgets.dart';

/// User dashboard home tab — glass carousel & quick actions.
class UserHomeTab extends StatelessWidget {
  final VoidCallback onOpenVehicles;
  final VoidCallback onOpenDrivers;

  const UserHomeTab({
    super.key,
    required this.onOpenVehicles,
    required this.onOpenDrivers,
  });

  void _push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const UserHomeCarousel(),
        const SizedBox(height: 28),
        userSectionTitle('Quick Actions'),
        QuickActionGrid(
          actions: [
            QuickActionItem(
              title: 'Register Vehicle',
              description: 'Add a new vehicle to your account',
              icon: Icons.add_circle_outline,
              color: const Color(0xFF10B981),
              onTap: () => _push(context, const UserRegisterVehicleScreen()),
            ),
            QuickActionItem(
              title: 'Incident History',
              description: 'View your reported incidents',
              icon: Icons.history_rounded,
              color: const Color(0xFFEF4444),
              onTap: () => _push(context, const UserIncidentHistoryScreen()),
            ),
            QuickActionItem(
              title: 'Challan History',
              description: 'Track fines and payments',
              icon: Icons.receipt_long_outlined,
              color: const Color(0xFFA78BFA),
              onTap: () => _push(context, const UserChallanHistoryScreen()),
            ),
            QuickActionItem(
              title: 'Authorized Drivers',
              description: 'Manage driver access',
              icon: Icons.groups_outlined,
              color: const Color(0xFF38BDF8),
              onTap: onOpenDrivers,
            ),
          ],
        ),
      ],
    );
  }
}
