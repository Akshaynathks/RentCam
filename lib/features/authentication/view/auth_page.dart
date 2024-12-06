import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/view/login.dart';
import 'package:rent_cam/features/authentication/view/signup.dart';

class MainAuthPage extends StatelessWidget {
  const MainAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: AppColors.containerPrimary,
              ),
              height: screenHeight * 0.09,
              child: const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.secondary,
                indicatorColor: AppColors.button,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                tabs: [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  LoginPageWrapper(),
                  SignupPageWrapper(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
