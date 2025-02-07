import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/todo_controller.dart';


class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoController = context.watch<TodoController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Todos 리스트")),
      body: todoController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todoController.todos.isEmpty
          ? const Center(child: Text("할 일이 없습니다."))
          : ListView.builder(
        itemCount: todoController.todos.length,
        itemBuilder: (context, index) {
          final todo = todoController.todos[index];
          return ListTile(
            title: Text(todo.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text(todo.description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ 수정 아이콘 버튼 추가
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/todoDetail",
                      arguments: todo.id, // ✅ tno 전달
                    );
                  },
                ),
                // ✅ 완료 여부 아이콘
                Icon(
                  todo.completed ? Icons.check_circle : Icons.cancel,
                  color: todo.completed ? Colors.green : Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

