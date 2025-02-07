import 'package:dart_test/ch6_mini_project/screen/details_screen.dart';
import 'package:dart_test/ch6_mini_project/screen/login_screen.dart';
import 'package:dart_test/ch6_mini_project/screen/main_screen.dart';
import 'package:dart_test/ch6_mini_project/screen/signup_screen.dart';
import 'package:dart_test/ch6_mini_project/screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/details': (context) => const DetailsScreen(),
      },
    );
  }
}