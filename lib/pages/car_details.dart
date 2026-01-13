import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class CarDetailsPage extends StatelessWidget {
  const CarDetailsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            CardTitle(icon: Icons.directions_car, title: 'Car Details'),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const LabeledField(label: 'Car Name', icon: Icons.drive_file_rename_outline),
                const SizedBox(height: 12),
                const LabeledField(label: 'Car Type', icon: Icons.directions_car_filled_outlined),
                const SizedBox(height: 12),
                const LabeledField(label: 'Fuel', icon: Icons.local_gas_station_outlined),
                const SizedBox(height: 12),
                const LabeledField(label: 'Engine No', icon: Icons.engineering_outlined),
                const SizedBox(height: 12),
                const LabeledField(label: 'Chassis No', icon: Icons.confirmation_number_outlined),
                const SizedBox(height: 16),
                const UploadRow(label: 'Upload Car Pictures'),
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: GradientButton(onPressed: () {}, icon: Icons.save_outlined, child: const Text('Save'))),
          ]),
        ),
      ]),
    );
  }
}


