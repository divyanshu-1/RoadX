import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../admin/admin_analytics_dashboard.dart';
import '../admin/providers/admin_dashboard_provider.dart';
import '../admin/admin_licenses_view.dart';
import '../admin/widgets/admin_theme.dart';
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

        return ChangeNotifierProvider(
          create: (_) => AdminDashboardProvider()..startListening(),
          child: const AdminPanel(),
        );
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
  int currentIndex = 0;
  late final PageController _pageController;
  late final List<Widget> pages;

  static const _titles = [
    'Analytics',
    'Users',
    'Vehicles',
    'Incidents',
    'Licenses',
  ];

  static const _subtitles = [
    'Live challan insights',
    'Registered platform users',
    'Fleet overview',
    'Reported incidents',
    'Driving license records',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    pages = [
      const AdminAnalyticsDashboard(),
      const _UsersView(),
      const _VehiclesView(),
      const _IncidentsView(),
      const AdminLicensesView(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AdminTheme.pageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.92),
          foregroundColor: AdminTheme.textPrimary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RoadX Admin',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              Text(
                _subtitles[currentIndex],
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AdminTheme.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(
                  _titles[currentIndex],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AdminTheme.accent,
                  ),
                ),
                backgroundColor: AdminTheme.accent.withValues(alpha: 0.15),
                side: BorderSide(
                  color: AdminTheme.accent.withValues(alpha: 0.35),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded, color: AdminTheme.textPrimary),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (newIndex) => setState(() => currentIndex = newIndex),
          children: pages,
          physics: const BouncingScrollPhysics(),
        ),
        bottomNavigationBar: AdminGlassNavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) {
            setState(() => currentIndex = i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            );
          },
        ),
      ),
    );
  }
}

// Admin Bottom Navigation Bar with enhanced styling
class AdminBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AdminBottomNav> createState() => _AdminBottomNavState();
}

class _AdminBottomNavState extends State<AdminBottomNav>
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
  void didUpdateWidget(AdminBottomNav oldWidget) {
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
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Users',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          selectedIcon: Icon(Icons.directions_car),
          label: 'Vehicles',
        ),
        NavigationDestination(
          icon: Icon(Icons.warning_outlined),
          selectedIcon: Icon(Icons.warning),
          label: 'Incidents',
        ),
        NavigationDestination(
          icon: Icon(Icons.badge_outlined),
          selectedIcon: Icon(Icons.badge),
          label: 'Licenses',
        ),
      ],
    );
  }
}

// Reusable Admin Search Bar Widget — glass style
class _AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _AdminSearchBar({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AdminGlassSearchBar(controller: controller, hintText: hintText);
  }
}

Widget _adminAvatarIcon(IconData icon, {Color? color}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AdminTheme.accent.withValues(alpha: 0.15),
      shape: BoxShape.circle,
      border: Border.all(color: AdminTheme.accent.withValues(alpha: 0.3)),
    ),
    child: Icon(icon, color: color ?? AdminTheme.accent, size: 22),
  );
}

