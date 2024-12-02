import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/authentication/bloc/auth_bloc.dart';
import 'package:rent_cam/features/authentication/widget/text_field.dart';
import 'package:rent_cam/core/widget/button.dart';

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
        return Center(
          child: const CircularProgressIndicator(
            color: Color(0xFFFFC107),
          ),
        );
      }

      if (state is Authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
          child: Column(
            children: [
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
                              Navigator.pushNamed(context, '/signin');
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
                              'Sign Up',
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
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextFormField(
                      hintText: 'Email',
                      controller: _emailController,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextFormField(
                      obscureText: true,
                      hintText: 'Password',
                      controller: _passwordController,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    const Row(
                      children: [
                        // Left Line
                        Expanded(
                          child: Divider(
                            color: Colors.grey, // Line color
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
                            color: Colors.grey, // Line color
                            thickness: 1.0, // Line thickness
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    CustomElevatedButton(
                      icon: Image.asset('assets/images/google.png'),
                      text: 'Sign in with Google',
                      onPressed: () {},
                      color: Colors.white,
                      width: screenWidth * 0.8,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    CustomElevatedButton(
                      icon: Image.asset('assets/images/facebook.png'),
                      text: 'Sign in with Google',
                      onPressed: () {},
                      color: Colors.white,
                      width: screenWidth * 0.8,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text('By continuing, you agree to our'),
                    SizedBox(height: screenHeight * 0.01),
                    GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Terms of service & Privacy Policy',
                          style: TextStyle(color: Colors.blue),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
