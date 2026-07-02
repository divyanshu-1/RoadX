import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens.dart';
import '../utils/custom_snackbar.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.error(context, 'Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
      final userDoc = await userRef.get();
      final userData = userDoc.data() ?? {};
      final isAdmin = userData['isAdmin'] == true;

      if (!userDoc.exists || !isAdmin) {
        if (mounted) {
          CustomSnackBar.error(
            context,
            'Access denied. You are not authorized to view the Admin panel.',
          );
        }
        await _auth.signOut();
        return;
      }

      if (mounted) {
        CustomSnackBar.success(context, 'Welcome, Admin!');
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No admin account found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = e.message ?? 'Login failed';
      }
      if (mounted) {
        CustomSnackBar.error(context, message);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error(context, 'An error occurred checking credentials.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFF43F5E); // Rose Red

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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Header
                        Hero(
                          tag: 'admin_logo',
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 64,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Admin Portal',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Authorized administrators only',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Form GlassCard
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
                              // Email Input
                              Text(
                                'ADMIN EMAIL',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  fillColor: Colors.white.withOpacity(0.05),
                                  filled: true,
                                  hintText: 'Enter your admin email',
                                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: accentColor, width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Input
                              Text(
                                'SECURE KEYCODE / PASSWORD',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  fillColor: Colors.white.withOpacity(0.05),
                                  filled: true,
                                  hintText: 'Enter secret passphrase',
                                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF94A3B8)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: accentColor, width: 1.5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Login Button
                              if (_isLoading)
                                Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  onPressed: _loginAdmin,
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
                                    'Access Administration',
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
            ],
          ),
        ),
      ),
    );
  }
}
