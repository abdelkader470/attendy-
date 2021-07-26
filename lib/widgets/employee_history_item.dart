import 'package:flutter/material.dart';

class EmployeeHistoryItem extends StatelessWidget {
  final String id;
  final String employeeId;
  final String startTime;
  final String endTime;
  final String date;

  EmployeeHistoryItem(
      this.id, this.employeeId, this.startTime, this.endTime, this.date);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.check_circle_outlined,
              color: Colors.green,
            ),
            Text(startTime),
          ],
        ),
      ),
      leading: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.date_range_rounded,
              color: Colors.blueAccent,
            ),
            Text(date),
          ],
        ),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            Text(endTime),
          ],
        ),
      ),
    );
  }
}
