import 'package:dart_test/ch6_spring_mini_test/screen/download_play_video_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/image_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/ai_image_controller.dart';
import 'dart:io'; // 파일 시스템 접근
import 'package:dio/dio.dart'; // HTTP 요청 및 다운로드
import 'package:path_provider/path_provider.dart'; // 앱별 저장소 경로

class AiImageScreen extends StatefulWidget {
  @override
  _AiImageScreenState createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  bool isDownloading = false;
  bool isDownloadComplete = false;

  // 서버의 기본 주소
  final String serverBaseUrl = "http://10.0.2.2:5000";

  /// 파일을 앱별 저장소에 다운로드하는 함수 (권한 불필요)
  Future<void> _downloadFile(String fileUrl) async {
    setState(() { 
      isDownloading = true;
      isDownloadComplete = false;
    });

    try {
      // 1. 앱별 저장소 경로 가져오기 (권한 불필요)
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. 파일명 추출 (타임스탬프 추가로 중복 방지)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalFileName = fileUrl.split('/').last;
      final fileName = '${timestamp}_$originalFileName';
      final filePath = '${directory.path}/$fileName';

      // 3. Dio 설정 개선 (타임아웃 증가, Keep-Alive 헤더)
      final dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30), // 연결 타임아웃: 30초
          receiveTimeout: Duration(minutes: 5),   // 수신 타임아웃: 5분
          sendTimeout: Duration(seconds: 30),     // 송신 타임아웃: 30초
          headers: {
            'Connection': 'keep-alive',           // Keep-Alive 유지
            'Accept': '*/*',                      // 모든 타입 허용
          },
        ),
      );

      print('📥 다운로드 시작: $fileUrl');

      // 4. 파일 다운로드 (재시도 로직 포함)
      int retryCount = 0;
      const maxRetries = 3;
      bool downloadSuccess = false;

      while (retryCount < maxRetries && !downloadSuccess) {
        try {
          await dio.download(
            fileUrl,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = (received / total * 100).toStringAsFixed(0);
                print('📥 다운로드 진행률: $progress%');
              }
            },
          );
          downloadSuccess = true;
          print('✅ 다운로드 성공!');
        } on DioException catch (e) {
          retryCount++;
          print('⚠️ 다운로드 시도 $retryCount/$maxRetries 실패: ${e.message}');
          
          if (retryCount < maxRetries) {
            // 재시도 전 대기 (지수 백오프)
            await Future.delayed(Duration(seconds: retryCount * 2));
            print('🔄 다운로드 재시도 중...');
          } else {
            // 최대 재시도 횟수 초과
            rethrow;
          }
        }
      }

      setState(() {
        isDownloading = false;
        isDownloadComplete = true;
      });

      // 4. 다운로드 완료 메시지 (파일 경로 포함)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ 다운로드 완료!\n파일: $fileName"),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: '열기',
            onPressed: () => _openDownloadedFile(filePath),
          ),
        ),
      );

      print("✅ 파일 저장 완료: $filePath");
    } on DioException catch (e) {
      print("🚨 다운로드 중 DioException 발생: ${e.type}");
      print("🚨 에러 메시지: ${e.message}");
      print("🚨 응답 코드: ${e.response?.statusCode}");
      
      setState(() {
        isDownloading = false;
        isDownloadComplete = false;
      });

      if (!mounted) return;
      
      String errorMessage = "다운로드 실패";
      String suggestion = "";

      // DioException 타입별 상세 메시지
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = "연결 시간 초과";
          suggestion = "서버가 응답하지 않습니다. 서버 상태를 확인하세요.";
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = "전송 시간 초과";
          suggestion = "네트워크 연결을 확인하세요.";
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = "수신 시간 초과";
          suggestion = "파일이 너무 크거나 서버가 느립니다.";
          break;
        case DioExceptionType.connectionError:
          errorMessage = "연결 오류";
          suggestion = "Flask 서버(10.0.2.2:5000)가 실행 중인지 확인하세요.";
          break;
        case DioExceptionType.badResponse:
          errorMessage = "잘못된 응답 (${e.response?.statusCode})";
          suggestion = "서버에서 파일을 찾을 수 없거나 오류가 발생했습니다.";
          break;
        case DioExceptionType.cancel:
          errorMessage = "다운로드 취소됨";
          break;
        case DioExceptionType.unknown:
          errorMessage = "알 수 없는 오류";
          suggestion = "서버 연결이 불안정합니다. Flask 서버 로그를 확인하세요.";
          break;
        default:
          errorMessage = e.message ?? "알 수 없는 오류";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🚨 $errorMessage", style: TextStyle(fontWeight: FontWeight.bold)),
              if (suggestion.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(suggestion, style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: '재시도',
            textColor: Colors.white,
            onPressed: () => _downloadFile(fileUrl),
          ),
        ),
      );
    } catch (e) {
      print("🚨 예상치 못한 오류: $e");
      
      setState(() {
        isDownloading = false;
        isDownloadComplete = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚨 예상치 못한 오류: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  /// 다운로드한 파일 열기 (비디오의 경우)
  Future<void> _openDownloadedFile(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚨 파일을 찾을 수 없습니다.")),
      );
      return;
    }

    // 비디오 파일인지 확인
    if (filePath.endsWith('.mp4') || filePath.endsWith('.avi') || filePath.endsWith('.mov')) {
      // 비디오 재생 화면으로 이동 (DownloadPlayVideoScreen 활용)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadPlayVideoScreen(videoPath: filePath),
        ),
      );
    } else {
      // 이미지 파일의 경우
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageUrl: filePath),
        ),
      );
    }
  }

  String updateUrl(String relativePath) {
    // 이미 전체 주소라면 그대로 반환 (예: http://...)
    if (relativePath.startsWith('http')) {
      return relativePath;
    }
    // 상대 경로라면(예: /results/...), 서버 기본 주소를 앞에 붙여서 전체 URL을 만듭니다.
    return serverBaseUrl + relativePath;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI 이미지 분류기")),
      body: Consumer<AiImageController>(
        builder: (context, controller, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("🔍 테스트 모델 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Column(
                    children: List.generate(5, (index) {
                      return _buildRadioTile(controller, index + 1, [
                        "🐶 동물상 테스트",
                        "🔌 폐가전 테스트",
                        "🛠️ 공구 테스트",
                        "🎯 Yolov8 이미지 테스트",
                        "🎯 Yolov8 동영상 테스트"
                      ][index]);
                    }),
                  ),
                  SizedBox(height: 16),

                  // ✅ 이미지 미리보기
                  controller.selectedImage != null
                      ? Image.file(controller.selectedImage!, height: 200, width: 200, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 100, color: Colors.grey),

                  SizedBox(height: 16),

                  // ✅ 갤러리/카메라 버튼
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildActionButton(Icons.photo, "갤러리(이미지)", () => controller.pickMedia(ImageSource.gallery)),
                      _buildActionButton(Icons.video_library, "갤러리(동영상)", () => controller.pickMedia(ImageSource.gallery, isVideo: true)),
                      _buildActionButton(Icons.camera, "카메라(이미지)", () => controller.pickMedia(ImageSource.camera)),
                      _buildActionButton(Icons.videocam, "카메라(동영상)", () => controller.pickMedia(ImageSource.camera, isVideo: true)),
                    ],
                  ),

                  SizedBox(height: 16),

                  // ✅ 업로드 버튼
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload),
                        label: Text("파일 업로드"),
                        onPressed: controller.isLoading ? null : () => controller.uploadMedia(context),
                      ),
                      if (controller.isLoading) CircularProgressIndicator(),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ✅ 예측 결과 리스트
                  if (controller.predictionResult?.isNotEmpty == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📌 예측 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if ([1, 2, 3].contains(controller.selectedModel)) ...[
                          _buildListTile(Icons.file_present, "📄 파일명", controller.predictionResult?['filename']),
                          _buildListTile(Icons.search, "🔍 예측된 클래스", controller.predictionResult?['predicted_class']),
                          _buildListTile(Icons.bar_chart, "📊 신뢰도", controller.predictionResult?['confidence']),
                        ],
                        _buildFileUrlTile(controller),
                        if ([4, 5].contains(controller.selectedModel)) _buildDownloadTile(controller),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ 모델 선택 라디오 버튼
  Widget _buildRadioTile(AiImageController controller, int value, String text) {
    return ListTile(
      title: Text(text),
      leading: Radio<int>(
        value: value,
        groupValue: controller.selectedModel,
        onChanged: (value) => controller.setModel(value!),
      ),
    );
  }

  /// ✅ 공통 액션 버튼 UI
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  /// ✅ 공통 리스트 타일 UI
  Widget _buildListTile(IconData icon, String title, String? value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? 'N/A'),
    );
  }

  /// ✅ 파일 URL 리스트 타일
  Widget _buildFileUrlTile(AiImageController controller) {
    // ❗️'url'이 null일 경우를 대비하여 방어 코드 추가
    final relativeUrl = controller.predictionResult?['url'];
    if (relativeUrl == null) return SizedBox.shrink();

    final fullUrl = updateUrl(relativeUrl);

    return ListTile(
      leading: Icon(Icons.image),
      title: Text("📊 파일 URL (클릭하여 미리보기)"),
      subtitle: InkWell(
        onTap: () {
          // Navigator로 이미지를 보여줄 때도 전체 URL을 사용합니다.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImagePreviewScreen(imageUrl: fullUrl)),
          );
        },
        child: Text(
          fullUrl,
          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  /// ✅ 파일 다운로드 리스트 타일
  Widget _buildDownloadTile(AiImageController controller) {
    // 'url'이 null일 경우 빈 위젯 반환
    final relativeUrl = controller.predictionResult?['url'];
    if (relativeUrl == null) return SizedBox.shrink();

    final fullUrl = updateUrl(relativeUrl);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        // 상태에 따라 아이콘 변경
        leading: isDownloading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isDownloadComplete ? Icons.check_circle : Icons.download,
                color: isDownloadComplete ? Colors.green : Colors.blue,
              ),
        title: Text(
          "📥 파일 다운로드",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isDownloading 
              ? "다운로드 중... 잠시만 기다려주세요." 
              : isDownloadComplete
                  ? "✅ 다운로드 완료! 앱 내부에 저장되었습니다."
                  : "앱 내부 저장소에 파일을 저장합니다. (권한 불필요)",
        ),
        // 다운로드 중일 때는 버튼 비활성화
        enabled: !isDownloading,
        onTap: isDownloading ? null : () => _downloadFile(fullUrl),
        // 다운로드 완료 시 다시 다운로드 버튼 표시
        trailing: isDownloadComplete
            ? TextButton(
                onPressed: () => _downloadFile(fullUrl),
                child: Text("재다운로드"),
              )
            : null,
      ),
    );
  }
}
