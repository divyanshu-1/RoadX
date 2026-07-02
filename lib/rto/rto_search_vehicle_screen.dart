import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/owner_model.dart';
import '../models/registered_vehicle_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import 'rto_data_provider.dart';

/// Search registered vehicles by plate using cached Firebase data.
class RtoSearchVehicleScreen extends StatefulWidget {
  final String officerName;

  const RtoSearchVehicleScreen({super.key, required this.officerName});

  @override
  State<RtoSearchVehicleScreen> createState() =>
      _RtoSearchVehicleScreenState();
}

class _RtoSearchVehicleScreenState extends State<RtoSearchVehicleScreen> {
  final _plateController = TextEditingController();
  bool _loading = false;
  OwnerModel? _owner;
  RegisteredVehicleModel? _result;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final plate = FirebaseService.normalizePlate(_plateController.text);
    if (plate.length < 6) {
      CustomSnackBar.error(context, 'Enter a valid vehicle number');
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _owner = null;
      _result = null;
    });

    try {
      final rto = context.read<RtoDataProvider>();
      final owner = await rto.searchVehicle(plate);
      if (!mounted) return;

      if (owner == null) {
        CustomSnackBar.error(context, 'Vehicle not found');
        setState(() {
          _owner = null;
          _result = null;
        });
      } else {
        final pending =
            rto.challans.where((c) => c.ownerUID == owner.uid && c.isPending).length;
        setState(() {
          _owner = owner;
          _result = RegisteredVehicleModel.fromOwner(
            owner,
            pendingChallans: pending,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        FirebaseService.friendlyError(e),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Search Vehicle',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _plateController,
                  hintText: 'e.g. MH31AB1234',
                  prefixIcon: Icons.search,
                  accentColor: AppConstants.rtoAccent,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    final upper = value.toUpperCase().replaceAll(' ', '');
                    if (upper != value) {
                      _plateController.value = TextEditingValue(
                        text: upper,
                        selection:
                            TextSelection.collapsed(offset: upper.length),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _loading ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.rtoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
          if (_loading) ...[
            const SizedBox(height: 32),
            const Center(
              child: AppLoadingIndicator(color: AppConstants.rtoAccent),
            ),
          ],
          if (_result != null && _owner != null) ...[
            const SizedBox(height: 24),
            DarkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _result!.vehicleNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _info('Owner Name', _owner!.ownerName),
                  _info('Vehicle Type', _owner!.vehicleType),
                  _info('RC Number', _owner!.rcNumber),
                  _info('Phone', _owner!.phone),
                  _info('Email', _owner!.email),
                  _info('Address', _owner!.address),
                  _info('Registration Date', _result!.registrationDate),
                  _info('Challan Status', _result!.challanStatus),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
