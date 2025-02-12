import 'package:flutter/material.dart';
import 'dart:convert'; // ✅ URL Decoding
import 'package:http/http.dart' as http;

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  ImagePreviewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // ✅ 127.0.0.1 → 10.0.2.2 변경 (에뮬레이터 호환성)
    String fixedUrl = imageUrl.replaceFirst("127.0.0.1", "10.0.2.2");
    print("📡 프리뷰, 플러터에서 최종 이미지 URL: $fixedUrl");

    return Scaffold(
      appBar: AppBar(title: Text("이미지 미리보기")),
      body: Center(
        child: InteractiveViewer( // ✅ 줌 기능 추가
          child: Image.network(
            fixedUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(child: Text("이미지를 불러올 수 없습니다."));
            },
          ),
        ),
      ),
    );
  }
}
