import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/owner_model.dart';
import '../services/challan_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import 'rto_data_provider.dart';

/// Issue challan with live GPS map pin and Firebase storage.
class RtoIssueChallanScreen extends StatefulWidget {
  final String officerName;

  const RtoIssueChallanScreen({super.key, required this.officerName});

  @override
  State<RtoIssueChallanScreen> createState() => _RtoIssueChallanScreenState();
}

class _RtoIssueChallanScreenState extends State<RtoIssueChallanScreen> {
  final _plateController = TextEditingController();
  final _fineController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _challanService = ChallanService();
  final _locationService = LocationService();

  String _violation = AppConstants.violationTypes.first;
  OwnerModel? _owner;
  bool _loading = false;
  bool _searching = false;
  bool _locating = false;

  double _lat = 18.5204;
  double _lng = 73.8567;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _fetchLocation();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _fineController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() => _locating = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _lat = loc.lat;
        _lng = loc.lng;
        _addressController.text = loc.address;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat, _lng), 16),
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _findVehicle() async {
    final plate = FirebaseService.normalizePlate(_plateController.text);
    if (plate.length < 6) {
      CustomSnackBar.error(context, 'Enter a valid vehicle number');
      return;
    }
    setState(() {
      _searching = true;
      _owner = null;
    });
    try {
      final owner = await context.read<RtoDataProvider>().searchVehicle(plate);
      if (!mounted) return;
      setState(() => _owner = owner);
      if (owner == null) {
        CustomSnackBar.error(context, 'Vehicle not found');
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _issue() async {
    if (_owner == null) {
      CustomSnackBar.error(context, 'Find vehicle first');
      return;
    }
    if (Validators.amount(_fineController.text) != null) {
      CustomSnackBar.error(context, 'Enter valid fine amount');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      CustomSnackBar.error(context, 'Location address required');
      return;
    }

    setState(() => _loading = true);
    try {
      await _challanService.issueChallan(
        vehicleNumber: _owner!.vehicleNumber,
        ownerUID: _owner!.uid,
        ownerName: _owner!.ownerName,
        violationType: _violation,
        fineAmount: int.parse(_fineController.text.trim()),
        officerName: widget.officerName,
        issuedDate: _dateController.text.trim(),
        latitude: _lat,
        longitude: _lng,
        address: _addressController.text.trim(),
      );
      if (!mounted) return;
      ToastHelper.success('Challan issued successfully');
      CustomSnackBar.success(context, 'Challan issued with map location');
      _fineController.clear();
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, FirebaseService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DarkGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _plateController,
                        hintText: 'Vehicle number',
                        prefixIcon: Icons.directions_car_outlined,
                        accentColor: AppConstants.rtoAccent,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _searching ? null : _findVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.rtoAccent,
                      ),
                      child: _searching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Find'),
                    ),
                  ],
                ),
                if (_owner != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Owner: ${_owner!.ownerName} • ${_owner!.vehicleType}',
                    style: GoogleFonts.poppins(
                      color: AppConstants.rtoAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _dropdown(),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _fineController,
                  hintText: 'Fine amount (INR)',
                  prefixIcon: Icons.currency_rupee,
                  accentColor: AppConstants.rtoAccent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _dateController,
                  hintText: 'Date',
                  prefixIcon: Icons.calendar_today_outlined,
                  accentColor: AppConstants.rtoAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LIVE LOCATION',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppConstants.rtoAccent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_lat, _lng),
                      zoom: 15,
                    ),
                    onMapCreated: (c) => _mapController = c,
                    markers: {
                      Marker(
                        markerId: const MarkerId('challan'),
                        position: LatLng(_lat, _lng),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  if (_locating)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: AppLoadingIndicator(
                          color: AppConstants.rtoAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _addressController,
                  hintText: 'Address from GPS',
                  prefixIcon: Icons.location_on_outlined,
                  accentColor: AppConstants.rtoAccent,
                ),
              ),
              IconButton(
                onPressed: _locating ? null : _fetchLocation,
                icon: const Icon(Icons.my_location, color: AppConstants.rtoAccent),
              ),
            ],
          ),
          Text(
            'Lat: ${_lat.toStringAsFixed(5)}, Lng: ${_lng.toStringAsFixed(5)}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: AppLoadingIndicator(color: AppConstants.rtoAccent),
            )
          else
            ElevatedButton.icon(
              onPressed: (_owner == null || _searching) ? null : _issue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.assignment_turned_in_rounded),
              label: const Text('Issue Challan'),
            ),
        ],
      ),
    );
  }

  Widget _dropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _violation,
          isExpanded: true,
          dropdownColor: AppConstants.darkBgEnd,
          style: const TextStyle(color: Colors.white),
          items: AppConstants.violationTypes
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: _loading
              ? null
              : (val) {
                  if (val != null) setState(() => _violation = val);
                },
        ),
      ),
    );
  }
}
