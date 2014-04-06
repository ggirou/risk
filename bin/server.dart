library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/event.dart';
import 'package:risk/game.dart';
import 'package:risk/engine.dart';

const DEFAULT_PORT = 8080;
const DEFAULT_PATH = '../web';

VirtualDirectory vDir;

main(List<String> args) {
  int port = args.length > 0 ? int.parse(args[0], onError: (_) => DEFAULT_PORT) : DEFAULT_PORT;
  String path = Platform.script.resolve(args.length > 1 ? args[1] : DEFAULT_PATH).toFilePath();
  runZoned(() {
    HttpServer.bind(InternetAddress.ANY_IP_V4, port).then((server) {
      print("Risk is running on http://localhost:$port\nBase path: $path");
      vDir = new VirtualDirectory(path)
          ..jailRoot = false
          ..allowDirectoryListing = true
          ..directoryHandler = directoryHandler;
      var riskServer = new RiskWsServer();
      server.listen((HttpRequest req) {
        if (req.uri.path == '/ws') {
          WebSocketTransformer.upgrade(req).then(riskServer.handleWebSocket);
        } else if (req.uri.path == '/new') {
          riskServer = new RiskWsServer();
          req.response.redirect(req.uri.resolve('/'));
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

class RiskWsServer {
  final Map<int, WebSocket> _clients = {};
  final RiskGameEngine engine;

  final StreamController outputStream;
  int currentPlayerId = 1;

  RiskWsServer(): this._(new StreamController.broadcast());
  RiskWsServer._(StreamController eventController)
      : outputStream = eventController,
          engine = new RiskGameEngine(eventController, new RiskGame());

  void handleWebSocket(WebSocket ws) {
    final playerId = connectPlayer(ws);

    // Decode JSON
    ws.map(JSON.decode)
    // Log incoming events
    .map(logEvent("IN", playerId))
    // Decode events
    .map(EVENT.decode)
    // Avoid unknown events and cheaters
    .where((event) => event is PlayerEvent && event.playerId == playerId)
    // Handle events in game engine
    .listen(engine.handle)
    // Connection closed
    .onDone(() => print("Player $playerId left"));
  }

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(outputStream.stream);
     
    ws.addStream(stream.stream.map(EVENT.encode).map(logEvent("OUT", playerId)
        ).map(JSON.encode));

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}
