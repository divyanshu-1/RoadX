import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme.dart';
import '../widgets.dart';
import '../utils/custom_snackbar.dart';

class DriverRegistrationPage extends StatefulWidget {
  final String vehicleId;
  const DriverRegistrationPage({super.key, required this.vehicleId});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dlNumberController = TextEditingController();
  DateTime? dlExpiry;
  bool isActive = true;
  bool isSubmitting = false;

  Future<void> _registerDriver() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        dlNumberController.text.trim().isEmpty ||
        dlExpiry == null) {
      CustomSnackBar.error(context, 'Please fill all fields');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        CustomSnackBar.error(context, 'User not authenticated');
        setState(() => isSubmitting = false);
        return;
      }

      // Verify vehicle ownership before registering driver
      final vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (!vehicleDoc.exists) {
        CustomSnackBar.error(context, 'Vehicle not found');
        setState(() => isSubmitting = false);
        return;
      }

      final vehicleData = vehicleDoc.data();
      final ownerUid = vehicleData?['owner_uid'] as String?;

      if (ownerUid != user.uid) {
        CustomSnackBar.error(context, 'You do not own this vehicle');
        setState(() => isSubmitting = false);
        return;
      }

      // Register driver with owner_uid for efficient querying
      await FirebaseFirestore.instance.collection('drivers').add({
        'vehicleId': widget.vehicleId,
        'owner_uid': user.uid, // Add owner_uid for direct user queries
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'dl_number': dlNumberController.text.trim(),
        'dl_expiry': Timestamp.fromDate(dlExpiry!),
        'isActive': isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      CustomSnackBar.success(context, 'Driver registered successfully');

      nameController.clear();
      phoneController.clear();
      dlNumberController.clear();
      setState(() {
        dlExpiry = null;
        isActive = true;
      });

      // Navigate back after successful registration
      Navigator.pop(context);
    } catch (e) {
      CustomSnackBar.error(context, 'Failed to register driver: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => dlExpiry = picked);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dlNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Driver'),
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
                    icon: Icons.person_add,
                    title: 'Authorized Driver Register',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Driver Name',
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Phone Number',
                    icon: Icons.phone,
                    controller: phoneController,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Driving License Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'DL Number',
                    icon: Icons.credit_card,
                    controller: dlNumberController,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'DL Expiry Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        dlExpiry != null
                            ? '${dlExpiry!.day}/${dlExpiry!.month}/${dlExpiry!.year}'
                            : 'Select expiry date',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Driver Access Control',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: SwitchListTile(
                      title: const Text('Driver Status'),
                      subtitle: Text(isActive ? 'ON - Driver is active' : 'OFF - Driver is inactive'),
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      activeColor: AppColors.primarySkyBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isSubmitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    GradientButton(
                      onPressed: _registerDriver,
                      icon: Icons.save,
                      child: const Text('Register Driver'),
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
