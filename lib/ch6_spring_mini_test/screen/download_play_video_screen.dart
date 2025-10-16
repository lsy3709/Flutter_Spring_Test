import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// 비디오 다운로드 및 재생 화면 (URL에서 다운로드)
class DownloadAndPlayVideo extends StatefulWidget {
  final String videoUrl;

  const DownloadAndPlayVideo({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _DownloadAndPlayVideoState createState() => _DownloadAndPlayVideoState();
}

/// 로컬 비디오 파일 재생 화면
class DownloadPlayVideoScreen extends StatefulWidget {
  final String videoPath;

  const DownloadPlayVideoScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  _DownloadPlayVideoScreenState createState() => _DownloadPlayVideoScreenState();
}

class _DownloadPlayVideoScreenState extends State<DownloadPlayVideoScreen> {
  VideoPlayerController? _controller;
  bool isInitialized = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// 비디오 플레이어 초기화
  Future<void> _initializeVideo() async {
    try {
      final file = File(widget.videoPath);
      
      if (!await file.exists()) {
        setState(() {
          hasError = true;
        });
        return;
      }

      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      
      setState(() {
        isInitialized = true;
      });

      // 자동 재생
      _controller!.play();
    } catch (e) {
      print("🚨 비디오 초기화 실패: $e");
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🎥 비디오 재생"),
        actions: [
          // 재생/일시정지 버튼
          if (isInitialized && _controller != null)
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying 
                      ? _controller!.pause() 
                      : _controller!.play();
                });
              },
            ),
        ],
      ),
      body: Center(
        child: hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    "🚨 비디오를 재생할 수 없습니다.",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "파일 경로: ${widget.videoPath}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : !isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text("비디오 로딩 중..."),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 비디오 플레이어
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      SizedBox(height: 20),
                      // 재생 컨트롤
                      _buildPlaybackControls(),
                    ],
                  ),
      ),
    );
  }

  /// 재생 컨트롤 UI
  Widget _buildPlaybackControls() {
    if (_controller == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 진행 바
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.blue,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          SizedBox(height: 10),
          // 재생/일시정지 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: () {
                  final currentPosition = _controller!.value.position;
                  _controller!.seekTo(
                    currentPosition - Duration(seconds: 10),
                  );
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
                iconSize: 48,
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying 
                        ? _controller!.pause() 
                        : _controller!.play();
                  });
                },
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: () {
                  final currentPosition = _controller!.value.position;
                  _controller!.seekTo(
                    currentPosition + Duration(seconds: 10),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
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
