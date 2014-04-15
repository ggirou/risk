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

  ARiskWsServer riskWsServer() {
    engine = new RiskGameEngineMock();
    return new RiskWsServer.fromStreamCtrl(engine);
  }


  setUp(() {
    wsServer = riskWsServer();
  });

  group('', () {
    test('should add a player', () {
      // GIVEN
      Stream stream = new Stream.fromIterable(['{"event":"Welcome","data":{"playerId":1}}', //
      '{"event":"JoinGame","data":{"playerId":1,"name":"mat","avatar":"mao-zedong.png","color":"#f7676d"}}', //
      '{"event":"PlayerJoined","data":{"playerId":1,"name":"mat","avatar":"mao-zedong.png","color":"#f7676d"}}']);

      /*check() {
        // THEN
        print("THEN -------------");
        engine.getLogs(callsTo('handle')).verify(happenedExactly(3));
      }
      stream.listen(null, onDone:expectAsync(check));

      // WHEN
      wsServer.listen(stream, 1);*/
    });


  });
}

class RiskGameEngineMock extends Mock implements RiskGameEngine {
}
