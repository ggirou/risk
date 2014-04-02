library risk.game;

import 'dart:async';
import 'dart:math';

import 'event.dart';
import 'map.dart';

const PLAYERS_MIN = 2;
const PLAYERS_MAX = 6;
const START_ARMIES = const [0, 0, 40, 35, 30, 25, 20];

const TURN_STEP_REINFORCEMENT = 'REINFORCEMENT';
const TURN_STEP_ATTACK = 'ATTACK';
const TURN_STEP_FORTIFICATION = 'FORTIFICATION';

class RiskGame {
  Map<String, CountryState> countries = {};
  Map<int, PlayerState> players = {};
  List<int> playersOrder = [];
  int activePlayerId;

  bool started = false;
  bool setupPhase = false;
  String turnStep;

  RiskGame();
  RiskGame.fromHistory(List<EngineEvent> events) {
    events.forEach(update);
  }

  void update(EngineEvent event) {
    if (event is PlayerJoined) {
      players[event.playerId] = new PlayerState(event.name, event.avatar,
          event.color);
    } else if (event is GameStarted) {
      started = true;
      setupPhase = true;
      playersOrder = event.playersOrder;
      players.values.forEach((ps) => ps.reinforcement = event.armies);
    } else if (event is ArmyPlaced) {
      countries.putIfAbsent(event.country, () => new CountryState(event.country,
          playerId: event.playerId)).armies++;
      players[event.playerId].reinforcement--;
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
      players[event.playerId].reinforcement = event.reinforcement;
      turnStep = TURN_STEP_REINFORCEMENT;
    } else if (event is SetupEnded) {
      setupPhase = false;
    } else if (event is NextStep) {
      turnStep = turnStep == TURN_STEP_REINFORCEMENT ? TURN_STEP_ATTACK :
          TURN_STEP_FORTIFICATION;
    } else if (event is BattleEnded) {
      countries[event.attacker.country].armies = event.attacker.remainingArmies;
      countries[event.defender.country].armies = event.defender.remainingArmies;
      if(event.conquered) {
        countries[event.defender.country].playerId = event.attacker.playerId;
      }
    } else if (event is ArmyMoved) {
      countries[event.from].armies -= event.armies;
      countries[event.to].armies += event.armies;
    }
  }

  /// Returns the country ids owned by the [playerId].
  Set<String> playerCountries(int playerId) => countries.values.where((c) =>
      c.playerId == playerId).map((c) => c.countryId).toSet();
}

class CountryState {
  final String countryId;
  int playerId;
  int armies;
  CountryState(this.countryId, {this.playerId, this.armies: 0});
}

class PlayerState {
  final String name;
  final String avatar;
  final String color;
  int reinforcement;
  PlayerState(this.name, this.avatar, this.color, {this.reinforcement: 0});
}

/**
 * Computes attacker loss comparing rolled [attacks] and [defends] dices.
 */
int computeAttackerLoss(List<int> attacks, List<int> defends) {
  int result = 0;
  for (int i = 0; i < min(attacks.length, defends.length); i++) {
    if (attacks[i] <= defends[i]) result++;
  }
  return result;
}

/**
 * Computes reinforcement for a [playerId] int the [game].
 * Reinforcement = (Number of countries player owns) / 3 + (Continent bonus)
 * Continent bonus is added if player owns all the countries of a continent.
 * If reinforcement is less than three, round up to three.
 */
int computeReinforcement(RiskGame game, int playerId) {
  var playerCountries = game.playerCountries(playerId);
  var continents = CONTINENTS.where((c) => c.countries.every(
      playerCountries.contains));
  var bonus = continents.map((c) => c.bonus).fold(0, (a, b) => a + b);
  return max(3, playerCountries.length ~/ 3 + bonus);
}

/// Hazard of the game
class Hazard {
  final Random _random = new Random();

  /// Shuffles the [players] order
  List<int> giveOrders(Iterable<int> players) => players.toList()..shuffle(
      _random);

  /// Rolls [n] dices and returns the result in descending order
  List<int> rollDices(int n) => (new List<int>.generate(n, (_) =>
      _random.nextInt(6) + 1)..sort()).reversed.toList();
}

class RiskGameEngine {
  final RiskGame game;
  final EventSink<EngineEvent> outSink;
  final List<EngineEvent> history = [];

  final Hazard hazard;

  BattleEnded lastBattle;

  RiskGameEngine(this.outSink, this.game, {Hazard hazard}): hazard = hazard !=
      null ? hazard : new Hazard();

  void handle(PlayerEvent event) {
    if (event is JoinGame) {
      onJoinGame(event);
    } else if (event is StartGame) {
      onStartGame(event);
    } else if (event is PlaceArmy) {
      onPlaceArmy(event);
    } else if (event is Attack) {
      onAttack(event);
    } else if (event is EndAttack) {
      onEndAttack(event);
    } else if (event is MoveArmy) {
      onMove(event);
    } else if (event is EndTurn) {
      onEndTurn(event);
    }
  }

