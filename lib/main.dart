import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/features/authentication/view/login.dart';
import 'package:rent_cam/features/authentication/view/signup.dart';
import 'package:rent_cam/features/home/view/home_page.dart';
import 'package:rent_cam/features/splash/view/splash_screen.dart';
import 'package:rent_cam/features/splash/view/welcome1.dart';
import 'package:rent_cam/features/splash/view/welcome2.dart';
import 'package:rent_cam/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 210, 222, 222),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => SplashPageWrappe(),
        '/home': (context) => HomePageWraper(),
        '/login': (context) => LoginPageWrapper(),
        '/signup':(context)=>SignupPageWrapper(),
        '/wel1':(context)=>WelcomePageOne(),
        '/wel2':(context)=>WelcomePageTwo(),
      },
      initialRoute: '/',
    );
  }
}
