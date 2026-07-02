import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_constants.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';

/// Incident history for the logged-in user (Firestore `incidents`).
class UserIncidentHistoryScreen extends StatelessWidget {
  const UserIncidentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Incident History',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('incidents')
              .where('userId', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: AppLoadingIndicator(color: AppConstants.ownerAccent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load incidents:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }

            final docs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
            docs.sort((a, b) {
              final aTime = (a.data() as Map)['timestamp'] as Timestamp?;
              final bTime = (b.data() as Map)['timestamp'] as Timestamp?;
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.report_gmailerrorred_outlined,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No incidents reported yet.',
                      style: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final type = data['type']?.toString() ?? 'unknown';
                final status = data['status']?.toString() ?? 'reported';
                final description = data['description']?.toString() ??
                    data['vehicle_no']?.toString() ??
                    '—';
                final timestamp = data['timestamp'] as Timestamp?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _typeIcon(type),
                            color: AppConstants.ownerAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _typeLabel(type),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _statusLabel(status),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(status),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      if (timestamp != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(timestamp.toDate()),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'theft':
        return Icons.car_crash_outlined;
      case 'scam_fraud':
        return Icons.warning_amber_outlined;
      case 'unauthorized_driver':
        return Icons.person_off_outlined;
      default:
        return Icons.error_outline;
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'theft':
        return 'Theft';
      case 'scam_fraud':
        return 'Scam / Fraud';
      case 'unauthorized_driver':
        return 'Unauthorized Driver';
      case 'other':
        return 'Other Incident';
      default:
        return type;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'reported':
        return 'Reported';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'in_progress':
        return Colors.orange;
      default:
        return AppConstants.ownerAccent;
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
