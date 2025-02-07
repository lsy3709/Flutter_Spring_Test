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


