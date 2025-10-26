import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffix;

  const AppInput({
    super.key,
    required this.label,
    this.controller,
    this.obscure = false,
    this.keyboard,
    this.validator,
    this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
      ),
    );
  }
}
