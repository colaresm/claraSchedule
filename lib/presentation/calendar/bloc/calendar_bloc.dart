// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule_clara/models/event_model.dart';
import 'package:schedule_clara/presentation/calendar/bloc/events/calendar_events.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'states/calendart_states.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc() : super(LoadingState()) {
    on<GetAllDataEvent>((event, emit) {
      _getAllEvents();
    });
    on<RegisterEvent>((event, emit) {
      _registerEvent(event);
    });
  }
  void _registerEvent(RegisterEvent event) async {
    EventModel newEvent = EventModel(
        id: null,
        eventName: event.eventName,
        description: event.description,
        date: event.date);

    Map<String, Object?> eventToJson = newEvent.toJson();

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    Database database = await openDatabase(
      path,
      version: 1,
    );
    await database.insert(
      'Events',
      eventToJson,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void _getAllEvents() async {
    emit(LoadingState());

    await Future.delayed(const Duration(seconds: 1));

    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');

    Database database = await openDatabase(
      path,
      version: 1,
    );

    List<Map<String, dynamic>> queryResult =
        await database.rawQuery('SELECT * FROM Events');

    List<EventModel> eventsList =
        queryResult.map((map) => EventModel.fromMap(map)).toList();

    emit(SuccessState(eventsList));
  }
}
