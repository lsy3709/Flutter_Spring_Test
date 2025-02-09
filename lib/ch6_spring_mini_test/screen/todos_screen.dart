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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final todoController = context.read<TodoController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      todoController.fetchTodos();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !todoController.isFetchingMore) {
        todoController.fetchMoreTodos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoController = context.watch<TodoController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Todos 리스트")),
      body: Column(
        children: [
          // ✅ 검색 입력창 추가
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child:  TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "검색어 입력",
                border: OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    todoController.updateSearchParams("TWC", ""); // ✅ 검색어 초기화
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                todoController.updateSearchParams("TWC", value); // ✅ 검색어 변경 시 즉시 서버 호출
              },
            ),
          ),

          // ✅ 검색 결과 및 출력 개수 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                todoController.todos.isEmpty
                    ? "🔍 검색 결과가 없습니다."
                    : "🔍 검색어: \"${todoController.keyword}\" / 총 ${todoController.remainingCount}개 중 ${todoController.todos.length}개 출력",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ),

          // ✅ 리스트 출력
          Expanded(
            child: todoController.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todoController.todos.isEmpty
                ? const Center(child: Text("할 일이 없습니다."))
                : ListView.builder(
              controller: _scrollController,
              itemCount: todoController.todos.length + (todoController.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (!todoController.hasMore && index == todoController.todos.length) {
                  return const SizedBox(); // ✅ 로딩 UI 제거
                }

                if (index == todoController.todos.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final todo = todoController.todos[index];
                return ListTile(
                  title: Text(
                    "${index + 1}. ${todo.title}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("ID: ${todo.tno}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
                          Text(", 작성자: ${todo.writer}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
                        ],
                      ),
                      Text("작성일: ${todo.dueDate}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}