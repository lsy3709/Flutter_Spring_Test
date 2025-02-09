class TodoDTO {
  final int tno;
  final String title;
  final String description;
  final String writer;
  final DateTime dueDate;
  final bool complete;

  TodoDTO({
    required this.tno,
    required this.title,
    required this.description,
    required this.writer,
    required this.dueDate,
    required this.complete,
  });

  factory TodoDTO.fromJson(Map<String, dynamic> json) {
    return TodoDTO(
      tno: json['tno'] ?? 0,
      title: json['title'] ?? "제목 없음",
      description: json['description'] ?? "설명 없음",
      writer: json['writer'] ?? "알 수 없음",
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // ✅ JSON → DateTime 변환
          : DateTime.now(),
      complete: json['complete'] ?? false,
    );
  }

  // ✅ dueDate를 "YYYY-MM-DD HH:mm" 형식으로 변환하는 함수 추가
  String get formattedDueDate {
    return "${dueDate.year}-${_twoDigits(dueDate.month)}-${_twoDigits(dueDate.day)} ";
        // "${_twoDigits(dueDate.hour)}:${_twoDigits(dueDate.minute)}";
  }

  // ✅ 한 자리 수일 경우 앞에 0을 추가하는 함수
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  Map<String, dynamic> toJson() {
    return {
      "tno": tno,
      "title": title,
      "description": description,
      "writer": writer,
      "dueDate": "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}", // ✅ 날짜 포맷 수정
      "complete": complete,
    };
  }
}
