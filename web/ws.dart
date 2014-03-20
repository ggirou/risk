import 'dart:html';
  
Element logs = querySelector("#logs");
InputElement sendButton = querySelector("#sendButton");
TextAreaElement eventInput = querySelector("#eventInput");

const url = "ws://127.0.0.1:8080/ws";
final ws = new WebSocket(url);

main(){
  ws.onMessage.listen(printEvent);
  sendButton.onClick.listen((_) => ws.send(eventInput.value));
}

printEvent(MessageEvent event) {
  logs.children.add(new LIElement()..text = event.data);
}