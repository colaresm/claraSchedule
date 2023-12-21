import 'package:flutter/material.dart';
import 'package:schedule_clara/presentation/calendar/calendar_page.dart';


void main() {
  return runApp(CalendarApp());
}

class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Demo',
      theme: ThemeData(useMaterial3: false),
      home: const CalendarPage(),
    );
  }
}
