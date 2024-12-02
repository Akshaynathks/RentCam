import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/models/user_model.dart';
import 'package:rent_cam/features/authentication/widget/clickable.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';

class SignupPageWrapper extends StatelessWidget {
  const SignupPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => AuthBloc(), child: const SignupPage());
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    TextEditingController _nameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _mobileController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    final authbloc = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is Authenticated) {
        WidgetsBinding.instance.addPersistentFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        });
      }

      return Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(screenHeight * 0.07),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: const Color.fromARGB(255, 210, 222, 222),
                elevation: 0,
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: screenHeight * 0.07,
                        child: const Image(
                            image: AssetImage('assets/images/croped.png')))
                  ],
                ),
              )),
          body: SingleChildScrollView(
            child: Column(children: [
              Container(
                  color: Colors.white,
                  height: screenHeight * 0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 40),
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'SignUp',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20),
                            )),
                      )
                    ],
                  )),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    CustomTextFormField(
                      hintText: 'Full Name',
                      controller: _nameController,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    CustomTextFormField(
                      hintText: 'Email',
                      controller: _emailController,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    CustomTextFormField(
                      hintText: 'Mobile',
                      controller: _mobileController,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    CustomTextFormField(
                      hintText: 'Password',
                      controller: _passwordController,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    CustomTextFormField(
                      hintText: 'Confirm Password',
                      controller: _confirmPasswordController,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Checkbox(value: true, onChanged: null),
                          Column(
                            children: [
                              const Text('By signing up you agree to our'),
                              Row(
                                children: [
                                  ClickableText(
                                      text: 'Terms of Services', onTap: () {}),
                                  const Text('and'),
                                  ClickableText(
                                      text: ' Privacy Policy', onTap: () {}),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    CustomElevatedButton(
                      text: 'Sign Up',
                      onPressed: () {
                        UserModel user = UserModel(
                          name: _nameController.text,
                          email: _emailController.text,
                          mobile: _mobileController.text,
                          password: _passwordController.text,
                        );
                        authbloc.add(SignupEvent(user: user));
                      },
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.07,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already a user?'),
                        ClickableText(
                          text: 'Login',
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ]),
          ));
    });
  }
}
