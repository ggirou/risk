library risk.game.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:risk/game.dart';
import 'package:risk/event.dart';
import 'utils.dart';

main() {
  group('Dices attack computation', testDicesAttackComputation);
  group('RiskGame', testRiskGame);
  group('RiskGameEngine', testRiskGameEngine);
}

testDicesAttackComputation() {
  test('[2] vs [1]', () {
    expect(computeAttackerLoss([2], [1]), equals(0));
  });
  test('[2] vs [2,1]', () {
    expect(computeAttackerLoss([2], [2, 1]), equals(1));
  });
  test('[2,1] vs [1]', () {
    expect(computeAttackerLoss([2, 1], [1]), equals(0));
  });
  test('[1,1] vs [1]', () {
    expect(computeAttackerLoss([1, 1], [1]), equals(1));
  });
  test('[1,1,1] vs [1]', () {
    expect(computeAttackerLoss([1, 1, 1], [1]), equals(1));
  });
  test('[2,2,1] vs [2,1]', () {
    expect(computeAttackerLoss([2, 2, 1], [2, 1]), equals(1));
  });
  test('[2,2,1] vs [1,1]', () {
    expect(computeAttackerLoss([2, 2, 1], [1, 1]), equals(0));
  });
  test('[2,2,1] vs [4,3]', () {
    expect(computeAttackerLoss([2, 2, 1], [4, 3]), equals(2));
  });
}

testRiskGame() {
  RiskGame game;

  setUp(() {
    game = riskGameInGame();
  });

  test('on PlayerJoined should add a player', () {
    // GIVEN
    var event = new PlayerJoined()
        ..playerId = 123
        ..name = "John Lennon"
        ..avatar = "kadhafi.png"
        ..color = "red";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.players[123] = new PlayerState("John Lennon", "kadhafi.png", "red"
        );

    expectEquals(game, expected);
  });

  test('on GameStarted should set player orders and player reinforcements', () {
    // GIVEN
    var event = new GameStarted()
        ..playersOrder = [2, 1, 0]
        ..armies = 42;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.started = true;
    expected.playersOrder = [2, 1, 0];
    expected.players[0].reinforcement = 42;
    expected.players[1].reinforcement = 42;
    expected.players[2].reinforcement = 42;

    expectEquals(game, expected);
  });

  test('on ArmyPlaced should add an army on a neutral country', () {
    // GIVEN
    var event = new ArmyPlaced()
        ..playerId = 0
        ..country = "eastern_australia";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.countries["eastern_australia"] = new CountryState(0, 1);
    expected.players[0].reinforcement--;

    expectEquals(game, expected);
  });

  test('on ArmyPlaced should add an army on country owned by the player', () {
    // GIVEN
    var event = new ArmyPlaced()
        ..playerId = 1
        ..country = "western_australia";

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.countries["western_australia"].armies++;
    expected.players[1].reinforcement--;

    expectEquals(game, expected);
  });

  test('on NextPlayer should set the current player and his reinforcement', () {
    // GIVEN
    var event = new NextPlayer()
        ..playerId = 2
        ..reinforcement = 42;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.activePlayerId = 2;
    expected.players[2].reinforcement = 42;

    expectEquals(game, expected);
  });

  test('on BattleEnded should set remaining armies in countries', () {
    // GIVEN
    var event = new BattleEnded()
        ..attacker = (new BattleOpponentResult()
            ..playerId = 1
            ..dices = [3, 2, 1]
            ..country = "western_australia"
            ..remainingArmies = 2)
        ..defender = (new BattleOpponentResult()
            ..playerId = 2
            ..dices = [6, 5]
            ..country = "indonesia"
            ..remainingArmies = 1);

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.countries["western_australia"].armies = 2;
    expected.countries["indonesia"].armies = 1;

    expectEquals(game, expected);
  });

  test('on ArmyMoved should move armies', () {
    // GIVEN
    var event = new ArmyMoved()
        ..playerId = 1
        ..from = "new_guinea"
        ..to = "western_australia"
        ..armies = 2;

    // WHEN
    game.update(event);

    // THEN
    var expected = riskGameInGame();
    expected.countries["new_guinea"].armies -= 2;
    expected.countries["western_australia"].armies += 2;

    expectEquals(game, expected);
  });

}

