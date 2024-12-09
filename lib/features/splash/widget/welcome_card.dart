import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class WelcomeCard extends StatelessWidget {
  final String animationPath; // Lottie animation file path
  final List<String> points; // List of bullet points
  final Color backgroundColor; // Background color for the card
  final double spacing; // Spacing between points

  const WelcomeCard({
    super.key,
    required this.animationPath,
    required this.points,
    required this.backgroundColor,
    this.spacing = 15.0, // Default spacing between points
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.all(16.0),
      color: backgroundColor, // Custom background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lottie Animation
            Lottie.asset(animationPath, height: 200), // Animation height

            const SizedBox(height: 20),

            // Dynamic List of Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((point) {
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: Text(
                    '• $point',
                    style: GoogleFonts.eczar(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Consistent text color
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
