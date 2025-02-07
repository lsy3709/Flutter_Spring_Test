import 'package:dart_test/ch6_mini_project/screen/DetailsScreen.dart';
import 'package:dart_test/ch6_mini_project/screen/LoginScreen.dart';
import 'package:dart_test/ch6_mini_project/screen/MainScreen.dart';
import 'package:dart_test/ch6_mini_project/screen/SignupScreen.dart';
import 'package:dart_test/ch6_mini_project/screen/SplashScreen.dart';
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