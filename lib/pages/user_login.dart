import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens.dart';
import '../utils/custom_snackbar.dart';
import 'signup.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginUser() async {
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

      if (!userDoc.exists) {
        await userRef.set({
          'email': email,
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        CustomSnackBar.success(context, 'Logged in successfully!');
        Navigator.pushReplacementNamed(context, AppRoutes.userShell);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
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
        CustomSnackBar.error(context, 'An unexpected error occurred.');
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
    final accentColor = const Color(0xFF38BDF8);

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
                          tag: 'app_logo',
                          child: const Icon(
                            Icons.traffic_rounded,
                            size: 64,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'User Portal',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Access vehicle status, reporting and profile',
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
                                'EMAIL ADDRESS',
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
                                  hintText: 'Enter your email',
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
                                'PASSWORD',
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
                                  hintText: 'Enter your password',
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
                                  onPressed: _loginUser,
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
                                    'Login to System',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Signup Redirect
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          ),
                          child: Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(color: accentColor, fontWeight: FontWeight.w600),
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
