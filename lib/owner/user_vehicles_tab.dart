import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/challan_model.dart';
import '../models/vehicle_model.dart';
import '../services/challan_service.dart';
import '../services/firebase_owner_service.dart';
import '../services/owner_vehicle_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/loading_indicator.dart';
import 'user_register_vehicle_screen.dart';
import 'widgets/user_shared_widgets.dart';

/// My Vehicles tab.
class UserVehiclesTab extends StatefulWidget {
  const UserVehiclesTab({super.key});

  @override
  State<UserVehiclesTab> createState() => _UserVehiclesTabState();
}

class _UserVehiclesTabState extends State<UserVehiclesTab> {
  final _ownerService = FirebaseOwnerService();
  final _vehicleService = OwnerVehicleService();
  final _challanService = ChallanService();

  int _challansForPlate(List<ChallanModel> challans, String plate) {
    return _challanService.countForVehicle(challans, plate);
  }

  String _formatDate(VehicleModel v) {
    if (v.addedAt == null) return '—';
    return DateFormat('dd MMM yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(v.addedAt!));
  }

  Future<void> _editVehicle(String uid, VehicleModel vehicle) async {
    String vehicleType = vehicle.vehicleType;
    final rcCtrl = TextEditingController(text: vehicle.rcNumber);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Vehicle', style: GoogleFonts.outfit(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setLocal) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vehicle.vehicleNo,
                style: GoogleFonts.outfit(color: AppConstants.ownerAccent, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: vehicleType,
                dropdownColor: AppConstants.darkBgEnd,
                style: const TextStyle(color: Colors.white),
                items: AppConstants.vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setLocal(() => vehicleType = v);
                },
              ),
              TextField(
                controller: rcCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'RC Number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || !mounted) {
      rcCtrl.dispose();
      return;
    }

    try {
      await _ownerService.updateVehicleDetails(
        uid: uid,
        vehicleId: vehicle.vehicleId,
        vehicleNo: vehicle.vehicleNo,
        vehicleType: vehicleType,
        rcNumber: rcCtrl.text,
      );
      if (mounted) CustomSnackBar.success(context, 'Vehicle updated');
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, e.toString());
    } finally {
      rcCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: AppLoadingIndicator());

    return StreamBuilder<List<VehicleModel>>(
      stream: _vehicleService.watchVehicles(uid),
      builder: (context, vehicleSnap) {
        final vehicles = vehicleSnap.data ?? [];

        return StreamBuilder<List<ChallanModel>>(
          stream: _challanService.watchChallansForOwner(uid),
          builder: (context, challanSnap) {
            final challans = challanSnap.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userSectionTitle('My Vehicles'),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserRegisterVehicleScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppConstants.ownerAccent,
                      ),
                    ),
                  ],
                ),
                if (vehicles.isEmpty)
                  userEmptyNote('No vehicles registered yet.')
                else
                  ...vehicles.map(
                    (v) => _vehicleCard(
                      v,
                      _challansForPlate(challans, v.vehicleNo),
                      () => _editVehicle(uid, v),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _vehicleCard(VehicleModel v, int challanCount, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConstants.ownerAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_filled, color: AppConstants.ownerAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  v.vehicleNo,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(color: AppConstants.ownerAccent),
                ),
              ),
            ],
          ),
          _detailRow('Type', v.vehicleType),
          _detailRow('Registered', _formatDate(v)),
          _detailRow('Active Challans', '$challanCount'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
