import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/owner_auth_provider.dart';
import '../screens.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';
import 'owner_dashboard_screen.dart';
import 'owner_register_screen.dart';

/// Clean user login — email, password, link to registration.
class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<OwnerAuthProvider>();
    try {
      final owner = await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted || owner == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, auth.mapAuthError(e));
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<OwnerAuthProvider>().isLoading;

    return PremiumBackground(
      gradientColors: const [
        Color(0xFF0A0F1C),
        Color(0xFF0F172A),
        Color(0xFF064E3B),
        Color(0xFF0F172A),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_filled_rounded,
                              size: 72, color: AppConstants.ownerAccent)
                          .animate()
                          .fadeIn()
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 16),
                      Text(
                        'User Login',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      Text(
                        'Your digital vehicle & road management hub',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppConstants.ownerAccent.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.ownerAccent.withValues(alpha: 0.12),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email address',
                              prefixIcon: Icons.email_outlined,
                              accentColor: AppConstants.ownerAccent,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              accentColor: AppConstants.ownerAccent,
                              obscureText: _obscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF94A3B8),
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: Validators.password,
                            ),
                            const SizedBox(height: 24),
                            if (loading)
                              const Center(child: AppLoadingIndicator())
                            else
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.ownerAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      AppConstants.ownerAccent.withValues(alpha: 0.5),
                                ),
                                child: Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OwnerRegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Don't have an account? Register",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
