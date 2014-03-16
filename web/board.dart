import 'dart:html';
import 'dart:convert';

import 'package:polymer/polymer.dart';
import 'package:risk/map.dart';


@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final List<Country> countries = COUNTRIES;

  final _svgPaths = <Country, String>{};

  @observable
  String selection;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then((json) {
      final svgDatas = JSON.decode(json);
      for (final c in countries) {
        _svgPaths[c] = svgDatas[c.id];
      }
      notifyPropertyChange(#countries, null, countries);
    });
  }

  String svgPath(Country country) => _svgPaths[country];

  countryClick(Event e, var detail, Element target) => target.classes.toggle(
      'selected');

  countryEnter(Event e, var detail, Element target) => selection = target.id;

  countryLeave(Event e, var detail, Element target) => selection = '';
}
