import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'authorized_members.dart';

class OwnerDetailsPage extends StatelessWidget {
  const OwnerDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CardTitle(icon: Icons.person, title: 'Owner Details'),
          const SizedBox(height: 12),
          const LabeledField(label: 'Owner Name', icon: Icons.person_outline),
          const SizedBox(height: 12),
          const LabeledField(label: 'Contact Info', icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          const LabeledField(label: 'Email', icon: Icons.alternate_email),
          const SizedBox(height: 12),
          const LabeledField(label: 'Address', icon: Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 16),
          const UploadRow(label: 'Upload License / Documents'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MembersPage()),
                  );
                },
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('Manage Authorized Members'),
              ),
            ),
            const SizedBox(width: 12),
            GradientButton(onPressed: () {}, icon: Icons.save_outlined, child: const Text('Save')),
          ]),
        ]),
      ),
    );
  }
}


