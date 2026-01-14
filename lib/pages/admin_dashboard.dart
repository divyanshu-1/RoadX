import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../screens.dart';

class AdminPanelGuarded extends StatelessWidget {
  const AdminPanelGuarded({super.key});

  Future<bool> _checkIsAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    return data['isAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = snapshot.data == true;

        if (!isAdmin) {
          // Redirect non-admins away from the admin panel
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Admin access required'),
              ),
            );
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.userShell,
              (route) => false,
            );
          });

          return const Scaffold(
            body: SizedBox.shrink(),
          );
        }

        return const AdminPanel();
      },
    );
  }
}

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? selectedView;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('RoadX Admin'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.button,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: selectedView == null ? _buildMainMenu() : _buildSelectedView(),
    );
  }

  Widget _buildMainMenu() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _MenuListTile(
          icon: Icons.dashboard,
          title: 'Dashboard Overview',
          onTap: () => setState(() => selectedView = 'dashboard'),
        ),
        _MenuListTile(
          icon: Icons.people,
          title: 'Users',
          onTap: () => setState(() => selectedView = 'users'),
        ),
        _MenuListTile(
          icon: Icons.directions_car,
          title: 'Vehicles',
          onTap: () => setState(() => selectedView = 'vehicles'),
        ),
        _MenuListTile(
          icon: Icons.warning,
          title: 'Incidents',
          onTap: () => setState(() => selectedView = 'incidents'),
        ),
      ],
    );
  }

  Widget _buildSelectedView() {
    switch (selectedView) {
      case 'dashboard':
        return _DashboardOverview(onBack: () => setState(() => selectedView = null));
      case 'users':
        return _UsersView(onBack: () => setState(() => selectedView = null));
      case 'vehicles':
        return _VehiclesView(onBack: () => setState(() => selectedView = null));
      case 'incidents':
        return _IncidentsView(onBack: () => setState(() => selectedView = null));
      default:
        return _buildMainMenu();
    }
  }
}

class _MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuListTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primarySkyBlue, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

// Dashboard Overview
class _DashboardOverview extends StatelessWidget {
  final VoidCallback onBack;

  const _DashboardOverview({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final totalUsers = data['totalUsers'] ?? 0;
        final totalVehicles = data['totalVehicles'] ?? 0;
        final totalIncidents = data['totalIncidents'] ?? 0;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            title: const Text('Dashboard Overview'),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(gradient: AppGradients.button),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    title: 'Total Users',
                    value: totalUsers.toString(),
                    icon: Icons.people,
                    color: AppColors.primarySkyBlue,
                  ),
                  _StatCard(
                    title: 'Total Vehicles',
                    value: totalVehicles.toString(),
                    icon: Icons.directions_car,
                    color: AppColors.accentLightBlue,
                  ),
                  _StatCard(
                    title: 'Total Incidents',
                    value: totalIncidents.toString(),
                    icon: Icons.warning,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final vehiclesSnapshot = await FirebaseFirestore.instance.collection('vehicles').get();
      final incidentsSnapshot = await FirebaseFirestore.instance.collection('incidents').get();

      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalVehicles': vehiclesSnapshot.docs.length,
        'totalIncidents': incidentsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// Users View
class _UsersView extends StatelessWidget {
  final VoidCallback onBack;

  const _UsersView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Users'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final userDoc = docs[index];
              final rawUser = userDoc.data();
              final userData = rawUser is Map<String, dynamic> ? rawUser : <String, dynamic>{};

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.person, color: AppColors.primarySkyBlue),
                  title: Text(
                    userData['name'] ?? userData['email'] ?? 'Unknown User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(userData['email'] ?? 'N/A'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Vehicles View
class _VehiclesView extends StatelessWidget {
  final VoidCallback onBack;

  const _VehiclesView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Vehicles'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadAllVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No vehicles found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final vehicle = snapshot.data![index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: AppColors.primarySkyBlue),
                  title: Text(
                    vehicle['vehicle_no'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model: ${vehicle['model'] ?? 'N/A'}'),
                      Text('Owner: ${vehicle['owner_name'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadAllVehicles() async {
    try {
      final vehiclesSnapshot = await FirebaseFirestore.instance.collection('vehicles').get();
      final vehicles = vehiclesSnapshot.docs;
      final List<Map<String, dynamic>> enriched = [];

      // Get all unique owner UIDs
      final ownerUids = vehicles
          .map((v) => v.data()['owner_uid'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      // Fetch all owners in one batch
      final Map<String, String> ownerNames = {};
      for (final uid in ownerUids) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          final userData = userDoc.data() ?? {};
          ownerNames[uid] = userData['name'] ?? userData['email'] ?? 'Unknown';
        } catch (e) {
          ownerNames[uid] = 'Unknown';
        }
      }

      // Enrich vehicles with owner names
      for (final vehicleDoc in vehicles) {
        final Map<String, dynamic> vehicleData = vehicleDoc.data();
        final ownerUid = vehicleData['owner_uid'] as String?;

        enriched.add({
          ...vehicleData,
          'owner_name': ownerNames[ownerUid] ?? 'Unknown',
        });
      }

      return enriched;
    } catch (e) {
      throw Exception('Failed to load vehicles: $e');
    }
  }
}

// Incidents View
class _IncidentsView extends StatelessWidget {
  final VoidCallback onBack;

  const _IncidentsView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Incidents'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('incidents')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No incidents reported'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final incidentDoc = docs[index];
              final raw = incidentDoc.data();
              final incidentData = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
              final type = incidentData['type'] as String? ?? 'unknown';
              final timestamp = incidentData['timestamp'] as Timestamp?;
              final vehicleNo = incidentData['vehicle_no'] as String? ?? 'N/A';
              final ownerName = incidentData['owner_name'] as String? ?? 'N/A';
              final status = incidentData['status'] as String? ?? 'reported';
              final location = incidentData['location'] as String? ?? 'N/A';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primarySkyBlue,
                    child: Icon(
                      _getTypeIcon(type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _getTypeDisplay(type),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: $vehicleNo'),
                      Text('Owner: $ownerName'),
                      Text('Location: $location'),
                      Text('Status: ${_getStatusDisplay(status)}'),
                      if (timestamp != null)
                        Text(
                          'Time: ${timestamp.toDate().toString().substring(0, 19)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'theft':
        return Icons.car_crash;
      case 'scam_fraud':
        return Icons.warning;
      case 'unauthorized_driver':
        return Icons.person_off;
      default:
        return Icons.error;
    }
  }

  String _getTypeDisplay(String type) {
    switch (type) {
      case 'theft':
        return 'Theft (Gadi chori)';
      case 'scam_fraud':
        return 'Scam/Fraud';
      case 'unauthorized_driver':
        return 'Unauthorized Driver';
      case 'other':
        return 'Other Incident';
      default:
        return type;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'reported':
        return 'Reported';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
