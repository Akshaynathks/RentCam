import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, 
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 2, 
          backgroundColor: Colors.white, 
          foregroundColor: AppColors.buttonPrimary, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
          ),
          padding: const EdgeInsets.symmetric(vertical: 12), 
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.10),
          child: Row(
            children: [
              Icon(icon, color: AppColors.buttonPrimary), 
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black, 
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
