import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:attendy/api/local_auth_api.dart';
import 'package:flutter/material.dart';
import 'package:attendy/providers/attendanceHistories.dart';
import 'package:attendy/providers/auth.dart';
import 'package:attendy/providers/employees.dart';
import 'package:provider/provider.dart';
import 'package:attendy/screens/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FingerprintPage extends StatefulWidget {
  @override
  _FingerprintPageState createState() => _FingerprintPageState();
}

class _FingerprintPageState extends State<FingerprintPage> {
  static Future<void> _checkLocation() async {
    Auth _auth = Auth();
    var id = _auth.userId;
    var token = _auth.token;
    print('updated');

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double distance = Geolocator.distanceBetween(
        30.575640, 31.008410, position.latitude, position.longitude);

    if (distance > 10) {
      final url = Uri.parse(
          'https://shop-app-6a71c-default-rtdb.firebaseio.com/users/$id.json?auth=$token');
      await http.patch(url,
          body: json.encode({
            'status': 'offline',
            'latitude': position.latitude.toString(),
            'longtude': position.longitude.toString()
          }));
    } else {
      print('updated');
      var id = _auth.userId;
      final url = Uri.parse(
          'https://shop-app-6a71c-default-rtdb.firebaseio.com/users/$id.json?auth=$token');
      await http.patch(url,
          body: json.encode({
            'status': 'offline',
            'latitude': position.latitude.toString(),
            'longtude': position.longitude.toString()
          }));
      print('updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('put your finger print'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Location(),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                ),
                icon: Icon(Icons.fingerprint_rounded, size: 26),
                label: Text(
                  'attendance',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  final isAuthenticated = await LocalAuthApi.authenticate();

                  if (isAuthenticated) {
                    Position position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high);

                    double lat1 = 30.575640, lng1 = 31.008410;

                    double lat2 = position.latitude;
                    double lng2 = position.longitude;

                    double distance =
                        Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

                    if (distance < 10) {
                      _doAttend(distance);
                      await AndroidAlarmManager.periodic(
                        Duration(seconds: 5),
                        1,
                        _checkLocation,
                        exact: true,
                        wakeup: true,
                      );
                    } else {
                      _notAttend(distance);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doAttend(double distance) async {
    final auth = Provider.of<Auth>(context, listen: false);
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('kk:mm').format(now);
    String formattedDate = DateFormat('EEE d MMM').format(now);

    await Provider.of<Employees>(context, listen: false)
        .updateEmployeeStatus(auth.userId, 'online');
    await Provider.of<AttendanceHistories>(context, listen: false)
        .addAttendanceHistory(
            auth.userId, formattedTime, 'not yet', formattedDate);

    Fluttertoast.showToast(
        msg: 'authentecated successfulley you are ' +
            distance.round().toString() +
            ' m from the company',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _notAttend(double distance) async {
    final auth = Provider.of<Auth>(context, listen: false);
    await Provider.of<Employees>(context, listen: false)
        .updateEmployeeStatus(auth.userId, 'offline');

    Fluttertoast.showToast(
        msg: "you are aut of range and you are " +
            distance.round().toString() +
            " m from the company",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
