import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'image_preview_screen.dart';
import 'download_play_video_screen.dart';

/// 다운로드한 파일 목록을 보여주는 화면
class DownloadedFilesScreen extends StatefulWidget {
  @override
  _DownloadedFilesScreenState createState() => _DownloadedFilesScreenState();
}

class _DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  List<FileInfo> downloadedFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  /// 앱 내부 저장소에서 다운로드한 파일 목록 로드
  Future<void> _loadDownloadedFiles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();

      List<FileInfo> fileInfoList = [];

      for (var entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          final fileName = entity.path.split('/').last;

          // 타임스탬프가 있는 파일만 필터링 (우리가 다운로드한 파일)
          if (fileName.contains('_')) {
            fileInfoList.add(FileInfo(
              file: entity,
              name: fileName,
              size: stat.size,
              modifiedDate: stat.modified,
            ));
          }
        }
      }

      // 최신 파일이 위로 오도록 정렬
      fileInfoList.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

      setState(() {
        downloadedFiles = fileInfoList;
        isLoading = false;
      });

      print('📂 다운로드된 파일 ${downloadedFiles.length}개 발견');
    } catch (e) {
      print('🚨 파일 로드 오류: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  /// 파일 크기를 읽기 쉬운 형식으로 변환
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 파일 타입 확인
  String _getFileType(String fileName) {
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.png')) {
      return 'image';
    } else if (fileName.endsWith('.mp4') || fileName.endsWith('.avi') || fileName.endsWith('.mov')) {
      return 'video';
    }
    return 'unknown';
  }

  /// 파일 아이콘 가져오기
  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 파일 열기
  void _openFile(FileInfo fileInfo) {
    final fileType = _getFileType(fileInfo.name);

    if (fileType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageUrl: fileInfo.file.path),
        ),
      );
    } else if (fileType == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadPlayVideoScreen(videoPath: fileInfo.file.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지원하지 않는 파일 형식입니다.')),
      );
    }
  }

  /// 파일 삭제
  Future<void> _deleteFile(FileInfo fileInfo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('파일 삭제'),
        content: Text('${fileInfo.name}\n\n이 파일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await fileInfo.file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 파일이 삭제되었습니다.')),
        );
        _loadDownloadedFiles(); // 목록 새로고침
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🚨 삭제 실패: $e')),
        );
      }
    }
  }

  /// 모든 파일 삭제
  Future<void> _deleteAllFiles() async {
    if (downloadedFiles.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('전체 삭제'),
        content: Text('다운로드한 파일 ${downloadedFiles.length}개를 모두 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('전체 삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        for (var fileInfo in downloadedFiles) {
          await fileInfo.file.delete();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ 모든 파일이 삭제되었습니다.')),
        );
        _loadDownloadedFiles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🚨 삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📂 다운로드한 파일'),
        actions: [
          if (downloadedFiles.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: '전체 삭제',
              onPressed: _deleteAllFiles,
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: _loadDownloadedFiles,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : downloadedFiles.isEmpty
              ? _buildEmptyState()
              : _buildFileList(),
    );
  }

  /// 파일이 없을 때 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            '다운로드한 파일이 없습니다',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'AI 이미지 화면에서\n파일을 다운로드해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 파일 목록 표시
  Widget _buildFileList() {
    return Column(
      children: [
        // 헤더 (총 파일 수 및 용량)
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '총 ${downloadedFiles.length}개 파일 (${_getTotalSize()})',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // 파일 목록
        Expanded(
          child: ListView.builder(
            itemCount: downloadedFiles.length,
            itemBuilder: (context, index) {
              final fileInfo = downloadedFiles[index];
              final fileType = _getFileType(fileInfo.name);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: fileType == 'image' 
                        ? Colors.blue.shade100 
                        : Colors.orange.shade100,
                    child: Icon(
                      _getFileIcon(fileType),
                      color: fileType == 'image' ? Colors.blue : Colors.orange,
                    ),
                  ),
                  title: Text(
                    _getDisplayName(fileInfo.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text('크기: ${_formatFileSize(fileInfo.size)}'),
                      Text(
                        '다운로드: ${DateFormat('yyyy-MM-dd HH:mm').format(fileInfo.modifiedDate)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFile(fileInfo),
                        tooltip: '삭제',
                      ),
                    ],
                  ),
                  onTap: () => _openFile(fileInfo),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 전체 파일 크기 계산
  String _getTotalSize() {
    int totalBytes = downloadedFiles.fold(0, (sum, file) => sum + file.size);
    return _formatFileSize(totalBytes);
  }

  /// 파일명에서 타임스탬프 제거하고 표시
  String _getDisplayName(String fileName) {
    // 타임스탬프_원본파일명.확장자 형식에서 타임스탬프 제거
    final parts = fileName.split('_');
    if (parts.length > 1) {
      return parts.sublist(1).join('_');
    }
    return fileName;
  }
}

/// 파일 정보를 담는 클래스
class FileInfo {
  final File file;
  final String name;
  final int size;
  final DateTime modifiedDate;

  FileInfo({
    required this.file,
    required this.name,
    required this.size,
    required this.modifiedDate,
  });
}

