import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens.dart';
import 'firebase_options.dart';
import 'auth/owner_auth_provider.dart';
import 'auth/owner_auth_gate.dart';
import 'pages/login_selection_screen.dart';
import 'pages/user_login.dart';
import 'pages/admin_login.dart';
import 'pages/admin_dashboard.dart';
import 'pages/emergency_screen.dart';
import 'rto/rto_login_screen.dart';
import 'owner/owner_register_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseService.initialize();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerAuthProvider()..initSession(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'RoadX',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginSelectionScreen(),
          AppRoutes.userLogin: (context) => const UserLoginPage(),
          AppRoutes.adminLogin: (context) => const AdminLoginPage(),
          AppRoutes.carOwnerLogin: (context) => const OwnerAuthGate(),
          AppRoutes.ownerRegister: (context) => const OwnerRegisterScreen(),
          AppRoutes.rtoLogin: (context) => const RtoLoginScreen(),
          AppRoutes.userShell: (context) => const UserShell(),
          AppRoutes.admin: (context) => const AdminPanelGuarded(),
          AppRoutes.emergency: (context) => const EmergencyScreen(),
        },
      ),
    );
  }
}

