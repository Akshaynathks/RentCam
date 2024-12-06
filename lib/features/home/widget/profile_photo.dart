import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/color.dart';

class CircleAvatarSection extends StatelessWidget {
  const CircleAvatarSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            // Lottie animation for avatar
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Lottie.asset(
                  'assets/images/Animation - user.json', // Lottie animation path
                  fit: BoxFit.cover, // Cover the circle
                ),
              ),
            ),
            // Add photo icon
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
                onPressed: () {
                  // Handle image selection logic
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}