import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_event.dart';

class CustomBottomNavBar extends StatelessWidget {
  final NotchBottomBarController controller;

  const CustomBottomNavBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardGradientStart, AppColors.cardGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AnimatedNotchBottomBar(
        notchBottomBarController: controller,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: const Icon(Icons.home),
            activeItem:
                _buildLottieIcon('assets/images/Animation - home.json', true),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: const Icon(Icons.shopping_bag),
            activeItem: _buildLottieIcon(
                'assets/images/Animation - product.json', true),
            itemLabel: 'Products',
          ),
          BottomBarItem(
            inActiveItem: const Icon(Icons.camera_enhance_outlined),
            activeItem:
                _buildLottieIcon('assets/images/Animation - studio.json', true),
            itemLabel: 'Studio',
          ),
          BottomBarItem(
            inActiveItem: const Icon(Icons.shopping_cart),
            activeItem:
                _buildLottieIcon('assets/images/Animation - cart.json', true),
            itemLabel: 'Cart',
          ),
          BottomBarItem(
            inActiveItem: const Icon(Icons.chat),
            activeItem:
                _buildLottieIcon('assets/images/Animation - chat.json', true),
            itemLabel: 'Chat',
          ),
        ],
        onTap: (index) {
          context.read<HomeBloc>().add(ChangeTabEvent(index));
        },
        kBottomRadius: 20,
        kIconSize: 30,
        showLabel: true,
      ),
    );
  }

  Widget _buildLottieIcon(String assetPath, bool isActive) {
    return SizedBox(
      width: isActive ? 10 : 30,
      height: isActive ? 10 : 30,
      child: Lottie.asset(
        assetPath,
        repeat: true,
        fit: BoxFit.contain,
      ),
    );
  }
}
