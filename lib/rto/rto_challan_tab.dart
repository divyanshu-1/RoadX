import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/vehicle_model.dart';
import '../services/challan_service.dart';
import '../utils/app_constants.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'rto_data_provider.dart';
import 'rto_issue_challan_screen.dart';
import 'rto_vehicle_challan_details_screen.dart';
import '../widgets/premium_background.dart';

/// RTO Challan tab — registered vehicles with challan counts.
class RtoChallanTab extends StatefulWidget {
  final String officerName;
  final VoidCallback? onIssueChallan;

  const RtoChallanTab({
    super.key,
    required this.officerName,
    this.onIssueChallan,
  });

  @override
  State<RtoChallanTab> createState() => _RtoChallanTabState();
}

class _RtoChallanTabState extends State<RtoChallanTab> {
  final _challanService = ChallanService();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VehicleModel> _filter(List<VehicleModel> vehicles) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return vehicles;
    return vehicles
        .where(
          (v) =>
              v.vehicleNo.toLowerCase().contains(q) ||
              v.ownerName.toLowerCase().contains(q) ||
              v.vehicleType.toLowerCase().contains(q),
        )
        .toList();
  }

  void _openIssueChallan() {
    if (widget.onIssueChallan != null) {
      widget.onIssueChallan!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeCtx) => ChangeNotifierProvider.value(
          value: context.read<RtoDataProvider>(),
          child: PremiumBackground(
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
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  'Issue Challan',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: RtoIssueChallanScreen(officerName: widget.officerName),
            ),
          ),
        ),
      ),
    );
  }

  void _openVehicleChallans(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RtoVehicleChallanDetailsScreen(vehicle: vehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openIssueChallan,
        backgroundColor: AppConstants.rtoAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Issue Challan',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              'Challan Management',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search vehicle, owner, type...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<VehicleModel>>(
              stream: _challanService.watchRegisteredVehicles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: AppLoadingIndicator(color: AppConstants.rtoAccent),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            snapshot.error.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final vehicles = _filter(snapshot.data ?? []);

                if (vehicles.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(
                          snapshot.data?.isEmpty ?? true
                              ? 'No registered vehicles yet.'
                              : 'No vehicles match your search.',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 24,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _VehicleChallanCard(
                                vehicle: vehicle,
                                onTap: () => _openVehicleChallans(vehicle),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleChallanCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const _VehicleChallanCard({
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasChallans = vehicle.totalChallanCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DarkGlassCard(
          borderColor: hasChallans
              ? AppConstants.rtoAccent.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.rtoAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppConstants.rtoAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.vehicleNo,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.vehicleType,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.ownerName.isNotEmpty
                          ? vehicle.ownerName
                          : 'Owner unknown',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${vehicle.totalChallanCount}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: hasChallans
                          ? AppConstants.rtoAccent
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Challans',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
