import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiStockProvider extends ChangeNotifier {
  String selectedPeriod = "";
  bool isLoading = false;
  List<Map<String, dynamic>> stockData = [];
  Map<String, dynamic> predictions = {};

  // ✅ 기간 선택 업데이트
  void updatePeriod(String period) {
    selectedPeriod = period;
    notifyListeners();
  }

  // ✅ 주가 데이터 가져오기
  Future<void> fetchStockData() async {
    if (selectedPeriod.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(
          "http://192.168.219.103:8080/api/ai2/stock-data?period=$selectedPeriod"));

      if (response.statusCode == 200) {
        stockData = List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception("데이터 로드 실패");
      }
    } catch (e) {
      print("오류 발생: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ✅ 예측 요청
  Future<void> makePrediction(String model) async {
    if (selectedPeriod.isEmpty || stockData.isEmpty) return;

    isLoading = true;
    notifyListeners();

    List<List<double>> inputData = stockData.map((item) {
      return [
        (item["Open"] as num).toDouble(),
        (item["Low"] as num).toDouble(),
        (item["High"] as num).toDouble(),
        (item["Close"] as num).toDouble()
      ];
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("http://192.168.219.103:8080/api/ai/predict/$model"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": inputData, "period": selectedPeriod}),
      );

      if (response.statusCode == 200) {
        predictions[model] = json.decode(response.body)["prediction"];
      } else {
        throw Exception("예측 실패");
      }
    } catch (e) {
      print("예측 요청 실패: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
