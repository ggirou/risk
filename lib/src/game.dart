part of risk;

/**
 * Stores the Risk game state.
 */
abstract class RiskGameState {
  static const PLAYERS_MIN = 2;
  static const PLAYERS_MAX = 6;
  static const START_ARMIES = const [0, 0, 40, 35, 30, 25, 20];
  static const TURN_STEP_REINFORCEMENT = 'REINFORCEMENT';
  static const TURN_STEP_ATTACK = 'ATTACK';
  static const TURN_STEP_FORTIFICATION = 'FORTIFICATION';

  /// Returns all possible countryIds
  List<String> get allCountryIds;

  /// Returns the countryId / country state map.
  Map<String, CountryState> get countries;
  /// Returns the playerId / player state map.
  Map<int, PlayerState> get players;
  /// Returns the players order.
  List<int> get playersOrder;
  /// Returns the player who is playing.
  int get activePlayerId;

  /// True if the game is started.
  bool get started;
  /// True if the game is setuping player countries.
  bool get setupPhase;
  /// Return the turn step of the active player (REINFORCEMENT, ATTACK, FORTIFICATION).
  String get turnStep;

  /**
   * Updates this Risk game state for the incoming [event].
   */
  void update(EngineEvent event);

  /**
   * Computes attacker loss comparing rolled [attacks] and [defends] dices.
   */
  int computeAttackerLoss(List<int> attacks, List<int> defends);

  /**
   * Computes reinforcement for a [playerId] in this game.
   * Reinforcement = (Number of countries player owns) / 3 + (Continent bonus)
   * Continent bonus is added if player owns all the countries of a continent.
   * If reinforcement is less than three, round up to three.
   */
  int computeReinforcement(int playerId);

  /**
   * Returns neighbours ids for the given [countryId].
   */
  List<String> countryNeighbours(String countryId);
}

/**
 * Stores the state of a country.
 */
abstract class CountryState {
  /// The countryId for this CountryState.
  String get countryId;
  /// The playerId who owns this country.
  int get playerId;
  /// The number of armies in this country.
  int get armies;
}

/**
 * Stores the state of a player.
 */
abstract class PlayerState {
  /// The playerId for this CountryState.
  int get playerId;
  /// The player's name.
  String get name;
  /// The player's avatar.
  String get avatar;
  /// The player's color.
  String get color;
  /// The number of available armies for the player.
  int get reinforcement;
}

class RiskGameStateImpl extends RiskGameState with Observable {
  @observable
  Map<String, CountryStateImpl> countries = toObservable({}, deep: true);
  @observable
  Map<int, PlayerStateImpl> players = toObservable({}, deep: true);
  @observable
  List<int> playersOrder = [];
  @observable
  int activePlayerId;

  @observable
  bool started = false;
  @observable
  bool setupPhase = false;
  @observable
  String turnStep;

  void update(EngineEvent event) {
    if (event is PlayerJoined) {
      players[event.playerId] = new PlayerStateImpl(event.playerId, event.name,
          event.avatar, event.color);
      // Workaround before https://codereview.chromium.org/213743012/
      notifyPropertyChange(#players, {}, players);
    } else if (event is GameStarted) {
      started = true;
      setupPhase = true;
      playersOrder = event.playersOrder;
      players.values.forEach((ps) => ps.reinforcement = event.armies);
    } else if (event is ArmyPlaced) {
      countries.putIfAbsent(event.country, () => new CountryStateImpl(
          event.country, playerId: event.playerId)).armies++;
      players[event.playerId].reinforcement--;
      // Workaround before https://codereview.chromium.org/213743012/
      notifyPropertyChange(#countries, {}, countries);
    } else if (event is NextPlayer) {
      activePlayerId = event.playerId;
      players[event.playerId].reinforcement = event.reinforcement;
      turnStep = RiskGameState.TURN_STEP_REINFORCEMENT;
    } else if (event is SetupEnded) {
      setupPhase = false;
    } else if (event is NextStep) {
      turnStep = turnStep == RiskGameState.TURN_STEP_REINFORCEMENT ?
          RiskGameState.TURN_STEP_ATTACK : RiskGameState.TURN_STEP_FORTIFICATION;
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

  Set<String> playerCountries(int playerId) => countries.values.where((c) =>
      c.playerId == playerId).map((c) => c.countryId).toSet();

  int computeAttackerLoss(List<int> attacks, List<int> defends) {
    int result = 0;
    for (int i = 0; i < min(attacks.length, defends.length); i++) {
      if (attacks[i] <= defends[i]) result++;
    }
    return result;
  }

  int computeReinforcement(int playerId) {
    var playerCountries = this.playerCountries(playerId);
    var continents = CONTINENTS.where((c) => c.countries.every(
        playerCountries.contains));
    var bonus = continents.map((c) => c.bonus).fold(0, (a, b) => a + b);
    return max(3, playerCountries.length ~/ 3 + bonus);
  }

  List<String> get allCountryIds => COUNTRIES.keys.toList();
  List<String> countryNeighbours(String countryId) => COUNTRIES[countryId].neighbours;
}

class CountryStateImpl extends CountryState with Observable {
  final String countryId;
  @observable
  int playerId;
  @observable
  int armies;
  CountryStateImpl(this.countryId, {this.playerId, this.armies: 0});
}

class PlayerStateImpl extends PlayerState with Observable {
  final int playerId;
  final String name;
  final String avatar;
  final String color;
  @observable
  int reinforcement;

  PlayerStateImpl(this.playerId, this.name, this.avatar, this.color, {this.reinforcement: 0});
}
