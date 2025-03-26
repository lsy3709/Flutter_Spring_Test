import 'package:dart_test/ch6_spring_mini_test/screen/ai_image_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/ai_stock_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/ex_sample_design/cupertino_style_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/ex_sample_design/material_home_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/ex_sample_design/responsive_navbar_screen.dart';
// import 'package:dart_test/ch6_spring_mini_test/screen/details_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/login_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/main_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/public_data_screen/food_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/public_data_screen/walking_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/signup_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/splash_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/todo_create_screen.dart';
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
        "/todoCreate": (context) => const TodoCreateScreen(),
        "/aiTest": (context) => AiImageScreen(),
        "/aiTest2": (context) => AiStockScreen(),
        "/ex1_material": (context) => MaterialHomePage(),
        "/ex2_cupertino": (context) => CupertinoTabWrapper(),
        "/ex3_responsive_navbar": (context) => ResponsiveNavBarPage(),
        "/public_data_ex1_walking": (context) => WalkingScreen(),
        "/public_data_ex2_food": (context) => FoodScreen(),


  },

    );
  }
}