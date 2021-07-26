import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendy/widgets/TextFieldContainer.dart';
import 'package:attendy/widgets/constants.dart';

import '../providers/employees.dart';
import 'employee_item.dart';

class EmployeesGrid extends StatelessWidget {
  final bool showOnline;

  EmployeesGrid(this.showOnline);

  @override
  Widget build(BuildContext context) {
    final employeesData = Provider.of<Employees>(context);
    //  final employees = employeesData.items;
    var employees = showOnline ? employeesData.onlines : employeesData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(6.0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: employees[i],
        child: Column(
          children: [EmployeeItem(), Divider()],
        ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 5 / 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }

  _searchBar(BuildContext context) {
    final employeesData = Provider.of<Employees>(context);
    var employees = employeesData.items;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFieldContainer(
        child: TextFormField(
          decoration: InputDecoration(
              icon: Icon(
                Icons.search,
                color: kPrimaryColor,
              ),
              hintText: 'search',
              border: InputBorder.none),
          onChanged: (text) {
            text = text.toLowerCase();
            employees = employees.where((employee) {
              var name = employee.username.toLowerCase();
              return name.contains(text);
            }).toList();
          },
        ),
      ),
    );
  }
}
