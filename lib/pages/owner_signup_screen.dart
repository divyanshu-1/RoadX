import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_owner_service.dart';
import '../widgets/custom_text_field.dart';
import '../utils/custom_snackbar.dart';
import '../owner/owner_dashboard_screen.dart';

class OwnerSignupScreen extends StatefulWidget {
  const OwnerSignupScreen({super.key});

  @override
  State<OwnerSignupScreen> createState() => _OwnerSignupScreenState();
}

class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseOwnerService _ownerService = FirebaseOwnerService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validator patterns
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _ownerService.signupOwner(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        licenseNo: _licenseController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        CustomSnackBar.success(context, 'Account Created Successfully');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, e.message ?? 'An authentication error occurred.');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF10B981); // Emerald Green

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.app_registration_rounded,
                            size: 60,
                            color: accentColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Owner Registration',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Register your details for compliance checks',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Glassmorphic Signup Form Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Full Name
                                _buildLabel('FULL NAME', accentColor),
                                CustomTextField(
                                  controller: _nameController,
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icons.person_outline,
                                  accentColor: accentColor,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Full Name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                _buildLabel('EMAIL ADDRESS', accentColor),
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: 'Enter your email',
                                  prefixIcon: Icons.email_outlined,
                                  accentColor: accentColor,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!_emailRegex.hasMatch(val.trim())) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Mobile Number
                                _buildLabel('MOBILE NUMBER', accentColor),
                                CustomTextField(
                                  controller: _mobileController,
                                  hintText: 'Enter 10-digit mobile number',
                                  prefixIcon: Icons.phone_android_outlined,
                                  accentColor: accentColor,
                                  keyboardType: TextInputType.phone,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Mobile number is required';
                                    }
                                    if (val.trim().length != 10 || int.tryParse(val.trim()) == null) {
                                      return 'Enter a valid 10-digit number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // License Number
                                _buildLabel('LICENSE NUMBER', accentColor),
                                CustomTextField(
                                  controller: _licenseController,
                                  hintText: 'e.g. MH100001',
                                  prefixIcon: Icons.badge_outlined,
                                  accentColor: accentColor,
                                  textCapitalization: TextCapitalization.characters,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'License number is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _buildLabel('PASSWORD (MIN 6 CHARACTERS)', accentColor),
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: 'Create a password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  accentColor: accentColor,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (val.trim().length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                _buildLabel('CONFIRM PASSWORD', accentColor),
                                CustomTextField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icons.lock_clock_outlined,
                                  accentColor: accentColor,
                                  obscureText: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Confirm password is required';
                                    }
                                    if (val.trim() != _passwordController.text.trim()) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),

                                // Action Button
                                if (_isLoading)
                                  Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: _handleSignup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                      shadowColor: accentColor.withOpacity(0.4),
                                    ),
                                    child: Text(
                                      'Create Owner Account',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String labelText, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        labelText,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accentColor,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
