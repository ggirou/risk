library risk.game;

import 'dart:async';
import 'dart:math';
import 'event.dart';

class RiskGamePlayer {
  final RiskGame game;
  int playerId;
  EventSink engineSink;

  String step = 'startPending';
  Attack _myAttack;

  RiskGamePlayer(this.game, Stream stream, this.engineSink) {
    stream.listen(handle);
  }

  PlayerState get myState => game.players[playerId];

  void handle(event) {
    game.handle(event);

    if (event is Welcome) {
      // nothing
    } else if (event is JoinGame) {
      // nothing
    } else if (event is StartGame) {
      // nothing
    } else if (event is GameStarted) {
      step = 'started';
    } else if (event is ArmyPlaced) {
      if (step == 'started' && myState.reinforcement == 0) {
        step == 'waiting';
      }
      if (step == 'reinforcement' && myState.reinforcement == 0) {
        step = 'attack';
      }
    } else if (event is NextPlayer) {
      if (event.playerId == playerId) {
        step = 'reinforcement';
      }
    } else if (event is Attack) {
      if (game.countries[event.from].playerId == playerId) {
        _myAttack = event;
        step == 'waiting-defense';
      }
      if (game.countries[event.to].playerId == playerId) {
        step = 'defend';
      }
    } else if (event is Defend) {
      // nothing
    } else if (event is BattleEnded) {
      if (step == 'attack') {
        if (game.countries[_myAttack.to].playerId == playerId) {
          step = 'battleMove';
          if (game.countries[_myAttack.from].armies == 2) {
            moveArmies(_myAttack.from, _myAttack.to, 1);
          }
        } else {
          step = 'attack';
          _myAttack = null;
        }
      }
    } else if (event is Move) {
      if (event.playerId == playerId) {
        if (step == 'battleMove') {
          _myAttack = null;
          step == 'attack';
        } else if (step == 'fortification') {
          endTurn();
        }
      }
    } else if (event is EndAttack) {
      if (event.playerId == playerId) {
        step == 'fortification';
      }
    } else if (event is EndTurn) {
      if (event.playerId == playerId) {
        step = 'waiting';
      }
    } else if (event is LeaveGame) {
      // TODO WAT ?
    }
  }

  void moveArmies(String from, String to, int armies) => engineSink.add(
      new Move()
      ..playerId = playerId
      ..from = from
      ..to = to
      ..armies = armies);

  void placeArmy(String country) => engineSink.add(new ArmyPlaced()
      ..playerId = playerId
      ..country = country);

  void attack(String from, String to) => engineSink.add(new Attack()
      ..playerId = playerId
      ..from = from
      ..to = to
      ..armies = min(3, game.countries[from].armies));

  void defend() => engineSink.add(new Defend()
      ..playerId = playerId
      ..armies = min(2, game.countries[game.lastAttack.to].armies));

  void endAttack() => engineSink.add(new EndAttack()..playerId = playerId);

  void endTurn() => engineSink.add(new EndTurn()..playerId = playerId);
}


class RiskGame {
  Map<String, CountryState> countries = {};
  Map<int, PlayerState> players = {};
  List<int> playersOrder;
  int activePlayerId;

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
      players.values.forEach((ps) => ps.reinforcement += event.armies);
    } else if (event is ArmyPlaced) {
      countries.putIfAbsent(event.country, () => new CountryState(
          event.playerId, 0)).armies++;
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
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

Random random = new Random();

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
    avoidCheaters(event) => event is PlayerEvent && event.playerId == playerId;
    stream.where(avoidCheaters).listen(handle);
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
      rollDices(n) => new List<int>.generate(n, (_) => random.nextInt(6) + 1);
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
