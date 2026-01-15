import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';

class IncidentHistoryPage extends StatelessWidget {
  const IncidentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Incident History'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('incidents')
            .where('userId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load incidents:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Sort by timestamp in memory (descending - newest first)
          final sortedDocs = List<QueryDocumentSnapshot>.from(allDocs);
          sortedDocs.sort((a, b) {
            final aTimestamp = a.data() as Map<String, dynamic>;
            final bTimestamp = b.data() as Map<String, dynamic>;
            final aTime = aTimestamp['timestamp'] as Timestamp?;
            final bTime = bTimestamp['timestamp'] as Timestamp?;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            
            return bTime.compareTo(aTime); // Descending order
          });

          if (sortedDocs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No incidents reported yet.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data = sortedDocs[index].data() as Map<String, dynamic>;
              final type = (data['type'] as String?) ?? 'unknown';
              final timestamp = data['timestamp'] as Timestamp?;
              final status = (data['status'] as String?) ?? 'reported';
              final vehicleNo = (data['vehicle_no'] as String?) ?? 'N/A';
              final location = (data['location'] as String?) ?? 'N/A';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primarySkyBlue,
                    child: Icon(
                      _getTypeIcon(type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _getTypeDisplay(type),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: $vehicleNo'),
                      Text('Location: $location'),
                      Text('Status: ${_getStatusDisplay(status)}'),
                      if (timestamp != null)
                        Text(
                          _formatTimestamp(timestamp.toDate()),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'theft':
        return Icons.car_crash;
      case 'scam_fraud':
        return Icons.warning;
      case 'unauthorized_driver':
        return Icons.person_off;
      default:
        return Icons.error;
    }
  }

  String _getTypeDisplay(String type) {
    switch (type) {
      case 'theft':
        return 'Theft (Gadi chori)';
      case 'scam_fraud':
        return 'Scam/Fraud';
      case 'unauthorized_driver':
        return 'Unauthorized Driver';
      case 'other':
        return 'Other Incident';
      default:
        return type;
    }
  }

  String _getStatusDisplay(String status) {
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

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

