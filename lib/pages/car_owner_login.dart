import 'package:flutter/material.dart';
import '../auth/owner_auth_gate.dart';

/// Entry point for Car Owner portal — routes to auth hub or dashboard.
class CarOwnerLoginPage extends StatelessWidget {
  const CarOwnerLoginPage({super.key});

  @override
  Widget build(BuildContext context) => const OwnerAuthGate();
}
