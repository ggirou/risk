library risk.test.utils;

import 'package:morph/morph.dart';
import 'package:unittest/unittest.dart';
import 'package:risk/game.dart';

/*
 * Assert equality between [actual] and [expected] by reflection.
 */
void expectEquals(actual, expected, {String reason, FailureHandler
    failureHandler, bool verbose: false}) {
  expect(_MORPH.serialize(actual), equals(_MORPH.serialize(expected)), reason:
      reason, failureHandler: failureHandler, verbose: verbose);
}

// TODO: comments
PlayerState playerState({playerId: 123, name: "John", avatar:
    "avatar.png", color: "blue", reinforcement: 0}) => new PlayerState(playerId,
    name, avatar, color, reinforcement: reinforcement);

RiskGame riskGamePlayerJoining() => new RiskGame()..players = {
      0: playerState(),
      1: playerState(),
      2: playerState(),
    };

RiskGame riskGameSetuping() => new RiskGame()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 1),
      2: playerState(reinforcement: 10),
    }
    ..countries = {
      "western_australia": new CountryState("western_australia", playerId: 1,
          armies: 4),
      "new_guinea": new CountryState("new_guinea", playerId: 1, armies: 3),
      "indonesia": new CountryState("indonesia", playerId: 2, armies: 2),
      "siam": new CountryState("siam", playerId: 2, armies: 4),
      "great_britain": new CountryState("great_britain", playerId: 2, armies: 4
          ),
    }
    ..started = true
    ..setupPhase = true
    ..activePlayerId = 2
    ..playersOrder = [1, 2, 0];

RiskGame riskGameReinforcement() => riskGameSetuping()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 5),
      2: playerState(reinforcement: 0),
    }
    ..setupPhase = false
    ..turnStep = TURN_STEP_REINFORCEMENT
    ..activePlayerId = 1;


RiskGame riskGameAttacking() => riskGameReinforcement()
    ..players = {
      0: playerState(reinforcement: 0),
      1: playerState(reinforcement: 0),
      2: playerState(reinforcement: 0),
    }
    ..turnStep = TURN_STEP_ATTACK;


RiskGame riskGameFortification() => riskGameAttacking()
    ..turnStep = TURN_STEP_FORTIFICATION;

// When we try to serialize Observable object, we get an error on serializing `changes` value
final ignoreObservableStreamType = new RiskGame().changes.runtimeType;
final _MORPH = new Morph()..registerTypeAdapter(ignoreObservableStreamType,
    new _ToNullSerializer());

class _ToNullSerializer extends Serializer {
  @override
  serialize(object) => null;
}
