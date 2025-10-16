import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  ImagePreviewScreen({Key? key, required this.imageUrl}) : super(key: key);

  /// 이미지 URL이 네트워크 주소인지 로컬 파일 경로인지 확인
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// 127.0.0.1 → 10.0.2.2 변환 (에뮬레이터 호환성)
  String _updateImageUrl(String url) {
    return url.replaceFirst("127.0.0.1", "10.0.2.2");
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = _isNetworkUrl(imageUrl);
    final displayUrl = isNetwork ? _updateImageUrl(imageUrl) : imageUrl;
    
    print("📡 프리뷰 화면 - 이미지 ${isNetwork ? 'URL' : '경로'}: $displayUrl");

    return Scaffold(
      appBar: AppBar(
        title: Text("이미지 미리보기"),
        actions: [
          // 이미지 타입 표시
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                label: Text(
                  isNetwork ? "🌐 네트워크" : "📁 로컬",
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: isNetwork ? Colors.blue.shade100 : Colors.green.shade100,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // 패닝 활성화 (줌 가능)
          minScale: 0.5,
          maxScale: 3.0,
          child: isNetwork 
              ? _buildNetworkImage(displayUrl)
              : _buildLocalImage(displayUrl),
        ),
      ),
    );
  }

  /// 네트워크 이미지 위젯 (Dio로 직접 다운로드 후 표시)
  Widget _buildNetworkImage(String url) {
    return FutureBuilder<File?>(
      future: _downloadImageFile(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("이미지 다운로드 중...", style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Text("서버에서 이미지를 가져오고 있습니다.", 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(url, snapshot.error.toString());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(url, error.toString());
            },
          );
        }

        return _buildErrorWidget(url, "이미지를 불러올 수 없습니다.");
      },
    );
  }

  /// 네트워크 이미지를 임시 파일로 다운로드 (재시도 로직 포함)
  Future<File?> _downloadImageFile(String url) async {
    try {
      // Dio 설정 (타임아웃 및 재시도)
      final dio = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(minutes: 2),
          headers: {
            'Connection': 'keep-alive',
            'Accept': 'image/*',
          },
        ),
      );

      // 임시 디렉토리에 저장
      final directory = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';

      print('🖼️ 이미지 다운로드 시작: $url');

      // 재시도 로직
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total != -1) {
                final progress = (received / total * 100).toStringAsFixed(0);
                print('🖼️ 이미지 로딩: $progress%');
              }
            },
          );

          print('✅ 이미지 다운로드 성공!');
          return File(filePath);
        } on DioException catch (e) {
          retryCount++;
          print('⚠️ 이미지 다운로드 시도 $retryCount/$maxRetries 실패: ${e.message}');

          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
            print('🔄 이미지 다운로드 재시도 중...');
          } else {
            rethrow;
          }
        }
      }

      return null;
    } catch (e) {
      print('🚨 이미지 다운로드 실패: $e');
      rethrow;
    }
  }

  /// 로컬 이미지 위젯
  Widget _buildLocalImage(String path) {
    final file = File(path);
    
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("이미지 로딩 중...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Image.file(
            file,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(path, error.toString());
            },
          );
        }

        return _buildErrorWidget(path, "파일을 찾을 수 없습니다.");
      },
    );
  }

  /// 에러 위젯
  Widget _buildErrorWidget(String path, String errorMessage) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 80, color: Colors.red),
          SizedBox(height: 10),
          Text(
            "❌ 이미지를 불러올 수 없습니다.",
            style: TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "경로: $path",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            "오류: $errorMessage",
            style: TextStyle(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
