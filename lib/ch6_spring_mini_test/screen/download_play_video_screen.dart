import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class DownloadAndPlayVideo extends StatefulWidget {
  final String videoUrl;

  const DownloadAndPlayVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _DownloadAndPlayVideoState createState() => _DownloadAndPlayVideoState();
}

class _DownloadAndPlayVideoState extends State<DownloadAndPlayVideo> {
  bool isDownloading = false;
  double progress = 0.0;
  String? downloadedFilePath;
  VideoPlayerController? _controller;

  Future<void> downloadVideo() async {
    setState(() {
      isDownloading = true;
      progress = 0.0;
    });

    try {
      // ✅ 저장할 디렉토리 가져오기 (앱 내부 저장소)
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/downloaded_video.mp4";

      String formattedUrl = Uri.encodeFull(widget.videoUrl.replaceFirst("127.0.0.1", "10.0.2.2")); // ✅ 에뮬레이터용 IP 변환

      // ✅ 파일 다운로드 시작
      await Dio().download(
        formattedUrl,
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = received / total;
          });
        },
      );

      setState(() {
        isDownloading = false;
        downloadedFilePath = filePath;
        _initializeVideo(filePath); // ✅ 동영상 재생 초기화
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ 다운로드 완료: $filePath")),
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚨 다운로드 실패: $e")),

      );
    }
  }

  // ✅ 다운로드된 파일을 재생할 VideoPlayerController 초기화
  void _initializeVideo(String path) {
    _controller = VideoPlayerController.file(File(path))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🎥 다운로드 & 재생")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDownloading)
              Column(
                children: [
                  CircularProgressIndicator(value: progress),
                  SizedBox(height: 10),
                  Text("다운로드 중... ${(progress * 100).toStringAsFixed(1)}%"),
                ],
              ),

            if (downloadedFilePath == null && !isDownloading)
              ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text("동영상 다운로드"),
                onPressed: downloadVideo,
              ),

            if (downloadedFilePath != null && _controller != null && _controller!.value.isInitialized)
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                      });
                    },
                    child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
