import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _vehicleNoController = TextEditingController();
  String? selectedType;
  bool _isLoading = false;

  final List<String> incidentTypes = [
    'theft',
    'scam_fraud',
    'unauthorized_driver',
    'other',
  ];

  Future<void> _submitIncident() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    if (_vehicleNoController.text.trim().isEmpty || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user data for owner name
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};
      final ownerName = userData['name'] ?? userData['email'] ?? 'Unknown';

      // Generate incident ID
      final incidentId = FirebaseFirestore.instance.collection('incidents').doc().id;

      await FirebaseFirestore.instance.collection('incidents').doc(incidentId).set({
        'incidentID': incidentId,
        'userId': user.uid,
        'vehicle_no': _vehicleNoController.text.trim(),
        'type': selectedType,
        'owner_name': ownerName,
        'timestamp': FieldValue.serverTimestamp(),
        // Basic fields used by history/admin views
        'status': 'reported',
        'location': 'N/A',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incident reported successfully!")),
      );

      _vehicleNoController.clear();
      setState(() => selectedType = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
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

  @override
  void dispose() {
    _vehicleNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Report"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: GradientScaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CardTitle(
                    icon: Icons.warning,
                    title: 'Report Incident',
                  ),
                  const SizedBox(height: 24),
                  LabeledField(
                    label: 'Vehicle Number',
                    icon: Icons.directions_car,
                    controller: _vehicleNoController,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Incident Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: incidentTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeDisplay(type)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedType = value),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GradientButton(
                      onPressed: _submitIncident,
                      icon: Icons.report,
                      child: const Text("Report Incident"),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
