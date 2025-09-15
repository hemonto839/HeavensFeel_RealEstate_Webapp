import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;

  const Textfield({
      super.key,
      required this.hintText,
      required this.controller,
      required this.obscureText,
  });

  @override 
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }
}