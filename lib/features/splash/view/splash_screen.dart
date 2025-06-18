import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/splash/bloc/version_bloc/version_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<VersionBloc>().add(LoadVersionEvent());
    context.read<AuthBloc>().add(CheckLoaginStatusEvent());

    return MultiBlocListener(
      listeners: [
        BlocListener<VersionBloc, VersionState>(
          listener: (context, versionState) {
            if (versionState is VersionReady && versionState.canNavigate) {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (authState is UnAuthenticated) {
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            }
          },
        ),
      ],
      child: BlocBuilder<VersionBloc, VersionState>(
        builder: (context, versionState) {
          String? versionText;
                    if (versionState is VersionLoaded) {
            versionText = versionState.version;
          } else if (versionState is VersionReady) {
            versionText = versionState.version;
          }

          return Scaffold(
            backgroundColor: AppColors.textAccent,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(image: AssetImage('assets/images/bgerase-444.png')),
                  const SizedBox(height: 20),
                  if (versionText != null)
                    Text(
                      versionText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SplashPageWrapper extends StatelessWidget {
  const SplashPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => VersionBloc()),
        BlocProvider(create: (context) => AuthBloc(authService: AuthService())),
      ],
      child: const SplashScreen(),
    );
  }
}