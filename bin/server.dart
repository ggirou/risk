library risk.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:risk/event.dart';

final int port = 8080;

final List<PlayerEvent> _eventsHistory = [];
final Map<int, StreamController<PlayerEvent>> _clients = {};

VirtualDirectory vDir;

main() {
  runZoned(() {
    HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
      print("Risk is running on http://${server.address.address}:$port ");
      vDir = new VirtualDirectory(Platform.script.resolve('../web').toFilePath())
          ..jailRoot = false
          ..allowDirectoryListing = true
          ..directoryHandler = directoryHandler;

      server.listen((HttpRequest req) {
        if (req.uri.path == '/ws') {
          WebSocketTransformer.upgrade(req).then(handleWebSocket);
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

void handleWebSocket(WebSocket ws) {
  print("Player connected");
  final playerId = generatePlayerId();
  connectPlayer(playerId, ws);
  ws.map(JSON.decode).map(EVENT.decode)
    .where((event) => event != null && event.playerId == playerId) // Avoid unknown event and cheater 
    .listen(handleEvents)
    .onDone(() => disconnectPlayer(playerId)); // Connection is lost
}

int generatePlayerId() => new DateTime.now().millisecondsSinceEpoch;

void connectPlayer(int playerId, WebSocket ws){
  final controler = new StreamController<PlayerEvent>();
  _clients[playerId] = controler;
  final eventStream = controler.stream.map(EVENT.encode).map(JSON.encode);
  ws.addStream(eventStream);
  
  controler.add(new Welcome(playerId: playerId));
  // broadcast all events history to player
  _eventsHistory.forEach(controler.add);
  // TODO sent welcome to every body ?  
}

void disconnectPlayer(int playerId) {
  print("Connexion is lost");
  if(_clients.containsKey(playerId)){
    _clients[playerId].close();
    _clients.remove(playerId);
  }
  dispatchEventToAllPlayers(new LeaveGame(playerId: playerId));
}

void handleEvents(PlayerEvent event) {
  print("receive even=$event");
  // TODO event should be save after check validity
  _eventsHistory.add(event);
  // TODO dispatch event to all clients
  // TODO use map <event, handle> instead of switch and handleXXX(event) answer true if event is valid 
  switch (event.runtimeType) {
    case JoinGame:
      // TODO 
      break;
    case LeaveGame:
      handlePlayerLeft(event);
      break;
  }
  // broacast to all

}

void dispatchEventToAllPlayers(PlayerEvent event) {
  print("Send event $event to all");
  _clients.values.forEach((controler) => controler.add(event));
}

void handleJoin(JoinGame event) {
  print("Player ${event.playerId} is ready");  
  // TODO add to players
  // _players[event.playerId] = new Player();
}

void handlePlayerLeft(LeaveGame event) {
  print("Player ${event.playerId} is leaving");
  if(_clients.containsKey(event.playerId)){
    _clients[event.playerId].close();
    _clients.remove(event.playerId);
  }
}