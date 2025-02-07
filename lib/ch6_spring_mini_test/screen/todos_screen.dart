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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ID: ${todo.tno}", // ✅ ID 개별 표시
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
                Icon(
                  todo.complete ? Icons.check_circle : Icons.circle_outlined,
                  color: todo.complete ? Colors.green : Colors.grey,
                  size: 24,
                ),
                Text(
                  todo.complete ? '완료' : '미완료',
                  style: TextStyle(
                    fontSize: 14,
                    color: todo.complete ? Colors.black : Colors.grey,
                    decoration: todo.complete ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ],
            ),
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
                      arguments: todo.tno, // ✅ tno 전달
                    );
                  },
                ),
                // ✅ 삭제 버튼 (삭제 확인 다이얼로그 호출)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => todoController.confirmDelete(context, todo.tno),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

