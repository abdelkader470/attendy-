import 'package:flutter/foundation.dart';

class Employee with ChangeNotifier {
  final String id;
  final String username;
  final String status;
  final String address;
  final String job;
  final String phone;
  final String image;
  final String email;
  final String latitude;
  final String longtude;

  Employee({
    @required this.id,
    @required this.username,
    @required this.status,
    @required this.address,
    @required this.job,
    @required this.phone,
    @required this.image,
    @required this.email,
    @required this.latitude,
    @required this.longtude,
  });
}
