import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firebase_owner_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';

/// Password reset via Firebase Auth email link.
class OwnerForgotPasswordTab extends StatefulWidget {
  const OwnerForgotPasswordTab({super.key});

  @override
  State<OwnerForgotPasswordTab> createState() => _OwnerForgotPasswordTabState();
}

class _OwnerForgotPasswordTabState extends State<OwnerForgotPasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _service = FirebaseOwnerService();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.sendPasswordReset(_emailController.text);
      if (!mounted) return;
      CustomSnackBar.success(
        context,
        'Password reset link sent to your email',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, e.toString());
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
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: DarkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset_rounded,
                      size: 48, color: AppConstants.ownerAccent),
                  const SizedBox(height: 12),
                  Text(
                    'FORGOT PASSWORD',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.ownerAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered email to receive a reset link.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Icons.email_outlined,
                    accentColor: AppConstants.ownerAccent,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(child: AppLoadingIndicator())
                  else
                    ElevatedButton(
                      onPressed: _reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.ownerAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Send Reset Link',
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
}
