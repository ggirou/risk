library risk.game;

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

class RiskGameEngine {
  final RiskGame game;
  RiskGameEngine(this.game);

  handle(Map event) {
    switch (event["event"]) {
      case "ArmyPlaced":
        armyPlaced(event["data"]);
        break;
    }
  }

  armyPlaced(Map data) {
    var playerId = data["playerId"];
    var playerState = game.players[playerId];
    if (playerState.reinforcement > 0) {
      var countryState = game.countries.putIfAbsent(data["country"], () =>
          new CountryState(playerId, 0));
      if (countryState.playerId == playerId) {
        playerState.reinforcement--;
        countryState.armies++;
      }
    }
  }
}
