import 'package:flutter/cupertino.dart';


class CupertinoTabWrapper extends StatefulWidget {
  @override
  State<CupertinoTabWrapper> createState() => _CupertinoTabWrapperState();
}

class _CupertinoTabWrapperState extends State<CupertinoTabWrapper> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 0) {
      // 홈 탭 클릭 시 메인 라우트로 이동
      Navigator.pushNamed(context, '/main');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '설정'),
        ],
      ),
      tabBuilder: (context, index) {
        // 나머지 탭은 정적으로 보여주기
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('탭 $index'),
          ),
          child: Center(child: Text('탭 내용 $index')),
        );
      },
    );
  }
}

//스테이트리스 버전.
// class MyCupertinoApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoApp(
//       home: CupertinoTabScaffold(
//         tabBar: CupertinoTabBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: '홈'),
//             BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: '검색'),
//             BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: '설정'),
//           ],
//         ),
//         tabBuilder: (context, index) {
//           return CupertinoPageScaffold(
//             navigationBar: CupertinoNavigationBar(
//               middle: Text('Cupertino Page $index'),
//             ),
//             child: Center(child: Text('Page $index')),
//           );
//         },
//       ),
//     );
//   }
// }