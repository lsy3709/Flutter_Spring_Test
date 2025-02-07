import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../ch6_spring_mini_test/screen/main_screen.dart';

class LoginController extends ChangeNotifier {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage(); // 보안 저장소
  final String serverIp = "http://192.168.219.103:8080"; // 서버 주소

  bool isLoading = false; // 로그인 로딩 상태
  bool isLoggedIn = false; // 로그인 여부

  LoginController() {
    _checkLoginStatus(); // 생성 시 로그인 상태 확인
  }

  // 로그인 요청 및 JWT 저장
  Future<void> login(BuildContext context) async {
    String inputId = idController.text.trim();
    String inputPw = passwordController.text.trim();

    if (inputId.isEmpty || inputPw.isEmpty) {
      _showDialog(context, "오류", "아이디와 비밀번호를 입력하세요.");
      return;
    }

    Map<String, String> loginData = {"mid": inputId, "mpw": inputPw};

    try {
      isLoading = true;
      notifyListeners(); // UI 업데이트

      final response = await http.post(
        Uri.parse("$serverIp/generateToken"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        String accessToken = responseData["accessToken"];
        String refreshToken = responseData["refreshToken"];

        // JWT 토큰 보안 저장소에 저장
        await secureStorage.write(key: "accessToken", value: accessToken);
        await secureStorage.write(key: "refreshToken", value: refreshToken);
        await secureStorage.write(key: "mid", value: inputId); // 로그인한 ID 저장

        // 입력란 초기화
        clearInputFields();

        // 로그인 상태 업데이트
        isLoggedIn = true;
        notifyListeners();

        _showDialog(context, "로그인 성공", "메인 화면으로 이동합니다.");

        // 로그인 성공 후 메인 화면으로 이동
        // ✅ 로그인 후 이전 화면 제거 후 메인 화면 이동
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
                (Route<dynamic> route) => false, // 🔥 이전 모든 화면 제거
          );
        });
      } else {
        _showDialog(context, "로그인 실패", "아이디 또는 비밀번호가 잘못되었습니다.");
      }
    } catch (e) {
      _showDialog(context, "네트워크 오류", "오류 발생: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
// 로그아웃 확인 다이얼로그
  Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("로그아웃 확인"),
          content: const Text("정말 로그아웃 하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // 취소 버튼
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                logout(context); // 로그아웃 실행
              },
              child: const Text("확인", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃 기능 (저장된 로그인 정보 삭제)
  Future<void> logout(BuildContext context) async {
    await secureStorage.delete(key: "accessToken");
    await secureStorage.delete(key: "refreshToken");
    await secureStorage.delete(key: "mid");

    // 로그인 상태 업데이트
    isLoggedIn = false;
    notifyListeners();

    _showDialog(context, "로그아웃","성공");

    // 메인 화면으로 이동

    // ✅ 로그아웃 후 이전 모든 화면 제거 후 메인 화면 이동
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false, // 🔥 이전 모든 화면 제거
    );

  }

  // 입력 필드 초기화
  void clearInputFields() {
    idController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // 로그인 상태 확인 (앱 실행 시 호출)
  Future<void> _checkLoginStatus() async {
    String? mid = await secureStorage.read(key: "mid");
    isLoggedIn = mid != null;
    notifyListeners();
  }

  // 보안 저장소에서 JWT 토큰 가져오기
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: "accessToken");
  }

  // 보안 저장소에서 로그인한 사용자 ID 가져오기
  Future<String?> getUserId() async {
    return await secureStorage.read(key: "mid"); // 저장된 ID 불러오기
  }

  // 다이얼로그 표시 함수
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }
}
