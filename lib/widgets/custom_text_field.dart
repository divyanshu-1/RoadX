import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final Color accentColor;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.accentColor = const Color(0xFF10B981), // Default Emerald Green
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        fillColor: Colors.white.withOpacity(0.05),
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFF87171).withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}
