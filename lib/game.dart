library risk.game;

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
      players[event.playerId] = new PlayerState(event.playerId, event.name,
          event.avatar, event.color);
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
      if (event.conquered) {
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

// TODO: comments
class CountryState {
  final String countryId;
  int playerId;
  int armies;
  CountryState(this.countryId, {this.playerId, this.armies: 0});
}

// TODO: comments
class PlayerState {
  final int playerId;
  final String name;
  final String avatar;
  final String color;
  int reinforcement;

  PlayerState(this.playerId, this.name, this.avatar, this.color,
      {this.reinforcement: 0});
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
