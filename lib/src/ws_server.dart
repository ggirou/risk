part of risk;

abstract class ARiskWsServer {

  final Map<int, WebSocket> _clients = {
  };

  final RiskGameEngine engine;

  int currentPlayerId = 1;

  ARiskWsServer(): this.fromStreamCtrl(new StreamController.broadcast());

  ARiskWsServer.fromStreamCtrl(StreamController eventController):engine = new RiskGameEngine(eventController, new RiskGameStateImpl());

  void handleWebSocket(WebSocket ws) {
    final playerId = connectPlayer(ws);
    listen(ws, playerId);
  }

  void listen(Stream ws, int id) {
  }

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()
      ..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(engine.outputStream.stream);

    ws.addStream(stream.stream.map(EVENT.encode).map(logEvent("OUT", playerId)).map(JSON.encode));

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}