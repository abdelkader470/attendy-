import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/screens/employee_details.dart';
import '../models/employee.dart';

class EmployeeItem extends StatefulWidget {
  @override
  _EmployeeItemState createState() => _EmployeeItemState();
}

class _EmployeeItemState extends State<EmployeeItem> {
  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final employee = Provider.of<Employee>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(EmployeeDetailScreen.routeName,
                arguments: employee.id);
          },
          child: Row(
            children: [
              CircleAvatar(
                  radius: 27, backgroundImage: NetworkImage(employee.image)),
              SizedBox(
                width: 4,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(employee.username,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    employee.status == 'offline'
                        ? Text(employee.status,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))
                        : Text(employee.status,
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