// Users View
class _UsersView extends StatefulWidget {
  const _UsersView();

  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, String?> _userVehicleModels = {};
  bool _isLoadingVehicles = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadUserVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserVehicles() async {
    setState(() => _isLoadingVehicles = true);
    try {
      final vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .get();
      
      final Map<String, String?> vehicleModels = {};
      for (final vehicleDoc in vehiclesSnapshot.docs) {
        final vehicleData = vehicleDoc.data();
        final ownerUid = vehicleData['owner_uid'] as String?;
        final model = vehicleData['model'] as String?;
        
        if (ownerUid != null && model != null) {
          // Only store the first vehicle model per user
          if (!vehicleModels.containsKey(ownerUid)) {
            vehicleModels[ownerUid] = model;
          }
        }
      }
      
      setState(() {
        _userVehicleModels = vehicleModels;
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() => _isLoadingVehicles = false);
    }
  }

  List<QueryDocumentSnapshot> _filterUsers(List<QueryDocumentSnapshot> docs, String query) {
    if (query.isEmpty) return docs;
    
    final lowerQuery = query.toLowerCase();
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['name'] as String? ?? '').toLowerCase();
      final email = (data['email'] as String? ?? '').toLowerCase();
      return name.contains(lowerQuery) || email.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdminSectionHeader(title: 'Users'),
        _AdminSearchBar(
          controller: _searchController,
          hintText: 'Search by username or email...',
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || _isLoadingVehicles) {
                return const Center(
                  child: CircularProgressIndicator(color: AdminTheme.accent),
                );
              }

              if (snapshot.hasError) {
                return AdminEmptyState(message: 'Error: ${snapshot.error}');
              }

              final allDocs = snapshot.data?.docs ?? [];
              final filteredDocs = _filterUsers(allDocs, _searchController.text);

              if (filteredDocs.isEmpty) {
                return AdminEmptyState(
                  message: _searchController.text.isEmpty
                      ? 'No users found'
                      : 'No users match your search',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final userDoc = filteredDocs[index];
                  final rawUser = userDoc.data();
                  final userData = rawUser is Map<String, dynamic> ? rawUser : <String, dynamic>{};
                  final userId = userDoc.id;
                  final username = userData['name'] as String? ?? userData['username'] as String? ?? 'Unknown User';
                  final email = userData['email'] as String? ?? 'N/A';
                  final vehicleModel = _userVehicleModels[userId];

                  return AdminGlassListCard(
                    leading: _adminAvatarIcon(Icons.person_rounded),
                    title: username,
                    subtitles: [
                      email,
                      if (vehicleModel != null) 'Vehicle: $vehicleModel',
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// Vehicles View
class _VehiclesView extends StatefulWidget {
  const _VehiclesView();

  @override
  State<_VehiclesView> createState() => _VehiclesViewState();
}

class _VehiclesViewState extends State<_VehiclesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterVehicles(List<Map<String, dynamic>> vehicles, String query) {
    if (query.isEmpty) return vehicles;
    
    final lowerQuery = query.toLowerCase();
    return vehicles.where((vehicle) {
      final model = (vehicle['model'] as String? ?? '').toLowerCase();
      final vehicleNo = (vehicle['vehicle_no'] as String? ?? '').toLowerCase();
      return model.contains(lowerQuery) || vehicleNo.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdminSectionHeader(title: 'Vehicles'),
        _AdminSearchBar(
          controller: _searchController,
          hintText: 'Search by model or vehicle number...',
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadAllVehicles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AdminTheme.accent),
                );
              }

              if (snapshot.hasError) {
                return AdminEmptyState(message: 'Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const AdminEmptyState(message: 'No vehicles found');
              }

              final allVehicles = snapshot.data!;
              final filteredVehicles = _filterVehicles(allVehicles, _searchController.text);

              if (filteredVehicles.isEmpty) {
                return AdminEmptyState(
                  message: _searchController.text.isEmpty
                      ? 'No vehicles found'
                      : 'No vehicles match your search',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = filteredVehicles[index];

                  return AdminGlassListCard(
                    leading: _adminAvatarIcon(Icons.directions_car_rounded),
                    title: vehicle['vehicle_no'] ?? 'N/A',
                    subtitles: [
                      'Model: ${vehicle['model'] ?? 'N/A'}',
                      'Owner: ${vehicle['owner_name'] ?? 'N/A'}',
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
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
class _IncidentsView extends StatefulWidget {
  const _IncidentsView();

  @override
  State<_IncidentsView> createState() => _IncidentsViewState();
}

class _IncidentsViewState extends State<_IncidentsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot> _filterIncidents(List<QueryDocumentSnapshot> docs, String query) {
    if (query.isEmpty) return docs;
    
    final lowerQuery = query.toLowerCase();
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final type = _getTypeDisplay(data['type'] as String? ?? 'unknown').toLowerCase();
      final ownerName = (data['owner_name'] as String? ?? '').toLowerCase();
      final vehicleNo = (data['vehicle_no'] as String? ?? '').toLowerCase();
      
      return type.contains(lowerQuery) ||
          ownerName.contains(lowerQuery) ||
          vehicleNo.contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdminSectionHeader(title: 'Incidents'),
        _AdminSearchBar(
          controller: _searchController,
          hintText: 'Search by type, owner, or vehicle...',
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('incidents')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AdminTheme.accent),
                );
              }

              if (snapshot.hasError) {
                return AdminEmptyState(message: 'Error: ${snapshot.error}');
              }

              final allDocs = snapshot.data?.docs ?? [];
              final filteredDocs = _filterIncidents(allDocs, _searchController.text);

              if (filteredDocs.isEmpty) {
                return AdminEmptyState(
                  message: _searchController.text.isEmpty
                      ? 'No incidents reported'
                      : 'No incidents match your search',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final incidentDoc = filteredDocs[index];
                  final raw = incidentDoc.data();
                  final incidentData = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                  final type = incidentData['type'] as String? ?? 'unknown';
                  final timestamp = incidentData['timestamp'] as Timestamp?;
                  final vehicleNo = incidentData['vehicle_no'] as String? ?? 'N/A';
                  final ownerName = incidentData['owner_name'] as String? ?? 'N/A';
                  final status = incidentData['status'] as String? ?? 'reported';
                  final location = incidentData['location'] as String? ?? 'N/A';

                  return AdminGlassListCard(
                    leading: _adminAvatarIcon(_getTypeIcon(type)),
                    title: _getTypeDisplay(type),
                    subtitles: [
                      'Vehicle: $vehicleNo',
                      'Owner: $ownerName',
                      'Location: $location',
                      'Status: ${_getStatusDisplay(status)}',
                      if (timestamp != null)
                        'Time: ${timestamp.toDate().toString().substring(0, 19)}',
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
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
