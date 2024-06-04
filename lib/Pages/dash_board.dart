import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  Widget showCalendar() {
    return TableCalendar(
      locale: 'ja_JP',
      focusedDay: DateTime.now(),
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      availableCalendarFormats: const {CalendarFormat.month: '月間'},
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          return Center(
            child: Text(
              DateFormat.E('ja_JP').format(day),
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodySmall!.fontSize! * 0.9, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.all(8.0), child: const Text("あなたへのお知らせ")),
        const MaterialBanner(
          elevation: 4.0,
          leading: Icon(Icons.error),
          backgroundColor: Colors.amber,
          content: Text("賞味期限が近づいている食品があります"),
          actions: [
            TextButton(onPressed: null, child: Text("確認する")),
            // TextButton(onPressed: null, child: const Text("確認する")),
          ],
        ),
        showCalendar()
      ],
    );
  }
}
