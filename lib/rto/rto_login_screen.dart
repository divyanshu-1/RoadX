import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dark_glass_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/loading_indicator.dart';
import 'rto_shell_screen.dart';

/// RTO officer login — local credentials + Firebase Anonymous Auth for RTDB access.
class RtoLoginScreen extends StatefulWidget {
  const RtoLoginScreen({super.key});

  @override
  State<RtoLoginScreen> createState() => _RtoLoginScreenState();
}

class _RtoLoginScreenState extends State<RtoLoginScreen> {
  final _officerIdController = TextEditingController(
    text: AppConstants.demoRtoOfficerId,
  );
  final _passcodeController = TextEditingController(
    text: AppConstants.demoRtoPasscode,
  );
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _officerIdController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _officerIdController.text.trim();
    final pass = _passcodeController.text.trim();

    if (id.isEmpty || pass.isEmpty) {
      CustomSnackBar.error(context, 'Enter Officer ID and passcode');
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _loading = false);

    if (id == AppConstants.demoRtoOfficerId &&
        pass == AppConstants.demoRtoPasscode) {
      setState(() => _loading = true);
      try {
        await FirebaseAuth.instance.signOut();
        await FirebaseAuth.instance.signInAnonymously();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RtoShellScreen(
              officerId: id,
              officerName: 'Officer $id',
            ),
          ),
        );
        CustomSnackBar.success(context, 'Welcome to RTO Portal');
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        final msg = switch (e.code) {
          'operation-not-allowed' =>
            'Enable Anonymous sign-in: Firebase Console → Authentication → Sign-in method → Anonymous → Enable',
          'admin-restricted-operation' =>
            'Anonymous Auth is restricted. Enable it in Firebase Console for project mainroadx.',
          _ => e.message ?? 'Firebase sign-in failed (${e.code})',
        };
        CustomSnackBar.error(context, msg);
      } catch (e) {
        if (!mounted) return;
        CustomSnackBar.error(context, e.toString());
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } else {
      CustomSnackBar.error(
        context,
        'Invalid credentials. Use ${AppConstants.demoRtoOfficerId} / ${AppConstants.demoRtoPasscode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      Icon(Icons.security_rounded,
                          size: 64, color: AppConstants.rtoAccent),
                      const SizedBox(height: 12),
                      Text(
                        'RTO Inspector',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.rtoAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                AppConstants.rtoAccent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Default: ${AppConstants.demoRtoOfficerId} / ${AppConstants.demoRtoPasscode}\n'
                          'Requires Anonymous Auth enabled in Firebase',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppConstants.rtoAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      DarkGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _officerIdController,
                              hintText: 'Officer ID',
                              prefixIcon: Icons.badge_rounded,
                              accentColor: AppConstants.rtoAccent,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passcodeController,
                              hintText: 'Passcode',
                              prefixIcon: Icons.vpn_key_rounded,
                              accentColor: AppConstants.rtoAccent,
                              obscureText: _obscure,
                              keyboardType: TextInputType.number,
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
                            ),
                            const SizedBox(height: 24),
                            if (_loading)
                              const Center(
                                child: AppLoadingIndicator(
                                  color: AppConstants.rtoAccent,
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.rtoAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
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
          ],
        ),
      ),
    );
  }
}
