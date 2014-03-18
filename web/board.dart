import 'dart:html';
import 'dart:convert';

@MirrorsUsed(targets: 'risk.map')
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/map.dart';


@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final List<Country> countries = COUNTRIES;

  @observable
  var svgPaths;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('svg-datas.json').then(JSON.decode).then((e) =>
        svgPaths = e);
  }

  countryClick(Event e, var detail, Element target) {
    target.classes.toggle('selected');
  }
}
