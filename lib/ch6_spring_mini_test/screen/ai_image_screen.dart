import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controller/ai_image_controller.dart';

class AiImageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiImageController(),
      child: Scaffold(
        appBar: AppBar(title: Text("AI 이미지 분류기")),
        body: Consumer<AiImageController>(
          builder: (context, controller, child) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ 이미지 미리보기
                  controller.selectedImage != null
                      ? Image.file(controller.selectedImage!,
                      height: 200, width: 200, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 100, color: Colors.grey),

                  SizedBox(height: 16),

                  // ✅ 버튼: 갤러리 선택, 카메라 촬영
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.photo),
                        label: Text("갤러리"),
                        onPressed: () => controller.pickImage(ImageSource.gallery),
                      ),
                      SizedBox(width: 10),
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

                  // ✅ 결과 표시
                  controller.predictionResult != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📌 예측 결과", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("📄 파일명: ${controller.predictionResult!['filename']}"),
                      Text("🔍 예측된 클래스: ${controller.predictionResult!['predicted_class']}"),
                      Text("📊 신뢰도: ${controller.predictionResult!['confidence']}"),
                    ],
                  )
                      : Container(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
