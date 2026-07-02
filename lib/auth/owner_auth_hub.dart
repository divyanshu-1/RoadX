import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_constants.dart';
import '../widgets/gradient_background.dart';
import 'owner_login_tab.dart';
import 'owner_register_tab.dart';
import 'owner_forgot_password_tab.dart';
import 'owner_vehicle_verify_tab.dart';

/// Owner authentication hub: login, register, forgot password, vehicle verify.
class OwnerAuthHub extends StatefulWidget {
  const OwnerAuthHub({super.key});

  @override
  State<OwnerAuthHub> createState() => _OwnerAuthHubState();
}

class _OwnerAuthHubState extends State<OwnerAuthHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.directions_car_filled_rounded,
                            size: 48, color: AppConstants.ownerAccent),
                        const SizedBox(height: 8),
                        Text(
                          'Owner Portal',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Secure vehicle owner authentication',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppConstants.ownerAccent,
              labelColor: AppConstants.ownerAccent,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Login'),
                Tab(text: 'Register'),
                Tab(text: 'Forgot'),
                Tab(text: 'Verify'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OwnerLoginTab(),
                  OwnerRegisterTab(),
                  OwnerForgotPasswordTab(),
                  OwnerVehicleVerifyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
