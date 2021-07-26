import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  String id;
  String username;
  String job;
  String address;
  String status;
  String roomNumber;
  String email;
  String phone;
  String profileImage;

  User({
    @required this.id,
    @required this.username,
    @required this.job,
    @required this.address,
    @required this.status,
    @required this.roomNumber,
    @required this.email,
    @required this.phone,
    @required this.profileImage,
  });
}
