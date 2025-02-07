// 🟦 StatelessWidget 정의
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomStatelessWidget extends StatelessWidget {
  final String title;

  const CustomStatelessWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.blue,
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }
}

// 🟩 StatefulWidget 정의
class CustomStatefulWidget extends StatefulWidget {
  const CustomStatefulWidget({super.key});

  @override
  State<CustomStatefulWidget> createState() => _CustomStatefulWidgetState();
}

class _CustomStatefulWidgetState extends State<CustomStatefulWidget> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Counter: $counter',
          style: TextStyle(fontSize: 18.0),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: incrementCounter,
          child: Text('Increment Counter'),
        ),
      ],
    );
  }
}