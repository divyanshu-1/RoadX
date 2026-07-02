import 'package:flutter/material.dart';
import '../owner/owner_login_screen.dart';
import '../services/firebase_owner_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_background.dart';

/// Always requires owner email/password — never auto-skips to dashboard.
class OwnerAuthGate extends StatefulWidget {
  const OwnerAuthGate({super.key});

  @override
  State<OwnerAuthGate> createState() => _OwnerAuthGateState();
}

class _OwnerAuthGateState extends State<OwnerAuthGate> {
  final _service = FirebaseOwnerService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (_service.isOwnerAccountLoggedIn()) {
      await _service.signOut();
    } else if (_service.isOwnerLoggedIn()) {
      await _service.signOut();
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const PremiumBackground(
        child: Center(child: AppLoadingIndicator()),
      );
    }
    return const OwnerLoginScreen();
  }
}
