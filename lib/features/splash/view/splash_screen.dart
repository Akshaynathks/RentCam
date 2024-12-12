import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is UnAuthenticated) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.textAccent,
        body: Center(
          child: Image(image: AssetImage('assets/images/bgerase-444.png')),
        ),
      ),
    );
  }
}

class SplashPageWrappe extends StatelessWidget {
  const SplashPageWrappe({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: AuthService())..add(CheckLoaginStatusEvent()),
      child: SplashScreen(),
    );
  }
}
