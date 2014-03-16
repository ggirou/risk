library risk.map.test;

import 'package:unittest/unittest.dart';
import 'package:risk/map.dart';

main() {
  test('there should be 6 continents', () {
    expect(CONTINENTS.length, equals(6));
  });

  test('each continent should contain countries', () {
    for (final Continent continent in CONTINENTS) {
      expect(continent.countries.length, isPositive);
    }
  });

  test('there should be 42 countries', () {
    expect(COUNTRIES.length, equals(42));
  });

  test('each country should belong to on continent', () {
    for (final Country country in COUNTRIES) {
      expect(country.continent, isNotNull);
    }
  });

  skip_test('each country should have at least 1 neighbour', () {
    for (final Country country in COUNTRIES) {
      expect(country.neighbours.length, isPositive);
    }
  });
}
