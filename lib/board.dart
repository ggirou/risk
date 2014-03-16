library risk.board;

class Board {
  final Map<String, CountryState> countries = {};
  final List<PlayerState> players = [];
}

class CountryState {
  final int playerId;
  int armies;
  CountryState(this.playerId, this.armies);

  bool operator ==(other) => other is CountryState && playerId == other.playerId
      && armies == other.armies;
  int get hashCode => playerId.hashCode ^ armies.hashCode;
}

class PlayerState {
  int reinforcementArmies;
  PlayerState(this.reinforcementArmies);

  bool operator ==(other) => other is PlayerState && reinforcementArmies ==
      other.reinforcementArmies;
  int get hashCode => reinforcementArmies.hashCode;
}

class BoardEventHandler {
  final Board board;
  BoardEventHandler(this.board);

  handle(Map event) {
    switch (event["event"]) {
      case "ArmyPlaced":
        armyPlaced(event["data"]);
        break;
    }
  }

  armyPlaced(Map data) {
    var playerId = data["playerId"];
    var playerState = board.players[playerId];
    if (playerState.reinforcementArmies > 0) {
      var countryState = board.countries.putIfAbsent(data["country"], () =>
          new CountryState(playerId, 0));
      if (countryState.playerId == playerId) {
        playerState.reinforcementArmies--;
        countryState.armies++;
      }
    }
  }
}
