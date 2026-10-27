import 'package:flutter/material.dart';

class PTTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator; // Add validator parameter
  final bool isFormField; // Add flag for validation support
  final TextInputType? keyboardType; // Add keyboard type parameter

  const PTTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.validator,
    this.isFormField = false, // Default to false for backward compatibility
    this.keyboardType,
  });

  // Extract decoration to avoid code duplication
  InputDecoration _buildDecoration(BuildContext context) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        // Add error styling
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        // Add focused error styling
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFormField) {
      return TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: _buildDecoration(context),
        validator: validator,
      );
    } else {
      return TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: _buildDecoration(context),
        style: const TextStyle(fontSize: 14),
      );
    }
  }
}
