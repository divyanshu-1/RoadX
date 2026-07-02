import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_owner_service.dart';
import '../services/license_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/license_image_picker.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';
import 'owner_dashboard_screen.dart';
/// User signup — license verified against Firestore before account creation.
/// Vehicle registration happens later from the User Dashboard.
class OwnerRegisterScreen extends StatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  State<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends State<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseOwnerService();
  final _licenseService = LicenseService();

  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _addressController = TextEditingController();

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
      _passwordController,
      _confirmController,
      _phoneController,
      _aadhaarController,
      _addressController,
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
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            'User Registration',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('USER DETAILS', Icons.person_outline),
                  Text(
                    'License is verified before account creation. '
                    'Vehicle details can be added later from your dashboard.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _nameController,
                    'Full Name',
                    Icons.badge_outlined,
                    (v) => Validators.required(v, 'Full name'),
                  ),
                  _licenseField(),
                  const SizedBox(height: 4),
                  LicenseImagePicker(
                    imageFile: _licenseImage,
                    onImageSelected: (file) => setState(() => _licenseImage = file),
                  ),
                  _sectionTitle('CONTACT & ACCOUNT', Icons.mail_outline),
                  const SizedBox(height: 4),
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
                    Icons.phone_outlined,
                    Validators.phone,
                  ),
                  _field(
                    _aadhaarController,
                    'Aadhaar Number',
                    Icons.fingerprint,
                    Validators.aadhaar,
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
                    Icons.lock_outline,
                    Validators.password,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                  ),
                  _field(
                    _confirmController,
                    'Confirm Password',
                    Icons.lock,
                    (v) {
                      if (v == null || v.isEmpty) return 'Confirm password';
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return Validators.password(v);
                    },
                    obscure: _obscureConfirm,
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  const SizedBox(height: 24),
                  if (_loading)
                    const Center(child: AppLoadingIndicator())
                  else
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Complete Registration',
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

  Widget _sectionTitle(String t, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.ownerAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            t,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppConstants.ownerAccent,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType keyboard = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: c,
        hintText: hint,
        prefixIcon: icon,
        accentColor: AppConstants.ownerAccent,
        keyboardType: keyboard,
        textCapitalization: caps,
        obscureText: obscure,
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: onToggleObscure,
              )
            : null,
        validator: validator,
      ),
    );
  }
}
