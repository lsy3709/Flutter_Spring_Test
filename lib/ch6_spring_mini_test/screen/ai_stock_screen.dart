import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controller/ai_stock_provider.dart';

class AiStockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiStockController(),
      child: Scaffold(
        appBar: AppBar(title: Text("삼성 주가 예측")),
        body: Consumer<AiStockController>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // ✅ 최소 높이 설정
                  children: [
                    Text("🔍 기간 선택시, 1mo,3mo,6mo,1y 데이터 갯수 파악 후, 플라스크 서버 값 변경 후 하기", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    // ✅ 기간 선택
                    DropdownButton<String>(
                      value: provider.selectedPeriod.isEmpty ? null : provider.selectedPeriod,
                      hint: Text("기간 선택"),
                      items: ["1d", "5d", "1mo", "3mo", "6mo", "1y"].map((period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) => provider.updatePeriod(value!),
                    ),

                    SizedBox(height: 10),

                    // ✅ 데이터 가져오기 버튼
                    ElevatedButton(
                      onPressed: provider.isLoading ? null : provider.fetchStockData,
                      child: provider.isLoading
                          ? CircularProgressIndicator()
                          : Text("데이터 가져오기"),
                    ),

                    SizedBox(height: 20),

                    // ✅ 데이터 목록 (✅ `ListView.builder`을 `SizedBox`로 감싸서 스크롤 가능)
                    provider.stockData.isEmpty
                        ? Text("데이터가 없습니다.")
                        : SizedBox(
                      height: 250, // ✅ 스크롤 가능하도록 높이 제한
                      child: ListView.builder(
                        shrinkWrap: true, // ✅ 내부 요소 크기만큼만 차지하도록 설정
                        physics: AlwaysScrollableScrollPhysics(), // ✅ 스크롤 가능 설정
                        itemCount: provider.stockData.length,
                        itemBuilder: (context, index) {
                          var item = provider.stockData[index];
                          return ListTile(
                            title: Text("📅 ${item["Date"]}"),
                            subtitle: Text(
                              "시작가: ${item["Open"]}, 고가: ${item["High"]}, 저가: ${item["Low"]}, 종가: ${item["Close"]}",
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10),

                    // ✅ 예측 버튼
                    Wrap(
                      spacing: 10,
                      children: ["rnn", "lstm", "gru"].map((model) {
                        return ElevatedButton(
                          onPressed: provider.isLoading ? null : () => provider.makePrediction(model),
                          child: Text("$model 예측하기"),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 20),

                    // ✅ 예측 결과
                    provider.predictions.isNotEmpty
                        ? Column(
                      children: provider.predictions.keys.map((model) {
                        return Text("$model: ${provider.predictions[model]}");
                      }).toList(),
                    )
                        : Container(),

                    SizedBox(height: 20),

                    // ✅ 주가 데이터 그래프
                    provider.stockData.isNotEmpty
                        ? Container(
                      height: 300,
                      padding: EdgeInsets.all(10),
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          ),
                          lineBarsData: [
                            // 실제 종가 데이터
                            LineChartBarData(
                              spots: provider.stockData.map((e) {
                                int index = provider.stockData.indexOf(e);
                                return FlSpot(index.toDouble(), (e["Close"] as num).toDouble());
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                              dotData: FlDotData(show: false),
                            ),
                            // RNN 예측 데이터
                            if (provider.predictions.containsKey("RNN"))
                              LineChartBarData(
                                spots: [
                                  FlSpot(
                                    provider.stockData.length.toDouble(),
                                    (provider.predictions["RNN"] as num).toDouble(),
                                  )
                                ],
                                isCurved: false,
                                color: Colors.red,
                                dotData: FlDotData(show: true),
                              ),
                            // LSTM 예측 데이터
                            if (provider.predictions.containsKey("LSTM"))
                              LineChartBarData(
                                spots: [
                                  FlSpot(
                                    provider.stockData.length.toDouble(),
                                    (provider.predictions["LSTM"] as num).toDouble(),
                                  )
                                ],
                                isCurved: false,
                                color: Colors.green,
                                dotData: FlDotData(show: true),
                              ),
                            // GRU 예측 데이터
                            if (provider.predictions.containsKey("GRU"))
                              LineChartBarData(
                                spots: [
                                  FlSpot(
                                    provider.stockData.length.toDouble(),
                                    (provider.predictions["GRU"] as num).toDouble(),
                                  )
                                ],
                                isCurved: false,
                                color: Colors.purple,
                                dotData: FlDotData(show: true),
                              ),
                          ],
                        ),
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
