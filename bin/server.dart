library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/event.dart';
import 'package:risk/game.dart';

final int port = 8080;

VirtualDirectory vDir;

main() {
  runZoned(() {
    HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
      print("Risk is running on http://${server.address.address}:$port ");
      vDir = new VirtualDirectory(Platform.script.resolve('../web').toFilePath()
          )
          ..jailRoot = false
          ..allowDirectoryListing = true
          ..directoryHandler = directoryHandler;
      final riskServer = new RiskWsServer();
      server.listen((HttpRequest req) {
        if (req.uri.path == '/ws') {
          WebSocketTransformer.upgrade(req).then(riskServer.handleWebSocket);
        } else {
          vDir.serveRequest(req);
        }
      });
    });
  }, onError: (Error e) => print("An error occurred $e"));
}

void directoryHandler(dir, request) {
  final indexUri = new Uri.file(dir.path).resolve('index.html');
  vDir.serveFile(new File(indexUri.toFilePath()), request);
}



class RiskWsServer {
  final Map<int, WebSocket> _clients = {};
  final RiskGameEngine game = new RiskGameEngine();
  final List _eventsHistory = [];

  final _eventController = new StreamController.broadcast();
  int currentPlayerId = 1;
  
  void handleWebSocket(WebSocket ws) {
    final playerId = currentPlayerId++;
    
    _connectPlayer(playerId, ws);
    
    ws.map(JSON.decode).map(_logEvent("IN", playerId))
      .map(EVENT.decode)
      .where((event) => event is PlayerEvent && event.playerId == playerId) // Avoid unknown event and cheater
      // TODO: should be transform(game.add) when game will implement Transformer issue #20
      .map(game.handle).where((e) => e != null) // Update game state and output new events
      .map(_storeAndDispatch)
      .listen(_handleEvents)
      .onDone(() => _connectionLost(playerId)); // Connection is lost
  }

  void _connectPlayer(int playerId, WebSocket ws) {
    print("Player $playerId connected");

    _clients[playerId] = ws;
    
    // Keep incoming events in a buffer
    StreamController eventsBuffer = new StreamController()..addStream(_eventController.stream);

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()..playerId= playerId);
    stream.addStream(new Stream.fromIterable(_eventsHistory))
      .then((_) => stream.addStream(eventsBuffer.stream));

    ws.addStream(stream.stream.map(EVENT.encode).map(_logEvent("OUT", playerId)).map(JSON.encode));
  }

  _storeAndDispatch(event) {
    _eventsHistory.add(event);
    _eventController.add(event);
    return event;
  }

  _handleEvents(event) {
    if(event is LeaveGame) {
      _handleLeaveGame(event);
    }
  }
  
  _handleLeaveGame(LeaveGame event) {
    print("Player ${event.playerId} is leaving");
    _removePlayer(event.playerId);
  }

  _connectionLost(int playerId) {
    print("Connection closed");
    if(_removePlayer(playerId)) {
      _storeAndDispatch(new LeaveGame()..playerId = playerId);
    }
  }

  bool _removePlayer(int playerId) {
    var client = _clients.remove(playerId);
    if (client != null) {
      client.close();
    }
    return client != null;
  }

  _logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}