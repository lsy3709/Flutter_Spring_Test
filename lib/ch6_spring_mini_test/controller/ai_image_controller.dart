import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class AiImageController extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  File? selectedImage; // 선택한 이미지 파일
  bool isLoading = false; // 로딩 상태
  Map<String, dynamic>? predictionResult; // 예측 결과 저장
  int selectedModel = 1; // ✅ 기본 모델 (동물상 테스트)
  IO.Socket? socket; // ✅ Flask-SocketIO 연결

  AiImageController() {
    _connectToSocket(); // ✅ 소켓 연결
  }

  // ✅ Flask 소켓 연결
  void _connectToSocket() {
    if ((selectedModel == 4 || selectedModel == 5) && socket == null) {
      socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });

      socket!.onConnect((_) => print("✅ 소켓 연결됨"));
      socket!.onDisconnect((_) => print("❌ 소켓 연결 종료"));

      // ✅ Flask에서 YOLO 분석 결과 수신
      socket!.on('file_processed', (data) {
        print("✅ Flask에서 받은 데이터: $data");

        predictionResult = data;
        notifyListeners(); // ✅ UI 업데이트
      });
    }
  }
    // ✅ 앱 종료 시 소켓 해제
    void disconnectSocket() {
      socket?.disconnect();
      socket = null; // ✅ 소켓 완전히 해제
    }

    // ✅ 저장된 `accessToken` 가져오기
    Future<String?> getAccessToken() async {
      return await secureStorage.read(key: "accessToken");
    }

    // ✅ 모델 선택 변경
    void setModel(int model) {
      selectedModel = model;

      // ✅ YOLOv8 이미지 테스트일 경우에만 소켓 재연결
      if (selectedModel == 4 || selectedModel == 5) {
        _connectToSocket();
      } else {
        disconnectSocket(); // ✅ 다른 모델에서는 소켓 해제
      }

      notifyListeners();
    }

    // ✅ 이미지 선택 (갤러리 / 카메라)
    Future<void> pickImage(ImageSource source) async {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return;

      selectedImage = File(pickedFile.path);

      // ✅ 현재 모델이 YOLOv8(4,5)일 경우 소켓 재연결 확인
      if (selectedModel == 4 || selectedModel == 5) {
        _connectToSocket(); // ✅ 기존 소켓 유지 또는 재연결
      }

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
        // ✅ 선택한 모델에 따라 서버 API 주소 변경
        String apiUrl = "http://192.168.219.103:8080/api/ai/predict/$selectedModel";

        var request = http.MultipartRequest(
          "POST",
          Uri.parse(apiUrl),
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

          // ✅ YOLOv8 이미지 테스트일 경우에만 소켓으로 Flask에 데이터 전송
          if (selectedModel == 4 || selectedModel == 5) {
            socket?.emit(
                'process_image', {"image_url": jsonResponse['file_url']});
          }
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

