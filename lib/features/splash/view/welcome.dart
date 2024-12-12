import 'package:concentric_transition/page_view.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/splash/widget/welcome_card.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int currentIndex = 0; // Track the current page index

  // List of WelcomeCardData for each screen
  final List<WelcomeCardData> welcomeCardData = [
    const WelcomeCardData(
      animationPath: 'assets/images/Animation - welcome1.json', // Lottie animation path
      points: [
        "Wide Range of Rentals",
        "Flexible Options",
        "Add studio details ",
        "Simple Booking",
      ],
      backgroundColor: AppColors.secondary,
    ),
    const WelcomeCardData(
      animationPath: 'assets/images/Animation - welcome2.json', // Lottie animation path
      points: [
        "Custom Event Packages",
        "Increase Your Visibility",
        "Secure Payments",
        "Track Bookings",
      ],
      backgroundColor: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // ConcentricPageView to display cards
          ConcentricPageView(
            colors: welcomeCardData.map((data) => data.backgroundColor).toList(),
            itemCount: welcomeCardData.length,
            physics: const BouncingScrollPhysics(),
            onChange: (index) {
              // Update the current page index
              setState(() {
                currentIndex = index;
              });

              // Navigate to Auth page when the second page is reached
              if (currentIndex == welcomeCardData.length - 1) {
                Future.delayed(Duration(seconds: 3), () {
                  Navigator.pushReplacementNamed(context, '/auth');
                });
              }
            },
            itemBuilder: (int index) {
              final data = welcomeCardData[index];
              return WelcomeCard(data: data); // Pass data to WelcomeCard
            },
          ),

          // Add text or message at the bottom
          Positioned(
            bottom: 30, // Position above page indicators
            left: 0,
            right: 0,
            child: Center(
              child: currentIndex == 0
                  ? const Text(
                      "Swipe to Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container(), // No button displayed on the last page
            ),
          ),
        ],
      ),
    );
  }
}