testRiskGameEngine() {
  HazardMock hazard;
  StreamController outputStream;
  RiskGameEngine engine;

  setUp(() {
    hazard = new HazardMock();
    outputStream = new StreamController(sync: true);
    engine = new RiskGameEngine(outputStream, riskGameInGame(), hazard: hazard);
  });

  eventsList() {
    outputStream.close();
    return outputStream.stream.toList();
  }

  expectEvents(List<EngineEvent> expectedEvents) => eventsList().then((events)
      => expectEquals(events, expectedEvents));

  group('on JoinGame', () {
    setUp(() {
      engine = new RiskGameEngine(outputStream, riskGamePlayerJoining(), hazard:
          hazard);
    });

    test('should add a player', () {
      // GIVEN
      var event = new JoinGame()
          ..playerId = 123
          ..name = "John Lennon"
          ..avatar = "kadhafi.png"
          ..color = "red";

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.players[123] = new PlayerState("John Lennon", "kadhafi.png",
          "red");

      expectEquals(expected, engine.game);
      return expectEvents([new PlayerJoined()
            ..playerId = 123
            ..name = "John Lennon"
            ..color = "red"
            ..avatar = "kadhafi.png"]);
    });

    test('should NOT add an existing player', () {
      // GIVEN
      var event = new JoinGame()
          ..playerId = 1
          ..name = "John Lennon"
          ..color = "red"
          ..avatar = "kadhafi.png";

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();

      expectEquals(expected, engine.game);
      return expectEvents([]);
    });
  });

  group('on StarGame', () {
    setUp(() {
      engine = new RiskGameEngine(outputStream, riskGamePlayerJoining(), hazard:
          hazard);
    });

    test('should start game', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engine.game.activePlayerId = null;
      engine.setupPhase = true;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.started = true;
      expected.playersOrder = [2, 1, 0];
      expected.activePlayerId = 2;
      expected.players[2].reinforcement = 35;

      //expectEquals(expected, engine.game);
      return expectEvents([new GameStarted()
            ..armies = 35
            ..playersOrder = [2, 1, 0], new NextPlayer()
            ..playerId = 2
            ..reinforcement = 35]);
    });

    test('should NOT start game when it is not the master player', () {
      // GIVEN
      var event = new StartGame()..playerId = 2;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();

      expectEquals(expected, engine.game);
      return expectEvents([]);
    });

    test('should NOT start game when there is not enough player', () {
      // GIVEN
      var event = new StartGame()..playerId = 2;
      engine.game.players = {
        0: playerState()
      };

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.players = {
        0: playerState()
      };

      expectEquals(expected, engine.game);
      return expectEvents([]);
    });

    test('should NOT start game if the game is already started', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engine.game.started = true;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.started = true;

      expectEquals(expected, engine.game);
      return expectEvents([]);
    });
  });

  group('on ArmyPlaced', () {
    test('should add an army on a neutral country', () {
      // GIVEN
      var event = new PlaceArmy()
          ..playerId = 1
          ..country = "eastern_australia";
      engine.setupPhase = false;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["eastern_australia"] = new CountryState(1, 1);
      expected.players[1].reinforcement--;

      expectEquals(expected, engine.game);
      return expectEvents([new ArmyPlaced()
            ..playerId = 1
            ..country = "eastern_australia"]);
    });

    test('should add an army on country owned by the player', () {
      // GIVEN
      var event = new PlaceArmy()
          ..playerId = 1
          ..country = "western_australia";
      engine.setupPhase = false;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["western_australia"].armies++;
      expected.players[1].reinforcement--;

      expectEquals(expected, engine.game);
      return expectEvents([new ArmyPlaced()
            ..playerId = 1
            ..country = "western_australia"]);
    });

    var errorCases = {
      'on country owned by another player': new PlaceArmy()
          ..playerId = 1
          ..country = "indonesia",
      'if the player has not enough reinforcement armies': new PlaceArmy()
          ..playerId = 2
          ..country = "indonesia",
    };

    errorCases.forEach((key, event) {
      test('should NOT add an army $key', () {
        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameInGame();

        expectEquals(expected, engine.game);
        return expectEvents([]);
      });
    });
  });

  group('on Attack', () {
    test('should result in a BattleEnd', () {
      // GIVEN
      var event = new Attack()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "indonesia"
          ..armies = 3;
      hazard.when(callsTo('rollDices')).thenReturn([6, 2, 1]).thenReturn([1, 2]
          );

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["western_australia"].armies -= 1;
      expected.countries["indonesia"].armies -= 1;

      var expectedEvent = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 2, 1]
              ..country = "western_australia"
              ..remainingArmies = 3)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [1, 2]
              ..country = "indonesia"
              ..remainingArmies = 1);

      expectEquals(expected, engine.game);
      return expectEvents([expectedEvent]);
    });

    // Working event
    workingAttack() => new Attack()
        ..playerId = 1
        ..from = "western_australia"
        ..to = "indonesia"
        ..armies = 3;

    var errorCases = {
      "when it\'s not the active player": workingAttack()..playerId = 2,
      "when the from country is not owned by the player": workingAttack()..from
          = "siam",
      "when the to country is owned by the player": workingAttack()..to =
          "new_guinea",
      "when the player has not enough armies in the country": workingAttack(
          )..from = "new_guinea",
      "when the attacked country is not in the neighbourhood": workingAttack(
          )..to = "great_britain",
    };

    errorCases.forEach((key, event) {
      test('should NOT result in a BattleEnd $key', () {
        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameInGame();

        expectEquals(expected, engine.game);
        return expectEvents([]);
      });
    });
  });
}

playerState({name: "John", avatar: "avatar.png", color: "blue", reinforcement:
    0}) => new PlayerState(name, avatar, color, reinforcement: reinforcement);

riskGamePlayerJoining() => new RiskGame()..players = {
      0: playerState(),
      1: playerState(),
      2: playerState(),
    };

riskGameInGame() => new RiskGame()
    ..players = {
      0: playerState(reinforcement: 10),
      1: playerState(reinforcement: 1),
      2: playerState(reinforcement: 0),
    }
    ..countries = {
      "western_australia": new CountryState(1, 4),
      "new_guinea": new CountryState(1, 3),
      "indonesia": new CountryState(2, 2),
      "siam": new CountryState(2, 4),
      "great_britain": new CountryState(2, 4),
    }
    ..started = true
    ..activePlayerId = 1
    ..playersOrder = [1, 2, 0];

class HazardMock extends Mock implements Hazard {
  List<int> giveOrders(Iterable<int> players) => players.toList(
      ).reversed.toList();
}
