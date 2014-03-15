import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:risk/countries.dart' as c show decodeJson;
import 'package:risk/countries.dart' show Country;


@CustomTag('risk-board')
class RiskBoard extends PolymerElement {
  final List<Country> countries = toObservable([]);

  @observable
  String selection;

  RiskBoard.created(): super.created() {
    HttpRequest.getString('countries.json').then((json) => countries.addAll(
        c.decodeJson(json)));
  }

  countryClick(Event e, var detail, Element target) => target.classes.toggle(
      'selected');

  countryEnter(Event e, var detail, Element target) => selection = target.id;

  countryLeave(Event e, var detail, Element target) => selection = '';
}
