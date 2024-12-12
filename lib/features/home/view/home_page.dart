import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';

class HomePageWraper extends StatelessWidget {
  const HomePageWraper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: AuthService()),
      child: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.buttonPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
        ],
      ),
    );
  }
}
