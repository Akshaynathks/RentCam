import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/core/widget/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrandCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final VoidCallback onTap;

  const BrandCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: AppColors.cardGradientStart,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imagePath.isEmpty
                      ? const ShimmerEffect.rectangular(
                          height: 60, width: 60) // Shimmer while loading
                      : Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ShimmerEffect.rectangular(
                                height: 60, width: 60); // Shimmer while loading
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image,
                                size: 50, color: Colors.red);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.buttonText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
