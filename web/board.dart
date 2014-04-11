library risk.element.board;

import 'dart:convert';
import 'dart:html';

@MirrorsUsed(targets: const ['risk.map', 'risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';

@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  @published
  RiskGameState game;

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

  selectableCountry(int activePlayerId, String turnStep, String selectedCountryId, CountryState country) {
    var handler = getClickHandler(activePlayerId, turnStep, selectedCountryId, country.countryId);
    return handler != countryUnselect && (selectedCountryId == null || handler != countrySelect);
  }

  countryClick(Event e, var detail, Element target) {
    var handler = getClickHandler(game.activePlayerId, game.turnStep, selectedCountryId, target.dataset['country']);
    handler(e, detail, target);
  }

  getClickHandler(int activePlayerId, String turnStep, String selectedCountryId, String countryId) {
    if (activePlayerId != playerId) {
      return countryUnselect;
    } else if(turnStep == RiskGameState.TURN_STEP_REINFORCEMENT) {
      if(isMine(countryId)) return countryPlaceArmy;
    } else if(turnStep == RiskGameState.TURN_STEP_ATTACK) {
      if(countryId == selectedCountryId) return countryUnselect;
      else if(canAttackFrom(countryId)) return countrySelect;
      else if(selectedCountryId != null && canAttackTo(selectedCountryId, countryId)) return countryAttack;
    } else if(turnStep == RiskGameState.TURN_STEP_FORTIFICATION) {
      if(countryId == selectedCountryId) return countryUnselect;
      else if(canFortifyFrom(countryId)) return countrySelect;
      else if(selectedCountryId != null && canFortifyTo(selectedCountryId, countryId)) return countryMove;
    }
    return countryUnselect;
  }

  countrySelect(Event e, var detail, Element target) => selectedCountryId = target.dataset['country'];
  countryUnselect(Event e, var detail, Element target) => selectedCountryId = null;
  countryPlaceArmy(Event e, var detail, Element target) =>
    fire('selection', detail: target.dataset['country']);
  countryAttack(Event e, var detail, Element target) => fire('attack', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });
  countryMove(Event e, var detail, Element target) => fire('move', detail: {
    'from': selectedCountryId,
    'to': target.dataset['country']
  });

  bool isMine(String country) => game.countries[country].playerId == playerId;
  bool isNotMine(String country) => !isMine(country);
  bool areNeighbours(String myCountry, String strangeCountry) =>
      COUNTRY_BY_ID[myCountry].neighbours.contains(strangeCountry);
  bool canAttackFrom(String country) => isMine(country) &&
      game.countries[country].armies > 1 && COUNTRY_BY_ID[country].neighbours.any((to) =>
      isNotMine(to));
  bool canAttackTo(String from, String to) => isNotMine(to) &&
      areNeighbours(from, to);
  bool canFortifyFrom(String country) => isMine(country) &&
      game.countries[country].armies > 1 && COUNTRY_BY_ID[country].neighbours.any((to) =>
      isMine(to));
  bool canFortifyTo(String from, String to) => isMine(to) &&
      areNeighbours(from, to);

  String color(int playerId) {
    return playerId == null ? "white" : game.players[playerId].color;
  }
}
