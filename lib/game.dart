library risk.game;

import 'dart:async';
import 'event.dart';

class RiskGame implements EventSink {
  Map<String, CountryState> countries = {};
  Map<int, PlayerState> players = {};
  List<int> playersOrder;
  int activePlayerId;

  Attack _lastAttack;

  RiskGame();

  @override
  void add(event) {
    if (event is Welcome) {
      // nothing
    } else if (event is JoinGame) {
      players.putIfAbsent(event.playerId, () => new PlayerState(event.name,
          event.avatar, reinforcement: 0));
    } else if (event is StartGame) {
      // nothing
    } else if (event is GameStarted) {
      playersOrder = event.playersOrder;
    } else if (event is ArmyPlaced) {
      countries.putIfAbsent(event.country, () => new CountryState(
          event.playerId, 0)).armies++;
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
      players[event.playerId].reinforcement = event.reinforcement;
    } else if (event is Attack) {
      _lastAttack = event;
    } else if (event is Defend) {
      // nothing
    } else if (event is BattleEnded) {
      countries[_lastAttack.from].armies -= event.lostByAttacker;
      final to = countries[_lastAttack.to];
      to.armies -= event.lostByDefender;
      if (to.armies == 0) {
        to.playerId = _lastAttack.playerId;
      }
      _lastAttack = null;
    } else if (event is EndAttack) {
      // nothing
    } else if (event is Move) {
      countries[event.from].armies -= event.armies;
      countries[event.to].armies += event.armies;
    } else if (event is EndTurn) {
      // nothing
    } else if (event is LeaveGame) {
      // nothing
    }
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {}

  @override
  void close() {}
}

class CountryState {
  final int playerId;
  int armies;
  CountryState(this.playerId, this.armies);
}

class PlayerState {
  final String name;
  final String avatar;
  int reinforcement;
  PlayerState(this.name, this.avatar, {this.reinforcement: 0});
}

typedef EventHandler(event);

class RiskGameEngine {
  final RiskGame game;
  RiskGameEngine(this.game);

  handle(event) {
    if (event is ArmyPlaced) {
      return armyPlaced(event);
    } else {
      return null;
    }
  }

  armyPlaced(ArmyPlaced event) {
    var playerId = event.playerId;
    var playerState = game.players[playerId];
    if (playerState.reinforcement > 0) {
      var countryState = game.countries.putIfAbsent(event.country, () =>
          new CountryState(playerId, 0));
      if (countryState.playerId == playerId) {
        playerState.reinforcement--;
        countryState.armies++;
        return event;
      }
    }
  }
}
