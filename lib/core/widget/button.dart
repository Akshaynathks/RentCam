import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/animate.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color color; // Button color
  final Widget? icon; // Optional icon
  final double iconSize; // Icon size

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity, // Default width
    this.height = 50.0, // Default height
    this.color = const Color(0xFFFFC107), // Default button color
    this.icon, // Optional icon
    this.iconSize = 24.0, // Default icon size
  }) : super(key: key);

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
                SizedBox(
                  height: iconSize, // Set height of icon
                  width: iconSize, // Set width of icon
                  child: icon, // Add the optional icon if provided
                ),
                const SizedBox(width: 8), // Space between icon and text
              ],
              Text(
                text,
                style: const TextStyle(
                  color: Colors.black, // Fixed text color
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
