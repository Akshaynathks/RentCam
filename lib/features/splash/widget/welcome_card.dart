import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/color.dart';

class WelcomeCardData {
  final String animationPath;
  final List<String> points;
  final Color backgroundColor;
  final double spacing;

  const WelcomeCardData({
    required this.animationPath,
    required this.points,
    required this.backgroundColor,
    this.spacing = 15.0,
  });
}

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key, required this.data});

  final WelcomeCardData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Lottie.asset(data.animationPath, height: 200),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 85),
                  child: Column(
                    children: data.points.map((point) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: data.spacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                point,
                                style: GoogleFonts.eczar(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
