import 'package:dart_test/ch6/widgetJoin.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: ListView(
          shrinkWrap: true, // 필요 이상으로 크기를 확장하지 않음
          padding: EdgeInsets.all(16.0),

          children: [
            Wrap(
              children: [
                Center(
                  child: Text(
                    'Code Factory',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              direction: Axis.vertical, // 요소들을 세로 방향으로 정렬
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center, // 줄 바꿈된 요소들의 정렬
              children: [
                TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('텍스트버튼')),
                OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber,
                    ),
                    child: Text('아웃라인드 버튼')),
              ],
            ),
            Wrap(
              direction: Axis.vertical, // 요소들을 세로 방향으로 정렬
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center, // 줄 바꿈된 요소들의 정렬
              children: [
                ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text('엘리베이티드 버튼')),
                IconButton(onPressed: () {}, icon: Icon(Icons.home)),
                GestureDetector(
                  onTap: () {
                    print('on tap');
                  },
                  onDoubleTap: () {
                    print('on double tap');
                  },
                  onLongPress: () {
                    print('on long press');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                    ),
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                FloatingActionButton(
                  // 클릭했을 때 실행할 함수
                  onPressed: () {
                    print('FloatingActionButton 클릭됨');
                  },
                  child: Text('클릭'),
                ),
                Container(
                  // 스타일 적용
                  decoration: BoxDecoration(
                    // 배경색 적용
                    color: Colors.red,
                    // 테두리 적용
                    border: Border.all(
                      // 테두리 굵기
                      width: 16.0,
                      // 테두리 색상
                      color: Colors.black,
                    ),
                    // 모서리 둥글게 만들기
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  // 높이
                  height: 200.0,
                  // 너비
                  width: 100.0,
                ),
                SizedBox(
                  // 높이 지정
                  height: 200.0,
                  // 너비 지정
                  width: 200.0,
                  // SizedBox는 색상이 없으므로 크기를 확인하는
                  // 용도로 Container 추가
                  child: Container(
                    color: Colors.red,
                  ),
                ),
                Container(
                  color: Colors.blue,
                  child: Padding(
                    // 상하, 좌우로 모두 16픽셀만큼 패딩 적용
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      color: Colors.red,
                      width: 50.0,
                      height: 50.0,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black, // ③ 최상위 검정 컨테이너 (margin이 적용되는 대상)
                  child: Container(
                    color: Colors.blue, // ② 중간 파란 컨테이너

                    // 마진 적용 위치
                    margin: EdgeInsets.all(16.0),

                    // 패딩 적용
                    child: Padding(
                      padding: EdgeInsets.all(16.0),

                      // ① 패딩이 적용된 빨간 컨테이너
                      child: Container(
                        color: Colors.red,
                        width: 50.0,
                        height: 50.0,
                      ),
                    ),
                  ),
                ),
                // 외부, 위젯 조인
                CustomStatelessWidget(
                  title: '조인 테스트 위젯',
                ),
                SizedBox(height: 20),

                // StatefulWidget 사용
                CustomStatefulWidget(),
              ],
            ),
            SizedBox(
              // 반대축에서 이동할 공간을 제공하기 위해 높이를 최대한으로 설정
              height: 200.0,
              child: Row(
                // 주축 정렬 지정
                mainAxisAlignment: MainAxisAlignment.center,
                // 반대축 정렬 지정
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // 넣고 싶은 위젯 입력
                children: [
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.red,
                  ),
                  // SizedBox는 일반적으로 공백을 생성할 때 사용
                  SizedBox(width: 12.0),
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.green,
                  ),
                  SizedBox(width: 12.0),
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            SizedBox(
              // 반대축에서 이동할 공간을 제공하기 위해 너비를 최대한으로 설정
              width: double.infinity,
              height: 300.0,
              child: Column(
                // 주축 정렬 지정
                mainAxisAlignment: MainAxisAlignment.center,
                // 반대축 정렬 지정
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // 넣고 싶은 위젯 입력
                children: [
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.red,
                  ),
                  // SizedBox는 일반적으로 공백을 생성할 때 사용
                  SizedBox(height: 12.0), // 공백 추가 (Column이므로 height 사용)
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.green,
                  ),
                  SizedBox(height: 12.0), // 공백 추가
                  Container(
                    height: 50.0,
                    width: 50.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            SizedBox(
              // 반대축에서 이동할 공간을 제공하기 위해 너비를 최대한으로 설정
              width: double.infinity,
              height: 300.0,
              child: Column(
                // 주축 정렬 지정
                mainAxisAlignment: MainAxisAlignment.center,
                // 반대축 정렬 지정
                crossAxisAlignment: CrossAxisAlignment.center,
                // 넣고 싶은 위젯 입력
                children: [
                  Flexible(
                    // flex는 남은 공간을 차지할 비율을 의미합니다.
                    // flex값을 제공하지 않으면 기본값은 1입니다.
                    flex:1,
                    // 파란색 Container
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    // 빨간색 Container
                    child: Container(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0), // 요소 간 간격
            SizedBox(
              // 반대축에서 이동할 공간을 제공하기 위해 너비를 최대한으로 설정
              width: double.infinity,
              height: 300.0,
              child: Column(
                children: [
                  // 파란색 Container
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                    ),
                  ),
                  // 빨간색 Container
                  Expanded(
                    child: Container(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0), // 요소 간 간격
            SizedBox(
              // 반대축에서 이동할 공간을 제공하기 위해 너비를 최대한으로 설정
              width: double.infinity,
              height: 300.0,
              child: Stack(
                children: [
                  // 빨간색 Container
                  Container(
                    height: 300.0,
                    width: 300.0,
                    color: Colors.red,
                  ),
                  // 노란색 Container
                  Container(
                    height: 250.0,
                    width: 250.0,
                    color: Colors.yellow,
                  ),
                  // 파란색 Container
                  Container(
                    height: 200.0,
                    width: 200.0,
                    color: Colors.blue,
                  ),
                ],
              ),

            ),
          ],
        ),
      )),
    );
  }
}
