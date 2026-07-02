import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/owner_auth_provider.dart';
import '../models/owner_model.dart';
import '../screens.dart';
import '../services/firebase_owner_service.dart';
import '../utils/app_constants.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/loading_indicator.dart';
import 'widgets/user_shared_widgets.dart';

/// User profile tab with account info and settings actions.
class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  Future<void> _editProfile(BuildContext context, OwnerModel owner) async {
    final uid = owner.uid;
    final nameCtrl = TextEditingController(text: owner.ownerName);
    final phoneCtrl = TextEditingController(text: owner.phone);
    final aadhaarCtrl = TextEditingController(text: owner.aadhaar);
    final addressCtrl = TextEditingController(text: owner.address);
    final service = FirebaseOwnerService();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit Profile', style: GoogleFonts.outfit(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: aadhaarCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Aadhaar'),
              ),
              TextField(
                controller: addressCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || !context.mounted) {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      aadhaarCtrl.dispose();
      addressCtrl.dispose();
      return;
    }

    try {
      await service.updateOwnerProfile(
        uid: uid,
        ownerName: nameCtrl.text,
        phone: phoneCtrl.text,
        aadhaar: aadhaarCtrl.text,
        address: addressCtrl.text,
      );
      if (context.mounted) CustomSnackBar.success(context, 'Profile updated');
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.error(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      aadhaarCtrl.dispose();
      addressCtrl.dispose();
    }
  }

  Future<void> _changePassword(BuildContext context, String email) async {
    if (email.isEmpty) {
      CustomSnackBar.error(context, 'No email on file for password reset');
      return;
    }
    try {
      await FirebaseOwnerService().sendPasswordReset(email);
      if (context.mounted) {
        CustomSnackBar.success(context, 'Password reset link sent to $email');
      }
    } catch (e) {
      if (context.mounted) CustomSnackBar.error(context, e.toString());
    }
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(body, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<OwnerAuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: AppLoadingIndicator());

    return StreamBuilder<OwnerModel?>(
      stream: FirebaseOwnerService().watchOwner(uid),
      builder: (context, snap) {
        final owner = snap.data;
        if (owner == null) {
          return const Center(
            child: AppLoadingIndicator(color: AppConstants.ownerAccent),
          );
        }

        final licenseVerified = owner.licenseNo.isNotEmpty;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.ownerAccent.withValues(alpha: 0.4),
                          AppConstants.ownerAccent.withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: AppConstants.ownerAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    owner.ownerName,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (licenseVerified ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (licenseVerified ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          licenseVerified ? Icons.verified_rounded : Icons.pending_outlined,
                          size: 16,
                          color: licenseVerified ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          licenseVerified ? 'License Verified ✓' : 'License Pending',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: licenseVerified ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (owner.licenseImageUrl.isNotEmpty) ...[
              userGlassCard(
                title: 'LICENSE IMAGE',
                icon: Icons.credit_card_outlined,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    owner.licenseImageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            color: AppConstants.ownerAccent,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      alignment: Alignment.center,
                      child: Text(
                        'Could not load license image',
                        style: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            userGlassCard(
              title: 'USER INFORMATION',
              icon: Icons.badge_outlined,
              child: Column(
                children: [
                  _infoRow('Full Name', owner.ownerName),
                  _infoRow('Email', owner.email),
                  _infoRow('Phone', owner.phone),
                  _infoRow('Aadhaar', owner.aadhaar),
                  _infoRow('License Number', owner.licenseNo),
                ],
              ),
            ),
            const SizedBox(height: 16),
            userSectionTitle('Account Actions'),
            _actionTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update your personal details',
              onTap: () => _editProfile(context, owner),
            ),
            _actionTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Send reset link to your email',
              onTap: () => _changePassword(context, owner.email),
            ),
            _actionTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get assistance with RoadX',
              onTap: () => _showInfoDialog(
                context,
                'Help & Support',
                'Contact RoadX support at support@roadx.app or call 1800-ROADX-01.',
              ),
            ),
            _actionTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => _showInfoDialog(
                context,
                'Privacy Policy',
                'RoadX protects your personal and vehicle data. '
                'Information is stored securely and used only for traffic management services.',
              ),
            ),
            const SizedBox(height: 8),
            _actionTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () => _logout(context),
              isDestructive: true,
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFEF4444) : AppConstants.ownerAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: isDestructive ? color : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.7)),
      ),
    );
  }
}
