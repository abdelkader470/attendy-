import 'package:flutter/foundation.dart';

class Participant with ChangeNotifier {
  String id;
  String empId;
  String meetingId;

  Participant({
    @required this.id,
    @required this.empId,
    @required this.meetingId,
  });
}
