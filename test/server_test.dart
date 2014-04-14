library risk.server.test;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import '../lib/server.dart';
import '../bin/server.dart';
import 'utils.dart';

main() {
  group('RiskWsServer', testRiskWsServer);
}

testRiskWsServer() {
  RiskGameEngine engine;
  StreamController streamController;
  ARiskWsServer wsServer;

  rethrowHandler(e) => throw e;

  ARiskWsServer riskWsServer() => new RiskWsServer.raw(engine, streamController);

  setUp(() {
    streamController = new StreamController.broadcast();
    engine = new RiskGameEngineMock();
    wsServer = riskWsServer();
  });

  group('', () {
    test('should add a player', () {
      // GIVEN
      Stream stream = new Stream.fromIterable(['{"event":"Welcome","data":{"playerId":1}}', //
      '{"event":"JoinGame","data":{"playerId":1,"name":"mat","avatar":"mao-zedong.png","color":"#f7676d"}}', //
      '{"event":"PlayerJoined","data":{"playerId":1,"name":"mat","avatar":"mao-zedong.png","color":"#f7676d"}}']);

      // WHEN
      //wsServer.handleWebSocket(stream);

      // THEN
    });


  });
}

class RiskGameEngineMock extends Mock implements RiskGameEngine {
  /*RiskGameEngineMock(eventController) {
    super(eventController, new RiskGameStateImpl());
  }*/

//hazard.when(callsTo('rollDices')).thenReturn([6, 1]).thenReturn([2, 1]);
}
