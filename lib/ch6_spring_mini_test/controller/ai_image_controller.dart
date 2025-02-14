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
  File? selectedMedia; // ✅ 선택한 이미지 또는 동영상 파일

  AiImageController() {
    _connectToSocket(); // ✅ 소켓 연결
  }

  // ✅ Flask 소켓 연결
  void _connectToSocket() {
    if ((selectedModel == 4 || selectedModel == 5) && socket == null) {
      socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      // socket = IO.io('http://192.168.219.103:5000', <String, dynamic>{
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

  /// ✅ 갤러리 또는 카메라에서 이미지 또는 동영상 선택
  Future<void> pickMedia(ImageSource source, {bool isVideo = false}) async {
    final pickedFile = isVideo
        ? await ImagePicker().pickVideo(source: source)
        : await ImagePicker().pickImage(source: source);

    if (pickedFile == null) return;

    if (isVideo) {
      selectedMedia = File(pickedFile.path);
      // selectedImage = null; // ✅ 동영상 선택 시 이미지 초기화
    } else {
      selectedImage = File(pickedFile.path);
      selectedMedia = File(pickedFile.path);
      // selectedMedia = null; // ✅ 이미지 선택 시 동영상 초기화
    }

    notifyListeners();
  }

  // ✅ 서버로 이미지 또는 동영상 업로드 및 예측 요청
  Future<void> uploadMedia(BuildContext context) async {
    if (selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("파일을 선택해주세요!")),
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
      int apiModel = (selectedModel == 5) ? 4 :selectedModel;
      // ✅ 선택한 모델에 따라 서버 API 주소 변경
      String apiUrl = "http://192.168.219.103:8080/api/ai/predict/$apiModel";

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(apiUrl),
      );
      request.headers["Authorization"] = "Bearer $accessToken"; // ✅ 토큰 추가

      // ✅ 선택된 파일이 동영상인지 확인
      bool isVideo = selectedMedia!.path.endsWith(".mp4") ||
          selectedMedia!.path.endsWith(".avi") ||
          selectedMedia!.path.endsWith(".mov");

      request.files.add(
        // await http.MultipartFile.fromPath(isVideo ? "video" : "image", selectedMedia!.path),
        await http.MultipartFile.fromPath("image", selectedMedia!.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📩 서버 응답 코드: ${response.statusCode}");
      print("📩 서버 응답 본문: $responseBody");

      try {
        var jsonResponse = json.decode(responseBody);

        if (response.statusCode == 200) {
          print("✅ 서버 응답 정상 수신!");
          predictionResult = jsonResponse;

          if (selectedModel == 4 || selectedModel == 5) {

            // socket?.on('file_processed', (data) {
            //   print("📩 WebSocket 응답 수신! YOLO 결과:");
            //   print("   🔗 file_url: ${data['file_url']}");
            //   print("   🔗 download_url: ${data['download_url']}");
            //   print(data);
            //
            //   // 상태 업데이트
            //   predictionResult = data;
            //   notifyListeners();
            // });
            print("📡 YOLO 처리 대기 중... WebSocket 응답을 기다립니다.");
          }
        } else {
          print("❌ 서버 오류: ${jsonResponse['error']}");
          throw Exception("서버 오류: ${jsonResponse['error']}");
        }
      } catch (e) {
        print("❌ JSON 파싱 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("예측 실패: 응답 데이터를 처리하는 중 오류 발생! $e")),
        );
      }
    } catch (e) {
      String errorMessage = e.toString().contains("server")
          ? "서버 오류 발생! 관리자에게 문의하세요."
          : "예측 실패: $e";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      print("❌ 오류 발생: $errorMessage");
    }

    isLoading = false;
    notifyListeners();
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
                'process_image', {"file_url": jsonResponse['file_url']});
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

