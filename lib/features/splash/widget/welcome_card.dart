import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/color.dart';

class WelcomeCardData {
  final String animationPath; // Lottie animation file path
  final List<String> points; // List of bullet points
  final Color backgroundColor; // Background color for the page
  final double spacing; // Spacing between points

  const WelcomeCardData({
    required this.animationPath,
    required this.points,
    required this.backgroundColor,
    this.spacing = 15.0, // Default spacing between points
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
          // Animation and Points Centered
          const SizedBox(height: 80),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Lottie Animation
                Lottie.asset(data.animationPath, height: 200),

                const SizedBox(height: 30),

                // Dynamic List of Points with Dots
                Padding(
                  padding: const EdgeInsets.only(left: 85),
                  child: Column(
                    children: data.points.map((point) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: data.spacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center align the points
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Align text to the top
                          children: [
                            // Dot before each point
                            Container(
                              width: 10, // Dot size
                              height: 10,
                              margin: const EdgeInsets.only(
                                  right: 10), // Space between dot and text
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textPrimary, // Dot color
                              ),
                            ),
                            // Text for the point
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
