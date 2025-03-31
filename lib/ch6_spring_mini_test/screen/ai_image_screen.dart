import 'package:dart_test/ch6_spring_mini_test/screen/download_play_video_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/image_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/ai_image_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AiImageScreen extends StatefulWidget {
  @override
  _AiImageScreenState createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  bool isDownloading = false;
  bool isDownloadComplete = false;

  Future<void> handleDownload(AiImageController controller) async {
    if (controller.predictionResult?['download_url'] == null) return;

    setState(() {
      isDownloading = true;
      isDownloadComplete = false;
    });

    try {
      String downloadUrl = controller.predictionResult!['download_url'];
      Uri url = Uri.parse(downloadUrl);
      await launchUrl(url, mode: LaunchMode.externalApplication);

      setState(() {
        isDownloading = false;
        isDownloadComplete = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ 다운로드 완료")),
      );
    } catch (e) {
      print("🚨 다운로드 실행 중 오류 발생: $e");
      setState(() {
        isDownloading = false;
        isDownloadComplete = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚨 다운로드 실행 중 오류 발생")),
      );
    }
  }

  String updateUrl(String originalUrl) {
    if (originalUrl.contains("localhost:5000")) {
      // return originalUrl.replaceFirst("localhost:5000", "10.100.201.87:5000");
      //에뮬레이터 일 때
      return originalUrl.replaceFirst("localhost:5000", "10.0.2.2:5000");
    }
    return originalUrl;
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
    return ListTile(
      leading: Icon(Icons.image),
      title: Text("📊 파일 URL"),
      subtitle: controller.predictionResult?['file_url'] != null
          ? InkWell(
        onTap: () {
          String fileUrl = Uri.encodeFull(updateUrl(controller.predictionResult!['file_url']));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImagePreviewScreen(imageUrl: fileUrl)),
          );
        },
        child: Text(
          updateUrl(controller.predictionResult!['file_url']),
          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
        ),
      )
          : Text("URL 없음"),
    );

  }

  /// ✅ 파일 다운로드 리스트 타일
  Widget _buildDownloadTile(AiImageController controller) {
    return ListTile(
      leading: Icon(Icons.download),
      title: Text("📥 파일 다운로드"),
      subtitle: controller.predictionResult?['download_url'] != null
          ? InkWell(
        onTap: () async {
          String downloadUrl = updateUrl(controller.predictionResult!['download_url']);
          Uri url = Uri.parse(downloadUrl);
          print("📡 최종 다운로드 URL: $downloadUrl");

          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            print("🚨 다운로드 실행 중 오류 발생: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("🚨 다운로드 실행 중 오류 발생")),
            );
          }
        },
        child: Text(
          updateUrl(controller.predictionResult!['download_url']),
          style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
        ),
      )
          : Text("URL 없음"),
    );

  }
}
