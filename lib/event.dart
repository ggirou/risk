library risk.event;

@MirrorsUsed(override: '*')
import 'dart:mirrors';
import 'dart:convert';
import 'package:morph/morph.dart';

abstract class PlayerEvent {
  int get playerId;
}

class ArmyPlaced implements PlayerEvent {
  int playerId;
  String country;
  ArmyPlaced({this.playerId, this.country});
}

class Welcome {
  int playerId;
  Welcome({this.playerId});  
}

class JoinGame implements PlayerEvent {
  int playerId;
  String name;
  String avatar;
  JoinGame({this.playerId, this.name, this.avatar});
}

class LeaveGame implements PlayerEvent {
  int playerId;
  LeaveGame({this.playerId});
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
    "LeaveGame": LeaveGame,
    "ArmyPlaced": ArmyPlaced,
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
