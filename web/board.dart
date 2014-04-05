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

@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  @published
  RiskGame game;

  @published
  int playerId;

  @observable
  var svgPaths;

  @observable
  String selectedCountryId;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then(JSON.decode).then((e) =>
        svgPaths = e);
  }
  
  selectableCountry(String turnStep, String selectedCountryId, String countryId) {
    if(turnStep == TURN_STEP_REINFORCEMENT) {
      if(isMine(countryId)) return true;
    } else if(turnStep == TURN_STEP_ATTACK) {
      if(countryId == selectedCountryId) return false;
      else if(selectedCountryId == null && isMine(countryId)) return true;
      else if(selectedCountryId != null && isNotMine(countryId) && areNeighbours(selectedCountryId, countryId)) return true;
    } else if(turnStep == TURN_STEP_FORTIFICATION) {
      if(countryId == selectedCountryId) return false;
      else if(selectedCountryId == null && isMine(countryId)) return true;
      else if(selectedCountryId != null && isMine(countryId) && areNeighbours(selectedCountryId, countryId)) return true;
    }
    return false;
  }
  
  countryClick(Event e, var detail, Element target) {
    getClickHandler(game.turnStep, target.dataset['country'])(e, detail, target);
  }

  getClickHandler(String turnStep, String countryId) {
    if(turnStep == TURN_STEP_REINFORCEMENT) {
      if(isMine(countryId)) return countryPlaceArmy;
    } else if(turnStep == TURN_STEP_ATTACK) {
      if(countryId == selectedCountryId) return countryUnselect;
      else if(isMine(countryId)) return countrySelect;
      else if(selectedCountryId != null && isNotMine(countryId) && areNeighbours(selectedCountryId, countryId)) return countryAttack;
    } else if(turnStep == TURN_STEP_FORTIFICATION) {
      if(countryId == selectedCountryId) return countryUnselect;
      else if(isMine(countryId)) return countrySelect;
      else if(selectedCountryId != null && isMine(countryId) && areNeighbours(selectedCountryId, countryId)) return countryMove;
    }
    return countryUnselect;
  }
  
  countrySelect(Event e, var detail, Element target) => selectedCountryId = target.dataset['country'];
  countryUnselect(Event e, var detail, Element target) => selectedCountryId = null;
  countryPlaceArmy(Event e, var detail, Element target) =>
    dispatchEvent(new CustomEvent('selection', detail: target.dataset['country']));
  countryAttack(Event e, var detail, Element target) => dispatchEvent(new CustomEvent('attack', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  }));
  countryMove(Event e, var detail, Element target) => dispatchEvent(new CustomEvent('move', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  }));
  
  bool isMine(String country) => game.countries[country].playerId == playerId;
  bool isNotMine(String country) => !isMine(country);
  bool canAttackFrom(String country) => isMine(country) &&
      game.countries[country].armies > 1 && COUNTRIES[country].neighbours.any((to) =>
      isNotMine(to));
  bool canFortifyFrom(String country) => isMine(country) &&
      game.countries[country].armies > 1 && COUNTRIES[country].neighbours.any((to) =>
      isMine(to));
  bool areNeighbours(String myCountry, String strangeCountry) =>
      COUNTRIES[myCountry].neighbours.contains(strangeCountry);

  String color(String countryId) {
    final cs = game.countries[countryId];
    return cs == null || cs.playerId == null ? "white" : COLORS[cs.playerId %
        COLORS.length];
  }
}
