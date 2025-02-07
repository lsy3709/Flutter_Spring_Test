import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/LoginController.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();

    return Scaffold(
      appBar: AppBar(title: const Text('로그인 화면')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Center(child: FlutterLogo(size: 100)),
              const SizedBox(height: 16),
              TextField(
                controller: loginController.idController,
                decoration: const InputDecoration(labelText: '아이디'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: loginController.passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '패스워드'),
              ),
              const SizedBox(height: 20),
              loginController.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () => loginController.login(context),
                child: const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
