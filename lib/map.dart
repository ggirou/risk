library risk.map;

import 'package:observe/observe.dart';

@reflectable
class Continent {
  final String id;
  final int bonus;

  Continent._(this.id, this.bonus);

  List<Country> get countries => COUNTRIES.where((c) => c._continentId == id
      ).toList();
}

@reflectable
class Country {
  final String id;
  final String _continentId;
  final List<String> _neighbourIds;

  Country._(this.id, this._continentId, this._neighbourIds);

  Continent get continent => CONTINENTS.firstWhere((c) => c.id == _continentId);
  List<Country> get neighbours => COUNTRIES.where((c) => _neighbourIds.contains(
      c.id)).toList();
}

final CONTINENTS = <Continent>[//
  new Continent._('australia', 2), //
  new Continent._('north_america', 5), //
  new Continent._('south_america', 2), //
  new Continent._('africa', 3), //
  new Continent._('europe', 5), //
  new Continent._('asia', 7),//
];

final COUNTRIES = <Country>[//
  new Country._('eastern_australia', 'australia', []), //
  new Country._('indonesia', 'australia', []), //
  new Country._('new_guinea', 'australia', []), //
  new Country._('alaska', 'north_america', []), //
  new Country._('ontario', 'north_america', []), //
  new Country._('northwest_territory', 'north_america', []), //
  new Country._('venezuela', 'south_america', []), //
  new Country._('madagascar', 'africa', []), //
  new Country._('north_africa', 'africa', []), //
  new Country._('greenland', 'north_america', []), //
  new Country._('iceland', 'europe', []), //
  new Country._('great_britain', 'europe', []), //
  new Country._('scandinavia', 'europe', []), //
  new Country._('japan', 'asia', []), //
  new Country._('yakursk', 'asia', []), //
  new Country._('kamchatka', 'asia', []), //
  new Country._('siberia', 'asia', []), //
  new Country._('ural', 'asia', []), //
  new Country._('afghanistan', 'asia', []), //
  new Country._('middle_east', 'asia', []), //
  new Country._('india', 'asia', []), //
  new Country._('siam', 'asia', []), //
  new Country._('china', 'asia', []), //
  new Country._('mongolia', 'asia', []), //
  new Country._('irkutsk', 'asia', []), //
  new Country._('ukraine', 'europe', []), //
  new Country._('southern_europe', 'europe', []), //
  new Country._('western_europe', 'europe', []), //
  new Country._('northern_europe', 'europe', []), //
  new Country._('egypt', 'africa', []), //
  new Country._('east_africa', 'africa', []), //
  new Country._('congo', 'africa', []), //
  new Country._('south_africa', 'africa', []), //
  new Country._('brazil', 'south_america', []), //
  new Country._('argentina', 'south_america', []), //
  new Country._('eastern_united_states', 'north_america', []), //
  new Country._('western_united_states', 'north_america', []), //
  new Country._('quebec', 'north_america', []), //
  new Country._('central_america', 'north_america', []), //
  new Country._('peru', 'south_america', []), //
  new Country._('western_australia', 'australia', []), //
  new Country._('alberta', 'north_america', []),//
];
