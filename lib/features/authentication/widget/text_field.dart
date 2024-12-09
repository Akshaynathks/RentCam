import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/animate.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText; // Placeholder text for the field (mandatory)
  final TextEditingController
      controller; // Controller to manage text input (mandatory)
  final bool obscureText; // For hiding text (e.g., passwords)
  final TextInputType keyboardType; // Keyboard type (e.g., email, number)
  final String? Function(String?)? validator; // Form field validation function
  final Widget? prefixIcon; // Optional prefix icon
  final bool autoFocus; // Whether to focus on this field automatically
  final int maxLines; // Maximum lines (default: 1 for single-line input)
  

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.autoFocus = false,
    this.maxLines = 1,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomAnimateWidget(
        child: TextFormField(
          controller: widget.controller, // Mandatory controller
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          autofocus: widget.autoFocus,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText, // Mandatory hint text
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured; // Toggle visibility
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFC107), width: 2.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 17.0, vertical: 16.0),
          ),
          validator: widget.validator, 
          autovalidateMode: AutovalidateMode.onUserInteraction,// Field validation
        ),
      ),
    );
  }
}
