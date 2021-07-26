import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendy/models/http_exception.dart';
import 'package:attendy/models/participant.dart';

class Participants with ChangeNotifier {
  List<Participant> _items = [];
  final String authToken;
  final String userId;

  Participants(this.authToken, this.userId, this._items);

  List<Participant> get items {
    return [..._items];
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

  Future<void> fetchParticipant(String meetingId) async {
    bool filterByParticipan = true;
    final filterString =
        filterByParticipan ? 'orderBy="meetingId"&equalTo="$meetingId"' : '';

    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/Participants.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Participant> loadedParticipants = [];

      extractedData.forEach((id, participantsData) {
        loadedParticipants.add(Participant(
            id: id,
            empId: participantsData['empId'],
            meetingId: participantsData['meetingId']));
      });
      _items = loadedParticipants;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> joinMeeting(String meetingId) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/Participants.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'id': meetingId,
          'empId': userId,
          'meetingId': meetingId,
        }),
      );
      final newParticipant = Participant(
        empId: userId,
        meetingId: meetingId,
        id: json.decode(response.body)['name'],
      );
      _items.add(newParticipant);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> leaveMeeting(String id) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/Participants/$id.json?auth=$authToken');
    //  final existingParticipantIndex =
    //    _items.indexWhere((emp) => emp.id == userId);
    //var existingParticipant = _items[existingParticipantIndex];
    //_items.removeAt(existingParticipantIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //_items.insert(existingParticipantIndex, existingParticipant);
      notifyListeners();
      throw HttpException('Could not leave meeting.');
    }
    //existingParticipant = null;
  }

  Future<void> toggleJoinedtatus(String id) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/userJoins/$userId.json?auth=$authToken');
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        notifyListeners();
      }
    } catch (error) {
      print('error');
    }
  }
}
