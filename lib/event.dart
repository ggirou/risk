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

/**
 * Encodes and decodes Event from/to JSON.
 */
class EventCodec extends Codec<Object, Map> {
  final decoder = new EventDecoder();
  final encoder = new EventEncoder();
}

/**
 * Decodes Event from JSON.
 */
class EventDecoder extends Converter<Map, Object> {
  final _morph = new Morph();
  final _classes = const {
    "ArmyPlaced": ArmyPlaced
  };

  Object convert(Map input) {
    var event = input == null ? null : input['event'];
    var type = _classes[event];
    return type == null ? null : _morph.deserialize(type, input['data']);
  }
}

/**
 * Encodes Event to JSON.
 */
class EventEncoder extends Converter<Object, Map> {
  final _morph = new Morph();

  Map convert(Object input) => {
    'event': '${input.runtimeType}',
    'data': _morph.serialize(input)
  };
}
