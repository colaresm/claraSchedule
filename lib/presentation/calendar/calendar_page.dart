import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schedule_clara/models/event_model.dart';
import 'package:schedule_clara/presentation/calendar/bloc/calendar_bloc.dart';
import 'package:schedule_clara/presentation/calendar/bloc/events/calendar_events.dart';
import 'package:schedule_clara/presentation/calendar/bloc/states/calendart_states.dart';
import 'package:schedule_clara/presentation/event_details/event_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:path/path.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarBloc _calendarBloc;
  @override
  void initState() {
    _calendarBloc = CalendarBloc();
    _calendarBloc.add(GetAllDataEvent());
    super.initState();
    _startDb();
  }

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agenda da Clara"),
        backgroundColor: const Color.fromARGB(255, 243, 101, 149),
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
          bloc: _calendarBloc,
          builder: (context, state) {
            if (state is SuccessState) {
              return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () => _calendarBloc.add(GetAllDataEvent()),
                  child: SfCalendar(
                    onTap: (calendarTapDetails) {
                      if (calendarTapDetails.appointments!.isNotEmpty) {
                        print(calendarTapDetails.appointments!.first);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventDetails(
                                  events: calendarTapDetails.appointments)),
                        );
                      }
                    },
                    view: CalendarView.month,
                    dataSource:
                        MeetingDataSource(_getDataSource(state.eventsList)),
                    monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment),
                  ));
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                strokeWidth: 2.4,
                backgroundColor: Color.fromARGB(255, 243, 101, 149),
              ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 243, 101, 149),
        onPressed: () {
          _showDialog(context, _calendarBloc);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

Widget _createDateField(String label, TextEditingController controller) {
  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##-##-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(controller: controller, inputFormatters: [dateMaskFormatter]),
      ],
    ),
  );
}

Widget _createTextField(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(controller: controller),
      ],
    ),
  );
}

_showDialog(BuildContext context, CalendarBloc _calendarBloc) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Adicionar Evento'),
        content: Column(
          children: [
            _createTextField('Nome do evento:', nameController),
            _createTextField('Descrição:', descriptionController),
            _createDateField('Data:', dateController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              String eventName = nameController.text;
              String description = descriptionController.text;
              String date = convertDateFormat(dateController.text);
              bool isValid = eventName.isNotEmpty &&
                  description.isNotEmpty &&
                  date.isNotEmpty;
              if (isValid) {
                _calendarBloc.add(RegisterEvent(
                    eventName: eventName,
                    description: description,
                    date: date));
                _calendarBloc.add(GetAllDataEvent());
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      );
    },
  );
}

String convertDateFormat(String inputDate) {
  List<String> parts = inputDate.split('-');

  String outputDate = '${parts[2]}-${parts[1]}-${parts[0]}';

  return outputDate;
}

List<Meeting> _getDataSource(List<EventModel> events) {
  final List<Meeting> meetings = <Meeting>[];

  DateFormat format = DateFormat("yyyy-MM-dd");

  for (int i = 0; i < events.length; i++) {
    final DateTime startTime = format.parse(events[i].date);
    meetings.add(Meeting(events[i].description, format.parse(events[i].date),
        startTime, const Color(0xFF0F8644), false));
  }

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}

Future _startDb() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'demo.db');

// Delete the database
  // await deleteDatabase(path);

  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Events(id INTEGER PRIMARY KEY AUTOINCREMENT, eventName TEXT, description TEXT, date TEXT)');
  });

  //await database.transaction((txn) async {
  // int id1 = await txn.rawInsert(
  //    'INSERT INTO Events (eventName, description, date) VALUES("Estudar", "estudar matematica", "2023-12-22")');
  //  print('inserted1: $id1');
  // });
}
