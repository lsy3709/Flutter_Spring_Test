import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controller/login_controller.dart';
import 'package:provider/provider.dart';

import '../controller/todo_controller.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // 보안 저장소에서 로그인한 유저 ID 불러오기
  Future<void> _loadUserId() async {
    String? mid = await secureStorage.read(key: "mid"); // 저장된 ID 가져오기
    setState(() {
      userId = mid;
    });
  }
  @override
  Widget build(BuildContext context) {
    final loginController = context.watch<LoginController>();
    final todoController = context.watch<TodoController>();

    return Scaffold(
      appBar: AppBar(title: const Text('메인 화면'),
        actions: [
          // 로그인 상태일 때만 로그아웃 버튼 표시
          if (loginController.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => loginController.showLogoutDialog(context),
            ),
        ],),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userId != null ? "환영합니다, $userId님!" : "로그인이 필요합니다.",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Center(child: FlutterLogo(size: 100)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('회원 가입'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('로그인'),
            ),
            // const SizedBox(height: 10),
            // OutlinedButton(
            //   onPressed: () => Navigator.pushNamed(context, '/details'),
            //   child: const Text('상세화면'),
            // ),
            const SizedBox(height: 10),

            if (loginController.isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  todoController.fetchTodos(); // Todos 데이터 요청
                  Navigator.pushNamed(context, "/todos"); // Todos 화면으로 이동
                },
                child: const Text("Todos 조회"),
              ),

            const SizedBox(height: 10),

            if (loginController.isLoggedIn)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/aiTest"); // Todos 화면으로 이동
                },
                child: const Text("Ai Test"),
              ),
          ],
        ),
      ),
    );
  }
}