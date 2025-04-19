import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/home/bloc/user_details/user_details_bloc.dart';
import 'package:rent_cam/features/home/services/user_service.dart';
import 'package:rent_cam/features/home/view/my_orders.dart';
import 'package:rent_cam/features/home/widget/menu_button.dart';
import 'package:rent_cam/features/home/widget/profile_photo.dart';
import 'package:rent_cam/features/home/widget/user_details.dart';

class MenuPageWrapper extends StatelessWidget {
  const MenuPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService: AuthService()),
        ),
        BlocProvider(
          create: (_) => UserDetailsBloc(userService: UserService())
            ..add(FetchUserDetails()),
        ),
      ],
      child: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Menu',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: screenHeight * 0.95,
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              BlocBuilder<UserDetailsBloc, UserDetailsState>(
                builder: (context, state) {
                  if (state is UserDetailsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserDetailsError) {
                    return Center(child: Text("Error: ${state.error}"));
                  } else if (state is UserDetailsLoaded) {
                    return Container(
                      height: screenHeight * 0.32,
                      width: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const CircleAvatarSection(),
                          const SizedBox(height: 10),
                          UserInfoSection(
                            userDetails: state.userDetails,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text("No data available."));
                  }
                },
              ),
              const SizedBox(height: 20),
              MenuButton(
                icon: Icons.shopping_cart,
                label: 'My Orders',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrders()),
                  );
                },
              ),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.camera,
                label: 'My Studio',
                onTap: () {
                  Navigator.pushNamed(context, '/studio');
                },
              ),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.info,
                label: 'About Us',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.description,
                label: 'Terms of Use',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.lock,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              const SizedBox(height: 30),
              CustomElevatedButton(
                text: 'Logout',
                onPressed: () {
                  final authBloc = BlocProvider.of<AuthBloc>(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              authBloc.add(LogoutEvent(context: context));
                              Navigator.of(dialogContext).pop();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/auth',
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                width: screenWidth * 0.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
