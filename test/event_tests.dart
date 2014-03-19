library risk.event.test;

import 'package:collection/equality.dart';
import 'package:unittest/unittest.dart';
import 'package:risk/event.dart';

main() {
  group('ArmyPlaced should be', () {
    // GIVEN
    var event = new ArmyPlaced(playerId: 0, country: "eastern_australia");
    var json = {
      "event": "ArmyPlaced",
      "data": {
        "playerId": 0,
        "country": "eastern_australia"
      },
    };

    testSerialization(event, json);

    testDeserialization(event, json, (output) {
      expect(output.playerId, equals(event.playerId));
      expect(output.country, equals(event.country));
    });
  });
}

testSerialization(event, json) {
  test('serializable', () {
    // WHEN
    var output = EVENT.encode(event);

    // THEN
    expect(const DeepCollectionEquality().equals(json, output), isTrue);
  });
}

testDeserialization(event, json, expectation(output)) {
  test('deserializable', () {
    // WHEN
    var output = EVENT.decode(json);

    // THEN
    expectation(output);
  });
}
