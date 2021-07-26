import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:attendy/models/attendanceHistory.dart';

class AttendanceHistories with ChangeNotifier {
  List<AttendanceHistory> _items = [];
  final String authToken;
  final String userId;

  AttendanceHistories(this.authToken, this.userId, this._items);

  List<AttendanceHistory> get items {
    return [..._items];
  }

  AttendanceHistory findById(String id) {
    return _items.firstWhere((emp) => emp.id == id);
  }

  Future<void> fetchAttendanceHistory() async {
    bool filterByEmployee = true;
    final filterString =
        filterByEmployee ? 'orderBy="employeeId"&equalTo="$userId"' : '';

    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<AttendanceHistory> loadedHistory = [];

      extractedData.forEach((id, attendanceData) {
        loadedHistory.add(AttendanceHistory(
            id: id,
            employeeId: attendanceData['employeeId'],
            startTime: attendanceData['startTime'],
            endTime: attendanceData['endTime'],
            date: attendanceData['date']));
      });
      _items = loadedHistory;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchTodayAttendanceHistory() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE d MMM').format(now);
    bool filterByDate = true;

    final filterString =
        filterByDate ? 'orderBy="date"&equalTo="$formattedDate"' : '';

    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<AttendanceHistory> loadedHistory = [];

      extractedData.forEach((id, attendanceData) {
        loadedHistory.add(AttendanceHistory(
            id: id,
            employeeId: attendanceData['employeeId'],
            startTime: attendanceData['startTime'],
            endTime: attendanceData['endTime'],
            date: attendanceData['date']));
      });
      _items = loadedHistory;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addAttendanceHistory(
      String employeeId, String startTime, String endTime, String date) async {
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory.json?auth=$authToken');
    try {
      await http.post(
        url,
        body: json.encode({
          'employeeId': employeeId,
          'startTime': startTime,
          'endTime': endTime,
          'date': date,
        }),
      );

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateAttendanceEndTime(String empId) async {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('kk:mm').format(now);

    bool filterByEmployee = true;
    final filterString = filterByEmployee
        ? 'orderBy="employeeId"&equalTo="$userId"&"date"equalTo="$formattedTime"'
        : '';

    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<AttendanceHistory> loadedHistory = [];

      extractedData.forEach((id, attendanceData) {
        loadedHistory.add(AttendanceHistory(
            id: id,
            employeeId: attendanceData['employeeId'],
            startTime: attendanceData['startTime'],
            endTime: attendanceData['endTime'],
            date: attendanceData['date']));
      });
      fetchAttendanceHistory();
      _items = loadedHistory;
      final lastHistoryId = _items.last.id;

      if (lastHistoryId.length > 0) {
        final url = Uri.parse(
            'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory/$lastHistoryId.json?auth=$authToken');
        await http.patch(url, body: json.encode({'endTime': formattedTime}));
        notifyListeners();
      } else {
        print('...');
      }

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateEmployeeAttendanceHistory(
      String id, String endTime) async {
    final historyIndex = _items.indexWhere((history) => history.id == id);
    if (historyIndex >= 0) {
      final url = Uri.parse(
          'https://shop-app-6a71c-default-rtdb.firebaseio.com/attendancehistory/$id.json?auth=$authToken');
      await http.patch(url, body: json.encode({'endTime': endTime}));
      notifyListeners();
    } else {
      print('...');
    }
  }
}
