import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Meeting with ChangeNotifier {
  String id;
  String creatorId;
  String date;
  String start;
  String length;
  String desc;
  String address;

  bool isJoined;

  Meeting(
      {@required this.id,
      @required this.creatorId,
      @required this.date,
      @required this.start,
      @required this.length,
      @required this.desc,
      @required this.address,
      this.isJoined = false});

  void _setFavValue(bool newValue) {
    isJoined = newValue;
    notifyListeners();
  }

  Future<void> toggleJoinedtatus(String token, String userId) async {
    final oldStatus = isJoined;
    isJoined = !isJoined;
    notifyListeners();
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/userJoins/$userId/$id.json?auth=$token');
    try {
      final response = await http.put(url, body: json.encode(isJoined));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
