import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme.dart';
import '../widgets.dart';
import '../utils/custom_snackbar.dart';

class VehicleDocumentsPage extends StatefulWidget {
  final String vehicleId;
  const VehicleDocumentsPage({super.key, required this.vehicleId});

  @override
  State<VehicleDocumentsPage> createState() => _VehicleDocumentsPageState();
}

class _VehicleDocumentsPageState extends State<VehicleDocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  File? insuranceFile;
  File? pucFile;
  File? rcFile;
  DateTime? insuranceExpiry;
  DateTime? pucExpiry;
  DateTime? rcExpiry;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Documents'),
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
                    icon: Icons.folder,
                    title: 'Document Management',
                  ),
                  const SizedBox(height: 24),
                  _buildDocumentSection(
                    'Insurance',
                    insuranceFile,
                    insuranceExpiry,
                    (file) => setState(() => insuranceFile = file),
                    (date) => setState(() => insuranceExpiry = date),
                    () => _uploadDocument('insurance', insuranceFile, insuranceExpiry),
                  ),
                  const SizedBox(height: 20),
                  _buildDocumentSection(
                    'PUC',
                    pucFile,
                    pucExpiry,
                    (file) => setState(() => pucFile = file),
                    (date) => setState(() => pucExpiry = date),
                    () => _uploadDocument('puc', pucFile, pucExpiry),
                  ),
                  const SizedBox(height: 20),
                  _buildDocumentSection(
                    'RC',
                    rcFile,
                    rcExpiry,
                    (file) => setState(() => rcFile = file),
                    (date) => setState(() => rcExpiry = date),
                    () => _uploadDocument('rc', rcFile, rcExpiry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection(
    String docType,
    File? file,
    DateTime? expiry,
    Function(File?) onFileSelected,
    Function(DateTime?) onDateSelected,
    VoidCallback onUpload,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              docType,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(docType, onFileSelected),
                    icon: const Icon(Icons.upload_file),
                    label: Text(file == null ? 'Upload $docType' : 'Change File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySkyBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (file != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.green),
                ],
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context, onDateSelected),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '$docType Expiry Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  expiry != null
                      ? '${expiry.day}/${expiry.month}/${expiry.year}'
                      : 'Select expiry date',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (file != null && expiry != null)
              GradientButton(
                onPressed: isUploading ? null : onUpload,
                icon: Icons.save,
                child: const Text('Save Document'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(String docType, Function(File?) onFileSelected) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onFileSelected(File(image.path));
      }
    } catch (e) {
      CustomSnackBar.error(context, 'Error picking image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime?) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _uploadDocument(String docType, File? file, DateTime? expiry) async {
    if (file == null || expiry == null) {
      CustomSnackBar.error(
        context,
        'Please select file and expiry date',
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicle_documents')
          .child(widget.vehicleId)
          .child('${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('vehicle_documents').add({
        'vehicleId': widget.vehicleId,
        '${docType}_url': downloadUrl,
        '${docType}_expiry': Timestamp.fromDate(expiry),
        'createdAt': FieldValue.serverTimestamp(),
      });

      CustomSnackBar.success(
        context,
        '$docType document uploaded successfully',
      );

      // Clear the file and expiry after successful upload
      if (docType == 'insurance') {
        setState(() {
          insuranceFile = null;
          insuranceExpiry = null;
        });
      } else if (docType == 'puc') {
        setState(() {
          pucFile = null;
          pucExpiry = null;
        });
      } else if (docType == 'rc') {
        setState(() {
          rcFile = null;
          rcExpiry = null;
        });
      }
    } catch (e) {
      CustomSnackBar.error(
        context,
        'Failed to upload document: $e',
      );
    } finally {
      setState(() => isUploading = false);
    }
  }
}
