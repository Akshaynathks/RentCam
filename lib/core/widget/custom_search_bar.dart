import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextStyle? hintStyle;

  const CustomSearchBar({
    required this.hintText,
    this.hintStyle,
    super.key, required Null Function(dynamic query) onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      decoration: BoxDecoration(
        color: AppColors.indicatorInactive,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: AppColors.indicatorActive),
              onPressed: () {}
              ),
        ),
      ),
    );
  }
}
