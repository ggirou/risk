library risk.event;

@MirrorsUsed(override: '*')
import 'dart:mirrors';
import 'dart:convert';
import 'package:morph/morph.dart';

//////////////// PLAYER EVENTS

/// Event produced by Player
abstract class PlayerEvent {
  int get playerId;
}

/// sent by player that is ready to join a game
class JoinGame implements PlayerEvent {
  int playerId;
  String name;
  String avatar;
  String color;
}

/// sent by the first player to start a game
class StartGame implements PlayerEvent {
  int playerId;
}

/// sent by player when he put an army on a country
class PlaceArmy implements PlayerEvent {
  int playerId;
  String country;
}

/// sent by player when he attacks a country
class Attack implements PlayerEvent {
  int playerId;
  String from;
  String to;
  int armies;
}

/// sent by player to stop attacking
class EndAttack implements PlayerEvent {
  int playerId;
}

/// sent by player to move an army from a country to another
class MoveArmy implements PlayerEvent {
  int playerId;
  String from;
  String to;
  int armies;
}

/// sent by player to end its turn
class EndTurn implements PlayerEvent {
  int playerId;
}

//////////////// PLAYER EVENTS

/// Event produced by the Game Engine
abstract class EngineEvent {}

/// sent by engine to identify player when he arrives
class Welcome implements EngineEvent {
  int playerId;
}

/// sent when player joins the game
class PlayerJoined implements EngineEvent {
  int playerId;
  String name;
  String avatar;
  String color;
}

/// sent by the engine when countries are affected
class GameStarted implements EngineEvent {
  /// the number of armies by player
  int armies;
  List<int> playersOrder;
}

/// sent by engine when army is placed on a country
class ArmyPlaced implements EngineEvent {
  int playerId;
  String country;
}

/// sent by the engine to change user
class NextPlayer implements EngineEvent {
  int playerId;
  int reinforcement;
}

////// sent by the engine when setup phase is ended
//class SetupEnded implements EngineEvent {}

/// sent by engine the result of battle
class BattleEnded implements EngineEvent {
  BattleOpponentResult attacker;
  BattleOpponentResult defender;
}

/// Battle result for one opponent
class BattleOpponentResult {
  int playerId;
  List<int> dices;
  String country;
  int remainingArmies;
}

/// sent by engine when an army is moved from a country to another
class ArmyMoved implements EngineEvent {
  int playerId;
  String from;
  String to;
  int armies;
}

const EVENT = const EventCodec();
final _MORPH = new Morph();

/**
 * Encodes and decodes Event from/to JSON.
 */
class EventCodec extends Codec<Object, Map> {
  final decoder = const EventDecoder();
  final encoder = const EventEncoder();
  const EventCodec();
}

/**
 * Decodes Event from JSON.
 */
class EventDecoder extends Converter<Map, Object> {
  final _classes = const {
    "JoinGame": JoinGame,
    "StartGame": StartGame,
    "PlaceArmy": PlaceArmy,
    "Attack": Attack,
    "EndAttack": EndAttack,
    "MoveArmy": MoveArmy,
    "EndTurn": EndTurn,
    "Welcome": Welcome,
    "PlayerJoined": PlayerJoined,
    "GameStarted": GameStarted,
    "ArmyPlaced": ArmyPlaced,
    "NextPlayer": NextPlayer,
    "BattleEnded": BattleEnded,
    "ArmyMoved": ArmyMoved,
  };

  const EventDecoder();
  Object convert(Map input) {
    var event = input == null ? null : input['event'];
    var type = _classes[event];
    return type == null ? null : _MORPH.deserialize(type, input['data']);
  }
}

/**
 * Encodes Event to JSON.
 */
class EventEncoder extends Converter<Object, Map> {
  const EventEncoder();
  Map convert(Object input) => {
    'event': '${input.runtimeType}',
    'data': _MORPH.serialize(input)
  };
}
