import 'package:flutter/material.dart';
import '../theme.dart';

class GradientBackgroundContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  
  const GradientBackgroundContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.button,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySkyBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const CardTitle({super.key, required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return GradientBackgroundContainer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20), 
          const SizedBox(width: 8), 
          Text(
            title, 
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final int maxLines;
  final TextEditingController? controller;
  const LabeledField({super.key, required this.label, required this.icon, this.maxLines = 1, this.controller});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class UploadRow extends StatelessWidget {
  final String label;
  const UploadRow({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.cloud_upload_outlined),
      const SizedBox(width: 8),
      Expanded(child: Text(label)),
      FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.attach_file), label: const Text('Choose File')),
    ]);
  }
}


