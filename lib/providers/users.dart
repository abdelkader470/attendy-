import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendy/models/user.dart';

class Users with ChangeNotifier {
  List<User> _users = [];
  final String authToken;
  final String userId;

  Users(this.authToken, this.userId, this._users);

  List<User> get users {
    return [..._users];
  }

  Future<void> updateProfileImage(String profielImage) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/users/$userId.json?auth=$authToken'); //user id in the table;
    try {
      await http.patch(url, body: json.encode({'profileImage': profielImage}));
      print('\n');
      print(url);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
