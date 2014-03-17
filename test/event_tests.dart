library risk.event.test;

import 'package:unittest/unittest.dart';
import 'package:risk/event.dart';
import 'package:collection/equality.dart';

const eventMapEq = const DeepCollectionEquality();

main() {
  group('Event should deserialize then serialize', () {
      test('ArmyPlaced', () {
        // GIVEN
        var eventMap = {
          "event": "ArmyPlaced",
          "data": {
            "playerId": 0,
            "country": "eastern_australia"
          },
        };
        var event = new ArmyPlaced(0, "eastern_australia");

        // WHEN
        var outputEvent = new Event.fromMap(eventMap);
        var outputMap = outputEvent.toMap();

        // THEN
        expect(outputEvent.playerId, equals(event.playerId));
        expect(outputEvent.country, equals(event.country));

        expect(eventMapEq.equals(eventMap, outputMap), isTrue);
      });
  });
}
