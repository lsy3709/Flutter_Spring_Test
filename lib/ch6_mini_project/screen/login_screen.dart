import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인 화면')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(child: FlutterLogo(size: 100)),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '이메일')),
              const SizedBox(height: 16),
              const TextField(decoration: InputDecoration(labelText: '패스워드')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/details'),
                child: const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}