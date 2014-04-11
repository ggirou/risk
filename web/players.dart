@MirrorsUsed(targets: const ['risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';


@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @published
  Iterable<PlayerState> players;

  @published
  int activePlayerId;

  RiskPlayers.created(): super.created();
}