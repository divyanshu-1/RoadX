import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});
  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final List<Map<String, String>> members = [];
  final TextEditingController name = TextEditingController();
  final TextEditingController role = TextEditingController();
  final TextEditingController contact = TextEditingController();

  void addMember() {
    if (name.text.isEmpty) return;
    setState(() {
      members.add({'name': name.text, 'role': role.text, 'contact': contact.text});
      name.clear();
      role.clear();
      contact.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CardTitle(icon: Icons.group, title: 'Authorized Members'),
            const SizedBox(height: 12),
            LabeledField(controller: name, label: 'Name', icon: Icons.person_outline),
            const SizedBox(height: 12),
            LabeledField(controller: role, label: 'Role', icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            LabeledField(controller: contact, label: 'Contact', icon: Icons.phone_outlined),
            const SizedBox(height: 16),
            const UploadRow(label: 'Upload ID / Document'),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight, child: GradientButton(onPressed: addMember, icon: Icons.add, child: const Text('Add Member'))),
          ]),
        ),
        const SizedBox(height: 16),
        ...members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(m['name'] ?? ''),
                  subtitle: Text('${m['role'] ?? ''} • ${m['contact'] ?? ''}'),
                  trailing: const Icon(Icons.more_horiz),
                ),
              ),
            )),
      ]),
    );
  }
}


