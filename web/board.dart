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
  final List<Country> countries = COUNTRIES;

  @published
  RiskGame game = new RiskGame(countries: FAKE_COUNTRY_STATES);

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
  'eastern_australia': new CountryState(1, 2),
  'indonesia': new CountryState(0, 2),
  'new_guinea': new CountryState(4, 4),
  'alaska': new CountryState(2, 2),
  'ontario': new CountryState(2, 3),
  'northwest_territory': new CountryState(0, 2),
  'venezuela': new CountryState(3, 2),
  'madagascar': new CountryState(2, 2),
  'north_africa': new CountryState(3, 3),
  'greenland': new CountryState(4, 2),
  'iceland': new CountryState(0, 4),
  'great_britain': new CountryState(3, 1),
  'scandinavia': new CountryState(4, 3),
  'japan': new CountryState(3, 2),
  'yakursk': new CountryState(1, 2),
  'kamchatka': new CountryState(3, 1),
  'siberia': new CountryState(3, 4),
  'ural': new CountryState(3, 2),
  'afghanistan': new CountryState(2, 4),
  'middle_east': new CountryState(2, 3),
  'india': new CountryState(2, 4),
  'siam': new CountryState(1, 4),
  'china': new CountryState(4, 1),
  'mongolia': new CountryState(4, 1),
  'irkutsk': new CountryState(1, 3),
  'ukraine': new CountryState(4, 1),
  'southern_europe': new CountryState(4, 2),
  'western_europe': new CountryState(2, 3),
  'northern_europe': new CountryState(1, 1),
  'egypt': new CountryState(4, 1),
  'east_africa': new CountryState(1, 3),
  'congo': new CountryState(4, 4),
  'south_africa': new CountryState(1, 1),
  'brazil': new CountryState(1, 4),
  'argentina': new CountryState(1, 4),
  'eastern_united_states': new CountryState(3, 1),
  'western_united_states': new CountryState(4, 2),
  'quebec': new CountryState(1, 1),
  'central_america': new CountryState(4, 1),
  'peru': new CountryState(4, 2),
  'western_australia': new CountryState(0, 1),
  'alberta': new CountryState(1, 3),
};
