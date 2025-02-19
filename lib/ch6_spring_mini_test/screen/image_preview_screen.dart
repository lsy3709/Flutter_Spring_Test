import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  ImagePreviewScreen({Key? key, required this.imageUrl}) : super(key: key);

  /// ✅ 127.0.0.1 → 10.0.2.2 변환 (에뮬레이터 호환성)
  String updateImageUrl(String url) {
    return url.replaceFirst("127.0.0.1", "10.0.2.2");
  }

  @override
  Widget build(BuildContext context) {
    // String fixedUrl = updateImageUrl(imageUrl);
    String fixedUrl = imageUrl;
    print("📡 프리뷰 화면에서 최종 이미지 URL: $fixedUrl");

    return Scaffold(
      appBar: AppBar(title: Text("이미지 미리보기")),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // ✅ 패닝 활성화 (줌 가능)
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            fixedUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                    SizedBox(height: 10),
                    Text("이미지 로딩 중...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 80, color: Colors.red),
                  SizedBox(height: 10),
                  Text("❌ 이미지를 불러올 수 없습니다.", style: TextStyle(color: Colors.red)),
                  SizedBox(height: 5),
                  Text("URL을 확인해주세요", style: TextStyle(color: Colors.grey)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
