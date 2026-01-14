import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import '../screens.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  // ✅ Common login handler
  Future<void> loginUser({required bool asAdmin}) async {
    setState(() => isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
      final userDoc = await userRef.get();
      final userData = userDoc.data() ?? {};
      final isAdmin = userData['isAdmin'] == true;

      if (asAdmin) {
        // ✅ Admin login button pressed - only allow if user is already marked as admin
        if (!userDoc.exists || !isAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not authorized to access the admin panel.')),
          );
          await _auth.signOut();
          return;
        }
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      } else {
        // ✅ Normal user login
        if (!userDoc.exists) {
          await userRef.set({
            'email': email.text.trim(),
            'isAdmin': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        Navigator.pushReplacementNamed(context, AppRoutes.userShell);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found. Please sign up first.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = e.message ?? 'Login failed';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('RoadX'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.button),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.traffic, size: 32),
                      SizedBox(width: 8),
                      Text(
                        'RoadX',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ Email & Password Fields
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Normal User Login Button
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GradientButton(
                          onPressed: () => loginUser(asAdmin: false),
                          icon: Icons.login,
                          child: const Text('Login as User'),
                        ),
                        const SizedBox(height: 12),

                        // ✅ Admin Login Button (separate)
                        ElevatedButton.icon(
                          onPressed: () => loginUser(asAdmin: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primarySkyBlue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.admin_panel_settings,
                              color: Colors.white),
                          label: const Text(
                            'Login as Admin',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // ✅ Signup Redirect
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
                    child: const Text("Don't have an account? Sign up"),
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
