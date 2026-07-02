import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/registered_vehicle_model.dart';
import '../utils/app_constants.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import 'rto_data_provider.dart';

/// Live vehicle list with search and pull-to-refresh.
class RtoVehicleListScreen extends StatefulWidget {
  const RtoVehicleListScreen({super.key});

  @override
  State<RtoVehicleListScreen> createState() => _RtoVehicleListScreenState();
}

class _RtoVehicleListScreenState extends State<RtoVehicleListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RtoDataProvider>(
      builder: (context, rto, _) {
        final vehicles = rto.filterVehicles(
          query: _searchController.text,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Registered Vehicles',
                style: GoogleFonts.outfit(
                  fontSize: 24,
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
                  hintText: 'Search plate, owner, type...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
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
              child: _buildBody(rto, vehicles),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(RtoDataProvider rto, List<RegisteredVehicleModel> vehicles) {
    if (rto.isLoading && !rto.hasData) {
      return const Center(
        child: AppLoadingIndicator(color: AppConstants.rtoAccent),
      );
    }

    if (rto.error != null && !rto.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                rto.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: rto.refresh, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: rto.refresh,
      color: AppConstants.rtoAccent,
      child: vehicles.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Text(
                    rto.owners.isEmpty
                        ? 'No vehicles registered yet.'
                        : 'No vehicles match your search.',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            )
          : AnimationLimiter(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final v = vehicles[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 24,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _VehicleTile(vehicle: v),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final RegisteredVehicleModel vehicle;

  const _VehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final hasPending = vehicle.pendingChallanCount > 0;
    return DarkGlassCard(
      borderColor: hasPending
          ? Colors.orange.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded,
                  color: AppConstants.rtoAccent, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vehicle.vehicleNumber,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _chip(vehicle.challanStatus, hasPending),
            ],
          ),
          const SizedBox(height: 10),
          _line('Owner', vehicle.ownerName),
          _line('Type', vehicle.vehicleType),
          _line('Registered', vehicle.registrationDate),
          _line('Challan Count', '${vehicle.totalChallanCount}'),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF64748B))),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _chip(String text, bool warn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (warn ? Colors.orange : Colors.green).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: warn ? Colors.orange : Colors.green,
        ),
      ),
    );
  }
}
