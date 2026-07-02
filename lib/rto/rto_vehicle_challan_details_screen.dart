import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/challan_model.dart';
import '../models/vehicle_model.dart';
import '../services/challan_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';

/// All challans for one vehicle — view and reset.
class RtoVehicleChallanDetailsScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const RtoVehicleChallanDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<RtoVehicleChallanDetailsScreen> createState() =>
      _RtoVehicleChallanDetailsScreenState();
}

class _RtoVehicleChallanDetailsScreenState
    extends State<RtoVehicleChallanDetailsScreen> {
  final _challanService = ChallanService();
  bool _resetting = false;

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Are you sure?',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all challans\nfor this vehicle.',
          style: GoogleFonts.poppins(color: Colors.white70, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFF475569)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Cancel', style: GoogleFonts.outfit()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Reset',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _resetChallans();
  }

  Future<void> _resetChallans() async {
    setState(() => _resetting = true);
    try {
      await _challanService.resetVehicleChallans(widget.vehicle.vehicleNo);
      if (!mounted) return;
      ToastHelper.success('All challans cleared successfully.');
      CustomSnackBar.success(context, 'All challans cleared successfully.');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ToastHelper.error(msg);
      CustomSnackBar.error(context, msg);
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
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
            'Vehicle Challans',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<List<ChallanModel>>(
          stream: _challanService.watchVehicleChallans(
            widget.vehicle.vehicleNo,
          ),
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
                  child: Text(
                    snapshot.error.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final challans = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: DarkGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle: ${widget.vehicle.vehicleNo}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.vehicle.vehicleType} · ${widget.vehicle.ownerName.isNotEmpty ? widget.vehicle.ownerName : 'Unknown owner'}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (challans.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Material(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(14),
                      elevation: 4,
                      shadowColor: const Color(0xFFDC2626).withValues(alpha: 0.5),
                      child: InkWell(
                        onTap: _resetting ? null : _confirmReset,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_resetting)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              const SizedBox(width: 10),
                              Text(
                                _resetting
                                    ? 'Resetting...'
                                    : 'Reset All Challans',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: challans.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Challans Found',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: challans.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ChallanCard(
                                challan: challans[index],
                                index: index + 1,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChallanCard extends StatelessWidget {
  final ChallanModel challan;
  final int index;

  const _ChallanCard({required this.challan, required this.index});

  @override
  Widget build(BuildContext context) {
    final isPaid = challan.isPaid;

    return DarkGlassCard(
      borderColor: isPaid
          ? Colors.green.withValues(alpha: 0.2)
          : Colors.orange.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Challan $index',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              _statusChip(challan.displayStatus, isPaid),
            ],
          ),
          const SizedBox(height: 12),
          _row('Amount', '₹${challan.fineAmount}'),
          _row('Reason', challan.reason),
          if (challan.issuedDate.isNotEmpty)
            _row('Issued', challan.issuedDate),
          if (challan.officerName.isNotEmpty)
            _row('Officer', challan.officerName),
        ],
      ),
    );
  }

  Widget _statusChip(String text, bool paid) {
    final color = paid ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
