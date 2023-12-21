import 'package:schedule_clara/models/event_model.dart';

abstract class CalendarState {}

class LoadingState extends CalendarState {}

class SuccessState extends CalendarState {
  final List<EventModel> eventsList;

  SuccessState(this.eventsList);
  List<Object?> get props => [eventsList];
}
