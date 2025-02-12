import 'package:dart_test/ch6_spring_mini_test/screen/download_play_video_screen.dart';
import 'package:dart_test/ch6_spring_mini_test/screen/image_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/ai_image_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AiImageScreen extends StatelessWidget {
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
                  // ✅ 모델 선택 라디오 버튼
                  Text("🔍 테스트 모델 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Column(
                    children: [
                      _buildRadioTile(controller, 1, "🐶 동물상 테스트"),
                      _buildRadioTile(controller, 2, "🔌 폐가전 테스트"),
                      _buildRadioTile(controller, 3, "🛠️ 공구 테스트"),
                      _buildRadioTile(controller, 4, "🎯 Yolov8 이미지 테스트"),
                      _buildRadioTile(controller, 5, "🎯 Yolov8 동영상 테스트"),
                    ],
                  ),
                  SizedBox(height: 16),

                  // ✅ 이미지 미리보기
                  controller.selectedImage != null
                      ? Image.file(controller.selectedImage!, height: 200, width: 200, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 100, color: Colors.grey),

                  SizedBox(height: 16),

                  // ✅ 버튼: 갤러리 선택, 카메라 촬영
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

                  // ✅ 이미지 업로드 버튼
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.upload),
                        label: Text("파일  업로드"),
                        onPressed: controller.isLoading ? null : () => controller.uploadMedia(context),
                      ),

                      if (controller.isLoading) CircularProgressIndicator(),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ✅ 예측 결과 리스트 (shrinkWrap 적용)
                  if (controller.predictionResult?.isNotEmpty == true)
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Text("📌 예측 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildListTile(Icons.file_present, "📄 파일명", controller.predictionResult?['filename'] ?? 'N/A'),
                        _buildListTile(Icons.search, "🔍 예측된 클래스", controller.predictionResult?['predicted_class'] ?? 'N/A'),
                        _buildListTile(Icons.bar_chart, "📊 신뢰도", controller.predictionResult?['confidence'] ?? 'N/A'),

                        // ✅ 파일 URL
                        ListTile(
                          leading: Icon(Icons.image),
                          title: Text("📊 파일 URL"),
                          subtitle: controller.predictionResult?['file_url'] != null
                              ? InkWell(
                            onTap: () {
                              // ✅ URL 변환: 127.0.0.1 → 10.0.2.2 (에뮬레이터 사용 시)
                              String fileUrl = controller.predictionResult!['file_url'];
                              fileUrl = fileUrl.replaceFirst("127.0.0.1", "10.0.2.2");
                              fileUrl = Uri.encodeFull(fileUrl);
                              print("📡 화면, 최종 변환된 URL: $fileUrl"); // ✅ URL 디버깅 로그

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreviewScreen(imageUrl: fileUrl),
                                ),
                              );
                            },
                            child: Text(
                              controller.predictionResult!['file_url'],
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                          )
                              : Text("URL 없음"),
                        ),
                        ListTile(
                          leading: Icon(Icons.download),
                          title: Text("📥 파일 다운로드"),
                          subtitle: controller.predictionResult?['download_url'] != null
                              ? InkWell(
                            onTap: () async {
                              // ✅ URL 변환: 127.0.0.1 → 10.0.2.2 (에뮬레이터 사용 시)
                              String downloadUrl = controller.predictionResult!['download_url'];
                              try {
                                // ✅ URL 변환: 127.0.0.1 → 10.0.2.2 (에뮬레이터 사용 시)
                                String formattedUrl = Uri.encodeFull(downloadUrl.replaceFirst("127.0.0.1", "10.0.2.2"));
                                print("📡 최종 다운로드 URL: $formattedUrl"); // ✅ URL 디버깅 로그

                                Uri url = Uri.parse(formattedUrl);

                                // ✅ 브라우저에서 강제로 열기 (LaunchMode.externalApplication)
                                await launchUrl(url, mode: LaunchMode.externalApplication);

                                // ✅ `DownloadAndPlayVideo` 화면으로 이동
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => DownloadAndPlayVideo(videoUrl: formattedUrl),
                                //   ),
                                // );
                              } catch (e) {
                                print("🚨 다운로드 실행 중 오류 발생: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("🚨 다운로드 실행 중 오류 발생")),
                                );
                              }
                            },
                            child: Text(
                              "📂 파일 다운로드",
                              style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                            ),
                          )
                              :Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("🔄 데이터 처리 중...", style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 5),
                              LinearProgressIndicator(), // ✅ 로딩 진행 바 (LinearProgressIndicator)
                            ],
                          ),
                        ),
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

  /// ✅ 공통: 라디오 버튼 UI
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

  /// ✅ 공통: 액션 버튼 UI
  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  /// ✅ 공통: 리스트 아이템 UI
  Widget _buildListTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text("$title: $value"),
    );
  }
}
