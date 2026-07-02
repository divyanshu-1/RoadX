import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_owner_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';

/// Check if a vehicle plate is already registered in Firebase.
class OwnerVehicleVerifyTab extends StatefulWidget {
  const OwnerVehicleVerifyTab({super.key});

  @override
  State<OwnerVehicleVerifyTab> createState() => _OwnerVehicleVerifyTabState();
}

class _OwnerVehicleVerifyTabState extends State<OwnerVehicleVerifyTab> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleController = TextEditingController();
  final _service = FirebaseOwnerService();
  bool _loading = false;
  bool? _isRegistered;

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _isRegistered = null;
    });
    try {
      final exists = await _service.isVehicleRegistered(_vehicleController.text);
      if (!mounted) return;
      setState(() => _isRegistered = exists);
      if (exists) {
        ToastHelper.error('Vehicle already registered');
        CustomSnackBar.error(context, 'Vehicle already registered');
      } else {
        CustomSnackBar.success(
          context,
          'Vehicle is available for registration',
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: DarkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.verified_user_rounded,
                      size: 48, color: AppConstants.ownerAccent),
                  const SizedBox(height: 12),
                  Text(
                    'VEHICLE VERIFICATION',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.ownerAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verify plate availability before registering.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _vehicleController,
                    hintText: 'e.g. MH12AB1234',
                    prefixIcon: Icons.directions_car_outlined,
                    accentColor: AppConstants.ownerAccent,
                    textCapitalization: TextCapitalization.characters,
                    validator: Validators.vehicleNumber,
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: AppLoadingIndicator())
                  else
                    ElevatedButton(
                      onPressed: _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Verify Vehicle',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (_isRegistered != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (_isRegistered!
                                ? Colors.red
                                : Colors.green)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (_isRegistered!
                                  ? Colors.red
                                  : Colors.green)
                              .withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isRegistered!
                                ? Icons.block_rounded
                                : Icons.check_circle_rounded,
                            color: _isRegistered! ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isRegistered!
                                  ? 'This vehicle is already registered in RoadX.'
                                  : 'This vehicle number is available.',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
