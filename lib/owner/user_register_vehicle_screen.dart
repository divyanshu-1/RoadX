import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_owner_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';
import 'widgets/user_shared_widgets.dart';

/// Register a new vehicle — reuses existing owner vehicle registration.
class UserRegisterVehicleScreen extends StatefulWidget {
  const UserRegisterVehicleScreen({super.key});

  @override
  State<UserRegisterVehicleScreen> createState() =>
      _UserRegisterVehicleScreenState();
}

class _UserRegisterVehicleScreenState extends State<UserRegisterVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerService = FirebaseOwnerService();
  final _vehicleNumberController = TextEditingController();
  final _rcNumberController = TextEditingController();
  String _vehicleType = AppConstants.vehicleTypes.first;
  bool _saving = false;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _rcNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await _ownerService.addVehicleForOwner(
        uid: uid,
        vehicleNo: _vehicleNumberController.text,
        rcNumber: _rcNumberController.text,
        vehicleType: _vehicleType,
      );
      if (!mounted) return;
      CustomSnackBar.success(context, 'Vehicle registered successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Register Vehicle',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            userGlassCard(
              title: 'VEHICLE DETAILS',
              icon: Icons.directions_car_outlined,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _vehicleNumberController,
                      hintText: 'Vehicle number (MH12AB1234)',
                      prefixIcon: Icons.confirmation_number_outlined,
                      accentColor: AppConstants.ownerAccent,
                      textCapitalization: TextCapitalization.characters,
                      validator: Validators.vehicleNumber,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _rcNumberController,
                      hintText: 'RC number',
                      prefixIcon: Icons.description_outlined,
                      accentColor: AppConstants.ownerAccent,
                      validator: (v) => Validators.required(v, 'RC number'),
                    ),
                    const SizedBox(height: 12),
                    _vehicleTypeDropdown(),
                    const SizedBox(height: 20),
                    if (_saving)
                      const Center(
                        child: AppLoadingIndicator(
                          color: AppConstants.ownerAccent,
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Register Vehicle'),
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
          ],
        ),
      ),
    );
  }

  Widget _vehicleTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _vehicleType,
          isExpanded: true,
          dropdownColor: AppConstants.darkBgEnd,
          style: const TextStyle(color: Colors.white),
          items: AppConstants.vehicleTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _vehicleType = v);
          },
        ),
      ),
    );
  }
}
