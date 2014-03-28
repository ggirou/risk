library risk.game;

import 'dart:async';
import 'dart:math';

import 'event.dart';
import 'map.dart';

const PLAYERS_MIN = 2;
const PLAYERS_MAX = 6;
const START_ARMIES = const [0, 0, 40, 35, 30, 25, 20];

class RiskGame {
  Map<String, CountryState> countries = {};
  Map<int, PlayerState> players = {};
  List<int> playersOrder;
  int activePlayerId;

  Attack lastAttack;

  String step;

  RiskGame();
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

int computeLostByAttacker(List<int> attacks, List<int> defends) {
  int result = 0;
  for (int i = 0; i < defends.length; i++) {
    if (attacks[i] <= defends[i]) result++;
  }
  return result;
}

class RiskGameEngine {
  final RiskGame game;
  final EventSink outSink;

  RiskGameEngine.client({RiskGame game})
      : this.outSink = null,
        this.game = game != null ? game : new RiskGame();
  RiskGameEngine.server(this.outSink): this.game = new RiskGame();

  void handle(event) {
    if (event is Welcome) {
      // nothing
    } else if (event is JoinGame) {
      onJoinGame(event);
    } else if (event is StartGame) {
      onStartGame(event);
    } else if (event is GameStarted) {
      onGameStarted(event);
    } else if (event is ArmyPlaced) {
      onArmyPlaced(event);
    } else if (event is NextPlayer) {
      onNextPlayer(event);
    } else if (event is Attack) {
      onAttack(event);
    } else if (event is Defend) {
      onDefend(event);
    } else if (event is BattleEnded) {
      onBattleEnded(event);
    } else if (event is EndAttack) {
      onEndAttack(event);
    } else if (event is Move) {
      onMove(event);
    } else if (event is EndTurn) {
      onEndTurn(event);
    } else if (event is LeaveGame) {
      onLeaveGame(event);
    }
  }

  void onJoinGame(JoinGame event) {
    game.players.putIfAbsent(event.playerId, () => new PlayerState(event.name,
        event.avatar, reinforcement: 0));
    if (game.players.length == PLAYERS_MAX) {
      sendGameStarted();
    }
  }

  void onStartGame(StartGame event) {
    if (event.playerId != game.players.keys.first) return;

    if (game.players.length >= PLAYERS_MIN) {
      sendGameStarted();
    }
  }

  void onGameStarted(GameStarted event) {
    game.playersOrder = event.playersOrder;
  }

  void onArmyPlaced(ArmyPlaced event) {
    if (game.activePlayerId != null && event.playerId != game.activePlayerId)
        return;

    var playerId = event.playerId;
    var playerState = game.players[playerId];
    if (playerState.reinforcement > 0) {
      var countryState = game.countries.putIfAbsent(event.country, () =>
          new CountryState(playerId, 0));
      if (countryState.playerId == playerId) {
        playerState.reinforcement--;
        countryState.armies++;
      }
    }
    if (game.activePlayerId == null && game.players.values.every((ps) =>
        ps.reinforcement == 0)) {
      sendNextPlayer(game.playersOrder.first);
    }
  }

  void onNextPlayer(NextPlayer event) {
    game.activePlayerId = event.playerId;
    game.players[event.playerId].reinforcement = event.reinforcement;
  }

  void onAttack(Attack event) {
    if (event.playerId != game.activePlayerId) return;

    // if the attacked country is owned by another player
    if (game.countries[event.to].playerId == event.playerId) return;

    // if the attacker has enough armies in the from country
    if (game.countries[event.from].armies < 2) return;

    // if the attacked country is in the neighbourhood
    if (!Country.findById(event.from).neighbours.contains(Country.findById(
        event.to))) return;

    // valid attack
    game.lastAttack = event;
  }

  void onDefend(Defend event) {
    if (event.playerId != game.countries[game.lastAttack.to].playerId) return;

    rollDices(n) => (new List<int>.generate(n, (_) => random.nextInt(6) + 1
        )..sort()).reversed.toList();
    final attacks = rollDices(game.lastAttack.armies);
    final defends = rollDices(event.armies);
    final lostByAttacker = computeLostByAttacker(attacks, defends);
    final lostByDefender = defends.length - lostByAttacker;
    _broadcast(new BattleEnded()
        ..attackDices = attacks
        ..defendDices = defends
        ..lostByAttacker = lostByAttacker
        ..lostByDefender = lostByDefender);
  }

  void onBattleEnded(BattleEnded event) {
    final from = game.countries[game.lastAttack.from];
    final to = game.countries[game.lastAttack.to];
    from.armies -= event.lostByAttacker;
    to.armies -= event.lostByDefender;
    if (to.armies == 0) {
      to.playerId = game.lastAttack.playerId;
      if (from.armies == 2) {
        _broadcast(new Move()
            ..playerId = game.lastAttack.playerId
            ..from = from
            ..to = to
            ..armies = 1);
      }
    }
  }

  void onMove(Move event) {
    if (event.playerId != game.activePlayerId) return;

    // if the attacked country is owned by another player
    if (game.countries[event.to].playerId != event.playerId) return;

    // if the attacker has enough armies in the from country
    if (game.countries[event.from].armies - event.armies < 1) return;

    // if the attacked country is in the neighbourhood
    if (!Country.findById(event.from).neighbours.contains(Country.findById(
        event.to))) return;

    // if attack move, countries must be the same as attack
    if (game.step == null && (event.from != game.lastAttack.from || event.to !=
        game.lastAttack.to)) return;

    game.lastAttack = null;

    game.countries[event.from].armies -= event.armies;
    game.countries[event.to].armies += event.armies;

    if (game.step == 'fortification') {
      game.step = null;
      _broadcast(new EndTurn()..playerId = event.playerId);
    }
  }

  void onEndAttack(EndAttack event) {
    if (event.playerId != game.activePlayerId) return;

    game.step = 'fortification';
  }

  void onEndTurn(EndTurn event) {
    if (event.playerId != game.activePlayerId) return;

    final l = game.playersOrder;
    final index = l.indexOf(game.activePlayerId);
    final nextIndex = (index + 1) % l.length;
    final nextActivePlayer = l[nextIndex];
    sendNextPlayer(nextActivePlayer);
  }

  void onLeaveGame(LeaveGame event) {
  }

  void sendGameStarted() {
    _broadcast(new GameStarted()
        ..armies = START_ARMIES[game.players.length]
        ..playersOrder = (game.players.keys.toList()..shuffle(random)));
  }

  void sendNextPlayer(nextPlayerId) {
    //TODO compute reinforcement
    int reinforcement = 3;
    _broadcast(new NextPlayer()
        ..playerId = nextPlayerId
        ..reinforcement = reinforcement);
  }

  _broadcast(event) {
    if (outSink == null) return;
    outSink.add(event);
    handle(event);
  }
}
