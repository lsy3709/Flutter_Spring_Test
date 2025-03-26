import 'package:dart_test/ch6_spring_mini_test/controller/ai_image_controller.dart';
import 'package:dart_test/ch6_spring_mini_test/my_app.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ch6_spring_mini_test/controller/login_controller.dart';
import 'ch6_spring_mini_test/controller/public_data_network/food_controller.dart';
import 'ch6_spring_mini_test/controller/public_data_network/walking_controller.dart';
import 'ch6_spring_mini_test/controller/signup_controller.dart';
import 'ch6_spring_mini_test/controller/todo_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignupController()), // 회원 가입 상태 관리
        // 필요한 경우 다른 Provider 추가 가능
        ChangeNotifierProvider(create: (context) => LoginController()), // 로그인 컨트롤러 제공
        ChangeNotifierProvider(create: (context) => TodoController()), // Todos 컨트롤러 추가
        ChangeNotifierProvider(create: (context) => AiImageController()), // Todos 컨트롤러 추가
        ChangeNotifierProvider(create: (_) => WalkingController()),// 공공데이터1, 도보
        ChangeNotifierProvider(create: (_) => FoodController()),// 공공데이터2, 부산맛집
      ],
      child: const MyApp(),
    ),
  );
}
