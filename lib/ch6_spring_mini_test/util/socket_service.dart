import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connectToSocket() {

    // socket = IO.io('http://192.168.219.103:5000', <String, dynamic>{
    socket = IO.io('http:// 192.168.123.135:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, // ✅ 수동 연결
    });

    socket!.connect(); // ✅ 소켓 연결
    print("✅ 소켓 연결됨");

    // ✅ Flask에서 'file_processed' 이벤트 수신
    socket!.on('file_processed', (data) {
      print('✅ YOLO 처리 완료! 데이터: $data');
    });

    socket!.onDisconnect((_) => print("❌ 소켓 연결 종료"));
  }

  void disconnectFromSocket() {
    socket?.disconnect();
  }
}
