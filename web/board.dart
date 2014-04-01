import 'dart:html';
import 'dart:convert';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/game.dart';
import 'package:risk/map.dart';

// grabbed on http://i.stack.imgur.com/VewLV.png (http://gamedev.stackexchange.com/questions/46463/is-there-an-optimum-set-of-colors-for-10-players)
final COLORS = ['#FF8080', '#78BEF0', '#DED16F', '#CC66C9', '#5DBAAC',
    '#F2A279', '#7182E3', '#92D169', '#BF607C', '#7CDDF7'];

@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final Iterable<Country> countries = COUNTRIES.values;

  @published
  RiskGame game = new RiskGame()..countries = FAKE_COUNTRY_STATES;

  @observable
  var svgPaths;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then(JSON.decode).then((e) =>
        svgPaths = e);
  }

  countryClick(Event e, var detail, Element target) {
    target.classes.toggle('selected');
  }

  String color(Country country) {
    final cs = game.countries[country.id];
    return cs == null || cs.playerId == null ? "white" : COLORS[cs.playerId %
        COLORS.length];
  }
}

final FAKE_COUNTRY_STATES = {
  'eastern_australia': new CountryState('eastern_australia', playerId: 1, armies: 2),
  'indonesia': new CountryState('indonesia', playerId: 0, armies: 2),
  'new_guinea': new CountryState('new_guinea', playerId: 4, armies: 4),
  'alaska': new CountryState('alaska', playerId: 2, armies: 2),
  'ontario': new CountryState('ontario', playerId: 2, armies: 3),
  'northwest_territory': new CountryState('northwest_territory', playerId: 0, armies: 2),
  'venezuela': new CountryState('venezuela', playerId: 3, armies: 2),
  'madagascar': new CountryState('madagascar', playerId: 2, armies: 2),
  'north_africa': new CountryState('north_africa', playerId: 3, armies: 3),
  'greenland': new CountryState('greenland', playerId: 4, armies: 2),
  'iceland': new CountryState('iceland', playerId: 0, armies: 4),
  'great_britain': new CountryState('great_britain', playerId: 3, armies: 1),
  'scandinavia': new CountryState('scandinavia', playerId: 4, armies: 3),
  'japan': new CountryState('japan', playerId: 3, armies: 2),
  'yakursk': new CountryState('yakursk', playerId: 1, armies: 2),
  'kamchatka': new CountryState('kamchatka', playerId: 3, armies: 1),
  'siberia': new CountryState('siberia', playerId: 3, armies: 4),
  'ural': new CountryState('ural', playerId: 3, armies: 2),
  'afghanistan': new CountryState('afghanistan', playerId: 2, armies: 4),
  'middle_east': new CountryState('middle_east', playerId: 2, armies: 3),
  'india': new CountryState('india', playerId: 2, armies: 4),
  'siam': new CountryState('siam', playerId: 1, armies: 4),
  'china': new CountryState('china', playerId: 4, armies: 1),
  'mongolia': new CountryState('mongolia', playerId: 4, armies: 1),
  'irkutsk': new CountryState('irkutsk', playerId: 1, armies: 3),
  'ukraine': new CountryState('ukraine', playerId: 4, armies: 1),
  'southern_europe': new CountryState('southern_europe', playerId: 4, armies: 2),
  'western_europe': new CountryState('western_europe', playerId: 2, armies: 3),
  'northern_europe': new CountryState('northern_europe', playerId: 1, armies: 1),
  'egypt': new CountryState('egypt', playerId: 4, armies: 1),
  'east_africa': new CountryState('east_africa', playerId: 1, armies: 3),
  'congo': new CountryState('congo', playerId: 4, armies: 4),
  'south_africa': new CountryState('south_africa', playerId: 1, armies: 1),
  'brazil': new CountryState('brazil', playerId: 1, armies: 4),
  'argentina': new CountryState('argentina', playerId: 1, armies: 4),
  'eastern_united_states': new CountryState('eastern_united_states', playerId: 3, armies: 1),
  'western_united_states': new CountryState('western_united_states', playerId: 4, armies: 2),
  'quebec': new CountryState('quebec', playerId: 1, armies: 1),
  'central_america': new CountryState('central_america', playerId: 4, armies: 1),
  'peru': new CountryState('peru', playerId: 4, armies: 2),
  'western_australia': new CountryState('western_australia', playerId: 0, armies: 1),
  'alberta': new CountryState('alberta', playerId: 1, armies: 3),
};
