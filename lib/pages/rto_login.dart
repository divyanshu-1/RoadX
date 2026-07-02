// Legacy route — opens new RTO login screen.
export '../rto/rto_login_screen.dart' show RtoLoginScreen;

import 'package:flutter/material.dart';
import '../rto/rto_login_screen.dart';

@Deprecated('Use RtoLoginScreen directly')
class RtoLoginPage extends StatelessWidget {
  const RtoLoginPage({super.key});

  @override
  Widget build(BuildContext context) => const RtoLoginScreen();
}
