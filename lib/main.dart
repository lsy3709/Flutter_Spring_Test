import 'package:dart_test/ch6_spring_mini_test/MyApp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ch6_spring_mini_test/controller/LoginController.dart';
import 'ch6_spring_mini_test/controller/SignupController.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignupController()), // 회원 가입 상태 관리
        // 필요한 경우 다른 Provider 추가 가능
        ChangeNotifierProvider(create: (context) => LoginController()), // 로그인 컨트롤러 제공
      ],
      child: const MyApp(),
    ),
  );
}
