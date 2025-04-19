import 'package:concentric_transition/page_view.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/splash/widget/welcome_card.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int currentIndex = 0; 


  final List<WelcomeCardData> welcomeCardData = [
    const WelcomeCardData(
      animationPath: 'assets/images/Animation - welcome1.json', 
      points: [
        "Wide Range of Rentals",
        "Flexible Options",
        "Add studio details ",
        "Simple Booking",
      ],
      backgroundColor: AppColors.secondary,
    ),
    const WelcomeCardData(
      animationPath: 'assets/images/Animation - welcome2.json', 
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
          ConcentricPageView(
            colors: welcomeCardData.map((data) => data.backgroundColor).toList(),
            itemCount: welcomeCardData.length,
            physics: const BouncingScrollPhysics(),
            onChange: (index) {
              setState(() {
                currentIndex = index;
              });

              if (currentIndex == welcomeCardData.length - 1) {
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacementNamed(context, '/auth');
                });
              }
            },
            itemBuilder: (int index) {
              final data = welcomeCardData[index];
              return WelcomeCard(data: data); 
            },
          ),
          Positioned(
            bottom: 30, 
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
                  : Container(), 
            ),
          ),
        ],
      ),
    );
  }
}
