import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key});

  @override
  State<VehicleRegistrationPage> createState() => _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final TextEditingController engineNoController = TextEditingController();
  final TextEditingController chassisNoController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  String? selectedModel;
  bool isSubmitting = false;

  final List<String> vehicleModels = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Coupe',
    'Convertible',
    'Wagon',
    'Van',
    'Truck',
    'Motorcycle',
    'Other',
  ];

  String _formatNumberPlate(String value) {
    String cleaned = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleaned.length > 10) {
      cleaned = cleaned.substring(0, 10);
    }
    if (cleaned.length <= 2) {
      return cleaned;
    } else if (cleaned.length <= 4) {
      return '${cleaned.substring(0, 2)}${cleaned.substring(2)}';
    } else if (cleaned.length <= 6) {
      return '${cleaned.substring(0, 2)}${cleaned.substring(2, 4)}${cleaned.substring(4)}';
    } else {
      return '${cleaned.substring(0, 2)}${cleaned.substring(2, 4)}${cleaned.substring(4, 6)}${cleaned.substring(6)}';
    }
  }

  bool _isValidNumberPlate(String value) {
    RegExp pattern = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    return pattern.hasMatch(value);
  }

  Future<void> _registerVehicle() async {
    if (engineNoController.text.trim().isEmpty ||
        chassisNoController.text.trim().isEmpty ||
        vehicleNoController.text.trim().isEmpty ||
        selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!_isValidNumberPlate(vehicleNoController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid number plate format (e.g., MH12AB1234)')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not logged in');
      }

      await FirebaseFirestore.instance.collection('vehicles').add({
        'owner_uid': uid,
        'engine_no': engineNoController.text.trim(),
        'chassis_no': chassisNoController.text.trim(),
        'vehicle_no': vehicleNoController.text.trim(),
        'model': selectedModel,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle registered successfully')),
      );

      engineNoController.clear();
      chassisNoController.clear();
      vehicleNoController.clear();
      setState(() => selectedModel = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register vehicle: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    engineNoController.dispose();
    chassisNoController.dispose();
    vehicleNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Vehicle'),
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
                    icon: Icons.directions_car,
                    title: 'Vehicle Registration',
                  ),
                  const SizedBox(height: 24),
                  LabeledField(
                    label: 'Engine Number',
                    icon: Icons.engineering,
                    controller: engineNoController,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Chassis Number',
                    icon: Icons.confirmation_number,
                    controller: chassisNoController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: vehicleNoController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Number',
                      hintText: 'e.g. MH12AB1234',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      String formatted = _formatNumberPlate(value);
                      if (formatted != value) {
                        vehicleNoController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedModel,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: vehicleModels.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedModel = value),
                  ),
                  const SizedBox(height: 24),
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    GradientButton(
                      onPressed: _registerVehicle,
                      icon: Icons.add_circle,
                      child: const Text('Register Vehicle'),
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
