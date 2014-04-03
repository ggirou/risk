library risk.engine.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'package:risk/game.dart';
import 'package:risk/engine.dart';
import 'package:risk/event.dart';
import 'utils.dart';

main() {
  group('RiskGameEngine', testRiskGameEngine);
}

testRiskGameEngine() {
  HazardMock hazard;
  StreamController outputStream;
  RiskGameEngine engine;

  RiskGameEngine riskGameEngine(RiskGame game) => new RiskGameEngine(
      outputStream, game, hazard: hazard);

  setUp(() {
    hazard = new HazardMock();
    outputStream = new StreamController(sync: true);
    engine = riskGameEngine(riskGameInGame());
  });

  eventsList() {
    outputStream.close();
    return outputStream.stream.toList();
  }

  expectEvents(List<EngineEvent> expectedEvents) => eventsList().then((events)
      => expectEquals(events, expectedEvents));

  group('on JoinGame', () {
    setUp(() => engine = riskGameEngine(riskGamePlayerJoining()));

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
      expected.players[123] = new PlayerState(123, "John Lennon", "kadhafi.png",
          "red");

      expectEquals(engine.game, expected);
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

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });
  });

  group('on StarGame', () {
    setUp(() => engine = riskGameEngine(riskGamePlayerJoining()));

    test('should start game', () {
      // GIVEN
      var event = new StartGame()..playerId = 0;
      engine.game.activePlayerId = null;

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGamePlayerJoining();
      expected.started = true;
      expected.setupPhase = true;
      expected.turnStep = TURN_STEP_REINFORCEMENT;
      expected.playersOrder = [2, 1, 0];
      expected.activePlayerId = 2;
      expected.players[0].reinforcement = 35;
      expected.players[1].reinforcement = 35;
      expected.players[2].reinforcement = 35;

      expectEquals(engine.game, expected);
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

      expectEquals(engine.game, expected);
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

      expectEquals(engine.game, expected);
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

      expectEquals(engine.game, expected);
      return expectEvents([]);
    });
  });

  group('on ArmyPlaced', () {
    group('when setuping', () {
      setUp(() => engine = riskGameEngine(riskGameSetuping()));

      test('should add an army and next player', () {
        // GIVEN
        engine.game.activePlayerId = 1;
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameSetuping();
        expected.countries["eastern_australia"] = new CountryState(
            "eastern_australia", playerId: 1, armies: 1);
        expected.players[1].reinforcement--;

        expected.activePlayerId = 2;
        expected.turnStep = TURN_STEP_REINFORCEMENT;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "eastern_australia", new NextPlayer()
              ..playerId = 2
              ..reinforcement = 10]);
      });

      test('should add an army and end setup when all armies are placed', () {
        // GIVEN
        engine.game.players = {
          0: playerState(reinforcement: 0),
          1: playerState(reinforcement: 0),
          2: playerState(reinforcement: 1),
        };
        var event = new PlaceArmy()
            ..playerId = 2
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameSetuping();
        expected.countries["eastern_australia"] = new CountryState(
            "eastern_australia", playerId: 2, armies: 1);

        expected.setupPhase = false;
        expected.activePlayerId = 0;
        expected.turnStep = TURN_STEP_REINFORCEMENT;

        expected.players = {
          0: playerState(reinforcement: 3),
          1: playerState(reinforcement: 0),
          2: playerState(reinforcement: 0),
        };

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 2
              ..country = "eastern_australia", new SetupEnded(), new NextPlayer(
                  )
              ..playerId = 0
              ..reinforcement = 3]);
      });
    });

    group('in player turn', () {
      test('should add an army on a neutral country', () {
        // GIVEN
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "eastern_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameInGame();
        expected.countries["eastern_australia"] = new CountryState(
            "eastern_australia", playerId: 1, armies: 1);
        expected.players[1].reinforcement--;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "eastern_australia"]);
      });

      test('should add an army on country owned by the player', () {
        // GIVEN
        var event = new PlaceArmy()
            ..playerId = 1
            ..country = "western_australia";

        // WHEN
        engine.handle(event);

        // THEN
        var expected = riskGameInGame();
        expected.countries["western_australia"].armies++;
        expected.players[1].reinforcement--;

        expectEquals(engine.game, expected);
        return expectEvents([new ArmyPlaced()
              ..playerId = 1
              ..country = "western_australia"]);
      });
    });

    test('should add an army and next step', () {
      // GIVEN
      engine.game..players[1].reinforcement = 1;
      var event = new PlaceArmy()
          ..playerId = 1
          ..country = "eastern_australia";

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["eastern_australia"] = new CountryState(
          "eastern_australia", playerId: 1, armies: 1);
      expected.players[1].reinforcement = 0;

      expected.turnStep = TURN_STEP_ATTACK;

      expectEquals(engine.game, expected);
      return expectEvents([new ArmyPlaced()
            ..playerId = 1
            ..country = "eastern_australia", new NextStep()]);
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

        expectEquals(engine.game, expected);
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
          ..armies = 2;
      hazard.when(callsTo('rollDices')).thenReturn([6, 1]).thenReturn([2, 1]);

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["western_australia"].armies -= 1;
      expected.countries["indonesia"].armies -= 1;

      var expectedEvent = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 1]
              ..country = "western_australia"
              ..remainingArmies = 3)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "indonesia"
              ..remainingArmies = 1)
          ..conquered = false;

      expectEquals(engine.game, expected);
      return expectEvents([expectedEvent]);
    });

    test('should result in a BattleEnd with country conquered', () {
      // GIVEN
      var event = new Attack()
          ..playerId = 1
          ..from = "western_australia"
          ..to = "indonesia"
          ..armies = 3;
      hazard.when(callsTo('rollDices')).thenReturn([6, 3, 1]).thenReturn([2, 1]
          );

      // WHEN
      engine.handle(event);

      // THEN
      var expected = riskGameInGame();
      expected.countries["indonesia"].armies -= 2;
      expected.countries["indonesia"].playerId = 1;

      var expectedEvent = new BattleEnded()
          ..attacker = (new BattleOpponentResult()
              ..playerId = 1
              ..dices = [6, 3, 1]
              ..country = "western_australia"
              ..remainingArmies = 4)
          ..defender = (new BattleOpponentResult()
              ..playerId = 2
              ..dices = [2, 1]
              ..country = "indonesia"
              ..remainingArmies = 0)
          ..conquered = true;

      expectEquals(engine.game, expected);
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

        expectEquals(engine.game, expected);
        return expectEvents([]);
      });
    });
  });
}

class HazardMock extends Mock implements Hazard {
  List<int> giveOrders(Iterable<int> players) => players.toList(
      ).reversed.toList();

  List<List> split(Iterable elements, int n) => new List.generate(n, (_) => []);
}
