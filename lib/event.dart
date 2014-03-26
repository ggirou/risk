library risk.event;

@MirrorsUsed(override: '*')
import 'dart:mirrors';
import 'dart:convert';
import 'package:morph/morph.dart';

abstract class PlayerEvent {
  int get playerId;
}

/// sent by engine to identify player when he arrives
class Welcome {
  int playerId;
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

/// sent by the engine when countries are affected
class GameStarted {
  /// the number of armies by player
  int armies;
  List<int> playersOrder;
}

/// sent by player when he put an army on a country
class ArmyPlaced implements PlayerEvent {
  int playerId;
  String country;
}

/// sent by the engine to change user
class NextPlayer {
  int playerId;
  int reinforcement;
}

/// sent by player when he attacks a country
class Attack implements PlayerEvent {
  int playerId;
  String from;
  String to;
  int armies;
}

/// sent by player when he defends a country
class Defend implements PlayerEvent {
  int playerId;
  int armies;
}

/// sent by engine the result of random
class BattleEnded {
  List<int> attackDices;
  List<int> defendDices;

  int get lostByAttacker {
    final attacks = (attackDices.toList()..sort()).reversed.toList();
    final defends = (defendDices.toList()..sort()).reversed.toList();
    int result = 0;
    for (int i = 0; i < defends.length; i++) {
      if (attacks[i] <= defends[i]) result++;
    }
    return result;
  }
  int get lostByDefender => defendDices.length - lostByAttacker;
}

/// sent by player to stop attacking
class EndAttack implements PlayerEvent {
  int playerId;
}

/// sent by player to stop attacking
class Move implements PlayerEvent {
  int playerId;
  String from;
  String to;
  int armies;
}

/// sent by player to end its turn
class EndTurn implements PlayerEvent {
  int playerId;
}

/// sent by player to leave
class LeaveGame implements PlayerEvent {
  int playerId;
  LeaveGame();
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
    "Welcome": Welcome,
    "JoinGame": JoinGame,
    "StartGame": StartGame,
    "GameStarted": GameStarted,
    "ArmyPlaced": ArmyPlaced,
    "NextPlayer": NextPlayer,
    "Attack": Attack,
    "Defend": Defend,
    "BattleEnded": BattleEnded,
    "EndAttack": EndAttack,
    "Move": Move,
    "EndTurn": EndTurn,
    "LeaveGame": LeaveGame,
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
