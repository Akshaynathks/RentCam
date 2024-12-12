import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/forgot_password_bloc/bloc/forgot_password_bloc.dart';
import 'package:rent_cam/features/authentication/bloc/forgot_password_bloc/bloc/forgot_password_event.dart';
import 'package:rent_cam/features/authentication/bloc/forgot_password_bloc/bloc/forgot_password_state.dart';
import 'package:rent_cam/features/authentication/view/auth_page.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Forgot Password',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.secondary,
            ),
            width: screenWidth * 0.9,
            height: screenHeight * 0.6,
            child: BlocProvider(
              create: (_) => ForgotPasswordBloc(),
              child: BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
                listener: (context, state) {
                  if (state is ForgotPasswordSuccess) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text(
                              'Password reset link sent! Check your email'),
                        );
                      },
                    ).then((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainAuthPage()),
                      );
                    });
                  } else if (state is ForgotPasswordError) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(state.errorMessage),
                        );
                      },
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie animation
                    Lottie.asset(
                      'assets/images/Animation - forgot password.json',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enter your registered email to reset your password',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.textAccent),
                    ),
                    const SizedBox(height: 30),
                    CustomTextFormField(
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 30),
                    BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        if (state is ForgotPasswordLoading) {
                          return const CircularProgressIndicator();
                        }
                        return CustomElevatedButton(
                          width: screenWidth * 0.5,
                          text: 'Send',
                          onPressed: () {
                            final email = _emailController.text.trim();
                            if (_emailController.text.isNotEmpty) {
                              BlocProvider.of<ForgotPasswordBloc>(context)
                                  .add(SendPasswordResetEmail(email: email));
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const AlertDialog(
                                    content: Text('Please enter a valid email'),
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
