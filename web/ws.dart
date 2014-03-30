import 'dart:convert';
import 'dart:html';
import 'package:risk/game.dart';
import 'package:risk/event.dart';

final playerEvents = {
  "JoinGame": (playerId) => new JoinGame()
    ..playerId = playerId
    ..name = "John Lennon"
    ..avatar = "kadhafi.png",
  "LeaveGame": (playerId) => new LeaveGame()..playerId = playerId,
  "ArmyPlaced": (playerId) => new ArmyPlaced()
      ..playerId = playerId
      ..country = "eastern_australia",
};

Element logs = querySelector("#logs");
InputElement sendButton = querySelector("#sendButton");
TextAreaElement eventInput = querySelector("#eventInput");
SelectElement eventTemplate = querySelector("#eventTemplate");

const url = "ws://127.0.0.1:8080/ws";
final ws = new WebSocket(url);
final game = new RiskGameEngine.client();
int playerId;

main() {
  eventTemplate.children.addAll(playerEvents.keys.map((e)=> new OptionElement(data: e, value: e)));
  eventTemplate.onChange.listen(templateChanged);

  sendButton.onClick.listen((_) => ws.send(eventInput.value));

  var eventStream = ws.onMessage.map((e) => e.data).map(JSON.decode).map(
      printEvent).map(EVENT.decode).listen(handleEvents);
}

printEvent(event) {
  logs.children.add(new LIElement()..text = "$event");
  return event;
}

handleEvents(event) {
  if (event is Welcome) {
    playerId = event.playerId;
  }
}

templateChanged(_) {
  var event = playerEvents[eventTemplate.value];
  eventInput.text = event == null ? "" : JSON.encode(EVENT.encode(event(playerId)));
}