import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Icon prefixIcon;
  final TextEditingController controller;
  const InputField(
      {required this.prefixIcon,
      required this.obscureText,
      required this.hintText,
      required this.controller,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontWeight: FontWeight.w300),
            prefixIcon: prefixIcon,
            fillColor: Colors.white,
            filled: true,
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(12)))),
      ),
    );
  }
}
