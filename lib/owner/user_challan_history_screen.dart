import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challan_model.dart';
import '../services/challan_service.dart';
import '../utils/app_constants.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';
import 'widgets/user_shared_widgets.dart';

/// Full challan history with summary stats.
class UserChallanHistoryScreen extends StatelessWidget {
  const UserChallanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final challanService = ChallanService();

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Challan History',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<List<ChallanModel>>(
          stream: challanService.watchChallansForOwner(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: AppLoadingIndicator(color: AppConstants.ownerAccent),
              );
            }

            final all = snapshot.data ?? [];
            final pending = challanService.countPending(all);
            final outstanding = challanService.totalPendingAmount(all);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _summaryRow('Total Challans', '${all.length}'),
                _summaryRow('Pending Challans', '$pending'),
                _summaryRow('Outstanding Amount', '₹$outstanding'),
                const SizedBox(height: 16),
                userSectionTitle('All Challans'),
                if (all.isEmpty)
                  userEmptyNote('No challans on your account.')
                else
                  ...all.map(userChallanTile),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppConstants.ownerAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: const Color(0xFF94A3B8))),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
