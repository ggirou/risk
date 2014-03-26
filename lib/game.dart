library risk.game;

import 'dart:async';
import 'dart:math';
import 'event.dart';

class RiskGamePlayer {
  final RiskGame game;
  int playerId;
  EventSink sink;

  RiskGamePlayer(this.game, Stream stream, this.sink) {
    stream.listen(game.handle);
  }

  void placeArmy(String country) => sink.add(new ArmyPlaced()
      ..playerId = playerId
      ..country = country);

  void attack(String from, String to) => sink.add(new Attack()
      ..playerId = playerId
      ..from = from
      ..to = to
      ..armies = min(3, game.countries[from].armies));

  void defend() => sink.add(new Defend()
      ..playerId = playerId
      ..armies = min(2, game.countries[game.lastAttack.to].armies));

  void endAttack() => sink.add(new EndAttack()..playerId = playerId);

  void endTurn() => sink.add(new EndTurn()..playerId = playerId);
}

class Step {
  static final Step REINFORCEMENT = new Step('reinforcement');
  static final Step ATTACK = new Step('attack');
  static final Step FORTIFICATION = new Step('fortification');

  final String code;
  const Step(this.code);
}

class RiskGame {
  Map<String, CountryState> countries = {};
  Map<int, PlayerState> players = {};
  List<int> playersOrder;
  int activePlayerId;
  Step currentStep;

  Attack lastAttack;

  RiskGame();

  void handle(event) {
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
      if (players[event.playerId].reinforcement == 0) {
        currentStep = Step.ATTACK;
      }
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
      currentStep = Step.REINFORCEMENT;
      players[event.playerId].reinforcement = event.reinforcement;
    } else if (event is Attack) {
      lastAttack = event;
    } else if (event is Defend) {
      // nothing
    } else if (event is BattleEnded) {
      countries[lastAttack.from].armies -= event.lostByAttacker;
      final to = countries[lastAttack.to];
      to.armies -= event.lostByDefender;
      if (to.armies == 0) {
        to.playerId = lastAttack.playerId;
      }
      lastAttack = null;
    } else if (event is Move) {
      countries[event.from].armies -= event.armies;
      countries[event.to].armies += event.armies;
    } else if (event is EndAttack) {
      // nothing
    } else if (event is EndTurn) {
      // nothing
    } else if (event is LeaveGame) {
      // nothing
    }
  }
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

final _RANDOM = new Random();


class RiskGameEngine {
  final RiskGame game;
  final Map<int, EventSink> _sinkByPlayer = {};
  final List _eventsHistory;

  RiskGameEngine(this.game): _eventsHistory = [];
  RiskGameEngine.withEventsHistory(this.game, List events): _eventsHistory =
      events == null ? [] : events;

  void addPlayer(Stream stream, EventSink sink) {
    final playerId = generatePlayerId();
    _sinkByPlayer[playerId] = sink;

    // send a welcome event with the player id
    sink.add(new Welcome()..playerId = playerId);

    // broadcast all events history to player
    _eventsHistory.forEach(sink.add);

    // handle stream
    stream.listen(handle);
  }

  void handle(event) {
    game.handle(event);

    if (event is Welcome) {
      // nothing
    } else if (event is JoinGame) {
      // nothing
    } else if (event is StartGame) {
      _broadcast(new GameStarted()
          ..armies = [0, 0, 40, 35, 30, 25, 20][game.players.length]
          ..playersOrder = (game.players.keys.toList()..shuffle()));
    } else if (event is GameStarted) {
      // nothing
    } else if (event is ArmyPlaced) {
      if (game.activePlayerId == null && game.players.values.every((ps) =>
          ps.reinforcement == 0)) {
        //TODO compute reinforcement
        int reinforcement = 3;
        _broadcast(new NextPlayer()
            ..playerId = game.playersOrder.first
            ..reinforcement = reinforcement);
      }
    } else if (event is NextPlayer) {
      // nothing
    } else if (event is Attack) {
      // nothing
    } else if (event is Defend) {
      rollDices(n) => new List<int>.generate(n, _RANDOM.nextInt(6) + 1);
      _broadcast(new BattleEnded()
          ..attackDices = rollDices(game.lastAttack.armies)
          ..defendDices = rollDices(event.armies));
    } else if (event is BattleEnded) {
      // nothing
    } else if (event is Move) {
      // nothing
    } else if (event is EndAttack) {
      // nothing
    } else if (event is EndTurn) {
      final l = game.playersOrder;
      final index = l.indexOf(game.activePlayerId);
      final nextIndex = (index + 1) % l.length;
      final nextActivePlayer = l[nextIndex];
      //TODO compute reinforcement
      int reinforcement = 3;
      _broadcast(new NextPlayer()
          ..playerId = nextActivePlayer
          ..reinforcement = reinforcement);
    } else if (event is LeaveGame) {
      // TODO WAT ?
    }
  }

  void _broadcast(event) {
    game.handle(event);
    _sinkByPlayer.values.forEach((sink) => sink.add(event));
  }
}

int generatePlayerId() => new DateTime.now().millisecondsSinceEpoch;
