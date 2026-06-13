import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          maxLength: maxLength,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
