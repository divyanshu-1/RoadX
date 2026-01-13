import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPayPage extends StatelessWidget {
  const HistoryPayPage({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: const [
        TabBar(tabs: [Tab(text: 'History', icon: Icon(Icons.history)), Tab(text: 'Pay Challan', icon: Icon(Icons.receipt_long))]),
        Expanded(child: _HistoryPayBody())
      ]),
    );
  }
}

class _HistoryPayBody extends StatelessWidget {
  const _HistoryPayBody();
  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [
      _HistoryTab(),
      _PayChallanTab(),
    ]);
  }
}

class _HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
    final Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('date', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: const [GlassCard(child: Padding(padding: EdgeInsets.all(16), child: Text('No history yet.')))],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final String type = (d['type'] ?? 'Activity') as String;
            final Timestamp? ts = d['date'] as Timestamp?;
            final String date = ts != null ? ts.toDate().toLocal().toString().split('.').first : '';
            final String status = (d['status'] ?? 'Unpaid') as String;
            final num amount = (d['challanAmount'] ?? 0) as num;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: Text(type),
                  subtitle: Text(date),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _StatusChip(status: status),
                    const SizedBox(width: 8),
                    if (status != 'Paid')
                      GradientButton(
                        icon: Icons.payment,
                        onPressed: () async {
                          await docs[i].reference.set({'status': 'Paid'}, SetOptions(merge: true));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Challan of ₹$amount marked paid')));
                        },
                        child: const Text('Pay Challan'),
                      ),
                  ]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PayChallanTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const CardTitle(icon: Icons.receipt_long, title: 'Pay Challan'),
          const SizedBox(height: 12),
          const LabeledField(label: 'Challan No', icon: Icons.confirmation_number_outlined),
          const SizedBox(height: 12),
          const LabeledField(label: 'Amount', icon: Icons.currency_rupee),
          const SizedBox(height: 12),
          const LabeledField(label: 'Remarks', icon: Icons.notes_outlined, maxLines: 2),
          const SizedBox(height: 16),
          GradientButton(onPressed: () {}, icon: Icons.lock, child: const Text('Proceed to Pay (Dummy)')),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});
  Color _bg() {
    switch (status) {
      case 'Paid':
        return const Color(0xFFD1FAE5);
      case 'Unpaid':
        return const Color(0xFFFEE2E2);
      case 'Disputed':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFE5E7EB);
    }
  }
  Color _fg() {
    switch (status) {
      case 'Paid':
        return const Color(0xFF065F46);
      case 'Unpaid':
        return const Color(0xFF991B1B);
      case 'Disputed':
        return const Color(0xFF92400E);
      default:
        return const Color(0xFF374151);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _bg(), borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(color: _fg(), fontWeight: FontWeight.w600)),
    );
  }
}


