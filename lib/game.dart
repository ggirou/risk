library risk.game;

import 'event.dart';

class RiskGame {
  final Map<String, CountryState> countries;
  final List<PlayerState> players;
  int currentPlayerId;

  RiskGame({countries: const {}, players: const []})
      : countries = {}..addAll(countries),
        players = []..addAll(players);
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

typedef EventHandler(Event event);

class RiskGameEngine {
  final RiskGame game;
  RiskGameEngine(this.game);

  Event handle(Event event) {
    switch (event.runtimeType) {
      case ArmyPlaced:
        return armyPlaced(event);
      default:
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
