import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/bottom_bar.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_bloc.dart';
import 'package:rent_cam/features/home/bloc/home_bloc/home_state.dart';
import 'package:rent_cam/features/product/view/cart.dart';
import 'package:rent_cam/features/chat/view/chat.dart';
import 'package:rent_cam/features/home/view/home_page.dart';
import 'package:rent_cam/features/product/view/products.dart';
import 'package:rent_cam/features/studio/view/studio.dart';

class HomePageWrapper extends StatelessWidget {
  const HomePageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: AuthService())),
        BlocProvider(create: (context) => HomeBloc()),
      ],
      child: const HomePageMain(),
    );
  }
}

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key});

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  final NotchBottomBarController _bottomBarController =
      NotchBottomBarController();

  final List<Widget> _pages = [
    const HomePage(),
    const ProductsPage(),
    const StudioPage(),
    const CartPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        int currentIndex = 0;
        if (state is TabChangedState) {
          currentIndex = state.index;
        }

        return Scaffold(
          body: _pages[currentIndex],
          bottomNavigationBar:
              CustomBottomNavBar(controller: _bottomBarController),
        );
      },
    );
  }
}
