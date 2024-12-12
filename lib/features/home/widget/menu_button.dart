import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Makes the button stretch to full width
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 2, // Shadow effect
          backgroundColor: Colors.white, // Button background color
          foregroundColor: AppColors.buttonPrimary, // Icon and ripple effect color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 12), // Vertical padding
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.10),
          child: Row(
            children: [
              Icon(icon, color: AppColors.buttonPrimary), // Icon on the left
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black, // Text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
