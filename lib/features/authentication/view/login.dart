import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/animate.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/authentication/widget/clickable.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';

class LoginPageWrapper extends StatelessWidget {
  const LoginPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: AuthService()),
      child: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthenticatedError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message), 
            backgroundColor: Colors.red,
          ),
        );
      }

      if (state is Authenticated) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }, builder: (context, state) {
      if (state is AuthLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.secondary,
          ),
        );
      }

      return Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                CustomTextFormField(
                  hintText: 'Email',
                  controller: _emailController,
                  validator: validateEmail,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                CustomTextFormField(
                  obscureText: true,
                  hintText: 'Password',
                  controller: _passwordController,
                  validator: validatePassword,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                CustomElevatedButton(
                  text: 'Login',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      authBloc.add(LoaginEvent(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      ));
                    }
                  },
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width * 0.9,
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
                      Expanded(
                        child: Divider(
                          color: AppColors.secondary, 
                          thickness: 1.0, 
                        ),
                      ),
                      // "OR" Text
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold, 
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.secondary, 
                          thickness: 1.0, 
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                CustomElevatedButton(
                  icon: Image.asset(
                    'assets/images/google.png',
                    width: 25,
                    height: 25,
                  ),
                  text: 'Sign in with Google',
                  onPressed: () {
                    authBloc.add(GoogleSignInEvent());
                  },
                  color: AppColors.overlay,
                  width: screenWidth * 0.8,
                ),
                SizedBox(height: screenHeight * 0.05),
                const CustomAnimateWidget(
                    child: Text(
                  'By continuing, you agree to our',
                  style: TextStyle(color: AppColors.textPrimary),
                )),
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
        ),
      );
    });
  }
}
