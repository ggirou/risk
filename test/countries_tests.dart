library coutries.test;

import 'dart:convert';

import 'package:unittest/unittest.dart';
import 'package:risk/countries.dart';

main() {
  test('decode a single country', () {
    final countries = decodeJson(
        '[{"id": "france", "continent": "europe", "neighbours": [], "svgPath": "pathFrance"}]'
        );
    expect(countries is Iterable, equals(true));
    expect(countries.length, equals(1));
    final country = countries.first;
    expect(country.id, equals('france'));
    expect(country.continent, equals('europe'));
    expect(country.neighbours.length, equals(0));
    expect(country.svgPath, equals('pathFrance'));
  });

  group('decode countries', () {
    test('without neighbours', () {
      final json = JSON.encode([{
        "id": "france",
        "continent": "europe",
        "neighbours": [],
        "svgPath": "pathFrance"
      }, {
        "id": "belgique",
        "continent": "europe",
        "neighbours": [],
        "svgPath": "pathBelgique"
      }]);

      final countries = decodeJson(json);
      expect(countries.length, equals(2));

      final france = countries.firstWhere((c) => c.id == 'france');
      expect(france.continent, equals('europe'));
      expect(france.neighbours.length, equals(0));
      expect(france.svgPath, equals('pathFrance'));

      final belgique = countries.firstWhere((c) => c.id == 'belgique');
      expect(belgique.continent, equals('europe'));
      expect(belgique.neighbours.length, equals(0));
      expect(belgique.svgPath, equals('pathBelgique'));
    });

    test('with neighbours', () {
      final json = JSON.encode([{
        "id": "france",
        "continent": "europe",
        "neighbours": ["belgique"],
        "svgPath": "pathFrance"
      }, {
        "id": "belgique",
        "continent": "europe",
        "neighbours": ["france"],
        "svgPath": "pathBelgique"
      }]);

      final countries = decodeJson(json);
      expect(countries.length, equals(2));

      final france = countries.firstWhere((c) => c.id == 'france');
      final belgique = countries.firstWhere((c) => c.id == 'belgique');

      expect(france.continent, equals('europe'));
      expect(france.neighbours.length, equals(1));
      expect(france.neighbours.first, equals(belgique));
      expect(france.svgPath, equals('pathFrance'));

      expect(belgique.continent, equals('europe'));
      expect(belgique.neighbours.length, equals(1));
      expect(belgique.neighbours.first, equals(france));
      expect(belgique.svgPath, equals('pathBelgique'));
    });
  });
}
