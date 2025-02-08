import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../controller/todo_controller.dart';

class TodoCreateScreen extends StatefulWidget {
  const TodoCreateScreen({super.key});

  @override
  _TodoCreateScreenState createState() => _TodoCreateScreenState();
}

class _TodoCreateScreenState extends State<TodoCreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _dueDate;
  bool _complete = false;
  String? userId; // ✅ 로그인한 사용자 ID 저장

  @override
  void initState() {
    super.initState();

    // ✅ 로그인한 사용자 ID 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final todoController = context.read<TodoController>();
      String? mid = await todoController.getLoggedInUserId();
      setState(() {
        userId = mid;
      });
    });
  }

  Future<void> _submitTodo() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목을 입력하세요.")),
      );
      return;
    }

    final todoController = context.read<TodoController>();

    bool success = await todoController.createTodo(
      _titleController.text,
      _dueDate ?? DateTime.now(),
      _complete,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("할 일이 추가되었습니다.")),
      );
      Navigator.pop(context); // ✅ 작성 완료 후 리스트 화면으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("할 일 추가")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              userId != null ? "환영합니다, $userId님!" : "로그인이 필요합니다.",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: userId ?? ""),
              enabled: false, // ✅ 로그인한 사용자 자동 입력 (수정 불가능)
              decoration: const InputDecoration(labelText: "작성자"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("마감일: "),
                Text(_dueDate != null
                    ? "${_dueDate!.year}-${_dueDate!.month}-${_dueDate!.day}"
                    : "선택 안됨"),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _dueDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("완료"),
              value: _complete,
              onChanged: (value) {
                setState(() {
                  _complete = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTodo,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}