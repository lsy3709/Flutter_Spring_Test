import 'package:dart_test/ch6_spring_mini_test/screen/todo_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/todo_controller.dart';


class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  _TodosScreenState createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final todoController = context.read<TodoController>();

    // 빌드 이후에 실행되도록 조정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoController>().fetchTodos();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !todoController.isFetchingMore) {
        // ✅ 스크롤이 맨 아래에 도달하면 추가 데이터 요청
        todoController.fetchMoreTodos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        controller: _scrollController,
        itemCount: todoController.todos.length + (todoController.hasMore ? 1 : 0), // ✅ 로딩 아이템 추가,
        itemBuilder: (context, index) {

          if (index == todoController.todos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(), // ✅ 로딩 UI 추가
              ),
            );
          }

          final todo = todoController.todos[index];
          return ListTile(
            title: Text(todo.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "ID: ${todo.tno}", // ✅ ID 개별 표시
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                    Text(
                      ", 작성자: ${todo.writer}", // ✅ ID 개별 표시
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                    ),
                  ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodoCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

