import 'package:dart_test/ch6_spring_mini_test/DetailsScreen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/LoginScreen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/MainScreen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/SignupScreen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/SplashScreen.dart';
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