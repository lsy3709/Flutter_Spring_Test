//
// // 인스턴스화 가능
// import '1_a.dart';
//
// Parent parent = Parent();
//
// // 가능
// base class Child extends Parent{}
//
// // subtype of base or final is not base final or sealed 에러가 발생합니다.
// // base/ sealed / final 제한자 중 하나가 필요합니다.
//
// class Child2 extends Parent{}
//
// // subtype of base or final is not base final or sealed 에러가 발생합니다.
// // base 클래스는 impLement가 불가능합니다.
//
// class Child3 implements Parent{}