part of risk;

abstract class ARiskWsServer {
  final Map<int, WebSocket> _clients = {
  };
  final RiskGameEngine engine;

  final StreamController outputStream;
  int currentPlayerId = 1;

  ARiskWsServer(): this._(new StreamController.broadcast());

  ARiskWsServer._(StreamController eventController):outputStream = eventController, engine = new RiskGameEngine(eventController, new RiskGameStateImpl());

  ARiskWsServer.raw(this.engine, this.outputStream);

  void handleWebSocket(Stream ws) {
  }

  int connectPlayer(WebSocket ws) {
    int playerId = currentPlayerId++;

    _clients[playerId] = ws;

    // Concate streams: Welcome event, history events, incoming events
    var stream = new StreamController();
    stream.add(new Welcome()
      ..playerId = playerId);
    engine.history.forEach(stream.add);
    stream.addStream(outputStream.stream);

    ws.addStream(stream.stream.map(EVENT.encode).map(logEvent("OUT", playerId)).map(JSON.encode));

    print("Player $playerId connected");
    return playerId;
  }

  logEvent(String direction, int playerId) => (event) {
    print("$direction[$playerId] - $event");
    return event;
  };
}