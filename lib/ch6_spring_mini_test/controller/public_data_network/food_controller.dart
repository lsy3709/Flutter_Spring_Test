import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FoodItem {
  final String? mainTitle;
  final String? title;
  final String? image;

  FoodItem({this.mainTitle, this.title, this.image});

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      mainTitle: json['MAIN_TITLE'],
      title: json['TITLE'],
      image: json['MAIN_IMG_NORMAL'],
    );
  }
}

class FoodController with ChangeNotifier {
  final List<FoodItem> _items = [];
  bool _isLoading = false;

  List<FoodItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchFoodData() async {
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
      '/6260000/FoodService/getFoodKr',
      queryParams,
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final dynamic foodData = decoded['getFoodKr'];

        if (foodData is Map<String, dynamic> && foodData['item'] is List) {
          final List<dynamic> itemList = foodData['item'];
          _items.clear();
          _items.addAll(itemList.map((e) => FoodItem.fromJson(e)).toList());
        } else {
          debugPrint('데이터 구조가 예상과 다릅니다: ${jsonEncode(foodData)}');
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
