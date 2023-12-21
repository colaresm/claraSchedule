class EventModel {
  final int? id;
  final String eventName;
  final String description;
  final String date;

  EventModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.date,
  });
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      eventName: map['eventName'],
      description: map['description'],
      date: map['date'],
    );
  }
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'description': description,
      'date': date,
    };
  }
}
