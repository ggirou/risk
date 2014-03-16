library risk.board.test;

import 'package:unittest/unittest.dart';
import 'package:risk/board.dart';
import 'package:collection/equality.dart';

main() {
  group('BoardEventHandler', () {
    BoardEventHandler eventHandler;

    setUp(() {
      Board board = new Board();
      board.countries.addAll({
        "western_australia": new CountryState(1, 1),
      });
      board.players.addAll([new PlayerState(10), //
        new PlayerState(1), //
        new PlayerState(0)]);
      
      eventHandler = new BoardEventHandler(board);
    });

    test('ArmyPlaced should add an army on a neutral country', () {
      // GIVEN
      var event = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 0,
          "country": "eastern_australia"
        },
      };

      // WHEN
      eventHandler.handle(event);

      // THEN
      var expectedCountries = {
        "western_australia": new CountryState(1, 1),
        "eastern_australia": new CountryState(0, 1),
      };
      var expectedPlayers = [new PlayerState(9), //
        new PlayerState(1), //
        new PlayerState(0)];

      expect(const MapEquality().equals(expectedCountries, eventHandler.board.countries),
          isTrue);
      expect(const ListEquality().equals(expectedPlayers, eventHandler.board.players),
          isTrue);
    });

    test('ArmyPlaced should add an army on country owned by the player', () {
      // GIVEN
      var event = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 1,
          "country": "western_australia"
        },
      };

      // WHEN
      eventHandler.handle(event);

      // THEN
      var expectedCountries = {
        "western_australia": new CountryState(1, 2),
      };
      var expectedPlayers = [new PlayerState(10), //
        new PlayerState(0), //
        new PlayerState(0)];

      expect(const MapEquality().equals(expectedCountries, eventHandler.board.countries),
          isTrue);
      expect(const ListEquality().equals(expectedPlayers, eventHandler.board.players),
          isTrue);
    });

    test('ArmyPlaced should NOT add an army on country owned by another player',
        () {
      // GIVEN
      var event = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 0,
          "country": "western_australia"
        },
      };

      // WHEN
      eventHandler.handle(event);

      // THEN
      var expectedCountries = {
        "western_australia": new CountryState(1, 1),
      };
      var expectedPlayers = [new PlayerState(10), //
        new PlayerState(1), //
        new PlayerState(0)];

      expect(const MapEquality().equals(expectedCountries, eventHandler.board.countries),
          isTrue);
      expect(const ListEquality().equals(expectedPlayers, eventHandler.board.players),
          isTrue);
    });

    test('ArmyPlaced should NOT add an army if the player has not enough reinforcement armies',
        () {
      // GIVEN
      var event = {
        "event": "ArmyPlaced",
        "data": {
          "playerId": 2,
          "country": "western_australia"
        },
      };

      // WHEN
      eventHandler.handle(event);

      // THEN
      var expectedCountries = {
        "western_australia": new CountryState(1, 1),
      };
      var expectedPlayers = [new PlayerState(10), //
        new PlayerState(1), //
        new PlayerState(0)];

      expect(const MapEquality().equals(expectedCountries, eventHandler.board.countries),
          isTrue);
      expect(const ListEquality().equals(expectedPlayers, eventHandler.board.players),
          isTrue);
    });
  });
}
