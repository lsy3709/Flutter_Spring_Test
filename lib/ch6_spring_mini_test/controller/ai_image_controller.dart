import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiImageController extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  File? selectedImage; // 선택한 이미지 파일
  bool isLoading = false; // 로딩 상태
  Map<String, dynamic>? predictionResult; // 예측 결과 저장

  // ✅ 저장된 `accessToken` 가져오기
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: "accessToken");
  }

  // ✅ 이미지 선택 (갤러리 / 카메라)
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    selectedImage = File(pickedFile.path);
    notifyListeners(); // UI 업데이트
  }

  // ✅ 서버로 이미지 업로드 및 예측 요청
  Future<void> uploadImage(BuildContext context) async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이미지를 선택해주세요!")),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    String? accessToken = await getAccessToken(); // 🔹 토큰 가져오기
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인이 필요합니다.")),
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://192.168.219.103:8080/api/ai/predict"),
      );
      request.headers["Authorization"] = "Bearer $accessToken"; // ✅ 토큰 추가
      request.files.add(
        await http.MultipartFile.fromPath("image", selectedImage!.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        predictionResult = jsonResponse;
      } else {
        throw Exception("서버 오류: ${jsonResponse['error']}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("예측 실패: $e")),
      );
    }

    isLoading = false;
    notifyListeners();
  }
}
