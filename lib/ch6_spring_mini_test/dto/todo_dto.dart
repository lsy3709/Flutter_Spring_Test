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
