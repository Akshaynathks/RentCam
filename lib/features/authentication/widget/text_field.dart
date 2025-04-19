import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/animate.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText; 
  final TextEditingController
      controller; 
  final bool obscureText; 
  final TextInputType keyboardType; 
  final String? Function(String?)? validator; 
  final Widget? prefixIcon; 
  final bool autoFocus;
  final int maxLines; 
  

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
          controller: widget.controller, 
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          autofocus: widget.autoFocus,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText, 
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured; 
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }
}
