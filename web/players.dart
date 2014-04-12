@MirrorsUsed(targets: const ['risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/risk.dart';


@CustomTag('risk-players')
class RiskPlayers extends PolymerElement {
  @published
  Iterable<PlayerState> players;

  @published
  int activePlayerId;

  RiskPlayers.created(): super.created();
}