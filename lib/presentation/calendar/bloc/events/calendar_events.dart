abstract class CalendarEvent {}

class GetAllDataEvent extends CalendarEvent {}

class RegisterEvent extends CalendarEvent {
  final String eventName;
  final String description;
  final String date;
  RegisterEvent(
      {required this.eventName, required this.description, required this.date});
}
