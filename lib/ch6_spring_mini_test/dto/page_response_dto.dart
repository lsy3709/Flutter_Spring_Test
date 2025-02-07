class PageResponseDTO<T> {
  final int page;
  final int size;
  final int total;
  final int start;
  final int end;
  final bool prev;
  final bool next;
  final List<T> dtoList;

  PageResponseDTO({
    required this.page,
    required this.size,
    required this.total,
    required this.start,
    required this.end,
    required this.prev,
    required this.next,
    required this.dtoList,
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
    );
  }
}
