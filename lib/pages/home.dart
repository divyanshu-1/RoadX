import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets/carousel_slider.dart';
import 'vehicle_registration.dart';
import 'emergency_screen.dart';
import 'driver_registration.dart';
import 'incident_history.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider
            const RoadXCarousel(),
            
            // Dashboard Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Feature Cards Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _FeatureCard(
                        icon: Icons.directions_car,
                        title: 'Register Vehicle',
                        description: 'Add your vehicle details',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VehicleRegistrationPage()),
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.warning,
                        title: 'Report Incident',
                        description: 'Report emergencies',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.history,
                        title: 'Incident History',
                        description: 'View past reports',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IncidentHistoryPage(),
                          ),
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.person_add,
                        title: 'Authorized Drivers',
                        description: 'Manage drivers',
                        onTap: () => _showVehicleSelector(context, uid, (vehicleId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DriverRegistrationPage(vehicleId: vehicleId),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Quick Stats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
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
                      final vehicleCount = snapshot.data?.docs.length ?? 0;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.directions_car,
                              label: 'Vehicles',
                              value: vehicleCount.toString(),
                              color: AppColors.primarySkyBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('incidents')
                                  .where('userId', isEqualTo: uid)
                                  .snapshots(),
                              builder: (context, incidentSnapshot) {
                                final incidentCount = incidentSnapshot.data?.docs.length ?? 0;
                                return _StatCard(
                                  icon: Icons.warning,
                                  label: 'Incidents',
                                  value: incidentCount.toString(),
                                  color: AppColors.primarySkyBlue,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleSelector(
    BuildContext context,
    String uid,
    Function(String) onVehicleSelected,
  ) {
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySkyBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primarySkyBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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
