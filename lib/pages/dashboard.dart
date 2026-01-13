import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import 'vehicle_registration.dart';
import 'vehicle_documents.dart';
import 'driver_registration.dart';
import 'emergency_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<int> _getActiveDriversCount(String userId) async {
    try {
      // Get user's vehicles
      final vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('owner_uid', isEqualTo: userId)
          .get();
      
      final userVehicleIds = vehiclesSnapshot.docs.map((v) => v.id).toSet();
      
      // Get all drivers
      final driversSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .get();
      
      // Count active drivers for user's vehicles
      int count = 0;
      for (final driverDoc in driversSnapshot.docs) {
        final driverData = driverDoc.data();
        final vehicleId = driverData['vehicleId'] as String?;
        final isActive = driverData['isActive'] == true;
        
        if (vehicleId != null && userVehicleIds.contains(vehicleId) && isActive) {
          count++;
        }
      }
      
      return count;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('vehicles')
                        .where('owner_uid', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final vehicleCount = snapshot.data?.docs.length ?? 0;
                      return _StatCard(
                        icon: Icons.directions_car,
                        label: 'Total Vehicles',
                        value: vehicleCount.toString(),
                        color: AppColors.primarySkyBlue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('incidents')
                        .where('userId', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final incidentCount = snapshot.data?.docs.length ?? 0;
                      return _StatCard(
                        icon: Icons.warning,
                        label: 'Total Incidents',
                        value: incidentCount.toString(),
                        color: AppColors.primarySkyBlue,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: _getActiveDriversCount(uid),
              builder: (context, snapshot) {
                final activeDrivers = snapshot.data ?? 0;
                return _StatCard(
                  icon: Icons.person,
                  label: 'Active Drivers',
                  value: activeDrivers.toString(),
                  color: Colors.green,
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.directions_car,
                    label: 'Register Vehicle',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehicleRegistrationPage()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.warning,
                    label: 'Report Incident',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.folder,
                    label: 'Documents',
                    onTap: () => _showVehicleSelector(context, (vehicleId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleDocumentsPage(vehicleId: vehicleId),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.person_add,
                    label: 'Add Driver',
                    onTap: () => _showVehicleSelector(context, (vehicleId) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DriverRegistrationPage(vehicleId: vehicleId),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Vehicles
            const Text(
              'My Vehicles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vehicles')
                  .where('owner_uid', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final vehicles = snapshot.data?.docs ?? [];

                if (vehicles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No vehicles registered yet.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return Column(
                  children: vehicles.take(3).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: AppColors.primarySkyBlue),
                        title: Text(
                          data['vehicle_no'] ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Model: ${data['model'] ?? 'N/A'}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleSelector(BuildContext context, Function(String) onVehicleSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Vehicle'),
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vehicles')
              .where('owner_uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final vehicles = snapshot.data?.docs ?? [];

            if (vehicles.isEmpty) {
              return const Text('No vehicles registered. Please register a vehicle first.');
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final data = vehicle.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(data['vehicle_no'] ?? 'N/A'),
                    subtitle: Text('Model: ${data['model'] ?? 'N/A'}'),
                    onTap: () {
                      Navigator.pop(context);
                      onVehicleSelected(vehicle.id);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySkyBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primarySkyBlue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primarySkyBlue, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
