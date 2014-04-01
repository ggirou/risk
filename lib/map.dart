library risk.map;

class Continent {
  final String id;
  final int bonus;
  final List<String> countries;

  const Continent(this.id, this.bonus, this.countries);
}

class Country {
  final String id;
  final List<String> neighbours;

  const Country(this.id, this.neighbours);
}

const List<Continent> CONTINENTS = const [//
  const Continent('australia', 2, const ["eastern_australia", "indonesia",
      "new_guinea", "western_australia"]), //
  const Continent('north_america', 5, const ["alaska", "alberta",
      "central_america", "eastern_united_states", "greenland", "northwest_territory",
      "ontario", "quebec", "western_united_states"]), //
  const Continent('south_america', 2, const ["argentina", "brazil", "peru",
      "venezuela"]), //
  const Continent('africa', 3, const ["congo", "egypt", "east_africa",
      "madagascar", "north_africa", "south_africa"]), //
  const Continent('europe', 5, const ["great_britain", "iceland",
      "northern_europe", "scandinavia", "southern_europe", "ukraine",
      "western_europe"]), //
  const Continent('asia', 7, const ["afghanistan", "china", "india", "irkutsk",
      "japan", "kamchatka", "ural", "middle_east", "mongolia", "siam", "siberia",
      "yakursk"]),//
];

const Map<String, Country> COUNTRIES = const {
  // australia
  'eastern_australia': const Country('eastern_australia', const
      ['western_australia', 'new_guinea']),
  'indonesia': const Country('indonesia', const ['siam', 'new_guinea',
      'western_australia']),
  'new_guinea': const Country('new_guinea', const ['indonesia',
      'eastern_australia', 'western_australia']),
  'western_australia': const Country('western_australia', const
      ['eastern_australia', 'indonesia', 'new_guinea']),
  // south_america
  'argentina': const Country('argentina', const ['brazil', 'peru']),
  'brazil': const Country('brazil', const ['north_africa', 'venezuela',
      'argentina', 'peru']),
  'peru': const Country('peru', const ['venezuela', 'brazil', 'argentina']),
  'venezuela': const Country('venezuela', const ['central_america', 'brazil',
      'peru']),
  // africa
  'congo': const Country('congo', const ['east_africa', 'south_africa',
      'north_africa']),
  'egypt': const Country('egypt', const ['southern_europe', 'middle_east',
      'east_africa', 'north_africa']),
  'east_africa': const Country('east_africa', const ['middle_east',
      'madagascar', 'south_africa', 'congo', 'north_africa', 'egypt']),
  'madagascar': const Country('madagascar', const ['east_africa',
      'south_africa']),
  'north_africa': const Country('north_africa', const ['southern_europe',
      'western_europe', 'brazil', 'egypt', 'east_africa', 'congo']),
  'south_africa': const Country('south_africa', const ['madagascar',
      'east_africa', 'congo']),
  // north_america
  'alaska': const Country('alaska', const ['kamchatka', 'northwest_territory',
      'alberta']),
  'alberta': const Country('alberta', const ['alaska', 'ontario',
      'northwest_territory', 'western_united_states']),
  'central_america': const Country('central_america', const ['venezuela',
      'eastern_united_states', 'western_united_states']),
  'eastern_united_states': const Country('eastern_united_states', const
      ['quebec', 'ontario', 'western_united_states', 'central_america']),
  'greenland': const Country('greenland', const ['iceland', 'ontario',
      'northwest_territory', 'quebec']),
  'northwest_territory': const Country('northwest_territory', const ['alaska',
      'ontario', 'greenland', 'alberta']),
  'ontario': const Country('ontario', const ['northwest_territory', 'greenland',
      'eastern_united_states', 'western_united_states', 'quebec', 'alberta']),
  'quebec': const Country('quebec', const ['greenland', 'ontario',
      'eastern_united_states']),
  'western_united_states': const Country('western_united_states', const
      ['alberta', 'ontario', 'eastern_united_states', 'central_america']),
  // europe
  'great_britain': const Country('great_britain', const ['iceland',
      'western_europe', 'northern_europe', 'scandinavia']),
  'iceland': const Country('iceland', const ['greenland', 'great_britain',
      'scandinavia']),
  'northern_europe': const Country('northern_europe', const ['ukraine',
      'scandinavia', 'great_britain', 'western_europe', 'southern_europe']),
  'scandinavia': const Country('scandinavia', const ['iceland', 'great_britain',
      'northern_europe', 'ukraine']),
  'southern_europe': const Country('southern_europe', const ['north_africa',
      'egypt', 'middle_east', 'ukraine', 'northern_europe', 'western_europe']),
  'ukraine': const Country('ukraine', const ['ural', 'afghanistan',
      'middle_east', 'southern_europe', 'northern_europe', 'scandinavia']),
  'western_europe': const Country('western_europe', const ['north_africa',
      'southern_europe', 'northern_europe', 'great_britain']),
  // asia
  'afghanistan': const Country('afghanistan', const ['ukraine', 'ural', 'china',
      'india', 'middle_east']),
  'china': const Country('china', const ['siberia', 'ural', 'afghanistan',
      'india', 'siam', 'mongolia']),
  'india': const Country('india', const ['middle_east', 'afghanistan', 'china',
      'siam']),
  'irkutsk': const Country('irkutsk', const ['siberia', 'kamchatka', 'mongolia',
      'yakursk']),
  'japan': const Country('japan', const ['kamchatka', 'mongolia']),
  'kamchatka': const Country('kamchatka', const ['alaska', 'yakursk', 'irkutsk',
      'mongolia', 'japan']),
  'ural': const Country('ural', const ['siberia', 'china', 'afghanistan',
      'ukraine']),
  'middle_east': const Country('middle_east', const ['southern_europe',
      'ukraine', 'afghanistan', 'india', 'egypt', 'east_africa']),
  'mongolia': const Country('mongolia', const ['china', 'siberia', 'irkutsk',
      'kamchatka', 'japan']),
  'siam': const Country('siam', const ['india', 'china', 'indonesia']),
  'siberia': const Country('siberia', const ['yakursk', 'irkutsk', 'mongolia',
      'china', 'ural']),
  'yakursk': const Country('yakursk', const ['kamchatka', 'siberia', 'irkutsk']
      ),
};
