import 'package:flutter/foundation.dart';

class AttendanceHistory with ChangeNotifier {
  final String id;
  final String employeeId;
  final String startTime;
  final String endTime;
  final String date;

  AttendanceHistory(
      {@required this.id,
      @required this.employeeId,
      @required this.startTime,
      @required this.endTime,
      @required this.date});
}
