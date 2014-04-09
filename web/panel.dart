import 'package:polymer/polymer.dart';


@CustomTag('risk-panel')
class RiskPanel extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @published
  String title;

  RiskPanel.created(): super.created();
}