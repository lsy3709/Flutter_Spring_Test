import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dto/page_response_dto.dart';
import '../dto/todo_dto.dart';


class TodoController extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String serverIp = "http://192.168.219.103:8080/api/todo"; // 서버 주소

  List<TodoDTO> todos = [];
  bool isLoading = false;

  // ✅ 로그인한 사용자 ID 가져오기
  Future<String?> getLoggedInUserId() async {
    return await secureStorage.read(key: "mid"); // 보안 저장소에서 유저 ID 가져오기
  }

  // Todos 리스트 조회 요청
  Future<void> fetchTodos() async {
    isLoading = true;
    notifyListeners();

    String? accessToken = await secureStorage.read(key: "accessToken");

    if (accessToken == null) {
      print("토큰이 없습니다.");
      isLoading = false;
      notifyListeners();
      return;
    }

    // ✅ PageRequestDTO 데이터를 쿼리 파라미터로 변환
    final Uri requestUrl = Uri.parse(
      "$serverIp/list?page=1&size=10&type=&keyword=&from=&to=&completed=",
    );


    try {
      final response = await http.get(
        requestUrl,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $accessToken",
        },

      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        PageResponseDTO<TodoDTO> pageResponse = PageResponseDTO.fromJson(
          responseData,
          (json) => TodoDTO.fromJson(json),
        );

        todos = pageResponse.dtoList;
      } else {
        print("에러 발생: ${response.body}");
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }

    isLoading = false;
    notifyListeners();
  }


  // ✅ Todo 상세 조회 요청 (`GET /api/todo/{tno}`)
  Future<TodoDTO?> fetchTodoDetails(int tno) async {
    String? accessToken = await secureStorage.read(key: "accessToken");
    if (accessToken == null) return null;

    final Uri requestUrl = Uri.parse("$serverIp/$tno");

    try {
      final response = await http.get(
        requestUrl,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        return TodoDTO.fromJson(responseData);
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }
    return null;
  }

  // ✅ Todo 수정 요청 (`PUT /api/todo/{tno}`)
  Future<bool> updateTodo(int tno, String title, String writer, DateTime dueDate, bool complete) async {
    String? accessToken = await secureStorage.read(key: "accessToken");
    if (accessToken == null) return false;

    final Uri requestUrl = Uri.parse("$serverIp/$tno");

    final Map<String, dynamic> updateData = {
      "tno": tno,
      "title": title,
      "writer": writer,
      "dueDate": "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}", // ✅ 날짜 포맷 수정
      "complete": complete,
      "complete": complete,
    };

    try {
      final response = await http.put(
        requestUrl,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(updateData),
      );
      print("📢 [Flutter] 응답 코드: ${response.statusCode}");
      print("📢 [Flutter] 응답 바디: ${response.body}");


      if (response.statusCode == 200) {
        print("✅ [Flutter] Todo 수정 성공!");

        // ✅ 리스트 새로고침
        await fetchTodos(); // ✅ Todo 리스트 다시 불러오기
        notifyListeners(); // ✅ UI 업데이트
        return true;
      } else {
        print("⚠️ [Flutter] 서버 응답 오류: ${response.body}");
      }
    } catch (e) {
      print("❌ [Flutter] 네트워크 오류: $e");
    }
    return false;
  }

  Future<bool> deleteTodo(int tno) async {
    String? accessToken = await secureStorage.read(key: "accessToken");
    if (accessToken == null) {
      print("⚠️ [Flutter] accessToken 없음!");
      return false;
    }

    final Uri requestUrl = Uri.parse("$serverIp/$tno");
    print("📢 [Flutter] DELETE 요청 URL: $requestUrl");

    try {
      final response = await http.delete(
        requestUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );

      if (response.statusCode == 200) {
        print("✅ [Flutter] Todo 삭제 성공!");

        // ✅ 리스트 새로고침
        await fetchTodos(); // ✅ UI 업데이트
        notifyListeners();

        return true;
      } else {
        print("⚠️ [Flutter] 삭제 실패: ${response.body}");
      }
    } catch (e) {
      print("❌ [Flutter] 네트워크 오류: $e");
    }
    return false;
  }
  // ✅ 삭제 확인 다이얼로그 (UI에서 호출)
  void confirmDelete(BuildContext context, int tno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("삭제 확인"),
          content: const Text("정말 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // ✅ 다이얼로그 닫기
                bool success = await deleteTodo(tno);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("삭제되었습니다.")),
                  );
                }
              },
              child: const Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// ✅ Todo 작성 요청 (`POST /api/todo`)
  Future<bool> createTodo(String title, DateTime dueDate, bool complete) async {
    String? accessToken = await secureStorage.read(key: "accessToken");
    String? mid = await getLoggedInUserId(); // 로그인한 사용자 ID 가져오기

    if (accessToken == null || mid == null) {
      print("⚠️ [Flutter] 액세스 토큰 또는 사용자 ID 없음");
      return false;
    }

    final Uri requestUrl = Uri.parse("$serverIp/");

    final Map<String, dynamic> postData = {
      "title": title,
      "writer": mid, // ✅ 로그인한 사용자 ID 자동 입력
      "dueDate": "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}",
      "complete": complete,
    };

    try {
      final response = await http.post(
        requestUrl,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(postData),
      );

      print("📢 [Flutter] 응답 코드: ${response.statusCode}");
      print("📢 [Flutter] 응답 바디: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ [Flutter] Todo 작성 성공!");

        // ✅ 리스트 새로고침
        await fetchTodos();
        notifyListeners();
        return true;
      } else {
        print("⚠️ [Flutter] 서버 응답 오류: ${response.body}");
      }
    } catch (e) {
      print("❌ [Flutter] 네트워크 오류: $e");
    }
    return false;
  }

}


