import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/challan_model.dart';
import '../utils/app_constants.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_stat_card.dart';
import 'rto_data_provider.dart';

/// RTO dashboard with live stats and recent challan activity.
class RtoDashboardScreen extends StatelessWidget {
  final String officerId;

  const RtoDashboardScreen({super.key, required this.officerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<RtoDataProvider>(
      builder: (context, rto, _) {
        if (rto.isLoading && !rto.hasData) {
          return const Center(
            child: AppLoadingIndicator(color: AppConstants.rtoAccent),
          );
        }

        final stats = rto.stats;
        final recentChallans = rto.challans.take(5).toList();

        return RefreshIndicator(
          onRefresh: rto.refresh,
          color: AppConstants.rtoAccent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Badge: $officerId • Live Firebase',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppConstants.rtoAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  delegate: SliverChildListDelegate([
                    PremiumStatCard(
                      label: 'Registered Vehicles',
                      value: '${stats.totalVehicles}',
                      icon: Icons.directions_car_rounded,
                      accentColor: AppConstants.rtoAccent,
                      index: 0,
                    ),
                    PremiumStatCard(
                      label: 'Total Owners',
                      value: '${stats.totalOwners}',
                      icon: Icons.people_rounded,
                      accentColor: const Color(0xFF38BDF8),
                      index: 1,
                    ),
                    PremiumStatCard(
                      label: 'Total Challans',
                      value: '${stats.totalChallans}',
                      icon: Icons.receipt_long_rounded,
                      accentColor: const Color(0xFF10B981),
                      index: 2,
                    ),
                    PremiumStatCard(
                      label: 'Pending Challans',
                      value: '${stats.pendingChallans}',
                      icon: Icons.pending_actions_rounded,
                      accentColor: const Color(0xFFFB923C),
                      index: 3,
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'RECENT CHALLANS',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.rtoAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              if (recentChallans.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No challans issued yet.',
                      style: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _challanTile(recentChallans[i]),
                    childCount: recentChallans.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _challanTile(ChallanModel c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.isPending
              ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            c.isPending ? Icons.pending_actions : Icons.check_circle_outline,
            color: c.isPending ? const Color(0xFFF59E0B) : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.vehicleNumber,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${c.violationType} • ₹${c.fineAmount}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            c.status,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: c.isPending ? const Color(0xFFF59E0B) : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
