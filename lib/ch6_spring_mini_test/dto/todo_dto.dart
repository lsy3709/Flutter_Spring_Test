class TodoDTO {
  final int tno; // ✅ id → tno 변경
  final String title;
  final String description;
  final String writer;
  final DateTime dueDate; // ✅ Spring Boot의 LocalDate와 맞춤
  final bool complete; // ✅ completed → complete 변경

  TodoDTO({
    required this.tno,
    required this.title,
    required this.description,
    required this.writer,
    required this.dueDate,
    required this.complete,
  });

  // ✅ JSON → TodoDTO 변환
  factory TodoDTO.fromJson(Map<String, dynamic> json) {
    return TodoDTO(
      tno: json['tno'] ?? 0, // ✅ id → tno로 변경
      title: json['title'] ?? "제목 없음",
      description: json['description'] ?? "설명 없음",
      writer: json['writer'] ?? "알 수 없음",
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']) // ✅ LocalDate 변환
          : DateTime.now(),
      complete: json['complete'] ?? false, // ✅ completed → complete로 변경
    );
  }

  // ✅ TodoDTO → JSON 변환
  Map<String, dynamic> toJson() {
    return {
      "tno": tno, // ✅ 서버의 필드명과 일치
      "title": title,
      "description": description,
      "writer": writer,
      "dueDate": "${dueDate.year}-${dueDate.month}-${dueDate.day}", // ✅ `yyyy-MM-dd` 형식 변환
      "complete": complete, // ✅ completed → complete 변경
    };
  }
}
