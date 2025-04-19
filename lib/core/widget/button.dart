import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/animate.dart';
import 'package:rent_cam/core/widget/color.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color color;
  final Widget? icon;
  final double iconSize;
  final Color iconColor;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50.0,
    this.color = AppColors.buttonSecondary,
    this.icon,
    this.iconSize = 24.0,
    this.iconColor = AppColors.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAnimateWidget(
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    color: iconColor,
                    size: iconSize,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
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
