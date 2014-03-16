library board_model;

import 'package:observe/observe.dart';
import 'dart:convert';

@reflectable
class Country {
  final String id;
  final String continent;
  final String svgPath;
  List<Country> _neighbours;

  Country._(this.id, this.continent, this.svgPath);

  List<Country> get neighbours => _neighbours;
}

List<Country> decodeJson(String json) => _fromJson(JSON.decode(json));

List<Country> _fromJson(List json) {
  final countriesById = <String, Country>{};
  final neighbours = <String, List<String>>{};

  // collect from json
  for (final e in json) {
    final id = e['id'];
    countriesById[id] = new Country._(id, e['continent'], e['svgPath']);
    neighbours[id] = e['neighbours'];
  }

  // set neighbours
  for (Country country in countriesById.values) {
    country._neighbours = neighbours[country.id].map((id) => countriesById[id]).toList();
  }

  return countriesById.values.toList();
}


