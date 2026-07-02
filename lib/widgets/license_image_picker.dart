import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_constants.dart';

/// Pick and preview a driving-license image during registration.
class LicenseImagePicker extends StatelessWidget {
  final File? imageFile;
  final ValueChanged<File?> onImageSelected;

  const LicenseImagePicker({
    super.key,
    required this.imageFile,
    required this.onImageSelected,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked != null) {
      onImageSelected(File(picked.path));
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload License Image',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppConstants.ownerAccent),
                title: const Text('Choose from Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppConstants.ownerAccent),
                title: const Text('Take Photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(context, ImageSource.camera);
                },
              ),
              if (imageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remove Image',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onImageSelected(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppConstants.ownerAccent.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                color: hasImage
                    ? AppConstants.ownerAccent.withValues(alpha: 0.6)
                    : AppConstants.ownerAccent.withValues(alpha: 0.35),
                width: hasImage ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.ownerAccent.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.ownerAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppConstants.ownerAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload License Photo',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Required • Camera or Gallery',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasImage)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Added ✓',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showSourceSheet(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(imageFile!, fit: BoxFit.cover),
                                  Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.edit,
                                              color: Colors.white, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Change photo',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 44,
                                  color: AppConstants.ownerAccent
                                      .withValues(alpha: 0.9),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tap here to upload',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Front side of your driving license',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
