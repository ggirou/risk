@MirrorsUsed(targets: const ['risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';


@CustomTag('risk-player-vignette')
class RiskPlayerVignette extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @published
  PlayerState player;

  @published
  bool active;

  RiskPlayerVignette.created(): super.created();
}