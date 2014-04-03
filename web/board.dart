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

  @observable
  List<String> selectables = [];

  String _from;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then(JSON.decode).then((e) =>
        svgPaths = e);
  }

  modeChanged(String oldValue, String newValue) {
    final countryIds = countries.map((c) => c.id);
    if (newValue == MODE_SELECT) {
      selectables = countryIds.where(isMine).toList();
    } else if (mode == MODE_ATTACK) {
      selectables = countryIds.where(canAttackFrom).toList();
    } else if (mode == MODE_MOVE) {
      selectables = countryIds.where(isMine).toList();
    }
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
        selectables = COUNTRIES[_from].neighbours.where(isNotMine).toList();
      } else {
        final neighbours = COUNTRIES[_from].neighbours;

        // "to" must be a neighbour of "from"
        if (!neighbours.contains(countryId)) return;

        // "to" must not be mine
        if (isMine(countryId)) return;

        selectables = [];
        dispatchEvent(new CustomEvent('attack', detail: {
          'from': _from,
          'to': countryId
        }));
        _from = null;
      }
    } else if (mode == MODE_MOVE) {
      // select "from"
      if (_from == null) {
        // country selected must be mine
        if (isNotMine(countryId)) return;

        _from = countryId;
        selectables = COUNTRIES[_from].neighbours.where(isMine).toList();
      } else {
        final neighbours = COUNTRIES[_from].neighbours;

        // "to" must be a neighbour of "from"
        if (!neighbours.contains(countryId)) return;

        // "to" must be mine
        if (isNotMine(countryId)) return;

        selectables = [];
        dispatchEvent(new CustomEvent('move', detail: {
          'from': _from,
          'to': countryId
        }));
        _from = null;
      }
      return;
    }
  }

  bool isMine(String country) => game.countries[country].playerId == playerId;
  bool isNotMine(String country) => !isMine(country);
  bool canAttackFrom(String country) => isMine(country) &&
      game.countries[country].armies > 1 && COUNTRIES[country].neighbours.any((to) =>
      isNotMine(to));

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
