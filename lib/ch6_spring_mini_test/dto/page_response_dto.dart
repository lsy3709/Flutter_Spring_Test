class PageResponseDTO<T> {
  final int page;
  final int size;
  final int total;
  final int start;
  final int end;
  final bool prev;
  final bool next;
  final List<T> dtoList;

  // ✅ 추가된 멤버 변수
  final int? nextCursor; // 다음 페이지 요청을 위한 커서 ID
  final bool hasNext; // 다음 데이터 존재 여부

  PageResponseDTO({
    required this.page,
    required this.size,
    required this.total,
    required this.start,
    required this.end,
    required this.prev,
    required this.next,
    required this.dtoList,
    required this.nextCursor, // ✅ 추가
    required this.hasNext, // ✅ 추가
  });

  factory PageResponseDTO.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PageResponseDTO(
      page: json['page'] ?? 1, // 기본값 1
      size: json['size'] ?? 10, // 기본값 10
      total: json['total'] ?? 0, // 기본값 0
      start: json['start'] ?? 1, // 기본값 1
      end: json['end'] ?? 1, // 기본값 1
      prev: json['prev'] ?? false, // 기본값 false
      next: json['next'] ?? false, // 기본값 false
      dtoList: (json['dtoList'] as List?)?.map((item) => fromJsonT(item)).toList() ?? [], // `null`이면 빈 리스트 반환
      nextCursor: json['nextCursor'], // ✅ 추가
      hasNext: json['hasNext'] ?? false, // ✅ 추가
    );
  }
}
