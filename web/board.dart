import 'dart:html';
import 'package:polymer/polymer.dart';

import 'constants.dart' as constants;

@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final List countries = constants.countries;

  @published
  final Map<String, String> countryStyles = toObservable({});

  RiskBoard.created(): super.created();

  countryClick(Event e, var detail, Element target) => countryStyles[target.id]
      = "fill: red;";
}
