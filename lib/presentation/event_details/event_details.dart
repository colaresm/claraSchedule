import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:schedule_clara/presentation/event_details/widgets/event_card.dart';

class EventDetails extends StatefulWidget {
  const EventDetails({required this.events, super.key});
  final List<dynamic>? events;

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eventos"),
        backgroundColor: const Color.fromARGB(255, 243, 101, 149),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
          itemCount: widget.events!.length,
          itemBuilder: (BuildContext context, int index) {
            var event = widget.events![index];
            return Container(
               alignment: Alignment.center,
              child: EventCard(eventName: event.eventName));
          }),
    );
  }
}
