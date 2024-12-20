import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/animate.dart';
import 'package:rent_cam/core/widget/color.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color color; // Button color
  final Widget? icon; // Optional icon
  final double iconSize; // Icon size
  final Color iconColor; // Icon color

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity, // Default width
    this.height = 50.0, // Default height
    this.color = AppColors.buttonSecondary, // Default button color
    this.icon, // Optional icon
    this.iconSize = 24.0, // Default icon size
    this.iconColor = Colors.white, // Default icon color
  });

  @override
  Widget build(BuildContext context) {
    return CustomAnimateWidget(
      child: SizedBox(
        width: width, // Adjustable width
        height: height, // Adjustable height
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Customizable color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Fixed corner radius
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: iconColor, // Apply the custom icon color
                    size: iconSize, // Set the icon size
                  ),
                  child: icon!,
                ),
                const SizedBox(width: 8), // Space between icon and text
              ],
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary, // Fixed text color
                  fontSize: 16, // Fixed font size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
