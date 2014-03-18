import 'dart:html';
import 'dart:svg';
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

  String center(String svg) {
    if (svgPaths == null) return '';
    final PathElement path = new PathElement()..setAttribute('d', svg);
    $['svg'].append(path);
    final b = path.getBBox();
    final x = (b.x + b.width / 2);
    final y = (b.y + b.height / 2);
    path.remove();
    return "$x $y";
  }
}
