import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/authorized_user_model.dart';
import '../models/vehicle_model.dart';
import '../services/authorized_user_service.dart';
import '../services/owner_vehicle_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import 'widgets/user_shared_widgets.dart';

/// Authorized Drivers tab.
class UserDriversTab extends StatefulWidget {
  const UserDriversTab({super.key});

  @override
  State<UserDriversTab> createState() => _UserDriversTabState();
}

class _UserDriversTabState extends State<UserDriversTab> {
  final _vehicleService = OwnerVehicleService();
  final _driverService = AuthorizedUserService();

  final _driverFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardController = TextEditingController();
  final _relationController = TextEditingController();
  String? _selectedVehicleId;
  bool _savingDriver = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cardController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _addDriver(String uid, List<VehicleModel> vehicles) async {
    if (!_driverFormKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      CustomSnackBar.error(context, 'Select a vehicle first');
      return;
    }
    final vehicle = vehicles.firstWhere((v) => v.vehicleId == _selectedVehicleId);

    setState(() => _savingDriver = true);
    try {
      await _driverService.addAuthorizedDriver(
        ownerUid: uid,
        vehicleId: vehicle.vehicleId,
        vehicleNumber: vehicle.vehicleNo,
        userName: _nameController.text,
        phone: _phoneController.text,
        cardId: _cardController.text,
        relation: _relationController.text,
      );
      if (!mounted) return;
      CustomSnackBar.success(context, 'Authorized driver added');
      _nameController.clear();
      _phoneController.clear();
      _cardController.clear();
      _relationController.clear();
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _savingDriver = false);
    }
  }

  Future<void> _editDriver(String uid, AuthorizedUserModel driver) async {
    final nameCtrl = TextEditingController(text: driver.userName);
    final phoneCtrl = TextEditingController(text: driver.phone);
    final cardCtrl = TextEditingController(text: driver.cardId);
    final relationCtrl = TextEditingController(text: driver.relation);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Driver', style: GoogleFonts.outfit(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: relationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Relation'),
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
      nameCtrl.dispose();
      phoneCtrl.dispose();
      cardCtrl.dispose();
      relationCtrl.dispose();
      return;
    }

    try {
      await _driverService.updateAuthorizedDriver(
        ownerUid: uid,
        vehicleId: driver.vehicleId,
        driverId: driver.authUserId,
        userName: nameCtrl.text,
        phone: phoneCtrl.text,
        cardId: cardCtrl.text,
        relation: relationCtrl.text,
      );
      if (mounted) CustomSnackBar.success(context, 'Driver updated');
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, e.toString());
    } finally {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      cardCtrl.dispose();
      relationCtrl.dispose();
    }
  }

  Future<void> _removeDriver(String uid, AuthorizedUserModel driver) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Remove Driver?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
          'Remove ${driver.userName} from authorized drivers?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _driverService.removeAuthorizedDriver(
        ownerUid: uid,
        vehicleId: driver.vehicleId,
        driverId: driver.authUserId,
      );
      if (mounted) CustomSnackBar.success(context, 'Driver removed');
    } catch (e) {
      if (mounted) CustomSnackBar.error(context, e.toString());
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
        if (_selectedVehicleId == null && vehicles.isNotEmpty) {
          _selectedVehicleId = vehicles.first.vehicleId;
        }

        return StreamBuilder<List<AuthorizedUserModel>>(
          stream: _driverService.watchAllAuthorizedDrivers(uid),
          builder: (context, driverSnap) {
            final drivers = driverSnap.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                userSectionTitle('Authorized Drivers'),
                if (vehicles.isEmpty)
                  userEmptyNote('Register a vehicle first before adding drivers.')
                else ...[
                  userGlassCard(
                    title: 'ADD DRIVER',
                    icon: Icons.person_add_alt_1_rounded,
                    child: Form(
                      key: _driverFormKey,
                      child: Column(
                        children: [
                          _vehicleSelector(vehicles),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Driver full name',
                            prefixIcon: Icons.person_outline,
                            accentColor: AppConstants.ownerAccent,
                            validator: (v) => Validators.required(v, 'Name'),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _phoneController,
                            hintText: 'Phone number',
                            prefixIcon: Icons.phone_android_outlined,
                            accentColor: AppConstants.ownerAccent,
                            validator: Validators.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _cardController,
                            hintText: 'License / ID number',
                            prefixIcon: Icons.badge_outlined,
                            accentColor: AppConstants.ownerAccent,
                            validator: (v) => Validators.required(v, 'ID number'),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _relationController,
                            hintText: 'Relationship',
                            prefixIcon: Icons.family_restroom_outlined,
                            accentColor: AppConstants.ownerAccent,
                            validator: (v) => Validators.required(v, 'Relation'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _savingDriver ? null : () => _addDriver(uid, vehicles),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(_savingDriver ? 'Saving...' : 'Add Driver'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.ownerAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (drivers.isEmpty)
                    userEmptyNote('No authorized drivers yet.')
                  else
                    ...drivers.map(
                      (d) => userDriverTile(
                        name: d.userName,
                        phone: d.phone,
                        relation: '${d.vehicleNumber} • ${d.relation}',
                        status: d.status,
                        onEdit: () => _editDriver(uid, d),
                        onRemove: () => _removeDriver(uid, d),
                      ),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _vehicleSelector(List<VehicleModel> vehicles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleId,
          isExpanded: true,
          hint: const Text('Select vehicle', style: TextStyle(color: Colors.white54)),
          dropdownColor: AppConstants.darkBgEnd,
          style: const TextStyle(color: Colors.white),
          items: vehicles
              .map(
                (v) => DropdownMenuItem(
                  value: v.vehicleId,
                  child: Text('${v.vehicleNo} (${v.vehicleType})'),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedVehicleId = v),
        ),
      ),
    );
  }
}
