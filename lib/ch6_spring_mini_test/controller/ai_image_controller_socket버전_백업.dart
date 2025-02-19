// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class AiImageController extends ChangeNotifier {
//   final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//   File? selectedImage; // 선택한 이미지 파일
//   bool isLoading = false; // 로딩 상태
//   Map<String, dynamic>? predictionResult; // 예측 결과 저장
//   int selectedModel = 1; // ✅ 기본 모델 (동물상 테스트)
//   IO.Socket? socket; // ✅ Flask-SocketIO 연결
//   File? selectedMedia; // ✅ 선택한 이미지 또는 동영상 파일
//
//   AiImageController() {
//     _connectToSocket(); // ✅ 소켓 연결
//   }
//
//   // ✅ WebSocket 연결
//   void _connectToSocket() {
//     if (socket != null && socket!.connected) {
//       print("✅ WebSocket 이미 연결됨");
//       return;
//     }
//
//     socket = IO.io('http://43.200.40.31:5000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });
//
//     socket!.onConnect((_) {
//       print("✅ WebSocket 연결 성공");
//     });
//
//     socket!.onDisconnect((_) {
//       print("❌ WebSocket 연결 종료");
//     });
//
//     socket!.on('file_processed', (data) {
//       print("📩 WebSocket 응답 수신! YOLO 결과: $data");
//       predictionResult = data;
//       notifyListeners();
//     });
//
//     socket?.connect();
//   }
//
//   // ✅ WebSocket 연결 보장
//   Future<void> _ensureSocketConnected(Function callback) async {
//     if (socket?.connected == true) {
//       callback();
//     } else {
//       print("⏳ WebSocket 연결 대기 중...");
//       await Future.delayed(Duration(milliseconds: 500));
//       _ensureSocketConnected(callback);
//     }
//   }
//
//   // ✅ WebSocket 해제
//   void disconnectSocket() {
//     socket?.disconnect();
//     socket = null;
//     print("🔌 WebSocket 연결 해제됨");
//   }
//
//     // ✅ 저장된 `accessToken` 가져오기
//     Future<String?> getAccessToken() async {
//       return await secureStorage.read(key: "accessToken");
//     }
//
//     // ✅ 모델 선택 변경
//     void setModel(int model) {
//       selectedModel = model;
//
//       // ✅ YOLOv8 이미지 테스트일 경우에만 소켓 재연결
//       if (selectedModel == 4 || selectedModel == 5) {
//         _connectToSocket();
//       } else {
//         disconnectSocket(); // ✅ 다른 모델에서는 소켓 해제
//       }
//
//       notifyListeners();
//     }
//
//   /// ✅ 갤러리 또는 카메라에서 이미지 또는 동영상 선택
//   Future<void> pickMedia(ImageSource source, {bool isVideo = false}) async {
//
//     final pickedFile = isVideo
//         ? await ImagePicker().pickVideo(source: source)
//         : await ImagePicker().pickImage(source: source);
//
//     if (pickedFile == null) return;
//
//     if (isVideo) {
//       selectedMedia = File(pickedFile.path);
//       // selectedImage = null; // ✅ 동영상 선택 시 이미지 초기화
//     } else {
//       selectedImage = File(pickedFile.path);
//       selectedMedia = File(pickedFile.path);
//       // selectedMedia = null; // ✅ 이미지 선택 시 동영상 초기화
//     }
//
//     notifyListeners();
//   }
//
//   // ✅ 서버로 이미지 또는 동영상 업로드 및 예측 요청
//   Future<void> uploadMedia(BuildContext context) async {
//     // _connectToSocket();
//     if (selectedMedia == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("파일을 선택해주세요!")),
//       );
//       return;
//     }
//
//     isLoading = true;
//     notifyListeners();
//
//     String? accessToken = await getAccessToken(); // 🔹 토큰 가져오기
//     if (accessToken == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("로그인이 필요합니다.")),
//       );
//       isLoading = false;
//       notifyListeners();
//       return;
//     }
//
//     try {
//       int apiModel = (selectedModel == 5) ? 4 :selectedModel;
//       // ✅ 선택한 모델에 따라 서버 API 주소 변경
//       // String apiUrl = "http://192.168.219.103:8080/api/ai/predict/$apiModel";
//       String apiUrl = "http://192.168.219.103:8080/api/ai/predict/$apiModel";
//
//       var request = http.MultipartRequest(
//         "POST",
//         Uri.parse(apiUrl),
//       );
//       request.headers["Authorization"] = "Bearer $accessToken"; // ✅ 토큰 추가
//
//        request.files.add(
//         // await http.MultipartFile.fromPath(isVideo ? "video" : "image", selectedMedia!.path),
//         await http.MultipartFile.fromPath("image", selectedMedia!.path),
//       );
//
//       var response = await request.send();
//       var responseBody = await response.stream.bytesToString();
//
//       print("📩 서버 응답 코드: ${response.statusCode}");
//       print("📩 서버 응답 본문: $responseBody");
//
//       try {
//         var jsonResponse = json.decode(responseBody);
//
//         if (response.statusCode == 200) {
//           print("✅ 서버 응답 정상 수신!");
//           predictionResult = jsonResponse;
//
//           if (selectedModel == 4 || selectedModel == 5) {
//             _ensureSocketConnected(() {
//               socket?.emit('process_image', {"file_url": jsonResponse['file_url']});
//               print("📡 YOLO 처리 대기 중... WebSocket 응답을 기다립니다.");
//             });
//           }
//         } else {
//           print("❌ 서버 오류: ${jsonResponse['error']}");
//           throw Exception("서버 오류: ${jsonResponse['error']}");
//         }
//       } catch (e) {
//         print("❌ JSON 파싱 오류: $e");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("예측 실패: 응답 데이터를 처리하는 중 오류 발생! $e")),
//         );
//       }
//     } catch (e) {
//       String errorMessage = e.toString().contains("server")
//           ? "서버 오류 발생! 관리자에게 문의하세요."
//           : "예측 실패: $e";
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//
//       print("❌ 오류 발생: $errorMessage");
//     }
//
//     isLoading = false;
//     notifyListeners();
//   }
//
//   }
//
