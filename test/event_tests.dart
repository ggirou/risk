library risk.event.test;

import 'package:unittest/unittest.dart';
import 'package:risk/event.dart';

var events = {
  "Welcome": new SerializableTest()
      ..event = (new Welcome()..playerId = 123)
      ..json = {
        "event": "Welcome",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (Welcome event, Welcome output) {
        expect(output.playerId, equals(event.playerId));
      },

  "JoinGame": new SerializableTest()
      ..event = (new JoinGame()
          ..playerId = 123
          ..name = "John Lennon"
          ..avatar = "kadhafi.png")
      ..json = {
        "event": "JoinGame",
        "data": {
          "playerId": 123,
          "name": "John Lennon",
          "avatar": "kadhafi.png",
        },
      }
      ..expectation = (JoinGame event, JoinGame output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.name, equals(event.name));
        expect(output.avatar, equals(event.avatar));
      },

  "LeaveGame": new SerializableTest()
      ..event = (new LeaveGame()..playerId = 123)
      ..json = {
        "event": "LeaveGame",
        "data": {
          "playerId": 123,
        },
      }
      ..expectation = (LeaveGame event, LeaveGame output) {
        expect(output.playerId, equals(event.playerId));
      },

  "ArmyPlaced": new SerializableTest()
      ..event = (new ArmyPlaced()
          ..playerId = 123
          ..country = "eastern_australia")
      ..json = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 123,
          "country": "eastern_australia"
        },
      }
      ..expectation = (ArmyPlaced event, ArmyPlaced output) {
        expect(output.playerId, equals(event.playerId));
        expect(output.country, equals(event.country));
      },

};

main() {
  events.forEach((name, test) => group('$name should be', test.run));
}

class SerializableTest {
  var event;
  var json;
  var expectation;

  run() {
    test('serializable', () {
      // WHEN
      var output = EVENT.encode(event);

      // THEN
      expect(output, equals(json));
    });

    test('deserializable', () {
      // WHEN
      var output = EVENT.decode(json);

      // THEN
      expect(output.runtimeType, equals(event.runtimeType), reason:
          "Type are different");
      expectation(event, output);
    });
  }
}
