@MirrorsUsed(targets: const ['risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';


@CustomTag('risk-player-inline')
class RiskPlayerInline extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @published
  PlayerState player;

  RiskPlayerInline.created(): super.created();
}