import 'dart:convert';
import 'dart:html';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/game.dart' as Game;
import 'package:risk/event.dart';

@CustomTag('risk-game')
class RiskGame extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  var gameEngine = new Game.RiskGameEngine(null, game: new Game.RiskGame()
      ..countries = toObservable({})
      ..players = toObservable({}));

  final WebSocket ws;

  int playerId;

  RiskGame.created(): this.fromUri(_currentWebSocketUri());

  RiskGame.fromUri(Uri wsUri): this.fromWebSocket(new WebSocket(wsUri.toString()
      ));

  RiskGame.fromWebSocket(this.ws): super.created() {
    var eventStream = ws.onMessage.map((e) => e.data).map(JSON.decode).map(
        _printEvent("IN")).map(EVENT.decode).listen(handleEvents);
  }

  handleEvents(event) {
    gameEngine.handle(event);

    if (event is Welcome) {
      playerId = event.playerId;
      // TODO Show enrollement popup
    }
        /*else if(event is Attack) {
      // TODO Show enrollement popup
    } */else {
      // TODO: Close all popup
    }
  }

  sendEvent(event) => ws.send(JSON.encode(EVENT.encode(event)));

  onArmyPlaced(Event e, detail, target) => sendEvent(new ArmyPlaced()
      ..playerId = playerId
      ..country = target);
}

Uri _currentWebSocketUri() {
  var uri = Uri.parse(window.location.toString());
  return new Uri(scheme: "ws", host: uri.host, port: uri.port, path: "/ws");
}

_printEvent(direction) => (event) {
  print("$direction - $event");
  return event;
};
