import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens.dart';
import 'pages/login.dart';
import 'pages/admin_dashboard.dart';
import 'pages/emergency_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoadX',
      theme: buildAppTheme(),
      // start from login screen
      initialRoute: AppRoutes.login,
      routes: {
        // Login page
        AppRoutes.login: (context) => const LoginPage(),

        // User interface after login
        AppRoutes.userShell: (context) => const UserShell(),

        // Admin dashboard (renamed from AdminPanel)
        AppRoutes.admin: (context) => const AdminPanel(),

        // Emergency reporting page
        AppRoutes.emergency: (context) => const EmergencyScreen(),
      },
    );
  }
}
