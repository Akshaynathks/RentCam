import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/animate.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/widget/clickable.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';

class LoginPageWrapper extends StatelessWidget {
  const LoginPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final authblocc = BlocProvider.of<AuthBloc>(context);

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.loading,
          ),
        );
      }

      if (state is Authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        });
      }
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              CustomTextFormField(
                hintText: 'Email',
                controller: _emailController,
                validator: validateEmail,
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextFormField(
                obscureText: true,
                hintText: 'Password',
                controller: _passwordController,
                validator: validatePassword,
              ),
              SizedBox(height: screenHeight * 0.05),

              //

              CustomElevatedButton(
                text: 'Login',
                onPressed: () {
                  authblocc.add(LoaginEvent(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim()));
                },
                height: screenHeight * 0.07,
                width: screenWidth * 0.9,
              ),

              //

              SizedBox(height: screenHeight * 0.0),
              CustomAnimateWidget(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgotPassword');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              const CustomAnimateWidget(
                child: Row(
                  children: [
                    // Left Line
                    Expanded(
                      child: Divider(
                        color: AppColors.secondary, // Line color
                        thickness: 1.0, // Line thickness
                      ),
                    ),
                    // "OR" Text
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 16.0, // Font size
                          fontWeight: FontWeight.bold, // Bold text
                          color: Colors.black, // Text color
                        ),
                      ),
                    ),
                    // Right Line
                    Expanded(
                      child: Divider(
                        color: AppColors.secondary, // Line color
                        thickness: 1.0, // Line thickness
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomElevatedButton(
                icon: Image.asset('assets/images/google.png'),
                text: 'Sign in with Google',
                onPressed: () {},
                color: AppColors.containerPrimary,
                width: screenWidth * 0.8,
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomElevatedButton(
                icon: Image.asset('assets/images/facebook.png'),
                text: 'Sign in with Google',
                onPressed: () {},
                color: AppColors.containerPrimary,
                width: screenWidth * 0.8,
              ),
              SizedBox(height: screenHeight * 0.02),
              const CustomAnimateWidget(
                  child: Text('By continuing, you agree to our')),
              SizedBox(height: screenHeight * 0.01),
              CustomAnimateWidget(
                child: ClickableText(
                  onTap: () {},
                  text: 'Terms of service & Privacy Policy',
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
