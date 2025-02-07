import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('상세 화면')),
      body: SafeArea(
        child: ListView(
          children: List.generate(
            20,
                (index) => ListTile(
              leading: const FlutterLogo(),
              title: Text('항목 $index'),
              subtitle: const Text('상세 설명'),
            ),
          ),
        ),
      ),
    );
  }
}