import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../controller/todo_controller.dart';
import '../dto/todo_dto.dart';


class TodoDetailScreen extends StatefulWidget {
  final int tno;

  const TodoDetailScreen({super.key, required this.tno});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _writerController = TextEditingController();
  DateTime? _dueDate;
  bool _completed = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodoDetails();
  }

  // ✅ `GET /api/todo/{tno}` 요청 (Todo 상세 조회)
  Future<void> _fetchTodoDetails() async {
    final todoController = Provider.of<TodoController>(context, listen: false);
    TodoDTO? todo = await todoController.fetchTodoDetails(widget.tno);

    if (todo != null) {
      setState(() {
        _titleController.text = todo.title;
        _writerController.text = todo.writer;
        _dueDate = todo.dueDate;
        _completed = todo.completed;
        isLoading = false;
      });
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("할 일 정보를 불러오지 못했습니다.")),
      );
      Navigator.pop(context);
    }
  }

  // ✅ `PUT /api/todo/{tno}` 요청 (Todo 수정)
  Future<void> _updateTodo() async {
    final todoController = Provider.of<TodoController>(context, listen: false);
    bool success = await todoController.updateTodo(
      widget.tno,
      _titleController.text,
      _writerController.text,
      _dueDate!,
      _completed,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("할 일이 수정되었습니다.")),
      );
      Navigator.pop(context, true); // 수정 완료 후 이전 화면으로 돌아감
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("할 일 수정")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _writerController,
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
              value: _completed,
              onChanged: (value) {
                setState(() {
                  _completed = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTodo,
              child: const Text("수정 완료"),
            ),
          ],
        ),
      ),
    );
  }
}
