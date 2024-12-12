import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/animate.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/models/user_model.dart';
import 'package:rent_cam/features/authentication/services/auth_services.dart';
import 'package:rent_cam/features/authentication/widget/clickable.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';

class SignupPageWrapper extends StatelessWidget {
  const SignupPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AuthBloc(authService: AuthService()), child: const SignupPage());
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    TextEditingController _nameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _mobileController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        if (state is Authenticated) {
    Future.microtask(() {
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    });
  } else if (state is AuthenticatedError) {
    Future.microtask(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    });
  }

      return Scaffold(
          body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              CustomTextFormField(
                  hintText: 'Full Name',
                  controller: _nameController,
                  validator: validateFullName),
              SizedBox(height: screenHeight * 0.01),
              CustomTextFormField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomTextFormField(
                  hintText: 'Mobile',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  validator: validateMobile),
              SizedBox(height: screenHeight * 0.01),
              CustomTextFormField(
                hintText: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: validatePassword,
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomTextFormField(
                hintText: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) =>
                    validateConfirmPassword(value, _passwordController.text),
              ),
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomAnimateWidget(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Checkbox(
                        value: true,
                        onChanged: null,
                        fillColor:
                            WidgetStatePropertyAll(AppColors.buttonPrimary),
                      ),
                      Column(
                        children: [
                          const Text(
                            'By signing up you agree to our',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          Row(
                            children: [
                              ClickableText(
                                  text: 'Terms of Services', onTap: () {}),
                              const Text(' and ',
                                  style:
                                      TextStyle(color: AppColors.textPrimary)),
                              ClickableText(
                                  text: ' Privacy Policy', onTap: () {}),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomElevatedButton(
                text: 'Sign Up',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Validation successful
                    final authBloc = BlocProvider.of<AuthBloc>(context);
                    UserModel user = UserModel(
                      name: _nameController.text,
                      email: _emailController.text,
                      mobile: _mobileController.text,
                      password: _passwordController.text,
                    );
                    authBloc.add(SignupEvent(user: user));
                  }
                },
                width: screenWidth * 0.8,
                height: screenHeight * 0.07,
              ),
              SizedBox(height: screenHeight * 0.04),
              CustomAnimateWidget(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already a user?',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    ClickableText(
                      text: 'Login',
                      onTap: () {
                        Navigator.pushNamed(context, '/auth');
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ));
    });
  }
}
