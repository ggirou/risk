import 'dart:html';
  

main(){
  print("Run");
  final url = "ws://127.0.0.1:8080/ws";
  final ws = new WebSocket(url);
  ws.onMessage.listen((MessageEvent e) => print("Receive=${e.data}"));
}