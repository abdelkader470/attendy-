import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:attendy/models/meeting.dart';

class Meetings with ChangeNotifier {
  List<Meeting> _items = [];
  final String authToken;
  final String userId;

  Meetings(this.authToken, this.userId, this._items);

  List<Meeting> get items {
    return [..._items];
  }

  Meeting findById(String id) {
    return _items.firstWhere((post) => post.id == id);
  }

  Future<Map<String, dynamic>> getCreatoreInfo(String creatoreId) async {
    final userUrl = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/users.json?auth=$authToken&orderBy="id"&equalTo="$creatoreId"');
    final userResponse = await http.get(userUrl);
    final extractedData =
        json.decode(userResponse.body) as Map<String, dynamic>;

    Map<String, dynamic> userUserrname;
    extractedData.forEach((userId, username) {
      userUserrname = username;
    });

    return userUserrname;
  }

  Future<void> fetchMeetings() async {
    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/meetings.json?auth=$authToken');
    final response = await http.get(url);

    final List<Meeting> loadedMeetings = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }

    url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/userJoins/$userId.json?auth=$authToken');
    final joinedResponse = await http.get(url);
    final joinedData = json.decode(joinedResponse.body);

    extractedData.forEach((id, meetingData) {
      loadedMeetings.add(
        Meeting(
            id: id,
            creatorId: meetingData['creatorId'],
            date: meetingData['date'],
            start: meetingData['start'],
            length: meetingData['length'],
            desc: meetingData['desc'],
            isJoined: joinedData == null ? false : joinedData[id] ?? false,
            address: meetingData['address']),
      );
    });
    _items = loadedMeetings.reversed.toList();
    notifyListeners();
  }

  Future<void> addMeeting(Meeting meeting) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM').format(now);
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/meetings.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'creatorId': userId,
          'date': meeting.date,
          'start': meeting.start,
          'length': meeting.length,
          'desc': meeting.desc,
          'address': meeting.address,
        }),
      );
      final newPost = Meeting(
        creatorId: meeting.creatorId,
        date: meeting.date,
        start: meeting.start,
        length: meeting.length,
        desc: meeting.desc,
        address: meeting.address,
        id: json.decode(response.body)['name'],
      );
      _items.add(newPost);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
