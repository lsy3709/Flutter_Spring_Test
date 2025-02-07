class TodoDTO {
  final int id;
  final String title;
  final String description;
  final String writer; // ✅ 작성자 추가
  final DateTime dueDate; // ✅ 마감일 추가
  final bool completed;

  TodoDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.writer, // ✅ 작성자 필수
    required this.dueDate, // ✅ 마감일 필수
    required this.completed,
  });

  factory TodoDTO.fromJson(Map<String, dynamic> json) {
    return TodoDTO(
      id: json['id'] ?? 0, // 기본값 0
      title: json['title'] ?? "제목 없음", // 기본값 제공
      description: json['description'] ?? "설명 없음", // 기본값 제공
      writer: json['writer'] ?? "알 수 없음", // ✅ 기본값 추가
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // ✅ 날짜 변환
          : DateTime.now(), // 기본값: 현재 날짜
      completed: json['completed'] ?? false, // 기본값 제공
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "writer": writer, // ✅ 추가
      "dueDate": dueDate.toIso8601String(), // ✅ ISO 8601 포맷 변환
      "completed": completed,
    };
  }
}
