library risk.game.test;

import 'package:unittest/unittest.dart';
import 'package:risk/game.dart';
import 'package:risk/event.dart';
import 'package:collection/equality.dart';

const riskGameEq = const RiskGameEquality();

main() {
  group('RiskGameEngine', () {
    RiskGameEngine eventHandler;

    setUp(() {
      eventHandler = new RiskGameEngine.client(game: riskGame());
    });

    group('on ArmyPlaced', () {
      test('should add an army on a neutral country', () {
        // GIVEN
        var event = new ArmyPlaced()
            ..playerId = 0
            ..country = "eastern_australia";

        // WHEN
        eventHandler.handle(event);

        // THEN
        var expected = riskGame();
        expected.countries["eastern_australia"] = new CountryState(0, 1);
        expected.players[0].reinforcement--;

        expect(riskGameEq.equals(expected, eventHandler.game), isTrue);
      });

      test('should add an army on country owned by the player', () {
        // GIVEN
        var event = new ArmyPlaced()
            ..playerId = 1
            ..country = "western_australia";

        // WHEN
        eventHandler.handle(event);

        // THEN
        var expected = riskGame();
        expected.countries["western_australia"].armies++;
        expected.players[1].reinforcement--;

        expect(riskGameEq.equals(expected, eventHandler.game), isTrue);
      });

      test('should NOT add an army on country owned by another player', () {
        // GIVEN
        var event = new ArmyPlaced()
            ..playerId = 0
            ..country = "western_australia";

        // WHEN
        eventHandler.handle(event);

        // THEN
        var expected = riskGame();

        expect(riskGameEq.equals(expected, eventHandler.game), isTrue);
      });

      test(
          'should NOT add an army if the player has not enough reinforcement armies', () {
        // GIVEN
        var event = new ArmyPlaced()
            ..playerId = 2
            ..country = "western_australia";

        // WHEN
        eventHandler.handle(event);

        // THEN
        var expected = riskGame();

        expect(riskGameEq.equals(expected, eventHandler.game), isTrue);
      });
    });
  });
}

riskGame() => new RiskGame()
    ..countries = {
      "western_australia": new CountryState(1, 1),
    }
    ..players = {
      0: playerState(reinforcement: 10),
      1: playerState(reinforcement: 1),
      2: playerState(reinforcement: 0),
    };

playerState({name: "John", avatar: "avatar.png", reinforcement: 0}) =>
    new PlayerState(name, avatar, reinforcement: reinforcement);

class RiskGameEquality implements Equality<RiskGame> {
  final _countryEq = const MapEquality(values: const CountryStateEquality());
  final _playerEq = const MapEquality(values: const PlayerStateEquality());

  const RiskGameEquality();

  bool equals(RiskGame e1, RiskGame e2) => _countryEq.equals(e1.countries,
      e2.countries) && _playerEq.equals(e1.players, e2.players) && e1.activePlayerId
      == e2.activePlayerId;
  int hash(RiskGame e) => _countryEq.hash(e.countries) ^ _playerEq.hash(
      e.players) ^ e.activePlayerId.hashCode;
  bool isValidKey(Object o) => o is RiskGame;
}

class CountryStateEquality implements Equality<CountryState> {
  const CountryStateEquality();
  bool equals(CountryState e1, CountryState e2) => e1.playerId == e2.playerId &&
      e1.armies == e2.armies;
  int hash(CountryState e) => e.playerId.hashCode ^ e.armies.hashCode;
  bool isValidKey(Object o) => o is CountryState;
}

class PlayerStateEquality implements Equality<PlayerState> {
  const PlayerStateEquality();
  bool equals(PlayerState e1, PlayerState e2) => e1.name == e2.name && e1.avatar
      == e2.avatar && e1.reinforcement == e2.reinforcement;
  int hash(PlayerState e) => e.name.hashCode ^ e.avatar.hashCode ^
      e.reinforcement.hashCode;
  bool isValidKey(Object o) => o is PlayerState;
}
