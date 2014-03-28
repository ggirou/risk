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
  }, onError: (e) => print("An error occurred $e"));
}

void directoryHandler(dir, request) {
  final indexUri = new Uri.file(dir.path).resolve('index.html');
  vDir.serveFile(new File(indexUri.toFilePath()), request);
}

abstract class RiskWsServer {
  factory RiskWsServer() => new _RiskWsServer();

  handleWebSocket(event);
}

class _RiskWsServer implements RiskWsServer {
  final Map<int, WebSocket> _clients = {};
  final RiskGameEngine game;
  final List _eventsHistory = [];

  final StreamController _eventController;
  int currentPlayerId = 1;

  _RiskWsServer() : this._(new StreamController.broadcast());
  _RiskWsServer._(StreamController eventController)
      : _eventController = eventController,
        game = new RiskGameEngine.server(eventController) {
    _eventController.stream.listen(_eventsHistory.add);
  }

  void handleWebSocket(WebSocket ws) {
    final playerId = currentPlayerId++;

    connectPlayer(playerId, ws);

    ws.map(JSON.decode).map(logEvent("IN", playerId))
      .map(EVENT.decode)
      .where((event) => event is PlayerEvent && event.playerId == playerId) // Avoid unknown event and cheater
      .listen((event) {
        // store and dispatch
        storeAndDispatch(event);

        // handle event in game engine
        game.handle(event);

        // handle Leaves
        if(event is LeaveGame) {
          handleLeaveGame(event);
        }
      })
      .onDone(() => connectionLost(playerId)); // Connection is lost
  }

  void connectPlayer(int playerId, WebSocket ws) {
    print("Player $playerId connected");

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()..playerId= playerId);
    _eventsHistory.forEach(stream.add);
    stream.addStream(_eventController.stream);

    ws.addStream(stream.stream.map(EVENT.encode).map(logEvent("OUT", playerId)).map(JSON.encode));
  }

  storeAndDispatch(event) {
    _eventController.add(event);
    return event;
  }

  handleLeaveGame(LeaveGame event) {
    print("Player ${event.playerId} is leaving");
    removePlayer(event.playerId);
  }

  connectionLost(int playerId) {
    print("Connection closed");
    if(removePlayer(playerId)) {
      storeAndDispatch(new LeaveGame()..playerId = playerId);
    }
  }

  bool removePlayer(int playerId) {
    var client = _clients.remove(playerId);
    if (client != null) {
      client.close();
    }
    return client != null;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}