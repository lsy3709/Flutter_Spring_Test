import 'package:dart_test/ch6_spring_mini_test/details_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/login_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/main_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/signup_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/splash_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/todo_detail_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/todos_screen.dart';
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
        // '/details': (context) => const DetailsScreen(),
        '/todos': (context) => const TodosScreen(), // ✅ Todos 화면 추가
    '/todoDetail': (context) => TodoDetailScreen(tno: ModalRoute.of(context)!.settings.arguments as int),
  },

    );
  }
}