import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignupController extends ChangeNotifier {
  // 입력 필드 컨트롤러
  final TextEditingController idController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  bool isPasswordMatch = true; // 패스워드 일치 여부

  // final String serverIp = "http://192.168.219.103:8080"; // 서버 주소 변경 필요
  final String serverIp = "http://192.168.123.135:8080"; // 서버 주소 변경 필요

  // 패스워드 일치 여부 검사
  void validatePassword() {
    isPasswordMatch = passwordController.text == passwordConfirmController.text;
    notifyListeners();
  }

  // 다이얼로그 표시
  void showDialogMessage(BuildContext context, String title, String message) {
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

  // 토스트 메시지 표시
  void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // 아이디 중복 체크 기능
  Future<void> checkDuplicateId(BuildContext context) async {
    String inputId = idController.text.trim();
    if (inputId.isEmpty) {
      showDialogMessage(context, "오류", "아이디를 입력하세요.");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$serverIp/member/check-mid?mid=$inputId"),
      );

      if (response.statusCode == 200) {
        showDialogMessage(context, "사용 가능", "이 아이디는 사용할 수 있습니다.");
      } else if (response.statusCode == 409) {
        showDialogMessage(context, "중복된 아이디", "이미 사용 중인 아이디입니다.");
      } else {
        showDialogMessage(context, "오류", "서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      showDialogMessage(context, "오류", "네트워크 오류 발생: $e");
    }
  }

  // 회원 가입 요청
  Future<void> signup(BuildContext context) async {
    if (!isPasswordMatch) {
      showDialogMessage(context, "오류", "패스워드가 일치해야 합니다.");
      return;
    }

    String inputId = idController.text.trim();
    String inputPw = passwordController.text.trim();

    if (inputId.isEmpty || inputPw.isEmpty) {
      showToast(context, "아이디와 비밀번호를 입력하세요.");
      return;
    }

    Map<String, String> userData = {"mid": inputId, "mpw": inputPw};

    try {
      final response = await http.post(
        Uri.parse("$serverIp/member/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        showToast(context, "회원 가입 성공!");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, "/main");
        });
      } else {
        showToast(context, "회원 가입 실패: ${response.body}");
      }
    } catch (e) {
      showToast(context, "오류 발생: $e");
    }
  }
}
