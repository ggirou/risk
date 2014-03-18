library risk.map;

class Continent {
  final String id;
  final int bonus;

  Continent._(this.id, this.bonus);

  List<Country> get countries => COUNTRIES.where((c) => c._continentId == id
      ).toList();
}

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
  // australia
  new Country._('eastern_australia', 'australia', //
  ['western_australia', 'new_guinea']), //
  new Country._('indonesia', 'australia', //
  ['siam', 'new_guinea', 'western_australia']), //
  new Country._('new_guinea', 'australia', //
  ['indonesia', 'eastern_australia', 'western_australia']), //
  new Country._('western_australia', 'australia', //
  ['eastern_australia', 'indonesia', 'new_guinea']), //
  // south_america
  new Country._('argentina', 'south_america', //
  ['brazil', 'peru']), //
  new Country._('brazil', 'south_america', //
  ['north_africa', 'venezuela', 'argentina', 'peru']), //
  new Country._('peru', 'south_america', //
  ['venezuela', 'brazil', 'argentina']), //
  new Country._('venezuela', 'south_america', //
  ['central_america', 'brazil', 'peru']), //
  // africa
  new Country._('congo', 'africa', //
  ['east_africa', 'south_africa', 'north_africa']), //
  new Country._('egypt', 'africa', //
  ['southern_europe', 'middle_east', 'east_africa', 'north_africa']), //
  new Country._('east_africa', 'africa', //
  ['middle_east', 'madagascar', 'south_africa', 'congo', 'north_africa',
      'egypt']), //
  new Country._('madagascar', 'africa', //
  ['east_africa', 'south_africa']), //
  new Country._('north_africa', 'africa', //
  ['southern_europe', 'western_europe', 'brazil', 'egypt', 'east_africa',
      'congo']), //
  new Country._('south_africa', 'africa', //
  ['madagascar', 'east_africa', 'congo']), //
  // north_america
  new Country._('alaska', 'north_america', //
  ['kamchatka', 'northwest_territory', 'alberta']), //
  new Country._('alberta', 'north_america', //
  ['alaska', 'ontario', 'northwest_territory', 'western_united_states']), //
  new Country._('central_america', 'north_america', //
  ['venezuela', 'eastern_united_states', 'western_united_states']), //
  new Country._('eastern_united_states', 'north_america', //
  ['quebec', 'ontario', 'western_united_states', 'central_america']), //
  new Country._('greenland', 'north_america', //
  ['iceland', 'ontario', 'northwest_territory', 'quebec']), //
  new Country._('northwest_territory', 'north_america', //
  ['alaska', 'ontario', 'greenland', 'alberta']), //
  new Country._('ontario', 'north_america', //
  ['northwest_territory', 'greenland', 'eastern_united_states',
      'western_united_states', 'quebec', 'alberta']), //
  new Country._('quebec', 'north_america', //
  ['greenland', 'ontario', 'eastern_united_states']), //
  new Country._('western_united_states', 'north_america', //
  ['alberta', 'ontario', 'eastern_united_states', 'central_america']), //
  // europe
  new Country._('great_britain', 'europe', //
  ['iceland', 'western_europe', 'northern_europe', 'scandinavia']), //
  new Country._('iceland', 'europe', //
  ['greenland', 'great_britain', 'scandinavia']), //
  new Country._('northern_europe', 'europe', //
  ['ukraine', 'scandinavia', 'great_britain', 'western_europe',
      'southern_europe']), //
  new Country._('scandinavia', 'europe', //
  ['iceland', 'great_britain', 'northern_europe', 'ukraine']), //
  new Country._('southern_europe', 'europe', //
  ['north_africa', 'egypt', 'middle_east', 'ukraine', 'northern_europe',
      'western_europe']), //
  new Country._('ukraine', 'europe', //
  ['ural', 'afghanistan', 'middle_east', 'southern_europe', 'northern_europe',
      'scandinavia']), //
  new Country._('western_europe', 'europe', //
  ['north_africa', 'southern_europe', 'northern_europe', 'great_britain']), //
  // asia
  new Country._('afghanistan', 'asia', //
  ['ukraine', 'ural', 'china', 'india', 'middle_east']), //
  new Country._('china', 'asia', //
  ['siberia', 'ural', 'afghanistan', 'india', 'siam', 'mongolia']), //
  new Country._('india', 'asia', //
  ['middle_east', 'afghanistan', 'china', 'siam']), //
  new Country._('irkutsk', 'asia', //
  ['siberia', 'kamchatka', 'mongolia', 'yakursk']), //
  new Country._('japan', 'asia', //
  ['kamchatka', 'mongolia']), //
  new Country._('kamchatka', 'asia', //
  ['alaska', 'yakursk', 'irkutsk', 'mongolia', 'japan']), //
  new Country._('ural', 'asia', //
  ['siberia', 'china', 'afghanistan', 'ukraine']), //
  new Country._('middle_east', 'asia', //
  ['southern_europe', 'ukraine', 'afghanistan', 'india', 'egypt', 'east_africa']
      ), //
  new Country._('mongolia', 'asia', //
  ['china', 'siberia', 'irkutsk', 'kamchatka', 'japan']), //
  new Country._('siam', 'asia', //
  ['india', 'china', 'indonesia']), //
  new Country._('siberia', 'asia', //
  ['yakursk', 'irkutsk', 'mongolia', 'china', 'ural']), //
  new Country._('yakursk', 'asia', //
  ['kamchatka', 'siberia', 'irkutsk']), //
];
