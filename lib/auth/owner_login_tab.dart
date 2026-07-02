import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../owner/owner_dashboard_screen.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../utils/toast_helper.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/loading_indicator.dart';
import 'owner_auth_provider.dart';

/// Owner email/password login tab.
class OwnerLoginTab extends StatefulWidget {
  const OwnerLoginTab({super.key});

  @override
  State<OwnerLoginTab> createState() => _OwnerLoginTabState();
}

class _OwnerLoginTabState extends State<OwnerLoginTab> {
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
      ToastHelper.success('Welcome back, ${owner.name}!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = auth.mapAuthError(e);
      CustomSnackBar.error(context, msg);
      if (msg == 'Invalid credentials') {
        ToastHelper.error('Invalid credentials');
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<OwnerAuthProvider>().isLoading;

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
                  Text(
                    'OWNER LOGIN',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.ownerAccent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      onPressed: () => setState(() => _obscure = !_obscure),
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
                      ),
                      child: Text(
                        'Sign In',
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