  void onJoinGame(JoinGame event) {
    if (game.players.containsKey(event.playerId)) return;

    _broadcast(new PlayerJoined()
        ..playerId = event.playerId
        ..name = event.name
        ..avatar = event.avatar
        ..color = event.color);

    if (game.players.length == PLAYERS_MAX) {
      sendGameStarted();
    }
  }

  void onStartGame(StartGame event) {
    if (event.playerId != game.players.keys.first) return;

    if (game.started) return;

    if (game.players.length >= PLAYERS_MIN) {
      sendGameStarted();
    }
  }

  void sendGameStarted() {
    _broadcast(new GameStarted()
        ..armies = START_ARMIES[game.players.length]
        ..playersOrder = hazard.giveOrders(game.players.keys));
    sendNextPlayer();
  }

  void onPlaceArmy(PlaceArmy event) {
    var playerId = event.playerId;

    // if another player try to play
    if (playerId != game.activePlayerId) return;

    // if player as not enough armies
    if (game.players[playerId].reinforcement == 0) return;

    // if country is owned by another player
    var countryState = game.countries[event.country];
    if (countryState != null && countryState.playerId != playerId) return;

    _broadcast(new ArmyPlaced()
        ..playerId = playerId
        ..country = event.country);

    if (game.setupPhase) {
      if(game.players.values.every((ps) => ps.reinforcement == 0)) {
        _broadcast(new SetupEnded());
      }
      sendNextPlayer();
    } else if (game.players[playerId].reinforcement == 0) {
      _broadcast(new NextStep());
    }
  }

  void onAttack(Attack event) {
    var playerId = event.playerId;

    // if another player try to play
    if (playerId != game.activePlayerId) return;

    // Attack country must be owned by the active player
    if (game.countries[event.from].playerId != playerId) return;

    var defenderId = game.countries[event.to].playerId;
    // Attacked country must be owned by another player
    if (defenderId == playerId) return;

    // Attacker must have enough armies in the from country
    if (game.countries[event.from].armies <= event.armies) return;
    
    // TODO: check maximum number of armies

    // The attacked country must be in the neighbourhood
    if (!COUNTRIES[event.from].neighbours.contains(event.to)) return;

    var attacker = new BattleOpponentResult()
        ..playerId = playerId
        ..dices = hazard.rollDices(event.armies)
        ..country = event.from;
    var defender = new BattleOpponentResult()
        ..playerId = defenderId
        ..dices = hazard.rollDices(min(2, game.countries[event.to].armies))
        ..country = event.to;

    var attackerLoss = computeAttackerLoss(attacker.dices, defender.dices);
    var defenderLoss = defender.dices.length - attackerLoss;

    attacker.remainingArmies = game.countries[attacker.country].armies -
        attackerLoss;
    defender.remainingArmies = game.countries[defender.country].armies -
        defenderLoss;

    lastBattle = new BattleEnded()
        ..attacker = attacker
        ..defender = defender
        ..conquered = defender.remainingArmies == 0
        ..minArmiesToMove = event.armies;

    _broadcast(lastBattle);
  }

  void onMove(MoveArmy event) {
    if (event.playerId != game.activePlayerId) return;

    // if the attacked country is owned by another player
    if (game.countries[event.to].playerId != event.playerId) return;

    // if the attacker has enough armies in the from country
    if (game.countries[event.from].armies - event.armies < 1) return;

    // if the attacked country is in the neighbourhood
    if (!COUNTRIES[event.from].neighbours.contains(event.to)) return;

    // if attack move, countries must be the same as attack
    if (game.turnStep == TURN_STEP_ATTACK && (event.from !=
        lastBattle.attacker.country || event.to != lastBattle.defender.country)) return;

    _broadcast(new ArmyMoved()
        ..playerId = event.playerId
        ..from = event.from
        ..to = event.to
        ..armies = event.armies);

    if (game.turnStep == TURN_STEP_FORTIFICATION) {
      // TODO: test
      sendNextPlayer();
    }
  }

  void onEndAttack(EndAttack event) {
    if (event.playerId != game.activePlayerId) return;

    // TODO: check current step
    
    _broadcast(new NextStep());
  }

  void onEndTurn(EndTurn event) {
    if (event.playerId != game.activePlayerId) return;

    sendNextPlayer();
  }

  void sendNextPlayer() {
    var orders = game.playersOrder;
    int nextPlayerIndex = game.activePlayerId == null ? 0 : orders.indexOf(
        game.activePlayerId) + 1;
    int nextPlayerId = orders[nextPlayerIndex % orders.length];
    int reinforcement = game.setupPhase ? game.players[nextPlayerId].reinforcement :
        // TODO: tests
    computeReinforcement(game, nextPlayerId);

    _broadcast(new NextPlayer()
        ..playerId = nextPlayerId
        ..reinforcement = reinforcement);
  }

  _broadcast(EngineEvent event) {
    game.update(event);
    history.add(event);
    if (outSink != null) {
      outSink.add(event);
    }
  }
}
