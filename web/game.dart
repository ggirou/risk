import 'dart:convert';
import 'dart:html';
import 'dart:js';
import 'dart:math';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/game.dart' hide RiskGame;
import 'package:risk/game.dart' as Game show RiskGame;
import 'package:risk/event.dart';
import 'package:risk/polymer_transformer.dart';

import 'board.dart';

const AUTO_SETUP = true;

class Move {
  String from, to;
  int maxArmies;
}

@CustomTag('risk-game')
class RiskGame extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  final game = new Game.RiskGame()
      ..countries = toObservable({})
      ..players = toObservable({});

  @observable
  bool canStart = false;

  @observable
  Move pendingMove; // {'from':from, 'to': to}

  @observable
  int armiesToMove = 1;

  @observable
  String mode;

  final asInteger = new StringToInt();

  final WebSocket ws;

  @observable
  int playerId;

  RiskGame.created(): this.fromUri(_currentWebSocketUri());

  RiskGame.fromUri(Uri wsUri): this.fromWebSocket(new WebSocket(wsUri.toString()
      ));

  RiskGame.fromWebSocket(this.ws): super.created() {
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
          ..name = _ask("What's your name?"));
    } else if (event is PlayerJoined) {
      canStart = game.players.length >= 2 && game.players.keys.first ==
          playerId;
    } else if (event is GameStarted) {
      canStart = false;
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

    updateMode();

    super.notifyPropertyChange(#game, null, game);
    // can we do someting else ?
    ($['board'] as RiskBoard).redraw();
  }

  updateMode() {
    if (!game.started || game.activePlayerId != playerId) {
      mode = null;
    } else if (game.setupPhase) {
      mode = MODE_SELECT;
    } else if (game.turnStep == TURN_STEP_REINFORCEMENT) {
      mode = MODE_SELECT;
    } else if (game.turnStep == TURN_STEP_ATTACK) {
      mode = MODE_ATTACK;
    } else if (game.turnStep == TURN_STEP_REINFORCEMENT) {
      mode = MODE_MOVE;
    }
  }

  attack(CustomEvent e, var detail, Element target) {
    mode = null;
    sendEvent(new Attack()
        ..playerId = playerId
        ..from = e.detail['from']
        ..to = e.detail['to']
        ..armies = min(3, game.countries[e.detail['from']].armies - 1));
  }

  move(CustomEvent e, var detail, Element target) {
    mode = null;
    pendingMove = new Move()
        ..from = e.detail['from']
        ..to = e.detail['to']
        ..maxArmies = game.countries[e.detail['from']].armies - 1;
    armiesToMove = pendingMove.maxArmies;
  }

  selection(CustomEvent e, var detail, Element target) {
    mode = null;
    sendEvent(new PlaceArmy()
        ..playerId = playerId
        ..country = e.detail);
  }

  moveArmies() {
    mode = null;
    sendEvent(new MoveArmy()
        ..playerId = playerId
        ..from = pendingMove.from
        ..to = pendingMove.to
        ..armies = armiesToMove);
  }

  String _ask(String question) => context.callMethod('prompt', [question]);

  sendEvent(PlayerEvent event) => ws.send(_printEvent('OUT')(JSON.encode(
      EVENT.encode(event))));
}

Uri _currentWebSocketUri() {
  var uri = Uri.parse(window.location.toString());
  return new Uri(scheme: "ws", host: uri.host, port: uri.port, path: "/ws");
}

_printEvent(direction) => (event) {
  print("$direction - $event");
  return event;
};
