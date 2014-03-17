library risk.event;

abstract class Event {
  factory Event.fromMap(Map map) {
    var data = map['data'];
    switch (map['event']) {
      case "ArmyPlaced":
        return new ArmyPlaced._fromData(data);
      default:
        return null;
    }
  }
  
  Event();
  
  String get _event => this.runtimeType.toString();
  Map get _data;
  
  Map toMap() => {
    "event": _event,
    "data": _data,
  };
}

abstract class PlayerEvent extends Event {
  int get playerId;
}

class ArmyPlaced extends PlayerEvent {
  final int playerId;
  final String country;
  ArmyPlaced(this.playerId, this.country);

  ArmyPlaced._fromData(Map data)
      : this(data['playerId'], data['country']);
  Map get _data => {
    'playerId': playerId,
    'country': country,
  };
}
