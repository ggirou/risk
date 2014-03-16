import 'dart:html';
import 'dart:convert';

@MirrorsUsed(targets: 'risk.map')
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/map.dart';


@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final List<Country> countries = COUNTRIES;

  final Map<Country, String> svgPaths = toObservable({});

  @observable
  String selection;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then((json) {
      final svgDatas = JSON.decode(json);
      for (final c in countries) {
        svgPaths[c] = svgDatas[c.id];
      }
    });
  }

  countryClick(Event e, var detail, Element target) => target.classes.toggle(
      'selected');

  countryEnter(Event e, var detail, Element target) => selection = target.id;

  countryLeave(Event e, var detail, Element target) => selection = '';
}
