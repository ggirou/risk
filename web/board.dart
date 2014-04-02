library risk.element.board;

import 'dart:convert';
import 'dart:html';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/game.dart';
import 'package:risk/map.dart';

// grabbed on http://i.stack.imgur.com/VewLV.png (http://gamedev.stackexchange.com/questions/46463/is-there-an-optimum-set-of-colors-for-10-players)
final COLORS = ['#FF8080', '#78BEF0', '#DED16F', '#CC66C9', '#5DBAAC',
    '#F2A279', '#7182E3', '#92D169', '#BF607C', '#7CDDF7'];

/// select on of my countries
const String MODE_SELECT = 'select';

/// select a battle to do
const String MODE_ATTACK = 'attack';

/// select a move to do
const String MODE_MOVE = 'move';

@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  @observable
  final Iterable<Country> countries = COUNTRIES.values;

  @published
  RiskGame game;

  @published
  int playerId;

  @published
  String mode;

  @observable
  var svgPaths;

  String _from;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then(JSON.decode).then((e) =>
        svgPaths = e);
  }

  countryClick(Event e, var detail, Element target) {
    if (mode == null) return;

    // country
    final countryId = target.dataset['country'];

    if (mode == MODE_SELECT) {
      // country selected is not mine
      if (game.countries[countryId].playerId != playerId) return;

      dispatchEvent(new CustomEvent('selection', detail: countryId));
    } else if (mode == MODE_ATTACK) {
      // select "from"
      if (_from == null) {
        // country selected must be mine
        if (isNotMine(countryId)) return;

        _from = countryId;
        _highlight(COUNTRIES[_from].neighbours.where(isNotMine));
      } else {
        final neighbours = COUNTRIES[_from].neighbours;

        // "to" must be a neighbour of "from"
        if (!neighbours.contains(countryId)) return;

        // "to" must not be mine
        if (isMine(countryId)) return;

        _removeHighlight();
        dispatchEvent(new CustomEvent('attack', detail: {'from': _from, 'to': countryId}));
        _from = null;
      }
    } else if (mode == MODE_MOVE) {
      // select "from"
      if (_from == null) {
        // country selected must be mine
        if (isNotMine(countryId)) return;

        _from = countryId;
        _highlight(COUNTRIES[_from].neighbours.where(isMine));
      } else {
        final neighbours = COUNTRIES[_from].neighbours;

        // "to" must be a neighbour of "from"
        if (!neighbours.contains(countryId)) return;

        // "to" must be mine
        if (isNotMine(countryId)) return;

        _removeHighlight();
        dispatchEvent(new CustomEvent('move', detail: {'from': _from, 'to': countryId}));
        _from = null;
      }
      return;
    }
  }

  isMine(country) => game.countries[country].playerId == playerId;
  isNotMine(country) => !isMine(country);

  _highlight(Iterable<String> countries) {
    shadowRoot.querySelector('.shape').classes.remove('highlighted');
    countries.forEach((c) => _findPath(c).classes.add('highlighted'));
  }

  //$['path-${id}'] doesn't work
  Element _findPath(String id) => $['svg'].querySelector('#path-${id}');

  _removeHighlight() => _highlight([]);

  String color(Country country) {
    final cs = game.countries[country.id];
    return cs == null || cs.playerId == null ? "white" : COLORS[cs.playerId %
        COLORS.length];
  }

  redraw() {
    notifyPropertyChange(#game, null, game);
    notifyPropertyChange(#countries, null, countries);
  }
}
