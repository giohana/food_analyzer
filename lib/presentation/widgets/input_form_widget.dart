import 'package:flutter/material.dart';

class InputFormWidget extends StatelessWidget {
  const InputFormWidget({
    required this.labelText,
    required this.validator,
    required this.controller,
    required this.focusNode,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final String labelText;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final bool obscureText;
  final FocusNode focusNode;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      focusNode: focusNode,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
