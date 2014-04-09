@MirrorsUsed(targets: const ['risk.game',])
import 'dart:mirrors';

import 'package:polymer/polymer.dart';
import 'package:risk/client.dart';


@CustomTag('risk-history')
class RiskHistory extends PolymerElement {
  // Whether styles from the document apply to the contents of the component
  bool get applyAuthorStyles => true;

  @published
  RiskGameState game;

  RiskHistory.created(): super.created();

  bool isArmyMoved(EngineEvent e) => e is ArmyMoved;
  bool isArmyPlaced(EngineEvent e) => e is ArmyPlaced;
  bool isBattleEnded(EngineEvent e) => e is BattleEnded;
  bool isGameStarted(EngineEvent e) => e is GameStarted;
  bool isNextPlayer(EngineEvent e) => e is NextPlayer;
  bool isNextStep(EngineEvent e) => e is NextStep;
  bool isPlayerJoined(EngineEvent e) => e is PlayerJoined;
  bool isSetupEnded(EngineEvent e) => e is SetupEnded;
  bool isWelcome(EngineEvent e) => e is Welcome;
}