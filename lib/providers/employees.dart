import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class Employees with ChangeNotifier {
  List<Employee> _items = [];
  final String authToken;
  final String userId;

  Employees(this.authToken, this.userId, this._items);

  List<Employee> get items {
    return [..._items];
  }

  List<Employee> get onlines {
    return _items.where((empItem) => empItem.status == 'online').toList();
  }

  List<Employee> get manager {
    return _items.where((empItem) => empItem.job == 'manager').toList();
  }

  Employee findById(String id) {
    return _items.firstWhere((emp) => emp.id == id);
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

    print(userUserrname);

    return userUserrname;
  }

  Future<void> fetchAndSetEmployees() async {
    var url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/users.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Employee> loadedProducts = [];

      extractedData.forEach((userId, userData) {
        loadedProducts.add(Employee(
          id: userId,
          username: userData['username'],
          status: userData['status'],
          address: userData['address'],
          job: userData['job'],
          email: userData['email'],
          phone: userData['phone'],
          image: userData['profileImage'],
          latitude: userData['latitude'].toString(),
          longtude: userData['longtude'].toString(),
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateEmployeeStatus(String id, String status) async {
    //  final empIndex = _items.indexWhere((emp) => emp.id == id);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final url = Uri.parse(
        'https://shop-app-6a71c-default-rtdb.firebaseio.com/users/$id.json?auth=$authToken');
    await http.patch(url,
        body: json.encode({
          'status': status,
          'latitude': position.latitude.toString(),
          'longtude': position.longitude.toString()
        }));
    notifyListeners();
  }
}
