import 'package:dart_test/ch6_spring_mini_test/screen/image_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/ai_image_controller.dart';

class AiImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("AI 이미지 분류기")),
        body: Consumer<AiImageController>(
          builder: (context, controller, child) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView( // ✅ 전체 스크롤 가능하도록 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ✅ 모델 선택 라디오 버튼 (ListView 대신 Column 사용)
                    Text("🔍 테스트 모델 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        ListTile(
                          title: Text("🐶 동물상 테스트"),
                          leading: Radio<int>(
                            value: 1,
                            groupValue: controller.selectedModel,
                            onChanged: (value) => controller.setModel(value!),
                          ),
                        ),
                        ListTile(
                          title: Text("🔌 폐가전 테스트"),
                          leading: Radio<int>(
                            value: 2,
                            groupValue: controller.selectedModel,
                            onChanged: (value) => controller.setModel(value!),
                          ),
                        ),
                        ListTile(
                          title: Text("🛠️ 공구 테스트"),
                          leading: Radio<int>(
                            value: 3,
                            groupValue: controller.selectedModel,
                            onChanged: (value) => controller.setModel(value!),
                          ),
                        ),
                        ListTile(
                          title: Text("🎯 Yolov8 이미지 테스트"),
                          leading: Radio<int>(
                            value: 4,
                            groupValue: controller.selectedModel,
                            onChanged: (value) => controller.setModel(value!),
                          ),
                        ),
                        ListTile(
                          title: Text("🎯 Yolov8 동영상 테스트"),
                          leading: Radio<int>(
                            value: 5,
                            groupValue: controller.selectedModel,
                            onChanged: (value) => controller.setModel(value!),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // ✅ 이미지 미리보기
                    controller.selectedImage != null
                        ? Image.file(controller.selectedImage!,
                        height: 200, width: 200, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 100, color: Colors.grey),

                    SizedBox(height: 16),

                    // ✅ 버튼: 갤러리 선택, 카메라 촬영
                    Wrap( // ✅ Row 대신 Wrap을 사용해 자동 줄바꿈 지원
                      spacing: 10,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.photo),
                          label: Text("갤러리"),
                          onPressed: () => controller.pickImage(ImageSource.gallery),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.camera),
                          label: Text("카메라"),
                          onPressed: () => controller.pickImage(ImageSource.camera),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // ✅ 이미지 업로드 버튼
                    ElevatedButton.icon(
                      icon: controller.isLoading ? CircularProgressIndicator() : Icon(Icons.upload),
                      label: Text("이미지 업로드"),
                      onPressed: controller.isLoading ? null : () => controller.uploadImage(context),
                    ),

                    SizedBox(height: 20),

                    // ✅ 예측 결과 리스트 (shrinkWrap 적용)
                    if (controller.predictionResult != null)
                      ListView(
                        shrinkWrap: true, // ✅ 내부 크기 자동 조정
                        physics: NeverScrollableScrollPhysics(), // ✅ 내부 스크롤 제거
                        children: [
                          Text("📌 예측 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ListTile(
                            leading: Icon(Icons.file_present),
                            title: Text("📄 파일명: ${controller.predictionResult!['filename']}"),
                          ),
                          ListTile(
                            leading: Icon(Icons.search),
                            title: Text("🔍 예측된 클래스: ${controller.predictionResult!['predicted_class']}"),
                          ),
                          ListTile(
                            leading: Icon(Icons.bar_chart),
                            title: Text("📊 신뢰도: ${controller.predictionResult!['confidence']}"),
                          ),
                          ListTile(
                            leading: Icon(Icons.image),
                            title: Text("📊 파일 URL"),
                            subtitle: controller.predictionResult != null
                                ? InkWell(
                              onTap: () {
                                // ✅ URL 변환: 127.0.0.1 → 10.0.2.2 (에뮬레이터 사용 시)
                                String fileUrl = controller.predictionResult!['file_url'];
                                fileUrl = fileUrl.replaceFirst("127.0.0.1", "10.0.2.2");
                                fileUrl = Uri.encodeFull(fileUrl); // ✅ 공백 및 특수 문자 인코딩
                                print("📡 화면,최종 변환된 URL: $fileUrl"); // ✅ URL 디버깅용 로그 출력

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
}