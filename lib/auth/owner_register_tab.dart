import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../owner/owner_dashboard_screen.dart';
import '../services/firebase_owner_service.dart';
import '../services/license_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/license_image_picker.dart';
import '../widgets/loading_indicator.dart';
import 'owner_auth_provider.dart';

/// Owner signup tab — license verified against Firestore before account creation.
/// Vehicle registration happens later from the Owner Dashboard.
class OwnerRegisterTab extends StatefulWidget {
  const OwnerRegisterTab({super.key});

  @override
  State<OwnerRegisterTab> createState() => _OwnerRegisterTabState();
}

class _OwnerRegisterTabState extends State<OwnerRegisterTab> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseOwnerService();
  final _licenseService = LicenseService();

  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  File? _licenseImage;

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _licenseController,
      _emailController,
      _phoneController,
      _aadhaarController,
      _addressController,
      _passwordController,
      _confirmController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_licenseImage == null) {
      CustomSnackBar.error(context, 'Please upload your license image');
      return;
    }

    setState(() => _loading = true);
    try {
      final licenseResult = await _licenseService.verifyOwnerLicense(
        licenseNo: _licenseController.text,
        ownerName: _nameController.text,
        aadhaar: _aadhaarController.text,
      );

      if (!licenseResult.success) {
        if (!mounted) return;
        CustomSnackBar.error(context, licenseResult.errorMessage!);
        return;
      }

      final credential = await _service.registerOwner(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        aadhaar: _aadhaarController.text,
        address: _addressController.text,
        licenseNo: _licenseController.text,
      );

      final uid = credential.user?.uid;
      if (uid == null) throw Exception('Registration failed — no user ID');

      await _service.uploadLicenseImage(uid: uid, imageFile: _licenseImage!);

      if (!mounted) return;
      final auth = context.read<OwnerAuthProvider>();
      await auth.initSession();
      if (!mounted) return;

      ToastHelper.success('Registration successful');
      CustomSnackBar.success(context, 'Registration successful');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, _service.authErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: DarkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'OWNER REGISTRATION',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.ownerAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'License is verified before account creation. '
                    'Vehicle details can be added later from your dashboard.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    _nameController,
                    'Full Name',
                    Icons.person_outline,
                    (v) => Validators.required(v, 'Full name'),
                  ),
                  _licenseField(),
                  LicenseImagePicker(
                    imageFile: _licenseImage,
                    onImageSelected: (file) => setState(() => _licenseImage = file),
                  ),
                  _field(
                    _emailController,
                    'Email',
                    Icons.email_outlined,
                    Validators.email,
                    keyboard: TextInputType.emailAddress,
                  ),
                  _field(
                    _phoneController,
                    'Phone Number',
                    Icons.phone_android_outlined,
                    Validators.phone,
                    keyboard: TextInputType.phone,
                  ),
                  _field(
                    _aadhaarController,
                    'Aadhaar Number',
                    Icons.badge_outlined,
                    Validators.aadhaar,
                    keyboard: TextInputType.number,
                  ),
                  _field(
                    _addressController,
                    'Address',
                    Icons.home_outlined,
                    (v) => Validators.required(v, 'Address'),
                  ),
                  _field(
                    _passwordController,
                    'Password',
                    Icons.lock_outline_rounded,
                    Validators.password,
                    obscure: _obscure,
                    suffix: _toggle(_obscure, () {
                      setState(() => _obscure = !_obscure);
                    }),
                  ),
                  _field(
                    _confirmController,
                    'Confirm Password',
                    Icons.lock_clock_outlined,
                    (v) {
                      if (v == null || v.isEmpty) return 'Confirm password';
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    obscure: _obscureConfirm,
                    suffix: _toggle(_obscureConfirm, () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    }),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: AppLoadingIndicator())
                  else
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _licenseField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _licenseController,
            hintText: 'License Number (e.g. MH100001)',
            prefixIcon: Icons.credit_card_outlined,
            accentColor: AppConstants.ownerAccent,
            textCapitalization: TextCapitalization.characters,
            validator: (v) => Validators.required(v, 'License number'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6, bottom: 8),
            child: Text(
              'License will be verified before account creation.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppConstants.ownerAccent.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType keyboard = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: controller,
        hintText: hint,
        prefixIcon: icon,
        accentColor: AppConstants.ownerAccent,
        keyboardType: keyboard,
        textCapitalization: caps,
        obscureText: obscure,
        suffixIcon: suffix,
        validator: validator,
      ),
    );
  }

  Widget _toggle(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: const Color(0xFF94A3B8),
        ),
        onPressed: onTap,
      );
}
