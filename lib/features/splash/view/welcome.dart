import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/features/splash/widget/welcome_card.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({super.key});

  // List of data for the Welcome Cards
  final List<Map<String, dynamic>> welcomeCardData = [
    {
      "animationPath": "assets/images/Animation - welcome1.json",
      "points": ["Wide Range of Rentals", "Flexible Options", "Simple Booking"],
      "backgroundColor": Colors.white,
    },
    {
      "animationPath": "assets/images/Animation - welcome1.json",
      "points": ["Add Studio Details", "Custom Plans", "User-Friendly"],
      "backgroundColor": Colors.blue,
    },
    {
      "animationPath": "assets/images/Animation - welcome1.json",
      "points": ["Quick Support", "Affordable Pricing", "Satisfaction Guaranteed"],
      "backgroundColor": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        colors: welcomeCardData
            .map((data) => data["backgroundColor"] as Color)
            .toList(),
        itemCount: welcomeCardData.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (int index) {
          // Generate the WelcomeCard dynamically
          final cardData = welcomeCardData[index];
          return WelcomeCard(
            animationPath: cardData["animationPath"] as String,
            points: cardData["points"] as List<String>,
            backgroundColor: cardData["backgroundColor"] as Color,
          );
        },
      ),
    );
  }
}

