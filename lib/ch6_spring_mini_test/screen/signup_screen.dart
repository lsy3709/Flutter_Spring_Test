import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/signup_controller.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final signupController = Provider.of<SignupController>(context);
    final signupController = context.watch<SignupController>(); // 상태 변경 감지
    return Scaffold(
      appBar: AppBar(title: const Text('회원 가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // 아이디 입력 필드 + 중복 체크 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: signupController.idController,
                      decoration: const InputDecoration(labelText: '아이디'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => signupController.checkDuplicateId(context),
                    child: const Text('중복 체크'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 이메일 입력 필드
              TextField(
                controller: signupController.emailController,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              const SizedBox(height: 16),

              // 패스워드 입력 필드
      TextField(
        controller: signupController.passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: '패스워드',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: signupController.passwordController.text.isNotEmpty
                  ? (signupController.isPasswordMatch ? Colors.green : Colors.red)
                  : Colors.grey, // ✅ 입력이 없을 때 기본 색상 유지
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: signupController.passwordController.text.isNotEmpty
                  ? (signupController.isPasswordMatch ? Colors.green : Colors.red)
                  : Colors.grey, // ✅ 입력이 없을 때 기본 색상 유지
              width: 2.0,
            ),
          ),
        ),
        onChanged: (value) => signupController.validatePassword(),
      ),
      const SizedBox(height: 16),

// ✅ 패스워드 확인 입력 필드
      TextField(
        controller: signupController.passwordConfirmController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: '패스워드 확인',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: signupController.passwordConfirmController.text.isNotEmpty
                  ? (signupController.isPasswordMatch ? Colors.green : Colors.red)
                  : Colors.grey, // ✅ 입력이 없을 때 기본 색상 유지
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: signupController.passwordConfirmController.text.isNotEmpty
                  ? (signupController.isPasswordMatch ? Colors.green : Colors.red)
                  : Colors.grey, // ✅ 입력이 없을 때 기본 색상 유지
              width: 2.0,
            ),
          ),
        ),
        onChanged: (value) => signupController.validatePassword(),
      ),

              const SizedBox(height: 16),

              // 회원 가입 버튼
              ElevatedButton(
                onPressed: () => signupController.signup(context),
                child: const Text('회원 가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
