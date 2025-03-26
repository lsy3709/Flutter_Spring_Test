import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemModel2 {
  final String? mainTitle;
  final String? title;
  final String? image;

  ItemModel2({this.mainTitle, this.title, this.image});

  factory ItemModel2.fromJson(Map<String, dynamic> json) {
    return ItemModel2(
      mainTitle: json['MAIN_TITLE'],
      title: json['TITLE'],
      image: json['MAIN_IMG_NORMAL'],
    );
  }
}

class WalkingController with ChangeNotifier {
  final List<ItemModel2> _items = [];
  bool _isLoading = false;

  List<ItemModel2> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchWalkingData() async {
    _isLoading = true;
    notifyListeners();

    final queryParams = {
      'serviceKey': 'ALRX9GpugtvHxcIO/iPg1vXIQKi0E6Kk1ns4imt8BLTgdvSlH/AKv+A1GcGUQgzuzqM3Uv1ZGgpG5erOTDcYRQ==',
      'pageNo': '1',
      'numOfRows': '100',
      'resultType': 'json',
    };

    final uri = Uri.https(
      'apis.data.go.kr',
      '/6260000/WalkingService/getWalkingKr',
      queryParams,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final dynamic walkingData = decoded['getWalkingKr'];

        if (walkingData is Map<String, dynamic> && walkingData['item'] is List) {
          final List<dynamic> itemList = walkingData['item'];
          _items.clear();
          _items.addAll(itemList.map((e) => ItemModel2.fromJson(e)).toList());
        } else {
          debugPrint('데이터 구조가 예상과 다릅니다: ${jsonEncode(walkingData)}');
        }
      } else {
        debugPrint('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('데이터 로딩 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }


}
