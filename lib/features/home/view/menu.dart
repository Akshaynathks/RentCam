import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/home/widget/menu_button.dart';
import 'package:rent_cam/features/home/widget/profile_photo.dart';
import 'package:rent_cam/features/home/widget/user_details.dart';

class MenuPageWrapper extends StatelessWidget {
  const MenuPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: AuthService()),
      child: MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menu',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            height: screenHeight * 0.95,
            width: screenWidth * 0.9,
            decoration: BoxDecoration(
              color: AppColors.secondary, // Background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  height: screenHeight * 0.34,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: AppColors.background, // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: const Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatarSection(),
                      SizedBox(height: 20),
                      UserInfoSection(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MenuButton(
                  icon: Icons.shopping_cart,
                  label: 'My Orders',
                  onTap: () {
                    // Handle My Orders logic
                  },
                ),
                const SizedBox(height: 10),
                MenuButton(
                  icon: Icons.camera,
                  label: 'My Studio',
                  onTap: () {
                    // Handle My Studio logic
                  },
                ),
                const SizedBox(height: 10),
                MenuButton(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onTap: () {
                    // Handle Notifications logic
                  },
                ),
                const SizedBox(height: 10),
                MenuButton(
                  icon: Icons.info,
                  label: 'About Us',
                  onTap: () {
                    // Handle About Us logic
                  },
                ),
                const SizedBox(height: 10),
                MenuButton(
                  icon: Icons.description,
                  label: 'Terms of Use',
                  onTap: () {
                    // Handle Terms of Use logic
                  },
                ),
                const SizedBox(height: 10),
                MenuButton(
                  icon: Icons.lock,
                  label: 'Privacy Policy',
                  onTap: () {
                    // Handle Privacy Policy logic
                  },
                ),
                const SizedBox(height: 30),
                CustomElevatedButton(
                  text: 'Logout',
                  onPressed: () {
                    final authBloc = BlocProvider.of<AuthBloc>(context);
                    authBloc.add(LogoutEvent());

                    Navigator.pushNamedAndRemoveUntil(
                        context, '/auth', (route) => false);
                  },
                  icon: const Icon(Icons.logout),
                  width: screenWidth * 0.5,
                )
              ],
            ) // Menu Buttons

            ),
      ),
    );
  }
}
