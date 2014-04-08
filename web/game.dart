import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';
import 'dart:math';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/game.dart' as Game;
import 'package:risk/event.dart';
import 'package:risk/polymer_transformer.dart';

const AUTO_SETUP = false;

// grabbed on http://i.stack.imgur.com/VewLV.png (http://gamedev.stackexchange.com/questions/46463/is-there-an-optimum-set-of-colors-for-10-players)
final COLORS = ['#FF8080', '#78BEF0', '#DED16F', '#CC66C9', '#5DBAAC',
    '#F2A279', '#7182E3', '#92D169', '#BF607C', '#7CDDF7'];
final AVATARS = ['ahmadi-nejad.png', 'bachar-el-assad.png', 'caesar.png',
    'castro.png', 'hitler.png', 'kadhafi.png', 'kim-jong-il.png', 'mao-zedong.png',
    'mussolini.png', 'napoleon.png', 'pinochet.png', 'saddam-hussein.png',
    'staline.png'];

class Move {
  String from, to;
  int maxArmies;
}

@CustomTag('risk-game')
class RiskGame extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @observable
  Game.RiskGame game = new Game.RiskGame();

  @observable
  int playerId;

  @observable
  Move pendingMove; // {'from':from, 'to': to}

  @observable
  int armiesToMove = 1;

  final asInteger = new StringToInt();

  final WebSocket ws;

  RiskGame.created(): this.fromWebSocket(new WebSocket(_currentWebSocketUri(
      ).toString())); // , snapshot: SNAPSHOT_GAME_ATTACK);

  RiskGame.fromWebSocket(this.ws, {Iterable<EngineEvent> snapshot: const []}):
      super.created() {
    new Stream.fromIterable(snapshot).listen(handleEvents);
    var eventStream = ws.onMessage.map((e) => e.data).map(JSON.decode).map(
        _printEvent("IN")).map(EVENT.decode).listen(handleEvents);
  }

  startGame(Event e, var detail, Element target) => sendEvent(new StartGame(
      )..playerId = playerId);

  handleEvents(EngineEvent event) {
    game.update(event);

    if (event is Welcome) {
      playerId = event.playerId;
      // TODO Show enrollement popup
      sendEvent(new JoinGame()
          ..playerId = playerId
          ..color = COLORS[playerId % COLORS.length]
          ..avatar = AVATARS[playerId % AVATARS.length]
          ..name = _ask("What's your name?"));
    } else if (event is BattleEnded) {
      if (event.attacker.playerId == playerId) {
        if (event.defender.remainingArmies == 0) {
          if (event.attacker.remainingArmies == 2) {
            sendEvent(new MoveArmy()
                ..playerId = playerId
                ..from = event.attacker.country
                ..to = event.defender.country
                ..armies = 1);
          } else {
            pendingMove = new Move()
                ..from = event.attacker.country
                ..to = event.defender.country
                ..maxArmies = event.attacker.remainingArmies - 1;
            armiesToMove = pendingMove.maxArmies;
          }
        }
      }
    } else if (event is ArmyMoved) {
      pendingMove = null;
    } else if (event is NextPlayer) {
      if (AUTO_SETUP && game.setupPhase && event.playerId == playerId) {
        sendEvent(new PlaceArmy()
            ..playerId = playerId
            ..country = (game.countries.values.where((cs) => cs.playerId ==
                playerId).map((cs) => cs.countryId).toList()..shuffle()).first);
      }
    }
  }

  attack(CustomEvent e, var detail, Element target) => sendEvent(new Attack()
      ..playerId = playerId
      ..from = e.detail['from']
      ..to = e.detail['to']
      ..armies = min(3, game.countries[e.detail['from']].armies - 1));

  move(CustomEvent e, var detail, Element target) {
    pendingMove = new Move()
        ..from = e.detail['from']
        ..to = e.detail['to']
        ..maxArmies = game.countries[e.detail['from']].armies - 1;
    armiesToMove = pendingMove.maxArmies;
  }

  selection(CustomEvent e, var detail, Element target) => sendEvent(
      new PlaceArmy()
      ..playerId = playerId
      ..country = e.detail);

  moveArmies() => sendEvent(new MoveArmy()
      ..playerId = playerId
      ..from = pendingMove.from
      ..to = pendingMove.to
      ..armies = armiesToMove);

  endAttack() => sendEvent(new EndAttack()..playerId = playerId);

  endTurn() => sendEvent(new EndTurn()..playerId = playerId);

  String _ask(String question) => context.callMethod('prompt', [question]);

  sendEvent(PlayerEvent event) => ws.send(_printEvent('OUT')(JSON.encode(
      EVENT.encode(event))));
}

Uri _currentWebSocketUri() {
  var uri = Uri.parse(window.location.toString());
  return new Uri(scheme: "ws", host: uri.host, port: uri.port, path: "/ws");
  //  return new Uri(scheme: "ws", host: "localhost", port: 8080, path: "/ws");
}

_printEvent(direction) => (event) {
  print("$direction - $event");
  return event;
};
